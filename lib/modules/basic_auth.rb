# -*- encoding : utf-8 -*-
class Modules::BasicAuth < ModuleIRC

Name="basic_auth"

def basic_auth privMsg
	askUser "zaratan"
	sleep(0.3)
	puts @user["zaratan"]
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
	addNoticeMethod(self,:addUser,":addUser")
	addAuthMethod(self,:basic_auth,":basic_auth")
end

def endMod
	delNoticeMethod(self,":addUser")
	delAuthMethod(self,":basic_auth")
end

end
