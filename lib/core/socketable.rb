module Linael
  class Socketable
    attr_accessor :server,:port,:name

    def initialize server,port,name=nil
      @name = name || server
      @port = port
      @server = server
      @socket = socket_klass.open(server,port)
    end

    def restart
      sleep 300
      @socket = socket_class.open(server,port)
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
end
