# -*- encoding : utf-8 -*-

# Looks up on kingjamesbibleonline.org the verse passed in argument.

require 'open-uri'
require 'nokogiri'

linael :bible do

  def generate_link(booknum, book, chapter, verse)
    str = "http://www.kingjamesbibleonline.org/"
	puts(booknum, book, chapter, verse)
	if booknum.nil?
		str += booknum + '-'
	end
	str += book 
	str += '-' + chapter + '-' + verse
  end

  def get_text(booknum, book, chapter, verse)
    link = generate_link(booknum, book, chapter, verse)
    html = Nokogiri::HTML(open(link))
    html.css('h2')[1].text
  end

  on :cmd, :bible, /^!bible\s/ do |msg,options|
    text = get_text(options.booknum, options.book, options.chapter, options.verse)
    answer(msg, text)
  end

  value	:booknum	=> /!bible\s*(\d?)/,
		:book		=> /!bible\s*\d?\s*(\S*)/,
		:chapter	=> /!bible\s*\d?\s*\S*\s*(\d*)/,
		:verse		=> /!bible\s*\d?\s*\S*\s*\d*\s*(\d*)/
end
