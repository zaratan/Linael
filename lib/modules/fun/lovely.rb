# -*- encoding : utf-8 -*-

linael :lovely do

    on :msg, :love, /^#{Linael::BotNick}.*je.*aime|#{Linael::BotNick}.*♥|#{Linael::BotNick}.*<3/ do |msg,options|
      answer(msg,"Moi aussi je t'aime #{msg.who}! ♥")
    end

end
