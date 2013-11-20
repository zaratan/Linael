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

    end

    def gets 
      @reader.gets #.chomp.force_encoding("UTF-8")
    end

    def puts msg      
      @writter.puts msg
      #@writter.flush
    end

  end

  class MessageFifo < SocketFifo

    include Singleton

    def initialize
      super "messages"
    end

    def gets
      result = JSON.parse(super)
      MessageStruct.new(result["server_id"].to_sym,result["element"],result["type"].to_sym)
    end

  end
end
