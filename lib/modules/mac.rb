# -*- encoding : utf-8 -*-
module Linael
  class Modules::Mac < ModuleIRC

    Name="mac"

    def startMod
      add_module :msg => [:macboue]
    end

    def macboue privMsg
      if (module? privMsg)
        answer(privMsg,"#{privMsg.who}: Apple, c'est de la boue :)")
      end
    end

    def module? privMsg
      privMsg.message.downcase =~ /\smac\s|^mac\s/
    end

  end
end
