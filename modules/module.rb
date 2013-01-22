class Modules::Module < ModuleIRC

attr_reader :modules

Name="module"

def initialize(runner)
	@dir = Dir.new("./modules")
	@modules=Hash.new
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
		(authorized? privMsg) &&
		(add? privMsg)
		privMsg.message.match /^!modules\sadd\s([A-z0-9]*)/
		modName = "#{$~[1]}"
		
		if @dir.find{|file| file.sub!(/\.rb$/,""); file ==  modName} 	
			load "./modules/#{modName}.rb"
			klass = "modules/#{modName}".camelize.constantize
			if (@modules.has_key?(klass::Name))
				answer(privMsg,"Module already loaded, please unload first")	
			else
				instKlass = klass.new(@runner)
				@modules[klass::Name] = instKlass
				instKlass.startMod
				answer(privMsg,"Module #{modName} loaded!")
			end
		end
	end
end

def delModule privMsg
if (module? privMsg) &&
		(authorized? privMsg) &&
		(del? privMsg)
		privMsg.message.match /^!modules\sdel\s([A-z0-9]*)/
		modName = "#{$~[1]}"
			if (!@modules.has_key?(modName))
				answer(privMsg,"Module not loaded")	
			else
				@modules[modName].endMod
				@modules.delete(modName)
				answer(privMsg,"Module #{modName} unloaded!")
			end

end
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
	addCmdMethod(self,:addModule,":addModule")
	addCmdMethod(self,:delModule,":delModule")
end

def endMod()
end

end
