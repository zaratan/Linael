
# -*- encoding : utf-8 -*-

#A module for rejoin
linael :rejoin, require_auth: true do

  help=[
    "Auto-rejoin module",
    "!start to start it"
    ]

  on_init do
    @started=false
    @chan_to_rejoin=[]
  end


  define_method "rejoin_all" do 
    @chan_to_rejoin.each do |chan|
      join_channel :dest => chan
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
    @chan_to_rejoin << msg.place
  end

  on :join, :do_i_join? do |msg|
    before(msg) do |msg|
      msg.who.downcase == Linael::BotNick.downcase
    end
    @chan_to_rejoin.delete(msg.where)
  end

end
