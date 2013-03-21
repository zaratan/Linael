# -*- encoding : utf-8 -*-
module Linael
  class Modules::Admin < ModuleIRC

    Name="admin"

    def self.require_auth 
      true
    end

    attr_reader :chan

    def initialize(runner)
      @chan = []
      super runner
    end

    def startMod
      add_module({cmdAuth:[
        :join,:part,:kick,:mode,:reload,:die
      ]})
    end

    def join privMsg
      if Options.join? privMsg.message
        options = Options.new privMsg
          answer(privMsg,"Oki doki! I'll join #{options.chan}")	
          @chan << options.chan unless @chan.include? options.chan
          join_channel :dest => options.chan
      end
    end

    def part privMsg
      if Options.part? privMsg.message
        options = Options.new privMsg
        if chan.include? options.chan
            answer(privMsg,"Oki doki! I'll part #{options.chan}")	
            talk(options.chan,"cya all!")
            @chan.delete options.chan
            part_channel :dest => options.chan
        else
          answer(privMsg,"Sorry, I'm not on #{options.chan}")	
        end
      end
    end

    def die privMsg
      if Options.die? privMsg.message
        answer(privMsg,"Oh... Ok... I'll miss you")
        quit_channel :msg => "I'll miss you!"
        exit 0
      end
    end

    def mode privMsg
      if Options.mode? privMsg.message
        options = Options.new privMsg
        mode_channel  :dest => options.chan,
                      :who  => options.what,
                      :args => options.reason
                      p options.chan
                      p options.what
                      p options.reason
        answer(privMsg,"Oki doki! I'll change mode #{options.what} #{options.reason+" " unless options.reason.empty?}on #{options.chan}")
      end
    end

    def reload privMsg
      if Options.reload? privMsg.message
        options = Options.new privMsg
        answer(privMsg,"Oki doki! Upgrading myself!") if load options.who
      end
    end

    def kick privMsg
      if Options.kick? privMsg.message
        options = Options.new privMsg
        answer(privMsg,"Oki doki! I'll kick #{options.who} on #{options.chan}")	
        talk(options.chan,"bye #{options.who}!")
        kick_channel({dest: options.chan,who: options.who, msg: options.reason})
      end
    end

  class Options < ModulesOptions
    generate_to_catch  :join   => /^!admin_join\s|^!join\s|^!j\s/,
              :part   => /^!admin_part\s|^!part\s/,
              :kick   => /^!admin_kick\s|^!kick\s|^!k\s/,
              :die    => /^!admin_die\s/,
              :mode   => /^!admin_mode\s|^!mode\s/,
              :reload => /^!admin_reload\s/
    generate_chan
    generate_who
    generate_reason
    generate_what
  end
  end
end
