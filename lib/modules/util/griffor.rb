linael :griffor do
  help [
    t.griffor.help.description,
    t.help.helper.line.white,
    t.help.helper.line.functions,
    t.griffor.function.show,
    t.griffor.function.add
  ]

  db_hash :scores

  on :cmd, :griffor, /^!griffor\s/ do |msg, options|
    before(options) do |before_options|
      before_options.type != "add"
    end

    if scores.key? options.who
      answer(msg, t.griffor.act.show(options.who, scores[options.who]))
    else
      answer(msg, t.griffor.not.score(options.who))
    end
  end

  on :cmd, :griffor_add, /^!griffor\s-add\s/ do |msg, options|
    before(options) do |before_options|
      before_options.who =~ /^\d*$/
    end

    scores[options.from_who] = options.who
    answer(msg, t.griffor.act.add(options.from_who, options.who))
  end
end
