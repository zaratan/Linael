# -*- encoding : utf-8 -*-

module Linael

  module IRC

    def send_msg(msg)
      @irc_socket.puts "#{msg}\n"
    end

    def connect(server,port,nick)
      @irc_socket = TCPSocket.open(server, port)
      send_msg "USER #{nick} 0 * :Linael"
      send_msg "NICK #{nick}"
    end

    def main_loop(msg_handler)
      while line = get_msg
        msg_handler.handle_msg(line)
      end
    end

    def get_msg()
      return @irc_socket.gets
    end

  end

  module Action

    include IRC

    def method_missing(name, *args)
      if name =~ /(.*)_channel/
        define_method(name) do |arg|
          msg = "#{$1.upcase} "
          msg += "#{arg[:dest]} " unless arg[:dest].nil?
          msg += "#{arg[:who]} " unless arg[:who].nil?
          msg += "#{arg[:args]} " unless arg[:args].nil?
          msg += ":#{arg[:msg]} " unless arg[:msg].nil?
          send_msg msg
        end      
        return self.send name,args[0]
      end
      super
    end

    def talk(dest,msg)
      privmsg_channel {dest: dest, msg: msg}
    end

    def answer(privMsg,ans)
      
  f(privMsg.private_message?)
        talk(privMsg.who,ans)
      else
        talk(privMsg.place,ans)
      end
    end

#    def join_channel(chan)
#      @irc.send_msg("JOIN #{chan}")
#    end
#
#    def part_channel(chan)
#      @irc.send_msg("PART #{chan}")
#    end
#
#    def quit_channel(msg)
#      @irc.send_msg("QUIT :#{msg}")
#    end
#
#    def kick_channel(chan,who,message)
#      @irc.send_msg("KICK #{chan} #{who} :#{message}")
#    end
#    def ping(dest)
#      @irc.send_msg "PONG #{dest}"
#    end
#
#    def mode_channel(who,mode,arg="")
#      @irc.send "MODE #{who} #{mode} #{arg}"
#    end
#
#    def version(dest)
#      @irc.send_msg "NOTICE #{dest} :Linael v0.2"
#    end

  end
end
