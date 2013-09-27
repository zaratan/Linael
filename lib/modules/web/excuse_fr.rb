# -*- encoding : utf-8 -*-

require('open-uri')
require('htmlentities')

# A module to get dev excuses (french)
linael :excuse_fr do

  help [
    t.excuse.help.description,
    t.excuse.help.source,
    t.help.helper.line.white,
    t.help.helper.line.functions,
    t.excuse.help.function.excuse
  ]

  on :cmd, :excuse, /^!excuse/ do |msg,options|
    page = open("http://www.excusesdedev.com/").read
    page =~ /div[^>]*quote[^>]*>([^<]*)/
    excuse = $1
    answer(msg,excuse)
  end

end
