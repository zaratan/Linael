# -*- encoding : utf-8 -*-

linael :lovely do

  help [
    t.lovely.help.description
  ]

  on :msg, :love, /#{Linael::BotNick.downcase}.*(je.*aime|♥|<3)/ do |msg,options|
    tim = Time.now
    answer(msg, t.lovely.act.love(options.from_who))
  end

end
