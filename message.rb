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

	def handleMode(msg)
		if Mode.match(msg) then
			mode = Mode.new msg			

			puts mode
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

	def handleNick(msg)
		if Nick.match(msg) then
			nick = Nick.new msg

			puts nick
			return true
		end
		return false
	end

	def handleJoin(msg)
		if Join.match(msg) then
			join = Join.new msg

			puts join
			return true
		end
		return false
	end

	def handlePart(msg)
		if Part.match(msg) then
			part = Part.new msg

			puts part
			return true
		end
		return false
	end	

	def initialize irc
		@toDo=[:handleKeepAlive,
				:handleMode,
				:handleNick,
				:handleJoin,
				:handlePart,
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
