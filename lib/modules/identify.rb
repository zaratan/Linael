# -*- encoding : utf-8 -*-

module Linael
  class Modules::Identify < ModuleIRC

    Name="identify"

    def startMod
      add_module :cmdAuth => [:identify,:askOp],
                 :cmd     => [:askVoice]
    end

    def identify privMsg
      if Options.identify? privMsg.message
        options = Options.new privMsg
        talk("nickserv","identify #{options.who}")
      end
    end

    def askOp privMsg
      if Options.askOp? privMsg.message
        options = Options.new privMsg
        talk("chanserv","op #{options.chan} #{options.who}")
      end
    end

    def askVoice privMsg
      if Options.askVoice? privMsg.message
        options = Options.new privMsg
        talk("chanserv","voice #{privMsg.place} #{options.who}")
      end
    end

    class Options < ModulesOptions
      generate_to_catch :identify => /^!identify\s/,
                        :askOp    => /^!op\s/,
                        :askVoice => /^!voice\s/

      generate_chan
      generate_who
    end

  end
end
