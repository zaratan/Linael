# -*- encoding : utf-8 -*-

require('open-uri')
require('htmlentities')

# A module to spoil movies (french)
linael :en_fait_a_la_fin do

  help [
    "Module to spoil movies (french)",
    " ",
    "#####Function#####",
    "!spoil [-t] => Spoil a film. If -t, it will give the title"
  ]

  on :cmd, :spoil, /^!spoil/ do |msg,options|
    if options.who != "" and options.who != options.from_who
      location = "/#{options.who}"
    else
      page_index = open("http://etenfaitalafin.fr").read
      page_index =~ /document\.location = '(.*)'/
      location = $1
    end
    page = open("http://etenfaitalafin.fr#{location}").read
    page =~ /<p>(.*)<\/p>/
    spoil = $1
    page =~ /<title>(.*)\s-\s/
    title = $1
    result = ""
    if options.type == "t"
      result = "#{title} - "
    end
    result += "#{spoil.gsub(/\\"/,"")} (#{location.gsub("/","")})"
    answer(msg,HTMLEntities.new.decode(result))
  end

end
