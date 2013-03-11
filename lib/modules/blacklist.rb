# -*- encoding : utf-8 -*-
module Linael
  class Modules::ModuleType
    
    attr_accessor :blackList,:whiteList

    def in_blacklist?(chan)
      @blackList.include?(chan.downcase) if blackList?
    end

    def in_whitelist?(chan)
        return @whiteList.include?(chan.downcase) if whiteList?
        true
    end
    
    ["black","white"].each do |color|
      define_method color+"list?" do
          send(color+"List")
      end
      define_method color+"list" do |chan|
        (send(color+"List")).= [] unless send(color+"List?")
        send(color+"List").<< chan.downcase
      end
      define_method "un_"+color+"list" do |chan|
        send(color+"List").delete(chan)
        send(color+"List").= nil if send(color+"List").empty?
      end
    end

  end

  class ModuleIRC

    def act_authorized?(instance,msg)
      moduleAdmin = @runner.modules.detect {|mod| mod.class == Modules::Module}
      mod = moduleAdmin.modules[instance.class::Name]
      result = true
      result &= !mod.in_blacklist?(msg.place) 
      result &= mod.in_whitelist?(msg.place) 
      result
    end

  end

  class Modules::Blacklist < ModuleIRC

    Name="blacklist"

    def startMod
      add_module({cmdAuth: [:whiteList,
                            :blackList]})
    end

    def self.require_auth
      true
    end

    def self.required_mod
      ["module","admin"]
    end

    def whiteList privMsg
      if Options.whitelist? privMsg.message
        act_anylist privMsg,"whitelist"
      end
    end

    def blackList privMsg
      if Options.blacklist? privMsg.message
        act_anylist privMsg,"blacklist"
      end
    end

    def act_anylist privMsg,colorlist
        options = Options.new privMsg
        if (mod("module").instance.modules.has_key?(options.who))
          mod=mod("module").instance.modules[options.who]
          toAdd = options.chan
          toAdd = mod("admin").instance.chan if options.all?
          if (options.type == "add")
            modify_status colorlist,"added",toAdd,options,true
          end
          if (options.type == "del")
            modify_status colorlist,"deleted",toAdd,options,false
          end
        else
          answer(privMsg,"The module #{options.module} is not loaded :(")
        end
    end

    def modify_status method,action_string,toAdd,options,add?
      toAdd.each do |chan|
        talk(privMsg.who,"The chan #{chan} have been #{action_string} from the #{method} of the module #{options.who}")
        mod.send("un_"+method,chan) unless add?
        mod.send(method,chan) if add?
      end
    end

    class Options < ModulesOptions

      generate_to_catch :blacklist => /^!blacklist\s|^!bl\s/,
                        :whitelist => /^!whitelist\s|^!wl\s/

      generate_type
      generate_chan
      generate_who

      def all?
        @message =~ /\s-all\s/
      end

    end
  end
end
