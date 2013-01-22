class ModuleIRC

	def addKickMethod(instance,nom,ident)
		@runner.kickAct[instance.class::Name+ident] = Proc.new {|msg| instance.send(nom,msg)}
	end

	def delKickMethod(instance,ident)
		@runner.kickAct.delete(instance.class::Name+ident)
	end
	
	def addNickMethod(instance,nom,ident)
		@runner.nickAct[instance.class::Name+ident] = Proc.new {|msg| instance.send(nom,msg)}
	end

	def delNickMethod(instance,ident)
		@runner.nickAct.delete(instance.class::Name+ident)
	end

	def addJoinMethod(instance,nom,ident)
		@runner.joinAct[instance.class::Name+ident] = Proc.new {|msg| instance.send(nom,msg)}
	end

	def delJoinMethod(instance,ident)
		@runner.joinAct.delete(instance.class::Name+ident)
	end

	def addPartMethod(instance,nom,ident)
		@runner.partAct[instance.class::Name+ident] = Proc.new {|msg| instance.send(nom,msg)}
	end

	def delPartMethod(instance,ident)
		@runner.partAct.delete(instance.class::Name+ident)
	end

	def addMsgMethod(instance,nom,ident)
		@runner.msgAct[instance.class::Name+ident] = Proc.new {|msg| instance.send(nom,msg)}
	end

	def delMsgMethod(instance,ident)
		@runner.msgAct.delete(instance.class::Name+ident)
	end

	def addModeMethod(instance,nom,ident)
		@runner.modeAct[instance.class::Name+ident] = Proc.new {|msg| instance.send(nom,msg)}
	end

	def delModeMethod(instance,ident)
		@runner.modeAct.delete(instance.class::Name+ident)
	end

	def addCmdMethod(instance,nom,ident)
		@runner.cmdAct[instance.class::Name+ident] = Proc.new {|msg| instance.send(nom,msg)}
	end
		
	def delCmdMethod(instance,ident)
		@runner.cmdAct.delete(instance.class::Name+ident)
	end

	def addAuthMethod(instance,nom,ident)
		@runner.authMeth[instance.class::Name+ident] = Proc.new {|msg| instance.send(nom,msg)}
	end
		
	def delAuthMethod(instance,ident)
		@runner.authMeth.delete(instance.class::Name+ident)
	end

	def addAuthCmdMethod(instance,nom,ident)
		@runner.cmdActAuth[instance.class::Name+ident] = Proc.new {|msg| instance.send(nom,msg)}
	end
		
	def delAuthCmdMethod(instance,ident)
		@runner.cmdActAuth.delete(instance.class::Name+ident)
	end

	

	def self.requireAuth?
		false
	end

	def self.auth?
		false
	end

	Name=""

	def startMod()
		
	end


	def endMod()

	end	

	def initialize(runner)
		@runner=runner
	end

	def answer(privMsg,ans)
		if(privMsg.private_message?)
			@runner.talk(privMsg.who,ans)
		else
			@runner.talk(privMsg.place,ans)
		end
	end

	attr_reader :runner

end

module Modules
end
