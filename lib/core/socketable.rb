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
      return if @on_restart
      begin          
        on_restart = true
        @socket.close
        @socket = nil
        sleep 300
        @socket = socket_klass.open(server,port)
        on_restart = false
      rescue Exception
        retry
      end
    end

    def type
      raise NotImplementedError
    end

    def socket_klass
      raise NotImplementedError
    end

    def gets
      begin
        unless @on_restart
          message = @socket.gets
          return MessageStruct.new(name,message,type)
        end
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

    def close
      @socket.close
    end

    def stop_listen
      @thread.kill
    end



    def listen
      fifo = Linael::MessageFifo.instance
      @thread = Thread.new do
        while(1)
          listening fifo
        end
      end
    end

    private 

    def listening fifo
      line = gets unless @on_restart
      sleep(0.001)
      fifo.puts line if line && line.element
    end

  end
end
