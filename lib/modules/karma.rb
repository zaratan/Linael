# -*- encoding : utf-8 -*-

#A module to count ++ on people
linael :karma do

  help [
    "A module to count ++ on people",
    " ",
    "=====Functions=====",
    "!karma              => show your karma",
    "!karma XXX          => show the karma of XXX",
    "!karma_list [regex] => private answer for karma matching regex",
    "XXX +1 or XXX ++    => add 1 to XXX karma",
    "XXX -1 or XXX --    => del 1 to XXX karma",
    " ",
    "=====Options=====",
    "!karma_list regex   => an irc regex * for a wildcard"
  ]

  on_init do
    @karma = Hash.new(0)
  end

  on_load do
    @karma.default = 0
  end

  on :msg, :add_karma, /\S\s*(\+\+|\+1)/ do |msg,options|
    to_karma = options.karma.downcase.gsub(":","").gsub(",","")
    @karma[to_karma] = @karma[to_karma] + 1 unless to_karma == msg.who.downcase
  end

  on :msg, :del_karma, /\S\s*(--|-1)/ do |msg,options|
    to_karma = options.karma.downcase.gsub(":","").gsub(",","")
    @karma[to_karma] = @karma[to_karma] - 1 unless to_karma == msg.who.downcase
  end

  on :cmd, :karma, /^!karma\s/ do |msg,options|
    answer(privMsg,"Karma for #{options.who} is : #{@karma[options.who.downcase]}!")
  end

  on :cmd, :karma_list, /^!karma_list\s/ do |msg,options|
    @karma.each do |key,value|
      talk(msg.who, "Karma for #{key}: #{value}") if  options.regex == "" || key.match("^#{options.regex.downcase.gsub("*",".*")}$")
    end
  end

  value :karma      => /(\S*)\s*(\+|-)/,
        :regex      => /^!karma_list\s([A-z\*]*)/

end
