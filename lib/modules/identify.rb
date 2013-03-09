# -*- encoding : utf-8 -*-

module Linael
  class Modules::Identify < ModuleIRC

    Name="identify"

    def startMod
      add_module :cmdAuth => [:identify,:askOp]
    end

    def identify privMsg
      if (module? privMsg)
        if (privMsg.message =~ /^!identify\s(\S*)\s/)
          talk("nickserv","identify #{$~[1]}")
          @ident=true
        end
      end
    end

    def askOp privMsg
      puts @ident
      if (privMsg.message =~ /!op\s(#\S*)\s(\S*)/) && (@ident)

        user=$~[2]
        place=$~[1]
        talk("chanserv","op #{place} #{user}")
      end
    end


    def module? privMsg
      privMsg.message.encode.downcase =~ /^!identify\s/
    end

    def initialize runner
      @ident=false
      super runner
    end

  end
end
