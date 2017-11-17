module Linael::Irc
  module Action
    attr_accessor :timer

    # Define a irc sending method
    def define_send(name, short)
      self.class.send("define_method", name) do |server, arg|
        msg = "#{short.upcase} "
        %i[dest who what args msg].each do |key|
          msg += "#{':' if key == :msg}#{arg[key]} " unless arg[key].nil?
        end
        puts "#{server} >>> #{msg}".blue
        to_send = Linael::MessageStruct.new(server, msg, :irc)
        Linael::Core.send_message to_send
      end
    end

    # Cover most of  IRC send.
    # Catch methods ending with _channel
    #   kick_channel #=> a kick
    def method_missing(name, *args, &block)
      if name =~ /(.*)_channel/
        define_send(name, $1)
        return send name, args[0], args[1]
      end
      super
    end

    # proxy for sendind a private_message to socket. Just for code readability
    def talk(dest, msg, server = nil)
      privmsg_channel(server, dest: dest, msg: msg)
    end

    # proxy for talk (proxyception) for readability
    def answer(priv_msg, ans)
      return unless priv_msg
      if priv_msg.private_message?
        talk(priv_msg.who, ans, priv_msg.server_id)
      else
        talk( priv_msg.place, ans, priv_msg.server_id)
      end
    end
  end
end
