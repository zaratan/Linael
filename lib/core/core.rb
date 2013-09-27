module Linael
  module Core

    def self.start_linael
      @handlers= {}
      @sockets= SocketList.new
      yield
      main_loop
    end

    def self.send_message message
      @sockets.send_message(message)
    end

    def self.start_server type,options
      @handlers[type] ||= "Linael::#{type.capitalize}::Handler".constantize
      @sockets.add "Linael::#{type.capitalize}::Socket".constantize,options
    end

    def self.main_loop
      while message = @sockets.gets
        if @handlers[message.type]
          @handlers[message.type].instance.handle message
        end
      end
    end
  end
end
