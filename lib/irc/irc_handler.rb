module Linael::Irc
  class Handler < Linael::Handler
    @to_handle = [
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
      self.class.to_do << :handle_privmsg
      @msg_act = {}
      @cmd_act = {}
      @auth_act = {}
      @cmd_auth_act = {}
      super
    end

    attr_accessor :msg_act,
                  :cmd_act,
                  :auth_act,
                  :cmd_auth_act,
                  :master

    def format_message(msg)
      msg.element.force_encoding('utf-8').encode('utf-8', invalid: :replace, undef: :replace, replace: '')
    end

    # A method to handle private messages
    def handle_privmsg(msg)
      if Privmsg.match?(msg.element)
        msg.element = Privmsg.new msg.element
        pretty_print_message msg
        if msg.command?
          @cmd_act.values.each { |act| act.call msg }
          if @auth_act.values.all? { |auth| auth.call msg }
            @cmd_auth_act.values.each { |act| act.call msg }
          end
        else
          @msg_act.values.each { |act| act.call msg }
        end
        true
      end
    end

    private

    # Pretty print messages
    def pretty_print_message(msg)
      puts "<<< #{msg.element}".colorize(
        if msg.element.is_a? Linael::Irc::Server
          :yellow
        else
          :green
        end
      )
    end
  end
end
