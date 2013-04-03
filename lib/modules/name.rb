# -*- encoding : utf-8 -*-
module Linael
  class Modules::Name < ModuleIRC

    require 'open-uri'
    require 'hpricot'
    require 'htmlentities'

    Name="name"

    Help=[
      "Module: Name",
      " ",
      "=====Fonctions=====",
      "!name       => display a random name from a database",
      "!name types => display the different types of names available",
      " ",
      "=====Options=====",
      "!name -g{m|f} -s[1-4] -[0-9] -a -tType1,Type2,...",
      "    -g    : Gender male or female",
      "    -s    : Size of the name",
      "    -     : Number of result",
      "    -a    : All ignore all the other options",
      "    -t    : Types of names",
      "!name types regex",
      "    regex : regex like b* for every type begining with b"
    ]


    def startMod
      add_module :cmd => [:getNames,:types]
    end

    def getNames privMsg
      if Options.name? privMsg.message
        options=Options.new privMsg
        p options.types?,options.info?
        if !options.types? and !options.info?
          coder = HTMLEntities.new

          options.time.times do |i|
            url="http://www.behindthename.com/random/random.php?"
            url+="number=#{options.size}"
            url+="&"
            url+="gender=#{options.gender}"
            url+="&all=yes" if options.all?
            url+="&all=no" if !options.all?
            options.types.each do |type|
              url+="&usage_#{type}=1"
            end
            page = Hpricot(open(url))
            name = (page/"div.body span.heavymedium a").inject("") {|str, nam| str += " #{coder.decode(nam.inner_html)}"}
            name = (page/"div.body span").inject("") {|str, nam| str += " #{coder.decode(nam.inner_html.gsub(/\s/,""))}"} if name.empty?
            answer(privMsg,"#{i+1} - #{name}")

          end
        end

      end
    end

    def types privMsg
      if Options.name_types? privMsg.message

        options=Options.new privMsg
        coder = HTMLEntities.new
        
        if (privMsg.message =~ /^!name\s-types\s([A-z\*]*)/)
          search=$1
          search.gsub!("*",".*")
        end
        url ="http://www.behindthename.com/random/"
        page = Hpricot(open(url))
        typesNames = (page/"div.body td.emcell table.emtable td")
        typesToParse = (page/"div.body td.emcell table.emtable input").map! do |input| 
          if input.to_html.match(/usage/)
            type=input.to_html.match(/usage_([A-z]*)/)[0].gsub(/usage_/,"")
            index=typesNames.find_index {|item| item.to_html.match(/usage_#{type}"/)}
            tdToParse=typesNames[index]
            tdToParse.to_html.match "usage_#{type}[^>]*>[^A-z]*([A-z]+\s*[A-z]*)"
            name=$1
            "#{type} : #{coder.decode(name)}" if search.nil? || search.empty? || type.match("^#{search}$")
          end
        end
        typesToParse.compact!
        typesToParse.cycle do |type|
          talk(privMsg.who,typesToParse.shift(5).join("   "))
        end
      end
      
    end


    class Options < ModulesOptions
  
      generate_to_catch :name       => /^!name/,
                        :name_info  => /^!name.*\s-info\s/,
                        :name_types => /^!name.*\s-types\s/ 
  
     
      generate_value_with_default :time_string => {regexp: /\s-([0-1]?[0-9])\s/, default: "1"},
                                  :size => {regexp: /\s-s([1-4])\s/, default: "1"}
  
      generate_value :gender        => /\s-g([mfa])\s/,
                     :types_string  => /\s-t([A-z0-9]*)\s/
  
      generate_match :all   => /\s-a\s/,
                     :types => /\s-types\s/,
                     :info  => /\s-info\s/
  
      def types
        types_string.split(',')
      end

      def time
        time_string.to_i
      end
  
    end
  end
end
