# -*- encoding : utf-8 -*-
require 'duck_duck_go'
linael :duckduckgo do

  help [
    t.duckduckgo.help.description,
    t.duckduckgo.help.source,
    t.help.helper.line.white,
    t.help.helper.line.functions,
    t.duckduckgo.help.function.duckduckgo,
  ]

  def print_search (msg,options)
    zci = DuckDuckGo.new.zeroclickinfo(options.all)
    # Type may be A (article), D (disambiguation), C (category),
    # N (name), E (exclusive), or empty
    # see https://api.duckduckgo.com/api

    if zci.answer
        answer(msg,"#{options.from_who}: #{zci.answer.gsub(/.*\n/,"").gsub(/<(.*?)>/, "")}")
    elsif zci.type
        begin
          send("answer_to_#{zci.type}",zci,msg,options)
        rescue NoMethodError
        end
    end
  end

  on :cmd, :duckduckgo_search, /^!ddg\s/ do |msg,options|
    print_search(msg,options)
  end

  private

  def answer_to_A(zci, msg, options)
    answer(msg,"#{options.from_who}: [#{zci.heading}] >> #{zci.abstract}")
  end

  def answer_to_C(zci, msg, options)
    ans = ""
    zci.related_topics['_'].each do |r|
      ans += r.text.gsub(/(.*)? - .*/, "#{$1} - ")
    end
    answer(msg,"#{options.from_who}: #{ans}")
  end

  def answer_to_D(zci, msg, options)
    ans = ""
    zci.related_topics.each do |topic|
      topic.each do |r|
        if r.class == String
          ans += " [#{r}]"
        else
          r.each {|t| ans += " - #{t.text}"}
        end
      end
    end
    answer(msg,"#{options.from_who}: #{ans}")
  end

  def answer_to_E(zci, msg, options)
    # We should arrive here only for redirect links via !bang syntax.
    # For other exclusives we just print zci.answer.
    answer(msg,"#{options.from_who}: #{zci.redirect.to_s}")
  end

end
