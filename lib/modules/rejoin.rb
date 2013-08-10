
# -*- encoding : utf-8 -*-

#A module for rejoin
linael :rejoin, require_auth: true do

  help []

  on_init do
    @chan_to_rejoin=[]
  end

  define_method "rejoin_all" do 
    @chan_to_rejoin.each do |chan|
      join_channel :dest => chan
    end
  end

  on :cmdAuth, :launch, /^!auto_rejoin/ do |msg,options|
    rejoin_all
    at 1.minutes.from_now do
      launch(msg)
    end
  end

  on :kick, :do_they_kick_me? do |msg|
    before(msg) do |msg| 
      msg.who.downcase == Linael::Nick.downcase 
    end
    @chan_to_rejoin << msg.place
  end

  on :join, :do_i_join? do |msg|
    before(msg) do |msg|
      msg.who.downcase == Linael::Nick.downcase
    end
    @chan_to_rejoin.delete(msg.where)
  end

end
