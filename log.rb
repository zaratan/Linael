require "./module.rb"

class IrcLog < ModuleIRC
	
	def log(msg)
		puts msg
	end

	def startMod()
		addMsgMethod(self,:log)
	end


end
