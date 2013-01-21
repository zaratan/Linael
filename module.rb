class ModuleIRC

	def addKickMethod(instance,nom)
		@runner.kickAct << Proc.new {|msg| instance.send(nom,msg)}
	end
	
	def addNickMethod(instance,nom)
		@runner.nickAct << Proc.new {|msg| instance.send(nom,msg)}
	end

	def addJoinMethod(instance,nom)
		@runner.joinAct << Proc.new {|msg| instance.send(nom,msg)}
	end

	def addPartMethod(instance,nom)
		@runner.partAct << Proc.new {|msg| instance.send(nom,msg)}
	end

	def addMsgMethod(instance,nom)
		@runner.msgAct << Proc.new {|msg| instance.send(nom,msg)}
	end

	def addModeMethod(instance,nom)
		@runner.modeAct << Proc.new {|msg| instance.send(nom,msg)}
	end

	def addCmdMethod(instance,nom)
		@runner.cmdAct << Proc.new {|msg| instance.send(nom,msg)}
	end
		

	def startMod()
		
	end


	def endMod()

	end	

	def initialize(runner)
		@runner=runner
	end

	attr_reader :runner

end
