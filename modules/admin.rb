class Modules::Admin < ModuleIRC

Name="admin"

def self.requireAuth?
	true
end

def startMod
	addAuthCmdMethod(self,:join,":join")
	addAuthCmdMethod(self,:part,":part")
	addAuthCmdMethod(self,:kick,":kick")
	addAuthCmdMethod(self,:die,":die")
end

def endMod
	delAuthMethod(self,":join")
	delAuthMethod(self,":part")
	delAuthMethod(self,":kick")
	delAuthMethod(self,":die")
end

def join privMsg
	if (module? privMsg) &&
		(join? privMsg)
		privMsg.message =~ /^!admin\sjoin\s(#[\S]*)/
		answer(privMsg,"Oki doki! i'll join #{$~[1]}")	
		join_channel $~[1]
	end
end

def part privMsg
	if (module? privMsg) &&
		(part? privMsg)
		privMsg.message =~ /^!admin\spart\s(#[\S]*)/
		answer(privMsg,"Oki doki! i'll part #{$~[1]}")	
		talk($~[1],"cya all!")
		part_channel $~[1]
	end


end

def die privMsg
	if (module? privMsg) &&
		(die? privMsg)

		answer(privMsg,"Oh... Ok... I'll miss you")
		quit_channel "I'll miss you!"
		exit 0
	end

end

def mode privMsg

end

def kick privMsg
	if (module? privMsg) &&
		(kick? privMsg)
		privMsg.message =~ /^!admin\skick\s(#\S*)\s(\S*)\s(.*)$/
		answer(privMsg,"Oki doki! i'll kick #{$~[2]} on #{$~[1]}")	
		talk($~[1],"bye #{$~[2]}!")
		kick_channel($~[1],$~[2],$~[3])
	end
	
end

def knockout

end

def module? privMsg
	privMsg.message.match '^!admin\s'
end

def join? privMsg
	privMsg.message.match '^!admin\sjoin\s'
end

def part? privMsg
	privMsg.message.match '^!admin\spart\s'
end

def kick? privMsg
	privMsg.message.match '^!admin\skick\s'
end

def die? privMsg
	privMsg.message.match '^!admin\sdie'
end

end
