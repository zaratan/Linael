require './irc.rb'
require './mess.rb'

class MessageAction

	include Action

	def handleKeepAlive(msg)
		if Ping.match(msg) then
			msgPing = Ping.new msg
			ping msgPing.sender
			return true
		end
		return false
	end

	def handlePrivMsg(msg)
		if PrivMessage.match(msg) then
			privmsg = PrivMessage.new msg
			if (privmsg.message =~ /^!/) then
				talk("zaratan",privmsg.message)
				match_cmd(privmsg.message.sub(/^!/,""))	
			end
			puts privmsg
			return true
		end
		return false
	end

	def isCommand(msg)
		if msg.match(/^:[^:]*:!(.*)$/) then
			match_cmd("#{$~[1]}")
			return true
		end
		return false
	end

	def initialize irc
		@toDo=[:handleKeepAlive,
				:handlePrivMsg]		
		@irc=irc
	end



	def match_cmd(cmd)		
		say_hello("#zarabotte") if cmd.match(/\AhelloAll/)
	end

	def say_hello(chan)
		talk(chan,"Hello all!")
	end

	def handle_msg(msg)
		@toDo.detect{|m| self.send(m,msg)}
	end
end
