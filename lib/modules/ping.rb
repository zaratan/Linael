# -*- encoding : utf-8 -*-

linael :ping do

    on :msg, :pong, /^linael..?\s*ping|linael.*je.*aime|linael.*♥|linael.*<3/ do |msg,options|
      answer(msg,"Moi aussi je t'aime #{msg.who}! ♥")
    end

end
