#encoding: utf-8

class Modules::Help < ModuleIRC

Name="help"

Help=[
	"Module Help:",
	"!help modName => display the help for the module modName"
]

def startMod
	addCmdMethod(self,:help,":help")
end

def endMod
	delCmdMethod(self,":help")
end


def help privMsg
	if (module? privMsg) && (privMsg.message.match /^!help\s([A-z0-9]*)/)
		modName=$~[1]
		if @dir.find{|file| file.sub!(/\.rb$/,""); file ==  modName} 	
			load "./modules/#{modName}.rb"
			klass = "modules/#{modName}".camelize.constantize
			puts klass::Help.empty?
			if !klass::Help.empty?
				klass::Help.each {|helpSent| answer(privMsg,helpSent)}
			else
				answer(privMsg,"No help for the module #{modName}. Ask #{klass::Constructor} for this :)")
			end
		else
			answer(privMsg,"There is no module named #{modName}")
		end
	end
end


def module? privMsg
	privMsg.message =~ /^!help\s/
end

def initialize(runner)
	@dir = Dir.new("./modules")
	super runner
end

end
