# -*- encoding : utf-8 -*-

#A module to auto-kick on marvin's roulette
linael :roulette do

  help [
    "Auto kick people who lose on roulette",
    "This module need marvin bot to work"
  ]

  on :msg, :kick_on_lose, /:\schamber.*6.*BANG/ do |msg,options|
    before(msg) do |msg|
      msg.who == "marvin"
    end
    kick_channel(msg.place,options.who_lose,"YOU LOSE!")	
  end

  value who_lose: /^(\S*):\s/
end

