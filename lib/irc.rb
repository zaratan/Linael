# -*- encoding : utf-8 -*-

module Linael

  # mains methods of IRC
  module IRC

    def self.linael_start
      self.connect(Linael::ServerAddress,Linael::Port,Linael::BotNick)
      action = Handler.new(Linael::MasterModule,Linael::ModulesToLoad)
      self.main_loop(action)
    end

    # Send a message in the socket
    def self.send_msg(msg)
      $linael_irc_socket.puts "#{msg}\n"
    end

    # Connect to a server
    def self.connect(server,port,nick)
      $linael_irc_socket = TCPSocket.open(server, port)
      send_msg "USER #{nick} 0 * :Linael"
      send_msg "NICK #{nick}"
    end

    # Main loop of the irc to keep the prog reading inside the socket
    def self.main_loop(msg_handler)
      while line = get_msg
        msg_handler.handle_msg(line)
      end
    end

    #read from socket
    def self.get_msg()
      return $linael_irc_socket.gets
    end

  end

  #different possible action from IRC
  module Action

    include IRC

    attr_accessor :timer

    # Cover most of  IRC send. 
    # Catch methods ending with _channel
    #   kick_channel #=> a kick
    def method_missing(name, *args, &block)
      if name =~ /(.*)_channel/
        self.class.send("define_method",name) do |arg|
          msg = "#{$1.upcase} "
          msg += "#{arg[:dest]} " unless arg[:dest].nil?
          msg += "#{arg[:who]} " unless arg[:who].nil?
          msg += "#{arg[:what]} " unless arg[:what].nil?
          msg += "#{arg[:args]} " unless arg[:args].nil?
          msg += ":#{arg[:msg]} " unless arg[:msg].nil?
          puts ">>> #{msg}".blue
          IRC::send_msg msg
        end      
        return self.send name,args[0]
      end
      super
    end

    #proxy for sendind a private_message to socket. Just for code readability
    def talk(dest,msg)
      $timer ||= 0
      sleep(0.2) until Time.now > $timer
      $timer = Time.now + 0.5
      privmsg_channel({dest: dest, msg: msg})
    end

    #proxy for talk (proxyception) for readability
    def answer(privMsg,ans)
      if !privMsg 
        return
      end
      if(privMsg.private_message?)
        talk(privMsg.who,ans)
      else
        talk(privMsg.place,ans)
      end
    end

  end
end
