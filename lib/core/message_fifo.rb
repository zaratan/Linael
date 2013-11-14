require 'monitor.rb'
require 'singleton'

module Linael

  class Fifo
    def initialize 
      @messages = []
      @messages.extend MonitorMixin
    end

    def gets 
      @messages.shift || :none
    end

    def puts msg
      @messages.push msg
    end

  end

  class MessageFifo < Fifo

    include Singleton

  end
end
