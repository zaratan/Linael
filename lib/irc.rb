# -*- encoding : utf-8 -*-

require 'active_support/inflector'
require 'active_support/core_ext/numeric/time'
require 'socket'
require 'colorize'
require 'r18n-desktop'


module Linael

  class Socket

    attr_accessor :server,:port,:name

    def initialize server,port,name=nil
      @name = name || server
      @port = port
      @server = server
      @socket = TCPSocket.open(server,port)
    end

    def restart
      sleep 300
      @socket = TCPSocket.open(server,port)
    end

    def gets
      begin
        ServerMessage.new(name,@socket.gets)
      rescue Exception => e
        puts e.to_s.red
        puts e.backtrace.join("\n").red
        restart
      end
    end

    def puts msg
      begin
        @socket.puts "#{msg}\n"
      rescue Exception => e
        puts e.to_s.red
        puts e.backtrace.join("\n").red
        restart
      end
    end

    def listen
      fifo = Linael::Fifo.instance
      Thread.new do
        while(line = gets)
          fifo.puts msg
        end
      end
    end

  end

  ServerMessage = Struct.new(:server_name, :content)

  class Fifo

    include Singleton

    def initialize 
      @messages = []
    end

    def gets 
      @messages.pop || ServerMessage.new("","")
    end

    def puts msg
      @messages << msg
    end

  end

  class ServerList

    include Enumerable

    attr_accessor :servers

    def initialize
      @servers = []      
      @fifo = Linael::Fifo.instance
    end

    def each
      @servers.each
    end

    def add server, port, name=nil
      name ||= server
      raise Exception, "Allready used name" if servers.detect {|s| s.name == name}
      @servers << Socket.new(server,port,name)
      name
    end

    def connect name
      server_by_name(name).listen
    end

    def remove name
      @servers = @servers.delete_if {|s| s.name == name}
    end

    def [](name)
      raise Exception, "No server." if servers.empty?
      return servers[0] unless name
      result = servers.detect {|s| s.name == name}
      raise Exception, "No server with this name (#{name})." unless result
      result
    end

    alias_method :server_by_name, :[]

    def send_msg(msg)
      server_by_name(msg.server_name).puts(msg.content)
    end

    def get_msg(server_name=nil)
      @fifo.gets
    end

  end

  # mains methods of IRC
  module IRC

    def self.linael_start
      @servers = ServerList.new
      self.connect(Linael::ServerAddress,Linael::Port,Linael::BotNick)
      action = Handler.new(Linael::MasterModule,Linael::ModulesToLoad)
      self.main_loop(action)
    end

    # Send a message in the socket
    def self.send_msg(msg)
      @servers.send_msg msg
    end

    # Connect to a server
    def self.connect(server,port,nick,name=nil)
      name = @servers.add(server,port,name)
      send_msg ServerMessage.new(name,"USER #{nick} 0 * :Linael")
      send_msg ServerMessage.new(name,"NICK #{nick}")
      @servers.connect name
    end

    # Main loop of the irc to keep the prog reading inside the socket
    def self.main_loop(msg_handler)
      while line = @servers.get_msg
        msg_handler.handle_msg(line)
      end
    end

  end

  #different possible action from IRC
  module Action

    attr_accessor :timer

    # Define a irc sending method
    def define_send(name,short)
      self.class.send("define_method",name) do |server,arg|
        msg = "#{short.upcase} "
        [:dest,:who,:what,:args,:msg].each do |key|
          msg += "#{":" if key==:msg}#{arg[key]} " unless arg[key].nil?            
        end
        puts "#{server} >>> #{msg}".blue

        to_send = Linael::ServerMessage.new(server,msg)
        IRC::send_msg to_send
      end      
    end

    # Cover most of  IRC send. 
    # Catch methods ending with _channel
    #   kick_channel #=> a kick
    def method_missing(name, *args, &block)
      if name =~ /(.*)_channel/
        define_send(name,$1)
        p name,args
        return self.send name,args[0],args[1]
      end
      super
    end

    #proxy for sendind a private_message to socket. Just for code readability
    def talk(dest,msg,server=nil)
      $timer ||= 0
      sleep(0.2) until Time.now > $timer
      $timer = Time.now + 0.5
      privmsg_channel(server,{dest: dest, msg: msg})
    end

    #proxy for talk (proxyception) for readability
    def answer(priv_msg,ans)
      return unless privMsg
      if(priv_msg.content.private_message?)
        talk(priv_msg.content.who, ans, priv_msg.server_name)
      else
        talk( priv_msg.content.place, ans,priv_msg.server_name)
      end
    end

  end
end

#It's ugly but you really need to load Action first
require_relative '../lib/messages.rb'
require_relative "../lib/modules.rb"
require_relative '../lib/DSL.rb'
require_relative '../lib/modules/master.rb'
require_relative '../lib/handler.rb'
