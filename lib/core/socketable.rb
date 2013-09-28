module Linael
  class Socketable
    attr_accessor :server,:port,:name,:on_restart

    def initialize options
      @name = options[:name].to_sym || options[:url]
      @port = options[:port]
      @server = options[:url]
      @socket = socket_klass.open(options[:url],options[:port])
    end

    def restart
      p "RESTARTING #{name}!"
      return if @on_restart
        begin          
          @on_restart = true
          @socket.close
          p "CLOSED!"
          @socket = nil
          sleep 100
          @socket = socket_klass.open(server,port)
          @on_restart = false
        rescue Exception
          retry
        end
    end

    def type
      raise NotImplementedError
    end

    def gets
      begin
        message = @socket.gets unless @on_restart
        return MessageStruct.new(name,message,type) unless @on_restart
      rescue Exception => e
        restart unless @on_restart
      end
      nil
    end

    def puts msg
      begin
        @socket.puts "#{msg}\n" unless @on_restart
      rescue Exception => e
        restart unless @on_restart
      end
    end

    def listen
      fifo = Linael::MessageFifo.instance
      Thread.new do
        while(1)
          line = gets unless @on_restart
          sleep(0.001)
          fifo.puts line if line && line.element
        end
      end
    end

  end
end
