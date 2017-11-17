# A module to auto-kick on marvin's roulette
linael :roulette do
  help [
    t.roulette.help.description.a,
    t.roulette.help.description.b
  ]

  on :msg, :kick_on_lose, /:\schamber.*6.*BANG/ do |msg, options|
    before(msg) do |msg|
      msg.who == "marvin"
    end
    kick_channel(msg.server_id, msg.place, options.who_lose, t.roulette.act.kick)
  end

  value who_lose: /^(\S*):\s/
end
