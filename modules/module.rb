class Modules::Module < ModuleIRC

attr_reader :modules,:authModule

Name="module"

def initialize(runner)
	@dir = Dir.new("./modules")
	@modules=Hash.new
	@authModule=[]
	super runner
end



def whichModule privMsg
	if (module? privMsg) && (list? privMsg)
		@dir.each do |file| 
			if file.match /^[A-z]/
				file.sub!(/\.rb$/,"")
				file.sub!(/^/,"*\s") if @modules.has_key? file
				answer(privMsg,file)
			end
		end
	end
end

def addModule privMsg
	if (module? privMsg) &&
		(add? privMsg)
		if privMsg.message.match /^!modules\sadd\s([A-z0-9]*)/
			modName = "#{$~[1]}"
			addModule_aux modName,privMsg	
		end
	end
end

def addModule_aux(modName,privMsg)
	if @dir.find{|file| file.sub!(/\.rb$/,""); file ==  modName} 	
		load "./modules/#{modName}.rb"
		klass = "modules/#{modName}".camelize.constantize
		if (@modules.has_key?(klass::Name))
			answer(privMsg,"Module already loaded, please unload first")	
		else
			if (klass::requireAuth? && authModule.empty?)
				answer(privMsg,"You need at least one authMethod to load this module")
			else
				instKlass = klass.new(@runner)
				@modules[klass::Name] = instKlass
				@authModule << klass::Name if klass::auth?
				instKlass.startMod
				answer(privMsg,"Module #{modName} loaded!")
			end
		end
	end

end

def delModule privMsg
if (module? privMsg) &&
		(del? privMsg)
		if privMsg.message.match /^!modules\sdel\s([A-z0-9]*)/
			modName = "#{$~[1]}"
			delModule_aux modName,privMsg
		end
end
end

def delModule_aux(modName,privMsg)
	if (!@modules.has_key?(modName))
		answer(privMsg,"Module not loaded")	
	else
		@modules[modName].endMod
		@modules.delete(modName)
		@authModule.delete(modName)
		answer(privMsg,"Module #{modName} unloaded!")
	end

end

def reloadModule privMsg
if (module? privMsg) &&
	(reload? privMsg)
	if privMsg.message =~ /^!modules\sreload\s([A-z0-9]*)/
		modName = $~[1]
		if (!@modules.has_key?(modName))
			answer(privMsg,"Module not loaded")
			return
		end
		if !(@dir.find{|file| file.sub!(/\.rb$/,""); file ==  modName})
			answer(privMsg,"The module don't exist")
			return
		end
		
		delModule_aux modName,privMsg
		addModule_aux modName,privMsg
		


	end

end
end

def reload? privMsg
	privMsg.message =~ /^!modules\sreload/
end

def self.requireAuth?
	true
end

def add? privMsg
	privMsg.message.match '^!modules\sadd'
end

def del? privMsg
	privMsg.message.match '^!modules\sdel'
end


def list? privMsg
	privMsg.message.match '^!modules\slist'
end

def authorized? privMsg
	privMsg.who == "Zaratan" && (privMsg.identification.match '^~Zaratan@.*$')
end

def module? privMsg
	privMsg.message.match '^!modules\s.*$' 
end

def startMod()
	@modules[self.class::Name] = self
	addCmdMethod(self,:whichModule,":whichModule")
	addAuthCmdMethod(self,:addModule,":addModule")
	addAuthCmdMethod(self,:delModule,":delModule")
	addAuthCmdMethod(self,:reloadModule,":reloadModule")
end


end
