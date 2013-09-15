linael :auto_rejoin do

  on :kick, :auto_rejoin do |msg|
    before(msg) do |msg|
      msg.who.downcase == Linael::BotNick.downcase
    end
    join_channel dest: msg.place

  end

end
