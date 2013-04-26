
def self.linael(name,config_hash)

  #create a class with the name
  #add config in it
  #change scope for class
    #add an Options class
    #yield in it with the check

  new_class = Class.new(ModuleIRC) do
  
    Constructor = config_hash[:constructor] if config_hash.has_key?(:constructor)
    Name =name.to_s

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

    class Options < ModulesOptions

    end

    yield

  end

  Object.const_set(name.to_s.camelize,new_class)

end

module Linael

  class InterruptLinael < Interrupt
  end

  class ModuleIRC
    def self.on(type, name,regex,config_hash)
    
      #define a method with name,
      #                checking regex,
      #                config with hash
      #                giving a type_msg and options if PrivateMsg
      #                which do yield
      #                catch special exceptions
      self.class::Options.class_eval do
        generate_to_catch name => regex
      end

      define_method(name) do |msg|
        if self.class::Options.send("#{name}?",msg.message)
          options = self.class::Options.new msg if msg.kind_of? PrivMessage
          begin
            yield
          rescue InterruptLinael
          end
        end
      end
      add_module(type => name)
    end

    def self.value(hash)
      self.class::Options.class_eval do
        generate_value hash
      end
    end

    At_launch=Proc.new do end
    def self.init(&block)
      At_launch = block
    end
    
    At_load=Proc.new do end
    def self.load(&block)
      At_load = block
    end

    def load_mod
      At_load.call
    end

    def initialize(runner)
      @runner = runner
      At_launch.call
      @runner.instance_variables.grep(/@(.*)Act/) {add_module_irc_behavior $1}
      
    end

    def self.match(hash)
      self.class::Options.class_eval do
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
