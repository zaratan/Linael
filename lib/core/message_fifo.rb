require 'message_fifo.rb'
module Linael
  class MessageFifo

    include Singleton

    def initialize 
      @messages = []
    end

    def gets 
      @messages.pop || MessageStruct.new("","",:none)
    end

    def puts msg
      @messages << msg
    end

  end
end
