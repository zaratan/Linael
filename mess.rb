class Message

@@type="MESSAGE"
@@motif=/\A.*\z/

attr_reader :sender, :identification, :message

	def initialize(sender,identification,message)
		@sender=sender
		@identification=identification
		@message=message

	end
	
	def	match(msg)
		return msg.match(@@motif)
	end

end

class Ping < Message

@@type="PING"
@@motif=/\APING :(.*)\z/

	def initialize(msg)
		if Ping.match(msg) then
			super("#{$~[1]}","","")
		else
			super("","","")
		end
	end


end

class PrivMessage < Message

	@@type="PRIVMSG"
	@@motif=/\A:([^!]*)!~(\S*)\s#{@@type}\s(\S*)\s:(.*)\z/

	attr_reader :place

	def initialize(msg)
		if PrivMessage.match(msg) then 
			@place="#{$~[3]}"
			super("#{$~[1]}","#{$~[2]}","#{$~[4]}")
		else
			super("","","")
			@place=""
		end
	end

	def is_private_message()
		return !@place.match /\A#.*\z/
	end

end

class Join < Message

	@@motif=/\A:([^!])!~(\S*)\s#{@@type}\s:(.*)\z/
	@@type="JOIN"

	def initialize(msg)

	end

end

class Nick < Message

	@@motif=/\A:([^!])!~(\S*)\s#{@@type}\s:(.*)\z/
	@@type="NICK"

	def initialize(msg)

	end
end

class Part < Message

	@@motif=/\A:([^!])!~(\S*)\s#{@@type}\s(.*)\z/
	@@type="PART"

	def initialize(msg)

	end

end

class Join < Message

	@@motif=/\A:([^!])!~(\S*)\s#{@@type}\s:(.*)\z/
	@@type="JOIN"

	def initialize(msg)

	end
end

class Mode < Message

	@@motif=/\A:([^!])!~(\S*)\s#{@@type}\s(\S*)\s(.*)\z/
	@@type="MODE"

	def initialize

	end
end


