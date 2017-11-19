
# -*- encoding : utf-8 -*-

# A module for rejoin
linael :rejoin, require_auth: true do
  help = [
    t.rejoin.help.description,
    t.help.helper.line.white,
    t.help.helper.line.admin,
    t.rejoin.help.function.start
  ]

  db_list :chan_to_rejoin

  on_init do
    at(15.seconds.from_now) do
      rejoin_all
    end
  end

  def rejoin_all
    chan_to_rejoin.each do |server, chan|
      join_channel server, dest: chan
    end
    at 1.minute.from_now do
      rejoin_all
    end
  end

  on :kick, :do_they_kick_me? do |msg|
    before(msg) do |msg|
      msg.target.casecmp(Linael::BotNick.downcase).zero?
    end
    chan_to_rejoin << [msg.server_id, msg.place]
  end

  on :join, :do_i_join? do |msg|
    before(msg) do |msg|
      msg.who.casecmp(Linael::BotNick.downcase).zero?
    end
    chan_to_rejoin.delete([msg.server_id, msg.where])
  end
end
