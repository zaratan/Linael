require 'socket'

class IRC
	def initialize(server,port,nick)
		@server=server
		@port=port
		@nick=nick
	end

	def send(msg)
		@irc.puts "#{msg}\n"
	end

	def connect()
		@irc = TCPSocket.open(@server, @port)
		send "USER #{@nick} 0 * :Zaratan"
		send "NICK #{@nick}"
	end

	def get_msg()
		return @irc.gets
	end


end

module Action

attr_reader :irc

	def initialize(irc)
		@irc=irc
	end

	def join_channel(chan)
		@irc.send("JOIN #{chan}")
	end

	def part_channel(chan)
		@irc.send("PART #{chan}")
	end

	def quit_channel(msg)
		@irc.send("QUIT :#{msg}")
	end

	def kick_channel(chan,who,message)
		@irc.send("KICK #{chan} #{who} :#{message}")
	end

	def talk(dest,msg)
		@irc.send("PRIVMSG #{dest} :#{msg}")
	end

	def ping(dest)
		@irc.send "PONG #{dest}"
	end

	def mode_channel(who,mode,arg="")
		@irc.send "MODE #{who} #{mode} #{arg}"
	end

	def version(dest)
		@irc.send "NOTICE #{dest} :Zar a Bottes v0.1"
	end
	
	def answer(privMsg,ans)
		if(privMsg.private_message?)
			talk(privMsg.who,ans)
		else
			talk(privMsg.place,ans)
		end
	end

end

