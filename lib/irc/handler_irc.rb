module Linael::Irc
  class Handler < Linael::Handler
   
    @to_handle=[Mode,Nick,Join,Notice,Part,Kick,Invite,Quit,Server,Ping]
    
    def initialize(master_module,modules)
      self.to_do << :handlePrivMsg
      @msgAct=Hash.new
      @cmdAct=Hash.new
      @authAct=Hash.new
      @cmdAuthAct=Hash.new
      super
    end
    
    attr_accessor :msgAct,
      :cmdAct,
      :authAct,
      :cmdAuthAct,
      :master

    def format_message msg
      msg.force_encoding('utf-8').encode('utf-8', :invalid => :replace, :undef => :replace, :replace => '')
    end
    
    # A method to handle private messages
    def handlePrivMsg(msg)
      if Privmsg.match?(msg) 
        privmsg.element = Privmsg.new msg.element
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
