# -*- encoding : utf-8 -*-
module Linael
  class Modules::BasicAuth < ModuleIRC

    Name="basic_auth"

    def basic_auth privMsg
      askUser "zaratan"
      sleep(0.3)
      privMsg.who == "Zaratan" && (privMsg.identification.match '^~Zaratan@zaratan.fr') && (@user["zaratan"] == "3")
    end

    def initialize runner
      @user = Hash.new
      super runner
    end

    def addUser privMsg
      if(privMsg.sender.downcase == "nickserv") && (privMsg.message =~ /STATUS\s(\S*)\s([0-3])/)
        @user[($~[1].downcase)]=$~[2]
      end
    end

    def askUser user
      talk("nickserv","status #{user}")
    end

    def self.auth?
      true
    end

    def startMod()
      add_module({notice:[:addUser],
                  auth:[:basic_auth]})
    end

  end
end
