class Modules::Name < ModuleIRC

	require 'open-uri'
	require 'hpricot'
	require 'htmlentities'

	Name="name"


	def startMod
		addCmdMethod(self,:getNames,":getNames")
		addCmdMethod(self,:types,":types")
	end

	def endMod
		delCmdMethod(self,":getNames")
		delCmdMethod(self,":types")
	end

	def getNames privMsg
		if module? privMsg
		
			options=Modules::Name::Options.new privMsg
			if !options.info?
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

	def types privMsg
		if (module? privMsg)	
			
			options=Modules::Name::Options.new privMsg
			if options.info?
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
						tdToParse.to_html.match "usage_#{type}[^>]*>[^A-z]*([A-z]*)"
						name=$~[1]	
						"#{type} : #{name}" if search.nil? || type.match("^#{search}$")
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

	def info?
		@message =~ /\stypes\s/
	end

end
