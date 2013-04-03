# -*- encoding : utf-8 -*-
module Linael
  class Modules::Log < ModuleIRC

    Name="log"	

    Help=["Module: Log"," ","Log every recognized message in the console"]

    def log(msg)
      p msg
    end

    def startMod()
      add_module({msg:  [:log],
                  cmd:  [:log],
                  kick: [:log],
                  nick: [:log],
                  part: [:log],
                  join: [:log],
                  mode: [:log]})
    end

  end
end
