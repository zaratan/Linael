#encoding: utf-8

class Modules::Identify < ModuleIRC

Name="identify"

def startMod
	addAuthCmdMethod(self,:identify,":identify")
	addAuthCmdMethod(self,:askOp,":askOp")
end

def endMod
	delAuthCmdMethod(self,":identify")
	delAuthCmdMethod(self,":askOp")

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
		puts user
		puts place
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
