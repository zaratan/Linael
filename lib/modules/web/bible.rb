# -*- encoding : utf-8 -*-

# Looks up on kingjamesbibleonline.org the verse passed in argument.

require 'open-uri'
require 'nokogiri'

linael :bible, author: "Zag" do

  help [
    t.bible.help.description,
    t.bible.help.source,
    t.help.helper.line.white,
    t.help.helper.line.functions,
    t.bible.help.function.bible
  ]

  def generate_link(options)
    str = "http://www.kingjamesbibleonline.org/"
    unless options.booknum.blank?
      str += options.booknum + '-'
    end
    str += options.book + '-' + options.chapter + '-' + options.verse
  end

  def get_text(options)
    p link = generate_link(options)
    html = Nokogiri::HTML(open(link))
    html.css('h2').last.text
  end

  on :cmd, :bible, /^!bible\s*[^-]/ do |msg,options|
    text = get_text(options)
    answer(msg, text)
  end

  def get_books
    url = "http://www.kingjamesbibleonline.org/"
    page = Nokogiri::HTML(open(url))
    page.css('.c1 a').map {|e| e.text}.each_slice(10).to_a.map{|e| e.join(", ")}
  end

  def split_books
    
  end
  
  on :cmd, :bible_book, /^!bible\s*-book/ do |msg,options|
    get_books.each do |books|
      answer(msg, "[#{books}]")
    end
  end

  value	booknum: /!bible\s*(\d+)/,
    book:    /!bible\s*\d?\s*(\S*)/,
    chapter: /!bible\s*\d?\s*\S*\s*(\d*)/,
    verse:   /!bible\s*\d?\s*\S*\s*\d*\s*(\d*)/
end
