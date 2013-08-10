# -*- encoding : utf-8 -*-

require('open-uri')
require('htmlentities')

# A module to spoil movies (french)
linael :excuse_fr do

  help [
    "Module for dev excuse (french)",
    " ",
    "#####Function#####",
    "!excuse => Give an excuse"
  ]

  on :cmd, :excuse, /^!excuse/ do |msg,options|
    page = open("http://www.excusesdedev.com/").read
    page =~ /div[^>]*quote[^>]*>([^<]*)/
    excuse = $1
    answer(msg,excuse)
  end

end
