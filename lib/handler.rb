# -*- encoding : utf-8 -*-
module Linael

  # Class for main loop of Linael
  class Handler
    attr_accessor :msgAct,
      :cmdAct,
      :authAct,
      :cmdAuthAct,
      :master

    # A method to handle private messages
    def handlePrivMsg(msg)
      if Privmsg.match?(msg) 
        privmsg = Privmsg.new msg
        pretty_print_message privmsg
        if (privmsg.command?) 
          @cmdAct.values.each {|act| act.call privmsg}
          if (@authAct.values.all? {|auth| auth.call privmsg})
            @cmdAuthAct.values.each {|act| act.call privmsg}
          end
        else
          @msgAct.values.each {|act| act.call privmsg}
        end
        true
      end
    end

    @to_handle=[Mode,Nick,Join,Notice,Part,Kick,Invite,Quit,Server,Ping]
    
    # To get ToDo list
    def self.toDo
      @toDo
    end
    
    # To get to_handle list
    def self.to_handle
      @to_handle
    end
    
    def self.add_act (klass)
      klass_name = klass.name.gsub(/.*:/,"").downcase
      attr_accessor "#{klass_name}Act".to_sym
      define_method "handle_#{klass_name}" do |msg|
        if klass.match?(msg)
          parsed_message = klass.new msg
          pretty_print_message parsed_message
          instance_variable_get("@#{klass_name}Act").values.each {|act| act.call parsed_message}
          true
        end
      end
      @toDo = [] if @toDo.nil?
      @toDo << "handle_#{klass_name}".to_sym
    end

    @to_handle.each {|handle| add_act(handle)}
    

    def handle_msg(msg)
      begin
        Handler.toDo.detect{|m| self.send(m,msg.force_encoding('utf-8').encode('utf-8', :invalid => :replace, :undef => :replace, :replace => ''))}
      rescue Exception
        puts $!.to_s.red	
      end
    end
    
    # Initialize
    def initialize(master_module,modules)
      Handler.toDo << :handlePrivMsg
      Handler.to_handle.each {|klass| instance_variable_set "@#{klass.name.gsub(/.*:/,"").downcase}Act",Hash.new}
      @msgAct=Hash.new
      @cmdAct=Hash.new
      @authAct=Hash.new
      @cmdAuthAct=Hash.new
      @master = master_module.new(self)
      @master.startMod
      modules.each {|modName| @master.modules.add(modName)}
    end
    
    private

    # Pretty print messages
    def pretty_print_message msg
      puts "<<< #{msg}".colorize( 
        if msg.kind_of? Linael::Server
          :yellow
        else
          :green
        end
      )
    end

  end
end
