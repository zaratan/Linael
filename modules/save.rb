#encoding: utf-8


class Modules::Save < ModuleIRC

Name="save"

def startMod
	addAuthCmdMethod(self,:whiteList,":whiteList")
	addAuthCmdMethod(self,:blackList,":blackList")
end

def endMod
	delAuthCmdMethod(self,":whiteList")
	delAuthCmdMethod(self,":blackList")
end

def self.requireAuth?
	true
end

def self.requiredMod
	["module","admin"]
end



def whiteList privMsg
	
	if (Options.whiteList? privMsg.message)
		options = Options.new privMsg
		modModule = getModule("module")
		modAdmin = getModule("admin")
		if (modModule.instance.modules.has_key?(options.module))
			mod=modModule.instance.modules[options.module]
			if (options.add?)
				if (options.all?)
					modAdmin.instance.chan.each do |chan| 
						talk(privMsg.who,"The chan #{chan} have been added to the whitelist of the module #{options.module}")
						mod.whiteList(chan)
					end
					
				else
					mod.whiteList(options.chan)	
					talk(privMsg.who,"The chan #{options.chan} have been added to the whitelist of the module #{options.module}")
				end
			end
			if (options.del?)
				if (options.all?)
					modAdmin.instance.chan.each do |chan| 
						mod.unWhiteList(chan)
						talk(privMsg.who,"The chan #{chan} have been deleted from the whitelist of the module #{options.module}")
					end
				else
					mod.unWhiteList(options.chan)
					talk(privMsg.who,"The chan #{options.chan} have been deleted from the whitelist of the module #{options.module}")
				end
			end
		else

			answer(privMsg,"The module #{options.module} is not loaded :(")
		end
	end
	
end

def blackList privMsg

	if (Options.blackList? privMsg.message)
		options = Options.new privMsg
		modModule = getModule("module")
		modAdmin = getModule("admin")
		if (modModule.instance.modules.has_key?(options.module))
			mod=modModule.instance.modules[options.module]
			if (options.add?)
				if (options.all?)
					modAdmin.instance.chan.each do |chan| 
						talk(privMsg.who,"The chan #{chan} have been added to the blacklist of the module #{options.module}")
						mod.blackList(chan)
					end
					
				else
					mod.blackList(options.chan)	
					talk(privMsg.who,"The chan #{options.chan} have been added to the blacklist of the module #{options.module}")
				end
			end
			if (options.del?)
				if (options.all?)
					modAdmin.instance.chan.each do |chan| 
						mod.unBlackList(chan)
						talk(privMsg.who,"The chan #{chan} have been deleted from the blacklist of the module #{options.module}")
					end
				else
					mod.unBlackList(options.chan)
					talk(privMsg.who,"The chan #{options.chan} have been deleted from the blacklist of the module #{options.module}")
				end
			end
		else

			answer(privMsg,"The module #{options.module} is not loaded :(")
		end
	end
end



end

class Modules::Blacklist::Options

	def initialize privMsg
		@message = privMsg.message
	end

	def add?
		@message =~ /\s-add\s/
	end

	def del?
		@message =~ /\s-del\s/
	end

	def self.blackList? message
		message =~ /^!blacklist\s|^!bl\s/
	end

	def self.whiteList? message
		message =~ /^!whitelist\s|^!wl\s/
	end

	def all?
		@message =~ /\s-all\s/
	end

	def module
		$~[1] if @message =~ /\s([A-z0-9]*)\s/
	end

	def chan
		$~[1] if @message =~ /\s(#\S*)\s/
	end

end
