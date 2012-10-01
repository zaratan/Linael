require './irc.rb'

class MessageAction

	

	def handleKeepAlive(msg)
		if msg.match(/^PING :(.*)$/) then
			@action.irc.send "PONG #{$~[1]}"
			
			return true
		end
		return false
	end

	def isCommand(msg)
		if msg.match(/^:[^:]*:!(.*)$/) then
			match_cmd("#{$~[1]}")
			@action.talk("zaratan","#{$~[1]}")
			return true
		end
		return false
	end

	def initialize(action)
		@toDo=[:handleKeepAlive,
				:isCommand]
		@act={/\AhelloAll/ => [:say_hello,"#zarabotte"]}
		@action=action
	end



	def match_cmd(cmd)
		@act.detect {|k, t| self.send(t[0],t.drop(1)) if cmd.match(k)} 
	end

	def say_hello(chan)
		chan.each {|i| @action.talk(i,"Hello all!")}
		return true
	end

	def handle_msg(msg)
		@toDo.detect{|m| self.send(m,msg)}
	end
end

