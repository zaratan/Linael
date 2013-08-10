# -*- encoding : utf-8 -*-

require 'google-search'


linael :google do

  help [
    "A module to make google and youtube search",
    " ",
    "!g xxx  => make a google research",
    "!yt xxx => make a youtube research"
    ]

  define_method "print_search" do |msg,options,clazz|
    result = clazz.new(:query => options.all).first
    answer(msg,"#{options.from_who}: #{result.title.gsub(/<[^>]*>/,"").gsub(/\s\s+/," ")} ( #{result.uri} )")
    answer(msg, result.content.gsub(/<[^>]*>/,"").gsub(/\s\s+/," "))
  end

  on :cmd, :google_search, /^!g\s/ do |msg,options|
    print_search(msg,options,Google::Search::Web)
  end

  on :cmd, :youtube_search, /^!yt\s/ do |msg,options|
    print_search(msg,options,Google::Search::Video)
  end

  on :cmd, :img_search, /^!img\s/ do |msg,options|
    print_search(msg,options,Google::Search::Image)
  end

end
