# -*- encoding : utf-8 -*-
module Linael
  class Modules::Name < ModuleIRC

    require 'open-uri'
    require 'hpricot'
    require 'htmlentities'
    include 

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
      if module? privMsg

        options=Modules::Name::Options.new privMsg
        if !options.types? && !options.infoName?
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

    def module? privMsg
      privMsg.message.match '^!name\s'
    end

    def infoName privMsg
      if module? privMsg

        options=Modules::Name::Options.new privMsg
        if !options.types? && options.infoName?
          if privMsg.message =~/^!name\sinfo\s(\S*)/
            coder = HTMLEntities.new
            name = parseName($~[1])
            #					url ="http://www.behindthename.com/name/#{name}"
            #					page = Hpricot(open(url))	
            #					tr = (page/"div.body table tr")
            #					title =(tr[0]/"div.namepagename").inner_html
            #					tr2 = tr[1]
          end
        end
      end

    end

    def types privMsg
      if (module? privMsg)	

        options=Modules::Name::Options.new privMsg
        coder = HTMLEntities.new
        if options.types? && !options.infoName?
          if (privMsg.message =~ /^!name\stypes\s([A-z\*]*)/)
            search=$~[1]
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
              name=$~[1]	
              "#{type} : #{coder.decode(name)}" if search.nil? || search.empty? || type.match("^#{search}$")
            end
          end
          typesToParse.compact!
          typesToParse.cycle do |type|
            talk(privMsg.who,typesToParse.shift(5).join("   "))
          end
        end
      end
    end

  end

  module Modules::Name::ParseName

    ParseHash=
      {
      /à/ => "a11",
      /é/ => "e10",
      /ì/ => "i11",
      /ò/ => "o11",
      /è/ => "e11",
      /á/ => "a10",
      /š/ => "s18",
      /Ł/ => "l16",
      /ú/ => "u10",
      /á/ => "a10",
      /ù/ => "u11",
      /í/ => "i10",
      /ä/ => "a12",
      /ë/ => "e12",
      /ï/ => "i12",
      /ö/ => "o12",
      /ü/ => "u12",
      /ÿ/ => "y12",
      /Ž/ => "z18",
      /â/ => "a13",
      /ê/ => "e13",
      /î/ => "i13",
      /ô/ => "o13",
      /û/	=> "u13",
      /ã/ => "a14",
      /ñ/ => "n14",
      /õ/ => "o14",
      /ĉ/ => "c13",
      /ç/ => "c15"
    }

      def parseName name
        ParseHash.each {|key,val| name.gsub!(key,val)}
        name
      end

  end


  class Modules::Name::Options

    def initialize privMsg
      @message = privMsg.message
    end

    def time
      if @message =~ /\s-([0-1]?[0-9])\s/
        $~[1].to_i
      else
        1
      end
    end

    def types
      if @message =~ /\s-t([A-z0-9,]*)\s/
        $~[1].split(',')
      else
        []
      end
    end

    def gender
      if @message =~ /\s-g([mfa])\s/
        $~[1]
      else
        ""
      end
    end

    def size
      if @message =~ /\s-s([1-4])\s/
        $~[1]
      else
        "1"
      end
    end

    def all?
      @message =~ /\s-a\s/
    end

    def types?
      @message =~ /\stypes\s/
    end

    def infoName?
      @message =~ /\sinfo\s/
    end
  end
end
