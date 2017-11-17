linael :auto_rejoin do
  help [
    t.autorejoin.help.description
  ]

  on :kick, :auto_rejoin do |msg|
    before(msg) do |msg|
      msg.who.casecmp(Linael::BotNick.downcase).zero?
    end
    join_channel msg.server_id, dest: msg.place
  end
end
