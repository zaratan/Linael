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
        :join,:part,:kick,:mode,:reload,:quickKick,:die
      ]})
    end

    def join privMsg
      if (module? privMsg) &&
        (join? privMsg)
        if privMsg.message =~ /^!admin\sjoin\s(#[\S]*)/ 
          answer(privMsg,"Oki doki! i'll join #{$~[1]}")	
          @chan << $~[1] unless @chan.include? $~[1]
          join_channel :dest => $~[1]
        end
      end
    end

    def part privMsg
      if (module? privMsg) &&
        (part? privMsg)
        if privMsg.message =~ /^!admin\spart\s(#[\S]*)/
          if @chan.include? $~[1] 
            answer(privMsg,"Oki doki! i'll part #{$~[1]}")	
            talk($~[1],"cya all!")
            @chan.delete $~[1]
            part_channel :dest => $~[1]
        else
          answer(privMsg,"Sorry, I'm not on #{$~[1]}")	
        end
        end
      end
    end

    def die privMsg
      if (module? privMsg) &&
        (die? privMsg)

        answer(privMsg,"Oh... Ok... I'll miss you")
        quit_channel :msg => "I'll miss you!"
        exit 0
      end

    end

    def mode privMsg
      if (mode? privMsg)
        if privMsg.message =~ /!admin\smode\s(#\S*)\s(\S*)\s(\S*)/
          answer(privMsg,"oki doki! i'll change mode #{$~[2]} #{$~[3]} on #{$~[1]}")
          mode_channel({dest:$~[1],who:$~[2],args:$~[3]})
        elsif privMsg.message =~ /!admin\smode\s(#\S*)\s(\S*)/
          answer(privMsg,"oki doki! i'll change mode #{$~[2]} on #{$~[1]}")
          mode_channel({dest:$~[1],who:$~[2]})
        end
      end
    end

    def reload privMsg
      if (reload? privMsg)
        if privMsg.message =~ /!admin\sreload\s(\S*)/
          load $~[1]
        end
      end
    end

    def quickKick privMsg
      if (quickKick? privMsg)

        if privMsg.message =~ /^!k\s(#\S*)\s(\S*)\s(.*)/
          where=$~[1]
          who=$~[2]
          message=$~[3]
        end
        if privMsg.message =~ /^!k\s([^\s#]*)\s(.*)/
          return if privMsg.private_message?
          where=privMsg.place
          who=$~[1]
          message=$~[2]
        end
        if privMsg.message =~ /^!k\s(#\S*)\s(\S*)[^\S]$/
          where=$~[1]
          who=$~[2]
          message=$~[2]
        end
        if privMsg.message =~ /^!k\s([^\s#]*)[^\S]$/
          return if privMsg.private_message?
          where=privMsg.place
          who=$~[1]
          message=$~[1]
        end
        return if !(defined? who)
        answer(privMsg,"Oki doki! i'll kick #{who} on #{where}")	
        talk(where,"bye #{who}!")
        kick_channel({dest: where,who: who, msg: message})
      end
    end

    def quickKick? privMsg
      privMsg.message =~ /^!k\s/
    end

    def kick privMsg
      if (module? privMsg) &&
        (kick? privMsg)
        if (privMsg.message =~ /^!admin\skick\s(#\S*)\s(\S*)\s(.*)$/)
          where=$~[1]
          who=$~[2]
          message=$~[3]
        else
          if privMsg.message =~ /^!admin\skick\s([^#\s]*)\s(.*)$/
            return if privMsg.private_message?
            where=privMsg.place
            who=$~[1]
            message=$~[2]
          else
            if privMsg.message =~ /^!admin\skick\s(#\S*)\s(\S*)/
              where =$~[1]
              who=$~[2]
              message=who
            else
              if privMsg.message =~ /^!admin\skick\s([^#\s]*)/
                return if privMsg.private_message?
                where=privMsg.place
                who=$~[1]
                message=who
              else
                return
              end
            end
          end
        end
        answer(privMsg,"Oki doki! i'll kick #{who} on #{where}")	
        talk(where,"bye #{who}!")
        kick_channel({dest:where,who:who,msg:message})
      end

    end

    def knockout

    end

    def module? privMsg
      privMsg.message.match '^!admin\s'
    end

    def join? privMsg
      privMsg.message.match '^!admin\sjoin\s'
    end

    def part? privMsg
      privMsg.message.match '^!admin\spart\s'
    end

    def kick? privMsg
      privMsg.message.match '^!admin\skick\s'
    end

    def die? privMsg
      privMsg.message.match '^!admin\sdie'
    end

    def mode? privMsg
      privMsg.message =~ /^!admin\smode\s/
    end

    def reload? privMsg
      privMsg.message =~/^!admin\sreload\s/
    end

  end
end
