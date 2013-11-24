# -*- encoding : utf-8 -*-
linael :auto_rejoin do

  help [
    t.autorejoin.help.description
  ]

  on :kick, :auto_rejoin do |msg|
    before(msg) do |msg|
      msg.who.downcase == Linael::BotNick.downcase
    end
    join_channel msg.server_id, dest: msg.place

  end

end
