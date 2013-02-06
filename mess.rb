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

class Notice < Message

Type="NOTICE"
Motif=/\A:([^!]*)![^:]*NOTICE[^:]*:(.*)/

	def initialize(msg)
		if Motif =~ msg then
			
			super($~[1],"",$~[2])
		else
			super("","","")
		end
	end

end

#FIXME ca marche pas
class Version < Message

Type="VERSION"
Motif=/:([^!]*)![^:]*:VER/
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
	Motif=/\A:([^!]*)!(\S*)\s#{self::Type}\s(\S*)\s:(.*)/

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

	def command?
		@message.match '^!.*$'
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

	Motif=/\A:([^!]*)!(\S*)\s#{self::Type}\s:(.*)\n\z/
	Type="Act"

	def initialize(msg,motif)
		if motif =~ msg then
			super("#{$~[1]}","#{$~[2]}","#{$~[3]}")
		else
			super("","","")
		end

	end

end

class Nick < AbstractAct

	Type="NICK"
	Motif=/\A:([^!]*)!(\S*)\s#{self::Type}\s:(.*)/

	def initialize(msg)
		super(msg,Motif)
	end

	def who
		@sender	
	end

	def newNick
		@message
	end

	def to_s
		"#{who} (#{@identification}) is now #{newNick}"
	end

end

class Part < AbstractAct

	Type="PART"
	Motif=/\A:([^!]*)!(\S*)\s#{self::Type}\s(.*)/

	def initialize(msg)
		super(msg,Motif)
	end

	def who
		@sender
	end

	def from
		@message
	end
		
	def to_s
		"#{who} (#{@identification}) has leave #{from}"
	end

end

class Kick < Message
	Type="KICK"
	Motif=/\A:([^!]*)!(\S*)\s#{self::Type}\s(\S*)\s(\S*)\s:(.*)/

	attr_reader :place, :who

	def initialize(msg)

		if Motif =~ msg then
			@place=$~[3]
			@who=$~[4]
			super($~[1],$~[2],$~[5])
		else			
			super("","","")
		end

		def to_s
			"#{@who} was kicked from #{@place} by #{@sender}(#{@identification}) because:#{@message}"
		end

	end
	

end

class Join < AbstractAct

	Type="JOIN"
	Motif=/\A:([^!]*)!(\S*)\s#{self::Type}\s:(.*)/

	def initialize(msg)
		super(msg,Motif)
	end

	def who
		@sender
	end

	def where
		@message
	end

	def to_s
		"#{who} (#{@identification}) has joined #{where}"
	end

end

class Mode < Message

	Type="MODE"
	Motif=/\A:([^!]*)!(\S*)\s#{self::Type}\s(\S*)\s(.*)/
	
	attr_reader :place

	def initialize(msg)
		if Motif =~ msg then
			@place = "#{$~[3]}"
			super("#{$~[1]}","#{$~[2]}","#{$~[4]}")
		else
			@place = ""
			super("","","")
		end

	end

	def to_s
		"#{@sender} (#{@identification}) has changed mode on #{@place} : #{@message}"
	end


end


