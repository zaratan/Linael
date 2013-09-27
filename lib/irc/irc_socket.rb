module Linael::Irc
  class Socket << Socketable
    def socket_klass 
      TCPSocket
    end
  end
end
