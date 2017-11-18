# A module to count ++ on people
linael :karma do
  help [
    t.karma.help.description,
    t.help.helper.line.white,
    t.help.helper.line.functions,
    t.karma.help.function.self,
    t.karma.help.function.karma,
    t.karma.help.function.plus_one,
    t.karma.help.function.minus_one
  ]

  db_hash :karmas

  on :msg, :add_karma, /\S\s*(\+\+|\+1)/ do |msg, options|
    to_karma = options.karma.downcase.delete(":").delete(",")
    karmas[to_karma] ||= 0
    karmas[to_karma] = karmas[to_karma] + 1 unless to_karma == msg.who.downcase
  end

  on :msg, :del_karma, /\S\s*(--|-1)/ do |msg, options|
    to_karma = options.karma.downcase.delete(":").delete(",")
    karmas[to_karma] ||= 0
    karmas[to_karma] = karmas[to_karma] - 1 unless to_karma == msg.who.downcase
  end

  on :cmd, :karma, /^!karma\s/ do |msg, options|
    answer(msg, t.karma.karma(options.who, (karmas[options.who.downcase] || 0)))
  end

  value karma: /(\S*)\s*(\+|-)/
end
