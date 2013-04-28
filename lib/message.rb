# -*- encoding : utf-8 -*-
module Linael

  # Class for main loop of Linael
  class Handler

    include Action

    # A method to handle Ping message
    def handleKeepAlive(msg)
      if Ping.match(msg) then
        msgPing = Ping.new msg
        pong_channel({dest: msgPing.sender})
        return true
      end
      return false
    end

    # A method to handle private messages
    def handlePrivMsg(msg)
      if PrivMessage.match(msg) then
        privmsg = PrivMessage.new msg
        if (privmsg.command?) then
          @cmdAct.values.each {|act| act.call privmsg}
          if (@authAct.values.all? {|auth| auth.call privmsg})
            @cmdAuthAct.values.each {|act| act.call privmsg}
          end
          return true
        end
        @msgAct.values.each {|act| act.call privmsg}
        return true
      end
      return false
    end

    #the differents type of actings
    attr_accessor :msgAct,
      :cmdAct,
      :authAct,
      :cmdAuthAct,
      :modules

    # To get ToDo list
    def self.toDo
      @toDo
    end

    # To get to_handle list
    def self.to_handle
      @to_handle
    end

    @to_handle=[Mode,Nick,Join,Notice,Part,Kick]
    
    @to_handle.each do |klass|
      attr_accessor "#{klass.name.downcase}Act".to_sym
      define_method "handle_#{klass.name.downcase}" do |msg|
        if klass.match(msg) then
          part = klass.new msg
          instance_variable_get("@#{klass.name.downcase}Act").values.each {|act| act.call part}
          return true
        end
        return false
      end
      @toDo = [] if @toDo.nil?
      @toDo << "handle_#{klass.name.downcase}".to_sym
    end

    # Initialize
    def initialize(modules)
      Handler.toDo << :handleKeepAlive << :handlePrivMsg
      Handler.to_handle.each {|klass| instance_variable_set "@#{klass.name.downcase}Act",Hash.new}
      @msgAct=Hash.new
      @cmdAct=Hash.new
      @authAct=Hash.new
      @cmdAuthAct=Hash.new
      @modules=[]
      modules.each {|klass| @modules << klass.new(self)}
      @modules.each {|mod| mod.startMod}
    end

    # Main method
    def handle_msg(msg)
      begin
        Handler.toDo.detect{|m| self.send(m,msg.force_encoding('utf-8').encode('utf-8', :invalid => :replace, 
                                                                        :undef => :replace, :replace => ''))}
      rescue Exception
        puts $!	
      end
    end

  end
end
