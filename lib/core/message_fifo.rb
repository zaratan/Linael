require 'monitor.rb'
require 'singleton'
require 'json'

module Linael

  require 'fifo'

  class SocketFifo
    def initialize name
      @writter = Fifo.new("sockets/#{name}.socks", :w, :nowait)
      @reader = Fifo.new("sockets/#{name}.socks", :r, :wait) 
      @writter.extend(MonitorMixin)
      @reader.extend(MonitorMixin)
    end

    def gets 
      @reader.synchronize do
        @reader.gets.chomp
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
      result = JSON.parse(super.chomp)
      MessageStruct.new(result["server_id"].to_sym,result["element"],result["type"].to_sym)
    end

  end
end
