module Linael

# General class for messages
# Quit, Ping, Nick
class Message
  
  attr_accessor :date, :sender, :identification, :content

  alias_method :who, :sender
  alias_method :message, :content

  def self.generate_message_class (name,super_class,motif,type=nil,&block)
    new_message_class = Class.new(super_class) do
      Motif = motif
      if type
        Type = type
      else
        Type = name.to_s
      end
    end
    Linael.const_set(name.to_s.camelize,new_message_class)
    if block_given?
      new_class.instance_eval &block
    end
  end

  def self.match? msg
    msg =~ self::Motif
  end

  def initialize(msg)
    date = Time.now
    msg =~ self::Motif
    sender = $1
    identification = $2 if $2
    content = $3 if $3
  end

  UserRegex=/:([^!]*)!(\S*)/
  ContentRegex=/:([^\r\n]*)/
  
  def self.default_regex(type)
    /\A#{Message::UserRegex}\s#{type}\s#{Message::ContentRegex}/
  end

end

generate_message_class :quit, Message, Message.default_regex("QUIT") do
  def to_s
    "#{who}(#{identification}) has quit: #{message}"
  end
end

generate_message_class :ping, Message,/\APING :([^\r\n]*)\z/ do
  def to_s
    "Ping from #{sender}"
  end
end

generate_message_class :nick, Message, Message.default_regex("NICK") do
  def to_s
    "#{sender}(#{identification}) changed his nick to #{content}"
  end
end

#Join, Part, Notice, PrivateMessage
class LocatedMessage < Message

  attr_accessor :location

  alias_method :where, :location

  def on_chan?
    location =~ /^#/
  end

end

#Kick, Mode
class UserLocatedMessage < LocatedMessage

  attr_accessor :target

end

#Numbered messages
class ServerMessage < Message

  attr_accessor :code

end

end
