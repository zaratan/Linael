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

	def handleVersion(msg)
		if Version.match(msg) then
			versionMsg = Version.new msg
			version msg.sender
			return true
		end
		return false
	end

	def handleMode(msg)
		if Mode.match(msg) then
			mode = Mode.new msg			
			@modeAct.values.each {|act| act.call mode}
			return true
		end
		return false
	end

	def handlePrivMsg(msg)
		if PrivMessage.match(msg) then
			privmsg = PrivMessage.new msg
			if (privmsg.command?) then
				talk("zaratan",privmsg.message)
				@cmdAct.values.each {|act| act.call privmsg}
				return true
			end
			@msgAct.values.each {|act| act.call privmsg}
			return true
		end
		return false
	end

	

	def handleNick(msg)
		if Nick.match(msg) then
			nick = Nick.new msg
			@nickAct.values.each {|act| act.call nick}
			return true
		end
		return false
	end

	def handleJoin(msg)
		if Join.match(msg) then
			join = Join.new msg
			@joinAct.values.each {|act| act.call join}
			
			return true
		end
		return false
	end

	def handlePart(msg)
		if Part.match(msg) then
			part = Part.new msg
			@partAct.values.each {|act| act.call part}
			return true
		end
		return false
	end	

	def handleKick(msg)
		if Kick.match(msg) then
			kick = Kick.new msg
			@kickAct.values.each {|act| act.call kick}
			return true
		end
		return false
	end

	attr_accessor :kickAct,:partAct,:joinAct,:nickAct,:msgAct,:modeAct,:cmdAct

	def initialize(irc,modules)
		@toDo=[:handleKeepAlive,
				:handleVersion,
				:handleMode,
				:handleNick,
				:handleJoin,
				:handlePart,
				:handleKick,
				:handlePrivMsg]		
		@irc=irc
		@modules=[]
		modules.each {|klass| @modules << klass.new(self)}
		@kickAct=Hash.new
		@partAct=Hash.new
		@joinAct=Hash.new
		@nickAct=Hash.new
		@msgAct=Hash.new
		@modeAct=Hash.new
		@cmdAct=Hash.new
		@modules.each {|mod| mod.startMod}
	end

	def match_cmd(cmd)		
		say_hello("#zarabotte") if cmd.match(/\AhelloAll/)
		if cmd.match(/join (.*)/) then
			join_channel($~[1])
		end
	end

	def say_hello(chan)
		talk(chan,"Hello all!")
	end

	def handle_msg(msg)
		@toDo.detect{|m| self.send(m,msg)}
	end
end
