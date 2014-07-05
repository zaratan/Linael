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
      options.type != "add" && options.type != "max" && options.type != "min"
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
  
  on :cmd, :griffor_max, /^!griffor\s-max\s/ do |msg,options|
    s = sorted.first(10).map{|person| "#{person[0]} => #{person[1]}" }.join("; ")
    answer(msg, s)
  end

  on :cmd, :griffor_min, /^!griffor\s-min\s/ do |msg,options|
    s = sorted.last(10).map{|person| "#{person[0]} => #{person[1]}" }.join("; ")
    answer(msg, s)
  end

  def sorted
    @scores.sort_by {|k,v| v.to_i}.reverse
  end
end
           
