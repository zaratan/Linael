# -*- encoding : utf-8 -*-
require 'monitor.rb'
require 'singleton'
require 'json'

module Linael


  class SocketFifo
    def initialize name
      pipe = IO.pipe
      @writter = pipe[1]
      @reader = pipe[0]
      @writter.extend(MonitorMixin)
      @reader.extend(MonitorMixin)
    end

    def gets 
      @reader.synchronize do
        CGI::unescapeHTML(@reader.gets).chomp
      end
    end

    def puts msg
      @writter.synchronize do
        @writter.puts msg
      end
    end

  end

  class MessageFifo < SocketFifo

    include Singleton

    def initialize
      super "messages"
    end

    def gets
      result = JSON.parse(super)
      MessageStruct.new(result["server_id"].to_sym,CGI::unescapeHTML(result["element"]),result["type"].to_sym)
    end

  end
end
