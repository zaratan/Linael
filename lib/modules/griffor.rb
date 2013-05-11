linael :griffor do

  help [
    "A module to track griffor test scores",
    " ",
    "#####Functions#####",
    "!griffor name => score of name",
    "!griffor -add score => update your score"
  ]

  on_init do
    @scores = {}
  end

  on :cmd, :griffor, /^!griffor\s/ do |msg,options|
    before(options) do |options|
      options.type != "add"
    end

    if @scores.has_key? options.who
      answer(msg,"#{options.who}: #{@scores[options.who]}")
    else
      answer(msg,"No score for #{options.who}. Do the test on http://test.griffor.com")
    end
  end

  on :cmd, :griffor_add, /^!griffor\s-add\s/ do |msg,options|
    before(options) do |options|
      options.who =~ /^\d*$/
    end

    @scores[options.from_who] = options.who
    answer(msg,"#{options.from_who}: Your score is now: #{options.who}")
  end
end
           
