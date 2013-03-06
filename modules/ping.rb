#encoding: utf-8

class Modules::Ping < ModuleIRC

Name="ping"

def startMod
	addMsgMethod(self,:pong,":pong")
end

def endMod
	delMsgMethod(self,":pong")
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
