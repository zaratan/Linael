# -*- encoding : utf-8 -*-

require 'open-uri'
require 'hpricot'
require 'htmlentities'
require 'net/http'

#A module to generate names
linael :name do

  help [
    t.name.help.description,
    t.name.help.source,
    t.help.helper.line.white,
    t.help.helper.line.functions,
    t.name.help.function.name,
    t.name.help.function.type,
    t.name.help.function.info,
    t.help.helper.line.white,
    t.help.helper.line.options,
    t.name.help.option.name.full,
    t.name.help.option.name.gender,
    t.name.help.option.name.size,
    t.name.help.option.name.number,
    t.name.help.option.name.type
  ]

  def generate_url(size,gender,types)
      url="http://www.behindthename.com/random/random.php?"
      url+="number=#{size}"
      url+="&"
      url+="gender=#{gender}"
      types.each do |type|
        url+="&usage_#{type}=1"
      end
      url
  end

  def parse_name(page)
    coder = HTMLEntities.new
      name = (page/"div.body span.heavybig a")
      if name.empty?
        name = (page/"div.body span") 
      end
      name = name.inject("") {|str, nam| str += " #{coder.decode(nam.inner_html)}"}
  end

  #generate a name
  on :cmd, :get_names, /^!name\s/ do |msg,options|
    before(options) do |options|
      !options.types? and !options.info?
    end

    url=generate_url(options.size,options.gender,types(options))

    time(options).times do |i|
      name = parse_name(Hpricot(open(url)))
      answer(msg,"#{i+1} - #{name}")
    end
  end


  def generate_url_info who
    uri = URI('http://www.behindthename.com/names/search.php')
    redirect = Net::HTTP.post_form(uri, 'terms' => who)
    "http://www.behindthename.com"+redirect.get_fields('location')[0]
  end

  def parse_gender page
    page =~ /GENDER[^>]*>[^>]*info[^>]*><[^<]*>([A-z]*)<[^<]*<\/span/m
    $1
  end

  def parse_usages page
    usages = page.scan /<a[^>]*usg[^>]*>([A-z\s]*)</
    usages.join(", ")
  end

  def parse_description page
    page =~ /padding:3px;padding-left:10px;[^>]*>.(.*)<.div.*nameheading.*triangle.gif[^>]*>[^>]*related/m
    $1.gsub!(/<[^>]*>/,"")
  end

  def split_string string
    string.split("\n").each do |splited|
      splited.gsub!("\r","")
      splited += " "
      splited.scan(/.{0,400}\s/).each do |line|
        yield line
      end
    end
  end

  #info on a name... this fonction is SO UGLY
  on :cmd, :info_name, /!name\s.*\s*-info\s/ do |msg,options|
    coder = HTMLEntities.new
    url = generate_url_info(options.who)
    page = coder.decode(Hpricot(open(url)))
    answer(msg,t.name.info.gender(parse_gender(page)))
    answer(msg,t.name.info.usages(parse_usages(page)))
    answer(msg,t.name.info.description)
    description = parse_description(page)
    split_string(description) do |line|
      answer(msg,line)
    end
  end

  def parse_search message
    if (message =~ /^!name\s.*\s*-types\s+([A-z\*]*)/)
      search=$1
      search.gsub!("*",".*")
    end
    return nil if !search || search.empty?
    search
  end

  def parse_types page,search
    types_names = (page/"div.body td.emcell table.emtable td")
    types_to_parse = (page/"div.body td.emcell table.emtable input").map! do |input| 
      if input.to_html.match(/usage/)
        type=input.to_html.match(/usage_([A-z]*)/)[0].gsub(/usage_/,"")
        index=types_names.find_index {|item| item.to_html.match(/usage_#{type}"/)}
        td_to_parse=types_names[index]
        td_to_parse.to_html.match "usage_#{type}[^>]*>[^A-z]*([A-z]+\s*[A-z]*)"
        name=$1
        "#{type} : #{coder.decode(name)}" if !search || type.match("^#{search}$")
      end
    end
    typesToParse
  end

  #show the differents types of names
  on :cmd, :what_types, /^!name\s.*\s*-types\s/ do |msg,options|
    search = parse_search msg.message
    coder = HTMLEntities.new
    url ="http://www.behindthename.com/random/"
    page = Hpricot(open(url))
    types = parse_types page, search
    types.compact!
    types.cycle do |type|
      talk(msg.who,typesToParse.shift(5).join("   "),msg.server_id)
    end
  end


  value_with_default :time_string => {regexp: /\s-([0-1]?[0-9])\s/, default: "1"},
                     :size => {regexp: /\s-s([1-4])\s/, default: "1"}

  value :gender        => /\s-g([mfa])\s/,
        :types_string  => /\s-t([A-z0-9]*)\s/

  match :all   => /\s-a\s/,
        :types => /\s-types\s/,
        :info  => /\s-info\s/

  def types options
    options.types_string.split(',')
  end

  def time options
    options.time_string.to_i
  end

end
