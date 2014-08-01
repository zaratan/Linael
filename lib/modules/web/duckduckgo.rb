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

  def print_search (msg,options,clazz)
    ddg = clazz.new
    zci = ddg.zeroclickinfo(options.all)
    # Type may be A (article), D (disambiguation), C (category),
    # N (name), E (exclusive), or empty
    # see https://api.duckduckgo.com/api
    case zci.type
    when 'A'
        answer(msg,"#{options.from_who}: [#{zci.heading}] >> #{zci.abstract}")
    when 'C'
        ans = ""
        zci.related_topics['_'].each do |r|
            ans += r.text.gsub(/(.*)? - .*/, "#{$1} - ")
        end
        answer(msg,"#{options.from_who}: #{ans}")
    when 'D'
        ans = ""
        zci.related_topics.each do |topic|
            topic.each do |r|
                if r.class == String
                    ans += " [#{r}]"
                else
                    r.each do |t|
                        ans += " - #{t.text}"
                    end
                end
            end
        end
        answer(msg,"#{options.from_who}: #{ans}")
    when 'E'
        answer(msg,"#{options.from_who}: #{zci.answer ? zci.answer : zci.redirect}")
    else
        answer(msg,"#{options.from_who}: #{zci.answer}")
    end
  end

  on :cmd, :duckduckgo_search, /^!ddg\s/ do |msg,options|
    print_search(msg,options,DuckDuckGo)
  end

end
