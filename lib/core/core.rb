# -*- encoding : utf-8 -*-

module Linael
  module Core

    def self.start_linael
      @handlers= {}
      @sockets= SocketList.new
      yield if block_given?
      main_loop
    end

    def self.send_message message
      @sockets.send_message(message)
    end

    def self.start_server type,options
      @sockets.add "Linael::#{type.capitalize}::Socket".constantize,options
      unless @handlers[type]
        @handlers[type] = "Linael::#{type.capitalize}::Handler".constantize
        @handlers[type].instance.configure options
      end
    end

    def self.main_loop
      while message = @sockets.gets
        if @handlers[message.type] && message.element
          @handlers[message.type].instance.handle message
        end
      end
    end
  end
end

