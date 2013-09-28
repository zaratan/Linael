module Linael::Irc
  class Handler < Linael::Handler
   
    @to_handle=[
      Linael::Irc::Mode,
      Linael::Irc::Nick,
      Linael::Irc::Join,
      Linael::Irc::Notice,
      Linael::Irc::Part,
      Linael::Irc::Kick,
      Linael::Irc::Invite,
      Linael::Irc::Quit,
      Linael::Irc::Server,
      Linael::Irc::Ping
    ]
    
    def initialize
      self.class.to_do << :handlePrivMsg
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
      msg.element.force_encoding('utf-8').encode('utf-8', :invalid => :replace, :undef => :replace, :replace => '')
    end
    
    # A method to handle private messages
    def handlePrivMsg(msg)
      if Privmsg.match?(msg.element) 
        msg.element = Privmsg.new msg.element
        pretty_print_message msg
        if (msg.command?) 
          @cmdAct.values.each {|act| act.call msg}
          if (@authAct.values.all? {|auth| auth.call msg})
            @cmdAuthAct.values.each {|act| act.call msg}
          end
        else
          @msgAct.values.each {|act| act.call msg}
        end
        true
      end
    end
    
    private

    # Pretty print messages
    def pretty_print_message msg
      puts "<<< #{msg.element}".colorize( 
        if msg.element.kind_of? Linael::Irc::Server
          :yellow
        else
          :green
        end
      )
    end

  end
end
