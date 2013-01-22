class Modules::Log < ModuleIRC
	
	Name="log"	

	def log(msg)
		puts msg
	end

	def startMod()
		addMsgMethod(self,:log,":log")
		addCmdMethod(self,:log,":log")
	end

	def endMod()
		delMsgMethod(self,":log")
		delCmdMethod(self,":log")
	end

end
