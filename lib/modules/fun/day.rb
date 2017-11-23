linael :day do
  help [
    t.day.help.description
  ]

  # add a tell
  on :cmd, :day, /^!day/ do |msg, options|
    answer(msg, t.day.act.day)
  end
end
