# -*- encoding : utf-8 -*-
linael :griffor do

  help [
    t.griffor.help.description,
    t.help.helper.line.white,
    t.help.helper.line.functions,
    t.griffor.function.show,
    t.griffor.function.add
  ]

  attr_accessor :scores

  on_init do
    @scores = {}
  end

  on :cmd, :griffor, /^!griffor\s/ do |msg,options|
    before(options) do |options|
      options.type != "add"
    end

    if @scores.has_key? options.who
      answer(msg,t.griffor.act.show(options.who, scores[options.who]))
    else
      answer(msg, t.griffor.not.score(options.who))
    end
  end

  on :cmd, :griffor_add, /^!griffor\s-add\s/ do |msg,options|

    @scores[options.from_who] = options.score
    answer(msg, t.griffor.act.add(options.from_who,options.score))
  end

  value :score => /^!griffor\s+-add\s+(-?\d+)/
  
  on :cmd, :griffor_top, /^!griffor\s-top\s/ do |msg,options|
    @scores.sort_by {|_, val| val}
    line = @scores.first(5).each.map {|a| a[0].to_s +" => " + a[1].to_s }.join(", ")   
    answer(msg, line)
  end
end
           
