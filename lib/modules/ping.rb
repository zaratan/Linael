# -*- encoding : utf-8 -*-

module Linael
  class Modules::Ping < ModuleIRC

    Name="ping"

    def startMod
      add_module :msg => [:pong]
    end

    def pong privMsg
      if (module? privMsg)
        answer(privMsg,"Moi aussi je t'aime #{privMsg.who}! ♥")
      end
    end

    def module? privMsg
      privMsg.message.encode.downcase =~ /^linael..?\s*ping|linael.*je.*aime|linael.*♥|linael.*<3/
    end

  end
end
