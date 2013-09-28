
module Linael
  class SocketList

    include Enumerable

    attr_accessor :sockets

    def initialize
      @sockets = []      
      @fifo = MessageFifo.instance
    end

    def each
      @sockets.each
    end

    def add klass, options
      options[:name] ||= options[:url] + options[:port].to_s
      raise Exception, "Already used name" if sockets.detect {|s| s.name == options[:name]}
      sockets << klass.new(options)
      options[:name]
    end

    def connect name
      server_by_name(name).listen
    end

    def remove name
      @sockets = @sockets.delete_if {|s| s.name == name}
    end

    def [](name)
      raise Exception, "No server." if sockets.empty?
      return sockets[0] unless name
      result = sockets.detect {|s| s.name == name}
      raise Exception, "No server with this name (#{name})." unless result
      result
    end

    alias_method :server_by_name, :[]

    def send_message(msg)
      server_by_name(msg.server_id).puts(msg.element)
    end

    def gets
      sleep(0.001)
      @fifo.gets
    end

  end
end
