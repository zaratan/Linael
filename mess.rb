class Message

Type="MESSAGE"
Motif=/\A.*\z/

attr_reader :sender, :identification, :message

	def initialize(sender,identification,message)
		@sender=sender
		@identification=identification
		@message=message

	end
	

	def	self.match(msg)
		return msg =~ self::Motif
	end
	

	def to_s
		"<#{@sender}(#{@identification})> #{@message}"
	end

end

class Ping < Message

Type="PING"
Motif=/\APING :(.*)\n\z/

	def initialize(msg)
		if Motif =~ msg then
			
			super("#{$~[1]}","","")
		else
			super("","","")
		end
	end


end

class PrivMessage < Message

	Type="PRIVMSG"
	Motif=/\A:([^!]*)!~(\S*)\s#{self::Type}\s(\S*)\s:(.*)\n\z/

	attr_reader :place

	def initialize(msg)
		if Motif =~ msg then 
			@place="#{$~[3]}"
			super("#{$~[1]}","#{$~[2]}","#{$~[4]}")
		else
			super("","","")
			@place=""
		end
	end

	def private_message?
		!@place.match '^#.*$'
	end

	def who
		@sender
	end

	def to_s
		"@#{@place}: <#{@sender}(#{@identification})> #{@message}"
	end

end

class PrivMessageAct < PrivMessage

	def action
		@message.sub(/^ACTION\s/,"")
	end

end

class AbstractAct < Message

	Motif=/\A:([^!])!~(\S*)\s#{self::Type}\s:(.*)\n\z/
	Type="Act"

	def initialize(msg)
		if Motif =~ msg then
			super("#{$~[1]}","#{$~[2]}","#{$~[3]}")
		else
			super("","","")
		end

	end

end

class Nick < AbstractAct

	Type="NICK"

	def who
		@sender	
	end

	def newNick
		@message
	end

end

class Part < AbstractAct

	Motif=/\A:([^!])!~(\S*)\s#{self::Type}\s(.*)\n\z/
	Type="PART"

	def who
		@sender
	end

	def from
		@message
	end
		

end

class Join < AbstractAct

	Type="JOIN"

	def who
		@sender
	end

	def where
		@message
	end

end

class Mode < Message

	Motif=/\A:([^!])!(\S*)\s#{self::Type}\s(\S*)\s(.*)\n\z/
	Type="MODE"
	
	attr_reader :place

	def initialize(msg)
		if Motif =~ msg then
			@place = "#{$~[3]}"
			$~[2].sub(/^~/,"")
			super("#{$~[1]}","#{$~[2]}","#{$~[4]}")
		else
			@place = ""
			super("","","")
		end

	end
end


