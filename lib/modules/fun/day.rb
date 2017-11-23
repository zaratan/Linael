linael :day do
  help [
    t.day.help.description
  ]

  # add a day command
  on :cmd, :day, /^!day/ do |msg, _|
    answer(msg, t.module_day.act.day)
  end
end
