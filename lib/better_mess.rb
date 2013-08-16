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
  end

  UserRegex=/:(?<sender>[^!]*)!(?<identification>\S*)/
  ContentRegex=/:(?<content>[^\r\n]*)/
  
  def self.default_regex(type)
    /\A#{UserRegex}\s#{type}\s#{ContentRegex}/
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

  LocationRegex=/(?<location>\S*)/

  def self.default_regex(type)
    /\A#{UserRegex}\s#{type}\s#{LocationRegex}\s#{ContentRegex}/
  end

end

join_regex = /#{LocatedMessage::UserRegex}\sJOIN\s:#{LocatedMessage::LocationRegex}/

generate_message_class :join, LocatedMessage, join_regex do
  def to_s
    "#{sender}(#{identification}) has joined #{location}"
  end
end

generate_message_class :part, LocatedMessage, LocatedMessage.default_regex("PART") do
  def to_s
    "#{sender}(#{identification}) has leaved #{location} saying: #{content}"
  end
end

generate_message_class :notice, LocatedMessage, LocatedMessage.default_regex("NOTICE") do
  def to_s
    "#{sender}(#{identification}) has noticed #{location} saying: #{content}"
  end
end

generate_message_class :priv_message, LocatedMessage, LocatedMessage.default_regex("PRIVMSG"), "PRIVMSG" do
  def to_s
    "#{sender}(#{identification}) said to #{location}: #{content}"
  end
end

#Kick, Mode
class UserLocatedMessage < LocatedMessage

  attr_accessor :target

  def initialize(msg)
    super(msg)
    content = nil
    target
  end

  TargetRegex=/(?<target>\S*)/

end

mode_regex=/\A#{UserLocatedMessage::UserRegex}\sMODE\s#{UserLocatedMessage::LocationRegex}\s(?<content>\S*)\s#{UserLocatedMessage::TargetRegex}/

generate_message_class :mode UserLocatedMessage, mode_regex do
  def to_s
    "#{sender}(#{identification}) changed mode on #{location}: #{content} #{target} "
  end
end

kick_regex=/\A#{UserLocatedMessage::UserRegex}\sKICK\s#{UserLocatedMessage::LocationRegex}\s#{UserLocatedMessage::TargetRegex}\s#{UserLocatedMessage::ContentRegex}/

generate_message_class :kick UserLocatedMessage, kick_regex do
  def to_s
    "#{sender}(#(identification}) kicked #{target} from #{location} for reason: #{content}"
  end
end


#Numbered messages
class ServerMessage < Message

  attr_accessor :code

end

end
