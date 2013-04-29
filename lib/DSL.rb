# DSL for writing linael's module.
# It's backward compatible with the old way of writing modules

# Main function for defining a module.
# Everything should be instide its block.
# Params:
# +name+::         a symbol to name the module
# +config_hash+:: optional hash for configuration. the differents options available are:
# * +:constructor+:: A string for the name of the module maker. "Zaratan" by default
# * +:require_auth+:: A boolean for saying if an auth method is required or not
# * +:required_mod+:: A list of module names required for this module
# * +:auth+:: A boolean telling if it's an auth module or not
#
# +block+:: definition of the module. Everything here will be executed in the scope of the module.
#   
#   linael :test, constructor: "Skizzk", require_auth: true, required_mod: ["admin"] do 
#   end 
#   #=> produce a module named Test with Skizzk for constructor, which require at least an auth method and the module admin.
def self.linael(name,config_hash = Hash.new,&block)

  # Create the class
  new_class = Class.new(Linael::ModuleIRC) do

    # Add config in it
    self.const_set("Constructor",config_hash[:constructor]) if config_hash.has_key?(:constructor)
    self.const_set("Name",name.to_s)

    define_singleton_method "require_auth" do
      return false unless config_hash.has_key?(:require_auth)
      config_hash[:require_auth]
    end

    define_singleton_method "required_mod" do
      return config_hash[:required_mod] if config_hash.has_key?(:required_mod)
    end

    define_singleton_method "auth?" do
      return false unless config_hash.has_key?(:auth)
      config_hash[:auth]
    end

    # Define Options class (with some magic methods)
    self.const_set("Options",Class.new(Linael::ModulesOptions) do 
      #Define method .chan which return the first word beging with a # . if none, return current chan
      generate_chan
      #Define method .who which retrun the first word with no # nor ! nor - . If none return current user
      generate_who
      #Define method .what which return first word with no # nor !
      generate_what
      #Define method .reason which return everything after :
      generate_reason
      #Define method .type which return the first word begining with -
      generate_type
      #return EVERYTHING but the first word
      generate_all
    end)


  end

  # Link the module to the right part of linael
  Linael::Modules.const_set(name.to_s.camelize,new_class)
  
  # Execute the block
  new_class.instance_eval(&block)

end

#Everything goes there
module Linael
  
  # Fake interruption for before check
  class InterruptLinael < Interrupt
  end

  # Modification of ModuleIRC class to describe the DSL methods
  class ModuleIRC 
    # Method to describe a feature of the module inside a linael bloc (see Object)
    # Params:
    # +type+:: type of message watched by the method should be in:
    # * +:msg+:: any message
    # * +:cmd+:: any command message (begining with a !)
    # * +:cmdAuth+:: any command which you should be auth on the bot to use
    # * +:join+   :: any join
    # * +:part+   :: any part
    # * +:kick+   :: any kick
    # * +:auth+   :: any auth asking (for :cmdAuth)
    # * +:mode+   :: any mode change
    # * +:nick+   :: any nick change
    # * +:notice+ :: any notice
    #
    # +name+:: the name of the feature
    # +regex+:: the regex that the method should match
    # +config_hash+:: an optional configuration hash (for now, there is no configuration option)
    # +block+:: where we describe what the method should do
    def self.on(type, name,regex=//,config_hash = Hash.new,&block)
    
      # Generate the catch of regex in Options class
      self::Options.class_eval do
        generate_to_catch name => regex
      end

      # Define the method which will be really called
      self.send("define_method",name) do |msg|
        # Is it matching the regex?
        if self.class::Options.send("#{name}?",msg.message)
          # if it's a message: generate options
          options = self.class::Options.new msg if msg.kind_of? PrivMessage
          begin
            #execute block
            self.instance_exec(msg,options,&block)
          #for catching before methods
          rescue InterruptLinael
          end
        end
      end
      # Add the feature to module start
      self.const_set("ToStart",Hash.new) unless defined?(self::ToStart)
      self::ToStart[type] ||= []
      self::ToStart[type] = self::ToStart[type] << name
    end

    # Wrapper to add values regex
    # Params:
    # +key+:: is the name of the method (options.name)
    # +value+:: is the regex used to find the result
    def self.value(hash)
      self::Options.class_eval do
        generate_value hash
      end
    end

    # Wrapper to add values regex with a default value
    # Params:
    # +key+:: is the name of the method (options.name)
    # +value+:: is a hash with 2 keys: 
    # * +:regexp+:: the matching regex 
    # * +:default+:: the default value
    def self.value_with_default(hash)
      self::Options.class_eval do
        generate_value_with_default hash
      end
    end

    # Wrapper to add matching regex to options
    # Params:
    # +key+:: is the name of the method (options.name?)
    # +value+:: is the regex to match
    def self.match(hash)
      self::Options.class_eval do
        generate_match hash
      end
    end

    # Instruction used at the start of the module
    def self.on_init(&block)
      self.const_set("At_launch",block)
    end
    
    # Instructions used at load (from save module) 
    def self.on_load(&block)
      self.const_set("At_load",block)
    end

    # An array of strings for help
    def self.help(help_array)
      self.const_set("Help",help_array)
    end

    # Override of normal method
    def load_mod
      self.instance_eval(&self.class::At_load) if defined?(self.class::At_load)
    end

    # Overide of normal method
    def startMod
      add_module(self.class::ToStart)
    end

    # Overide of normal method
    def initialize(runner)
      @runner = runner
      self.instance_eval(&self.class::At_launch) if defined?(self.class::At_launch)
      @runner.instance_variables.grep(/@(.*)Act/) {add_module_irc_behavior $1}
      
    end

    # A method used to describe preliminary tests in a method
    def before(msg,&block)
      raise InterruptLinael, "not matching" unless block.call(msg)
    end
  end

end
