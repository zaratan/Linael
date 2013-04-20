# -*- encoding : utf-8 -*-

module Linael
  class Modules::System < ModuleIRC

    Name="system"

    Help=[
      "Module : System",
      " ",
      "=====Functions=====",
      "!bash xxx => execute with bash the xxx command"
    ]

    def startMod
    end

    class Options < ModulesOptions

    end
  end
end
