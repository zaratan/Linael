require 'monitor.rb'

module Linael
  class MessageFifo

    include Singleton

    def initialize 
      @messages = []
      @messages.extend MonitorMixin
    end

    def gets 
      @messages.pop || :none
    end

    def puts msg
      @messages << msg
    end

  end
end
