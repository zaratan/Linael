class Modules::Log < ModuleIRC
	
	Name="log"	

	def log(msg)
		puts msg
	end

	def startMod()
		addMsgMethod(self,:log,":log")
		addCmdMethod(self,:log,":log")
		addKickMethod(self,:log,":log")
		addNickMethod(self,:log,":log")
		addPartMethod(self,:log,":log")
		addJoinMethod(self,:log,":log")
		addModeMethod(self,:log,":log")
	end

	def endMod()
		delMsgMethod(self,":log")
		delCmdMethod(self,":log")
		delNickMethod(self,":log")
		delKickMethod(self,":log")
		delPartMethod(self,":log")
		delJoinMethod(self,":log")
		delModeMethod(self,":log")
	end

end
