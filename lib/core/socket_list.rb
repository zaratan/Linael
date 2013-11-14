
module Linael
  class SocketList

    include Enumerable

    attr_accessor :sockets

    def initialize
      @sockets = []      
      @fifo = MessageFifo.instance
    end

    def each
      @sockets.each {|s| yield s}
    end

    def add klass, options={}
      options[:name] ||= "#{options[:url]}:#{options[:port]}"
      raise Exception, "Already used name" if sockets.detect {|s| s.name == options[:name]}
      sockets << klass.new(options)
      options[:name]
    end

    def connect name
      socket_by_name(name).listen
    end

    def remove name
      sock = socket_by_name(name)
      sock.stop_listen
      sock.close
      @sockets = @sockets.delete_if {|s| s.name == name}
    end

    def [](name=nil)
      raise Exception, "No socket." if sockets.empty?
      return sockets[0] unless name
      result = sockets.detect {|s| s.name == name}
      raise Exception, "No socket with this name (#{name})." unless result
      result
    end

    alias_method :socket_by_name, :[]

    def send_message(msg)
      socket_by_name(msg.server_id).write(msg.element)
    end

    def gets
      @fifo.gets
    end

  end
end
