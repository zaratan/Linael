module Linael::Irc
  class Socket < Linael::Socketable
    def socket_klass 
      TCPSocket
    end

    def initialize options

      super
      @nick = options[:nick]
      ident options[:nick]
      listen

    end

    def restart
      super
      ident @nick
    end

    def ident nick
      puts "USER #{nick} 0 * :Linael"
      puts "NICK #{nick}"
    end

    def type
      :irc
    end
  end
end
