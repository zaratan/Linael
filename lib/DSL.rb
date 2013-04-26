
def self.linael(name,config_hash = Hash.new,&block)

  #create a class with the name
  #add config in it
  #change scope for class
    #add an Options class
    #yield in it with the check

  new_class = Class.new(Linael::ModuleIRC) do

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

    self.const_set("Options",Class.new(Linael::ModulesOptions) do 
      generate_chan
      generate_who
      generate_what
      generate_reason
      generate_type
      generate_all
    end)


  end

  Linael::Modules.const_set(name.to_s.camelize,new_class)
  
  new_class.instance_eval(&block)


end

module Linael

  class InterruptLinael < Interrupt
  end

  class ModuleIRC
    def self.on(type, name,regex,config_hash = Hash.new,&block)
    
      #define a method with name,
      #                checking regex,
      #                config with hash
      #                giving a type_msg and options if PrivateMsg
      #                which do yield
      #                catch special exceptions
      self::Options.class_eval do
        generate_to_catch name => regex
      end

      self.send("define_method",name) do |msg|
        if self.class::Options.send("#{name}?",msg.message)
          options = self.class::Options.new msg if msg.kind_of? PrivMessage
          begin
            self.instance_exec(msg,options,&block)
            #yield msg
          rescue InterruptLinael
          end
        end
      end
      self.const_set("ToStart",Hash.new([])) unless defined?(ToStart)
      self::ToStart[type] = self::ToStart[type] << name
      #add_module(type => name)
    end

    def self.value(hash)
      self::Options.class_eval do
        generate_value hash
      end
    end

    def self.value_with_default(hash)
      self::Options.class_eval do
        generate_value_with_default hash
      end
    end

    def self.on_init(&block)
      self.const_set("At_launch",block)
    end
    
    def self.on_load(&block)
      self.const_set("At_load",block)
    end

    def self.help(help_array)
      self.const_set("Help",help_array)
    end

    def load_mod
      self.class::At_load.call if defined?(self.class::At_load)
    end

    def startMod
      add_module(self.class::ToStart)
    end

    def initialize(runner)
      @runner = runner
      self.class::At_launch.call if defined?(self.class::At_launch)
      @runner.instance_variables.grep(/@(.*)Act/) {add_module_irc_behavior $1}
      
    end

    def self.match(hash)
      self::Options.class_eval do
        generate_match hash
      end
    end

    def before(&block)
      raise InterruptLinael, "not matching" unless block.call
    end
  end

end

#linael :youtube, constructor:"Vinz_" do
#
#  value :id => //
#
#  on :msg, :youtube, // do
#    
#    before do
#      msg.who != "Internets"
#    end
#
#    open("http://www.youtube.com/watch?v=#{options.id}").read =~ /<title>(.*?)<\/title>/
#    answer(privMsg,HTMLEntities.new.decode("#{privMsg.who}: #{$1}"))
#  end
#
#
#end
