class Modules::Talk < ModuleIRC

def startMod
	addAuthCmdMethod(self,:talking,":talking")
end

def endMod
	delAuthMethod(self,":talking")
end


def talking privMsg
	if (module? privMsg)
		if privMsg.message =~ /^!talk\s(#[\S]*)\s(.*)/
			where=$~[1]
			what=$~[2]
			talk(where,what)
		end
	end
end

def self.requireAuth?
	true
end

def module? privMsg
	privMsg.message =~ /^!talk\s/
end

end
