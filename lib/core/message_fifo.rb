require 'monitor.rb'
require 'singleton'

module Linael
  class MessageFifo

    include Singleton

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
end
