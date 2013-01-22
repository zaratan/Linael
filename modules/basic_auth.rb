class Modules::BasicAuth < ModuleIRC

Name="basic_auth"

def basic_auth privMsg
	privMsg.who == "Zaratan" && (privMsg.identification.match '^~Zaratan@.*$')
end

def self.auth?
	true
end

def startMod()
	addAuthMethod(self,:basic_auth,":basic_auth")
end

def endMod
	delAuthMethod(self,":basic_auth")
end

end
