# -*- encoding : utf-8 -*-

module Linael
  class Modules::Ping < ModuleIRC

    Name="ping"

    def startMod
      add_module :msg => [:pong]
    end

    def pong privMsg
      if Options.ping? privMsg.message
        answer(privMsg,"Moi aussi je t'aime #{privMsg.who}! ♥")
      end
    end

    class Options < ModulesOptions
      generate_to_catch :ping => /^linael..?\s*ping|linael.*je.*aime|linael.*♥|linael.*<3/
    end

  end
end
