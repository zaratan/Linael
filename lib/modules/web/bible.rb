# -*- encoding : utf-8 -*-

# Looks up on kingjamesbibleonline.org the verse passed in argument.

require 'open-uri'
require 'nokogiri'

linael :bible do

  def generate_link(options)
    str = "http://www.kingjamesbibleonline.org/"
	if options.booknum.nil?
		str += options.booknum + '-'
	end
	str += options.book 
	str += '-' + options.chapter + '-' + options.verse
  end

  def get_text(options)
    link = generate_link(options)
    html = Nokogiri::HTML(open(link))
    html.css('h2')[1].text
  end

  on :cmd, :bible, /^!bible\s/ do |msg,options|
    text = get_text(options)
    answer(msg, text)
  end

  value	booknum: /!bible\s*(\d?)/,
        book:    /!bible\s*\d?\s*(\S*)/,
        chapter: /!bible\s*\d?\s*\S*\s*(\d*)/,
        verse:   /!bible\s*\d?\s*\S*\s*\d*\s*(\d*)/
end
