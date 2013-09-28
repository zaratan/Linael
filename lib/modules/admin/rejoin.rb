
# -*- encoding : utf-8 -*-

#A module for rejoin
linael :rejoin, require_auth: true do

  help=[
    t.rejoin.help.description,
    t.help.helper.line.white,
    t.help.helper.line.admin,
    t.rejoin.help.function.start
    ]

  on_init do
    @started=false
    @chan_to_rejoin=[]
  end


  def rejoin_all 
    @chan_to_rejoin.each do |server,chan|
      join_channel server, :dest => chan
    end
    at 1.minute.from_now do
      rejoin_all
    end
  end

  on :cmdAuth, :launch, /^!start/ do |msg,options|
    before(@started) {|start| !start}
    @started = true
    rejoin_all
  end

  on :kick, :do_they_kick_me? do |msg|
    before(msg) do |msg| 
      msg.who.downcase == Linael::BotNick.downcase 
    end
    @chan_to_rejoin << [msg.server_id,msg.place]
  end

  on :join, :do_i_join? do |msg|
    before(msg) do |msg|
      msg.who.downcase == Linael::BotNick.downcase
    end
    @chan_to_rejoin.delete([msg.server_id,msg.where])
  end

end
