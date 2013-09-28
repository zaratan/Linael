require 'active_support/inflector'
require 'active_support/core_ext/numeric/time'
require 'socket'
require 'colorize'
require 'r18n-desktop'

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
        sleep(0.001)
        if message != :none && @handlers[message.type] && message.element
          @handlers[message.type].instance.handle message
        end
      end
    end
  end
end

require_relative 'message_struct'
require_relative 'message_fifo.rb'
require_relative 'socket_list'
require_relative 'handler_list'
require_relative 'socketable'
require_relative 'handler'
require_relative '../messages.rb'
require_relative '../irc/irc_handler.rb'
require_relative '../irc/irc_socket.rb'
require_relative '../irc/irc_act.rb'

require_relative '../modules.rb'
require_relative '../DSL.rb'
require_relative '../modules/master.rb'
