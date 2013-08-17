# -*- encoding : utf-8 -*-
module Linael

  # Class for main loop of Linael
  class Handler

    include Action

    # A method to handle Ping message
    def handleKeepAlive(msg)
      if Ping.match?(msg) then
        ping_msg = Ping.new msg
        pong_channel({dest: ping_msg.sender})
        @pingAct.values.all?{|act| act.call ping_msg} 
        return true
      end
      return false
    end

    # A method to handle private messages
    def handlePrivMsg(msg)
      if PrivMessage.match?(msg) then
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
      :pingAct,
      :authAct,
      :cmdAuthAct,
      :master

    # To get ToDo list
    def self.toDo
      @toDo
    end

    # To get to_handle list
    def self.to_handle
      @to_handle
    end

    @to_handle=[Mode,Nick,Join,Notice,Part,Kick,Invite,Quit,Server]
    
    @to_handle.each do |klass|
      klass_name = klass.name.gsub(/.*:/,"").downcase
      attr_accessor "#{klass_name}Act".to_sym
      define_method "handle_#{klass_name}" do |msg|
        if klass.match?(msg) then
          part = klass.new msg
          instance_variable_get("@#{klass_name}Act").values.each {|act| act.call part}
          return true
        end
        return false
      end
      @toDo = [] if @toDo.nil?
      @toDo << "handle_#{klass_name}".to_sym
    end

    # Initialize
    def initialize(master_module,modules)
      Handler.toDo << :handleKeepAlive << :handlePrivMsg
      Handler.to_handle.each {|klass| instance_variable_set "@#{klass.name.gsub(/.*:/,"").downcase}Act",Hash.new}
      @msgAct=Hash.new
      @cmdAct=Hash.new
      @authAct=Hash.new
      @pingAct=Hash.new
      @cmdAuthAct=Hash.new
      @master = master_module.new(self)
      @master.startMod
      modules.each {|modName| @master.modules.add(modName)}
    end

    # Main method where we dispatch message over the != modules
    def handle_msg(msg)
      begin
        Handler.toDo.detect{|m| self.send(m,msg.force_encoding('utf-8').encode('utf-8', :invalid => :replace, :undef => :replace, :replace => ''))}
      rescue Exception
        puts $!	
      end
    end

  end
end
