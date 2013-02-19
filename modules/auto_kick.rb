#encoding: utf-8

class Modules::AutoKick < ModuleIRC

Name="auto_kick"

Help=[
	"Module: Auto_Kick",
	" ",
	"=====Functions=====",
	"!akick -[add|del|show] where <options>",
	" ",
	"=====Options=====",
	"-add   : add a rule of auto kick. can match nick or vhost. Can match regexp with *",
	"-del   : delete the rule by its number",
	"-show  : print the rule for the chan"

]

def self.requireAuth?
	true
end

def initialize runner
	@akick = Hash.new
	super(runner)
end

def startMod
	addAuthCmdMethod(self,:addAkick,":addAkick")
	addAuthCmdMethod(self,:delAkick,":delAkick")
	addAuthCmdMethod(self,:printAkick,":printAkick")
	addJoinMethod(self,:autokick,":autokick")
end

def endMod
	delAuthCmdMethod(self,":addAkick")
	delAuthCmdMethod(self,":delAkick")
	delAuthCmdMethod(self,":printAkick")
	delJoinMethod(self,":autokick")
end

def autokick joinMsg
	if !@akick[joinMsg.where.downcase].nil?
		if @akick[joinMsg.where.downcase].detect {|regexp| ((joinMsg.who.downcase.match regexp) || (joinMsg.identification.downcase.match regexp))}
			talk(joinMsg.where,"sorry #{joinMsg.who} you are akick from #{joinMsg.where}.")
			kick_channel(joinMsg.where,joinMsg.who,"sorry ♥")
		end
	end
end

def addAkick privMsg
	if privMsg.message =~ /!akick\s-add\s(#\S*)\s(\S*)/
		answer(privMsg,"Oki doki! #{$~[2]} will be auto kick on #{$~[1]}."
		addAkickRule $~[1].downcase,$~[2].downcase
	end
end

def delAkick privMsg
	if privMsg.message =~ /!akick\s-del\s(#\S*)\s(\d*)/
		answer(privMsg,"Oki doki! I'll no longuer match rule #{$~[2]} on #{$~[1]}."
		delAkickRule $~[1].downcase,($~[2].to_i)
	end
end

def printAkick privMsg
	if privMsg.message =~ /!akick\s-show\s(#\S*)/
		printRules $~[1].downcase,privMsg.who
	end
end



def addAkickRule where,rule
	rule.gsub!("*",".*")
	if @akick[where].nil?
		@akick[where] = [rule]
	else
		@akick[where] << rule
	end
end

def delAkickRule where,ruleNum
	if !@akick[where].nil?
		@akick[where].delete_at (ruleNum - 1)
	end
end

def printRules where,who
	if !@akick[where].nil?
		@akick[where].each_with_index {|rule,index| talk(who,"#{(index + 1)} - #{rule}")}
	end
end

def module? privMsg
	privMsg.message.downcase =~ /\smac\s|^mac\s/
end

end
