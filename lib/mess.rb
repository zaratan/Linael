# -*- encoding : utf-8 -*-

# Abstract class for message
class Message

  # Abstract type
  Type="MESSAGE"
  # Abstract motif
  Motif=/\A.*\z/

  # sender@identification :message
  attr_accessor :sender, :identification, :message

  # Initialize
  def initialize(sender, identification, message)
    @sender=sender
    @identification=identification
    @message=message
  end

  # Is matching Motif?
  def	self.match(msg)
    return msg =~ self::Motif
  end

  # Default to_s
  def to_s
    "<#{sender}(#{identification})> #{message}"
  end

end

# Class for Ping messages
class Ping < Message

  # Type
  Type="PING"

  # Motif of a Ping
  Motif=/\APING :(.*)\n\z/

  # Initialize
  def initialize(msg)
    if Motif =~ msg then

      super("#{$~[1]}","","")
    else
      super("","","")
    end
  end


end

# Class for Notice message
class Notice < Message

  # Type
  Type="NOTICE"

  # Motif for a Notice
  Motif=/\A:([^!]*)![^:]*NOTICE[^:]*:(.*)/

  # Initialize
  def initialize(msg)
    if Motif =~ msg then

      super($~[1],"",$~[2])
    else
      super("","","")
    end
  end

end

# Class for Private message
class PrivMessage < Message

  # Type
  Type="PRIVMSG"

  # Motif for a Private message
  Motif=/\A:([^!]*)!(\S*)\s#{self::Type}\s(\S*)\s:(.*)/

  # Place where sended
  attr_reader :place

  # Intialize
  def initialize(msg)
    if Motif =~ msg then 
      @place="#{$~[3]}"
      super("#{$~[1]}","#{$~[2]}","#{$~[4]}")
    else
      super("","","")
      @place=""
    end
  end

  # Is the message a query?
  def private_message?
    !@place.match '^#.*$'
  end

  # Who sended the message
  def who
    @sender
  end

  # Where the message is sended
  def where
    @place
  end

  # Is the message a command?
  def command?
    @message.match '^!.*$'
  end

  # Overide to_s
  def to_s
    "@#{@place}: <#{@sender}(#{@identification})> #{@message}"
  end

end

#Abstract class for action
class AbstractAct < Message

  # Motif for Abstract action
  Motif=/\A:([^!]*)!(\S*)\s#{self::Type}\s:(.*)\n\z/

  # Type
  Type="Act"

  # Initialize
  def initialize(msg,motif)
    if motif =~ msg then
      super("#{$~[1]}","#{$~[2]}","#{$~[3]}")
    else
      super("","","")
    end

  end

end

# Class for Nick action
class Nick < AbstractAct

  # Type
  Type="NICK"

  #Motif for a Nick
  Motif=/\A:([^!]*)!(\S*)\s#{self::Type}\s:(.*)/

  # Initialize
  def initialize(msg)
    super(msg,Motif)
  end

  # Who change his nick
  def who
    @sender	
  end

  # It's new nick
  def newNick
    @message
  end

  # Overide of to_s
  def to_s
    "#{who} (#{@identification}) is now #{newNick}"
  end

end

# Class for Part action
class Part < AbstractAct

  #Type
  Type="PART"

  #Motif for a Part
  Motif=/\A:([^!]*)!(\S*)\s#{self::Type}\s(.*)/

  # Initialize
  def initialize(msg)
    super(msg,Motif)
  end

  # Who part
  alias :who :sender

  # From where did he part
  alias :from :message

  # Overide of to_s
  def to_s
    "#{who} (#{@identification}) has leave #{from}"
  end

end

# Kick action
class Kick < Message

  # Type
  Type="KICK"

  #Motif of a Kick action
  Motif=/\A:([^!]*)!(\S*)\s#{self::Type}\s(\S*)\s(\S*)\s:(.*)/

  # *who*:: have been kicked from what *place*::
  attr_reader :place, :who

  # Initialize
  def initialize(msg)

    if Motif =~ msg then
      @place=$~[3]
      @who=$~[4]
      super($~[1],$~[2],$~[5])
    else			
      super("","","")
    end

    # Overide of to_s
    def to_s
      "#{@who} was kicked from #{@place} by #{@sender}(#{@identification}) because:#{@message}"
    end

  end


end

# Join action
class Join < AbstractAct

  # Type
  Type="JOIN"

  # Motif of a Join action
  Motif=/\A:([^!]*)!(\S*)\s#{self::Type}\s:(\S*)/

  # Intialize
  def initialize(msg)
    super(msg,Motif)
  end

  # Who Join
  def who
    @sender
  end

  # Where he joined
  def where
    @message
  end

  #Overide of to_s
  def to_s
    "#{who} (#{@identification}) has joined #{where}"
  end

end

# Mode action
class Mode < Message

  # Type
  Type="MODE"

  # Motif for a Mode action
  Motif=/\A:([^!]*)!(\S*)\s#{self::Type}\s(\S*)\s(.*)/

  # Place of mode change
  attr_reader :place

  # Initialize
  def initialize(msg)
    if Motif =~ msg then
      @place = "#{$~[3]}"
      super("#{$~[1]}","#{$~[2]}","#{$~[4]}")
    else
      @place = ""
      super("","","")
    end

  end

  # Overide of to_s
  def to_s
    "#{@sender} (#{@identification}) has changed mode on #{@place} : #{@message}"
  end

end
