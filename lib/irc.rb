# -*- encoding : utf-8 -*-

require 'active_support/inflector'
require 'active_support/core_ext/numeric/time'
require 'socket'
require 'colorize'

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

    attr_accessor :timer

    # Define a irc sending method
    def define_send(name,short)
        self.class.send("define_method",name) do |arg|
          msg = "#{short.upcase} "
          [:dest,:who,:what,:args,:msg].each do |key|
            msg += "#{":" if key==:msg}#{arg[key]} " unless arg[key].nil?            
          end
          puts ">>> #{msg}".blue
          IRC::send_msg msg
        end      
    end

    # Cover most of  IRC send. 
    # Catch methods ending with _channel
    #   kick_channel #=> a kick
    def method_missing(name, *args, &block)
      if name =~ /(.*)_channel/
        define_send(name,$1)
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
      return unless privMsg
      if(privMsg.private_message?)
        talk(privMsg.who,ans)
      else
        talk(privMsg.place,ans)
      end
    end

  end
end

#It's ugly but you really need to load Action first
require_relative '../lib/mess.rb'
require_relative "../lib/modules.rb"
require_relative '../lib/DSL.rb'
require_relative '../lib/modules/module.rb'
require_relative '../lib/message.rb'
