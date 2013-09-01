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
def self.linael(name, config_hash ={}, &block)

  # Create the class
  new_class = Class.new(Linael::ModuleIRC) do

    generate_all_config(name, config_hash)
    self.const_set("Options",generate_all_options)

  end # Class.new(Linael::ModuleIRC)

  # Link the module to the right part of linael
  Linael::Modules.const_set(name.to_s.camelize,new_class)

  # Execute the block
  "Linael::Modules::#{name.to_s.camelize}".constantize.class_eval &block if block_given?

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
    def self.on(type, name, regex=//, config_hash = {}, &block)

      # Generate regex catching in Options class
      self::Options.class_eval do
        generate_to_catch(name => regex)
      end

      generate_define_method_on(type,name,regex,&block) if block_given?

      # Define the method which will be really called
      # Add the feature to module start
      # TODO add doc here (why unless)
      self.const_set("ToStart",{}) unless defined?(self::ToStart)
      self::ToStart[type] ||= []
      self::ToStart[type] = self::ToStart[type] << name
    end

    def execute_method(type, msg, options, &block)
      if type == :auth
        instance_exec(msg,options,&block)
      else
        #execute block
        Thread.new do
          begin
            instance_exec(msg,options,&block)
          rescue InterruptLinael
          rescue Exception
            p "#{$!.red}"
          end
        end
      end

    end


    # TODO add it to protected
    def self.generate_define_method_on(type,name,regex,&block)
      self.send("define_method",name) do |msg|
        # Is it matching the regex?
        if self.class::Options.send("#{name}?",msg.message)
          # if it's a message: generate options
          options = self.class::Options.new msg if msg.kind_of? Privmsg
          execute_method(type,msg,options,&block)
        end
      end
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
      raise(InterruptLinael, "not matching") unless block.call(msg)
    end

    # Execute something later
    # Params:
    # +time+:: The time of the execution
    # +hash+:: Params sended to the block
    def at(time,hash=nil,&block)
      Thread.new do
        sleep(time - Time.now)
        self.instance_exec(hash,&block)
      end
    end


    protected
  end

end
