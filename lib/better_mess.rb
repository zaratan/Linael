# -*- encoding : utf-8 -*-

module Linael

  # General class for messages
  # Quit, Ping, Nick
  class Message

    attr_accessor :date, :sender, :identification, :content

    alias_method :who, :sender
    alias_method :message, :content

    def self.generate_message_class (name,super_class,motif,type=nil,&block)
      new_message_class = Class.new(super_class) do
        self.const_set('Motif', motif)
        self.const_set('Type', 
          if type
            type
          else
            name.to_s
          end
        )

      end
      Linael.const_set(name.to_s.camelize,new_message_class)
      if block_given?
        "Linael::#{name.to_s.camelize}".constantize.class_eval &block
      end
    end

    def self.match? msg
      msg =~ self::Motif
    end

    def initialize(msg,parse=nil)
      @date = Time.now
      unless parse
        self.class::Motif =~ msg
        parse = $~
      end
      @sender= (parse[:sender_r] if parse.names.include? 'sender_r') || ""
      @identification= (parse[:identification_r] if parse.names.include? 'identification_r') || ""
      @content= (parse[:content_r] if parse.names.include? 'content_r') || ""
    end

    def print_user
      "#{sender}(#{identification})"
    end

    UserRegex=/:(?<sender_r>[^!]*)!(?<identification_r>\S*)/
    ContentRegex=/:?(?<content_r>[^\n]*)/

    def self.default_regex(type)
      /\A#{UserRegex}\s#{type}\s#{ContentRegex}/
    end

  end

  Message.generate_message_class :quit, Linael::Message, Message.default_regex("QUIT") do
    def to_s
      "#{print_user} has quit: #{message}"
    end
  end

  Message.generate_message_class :ping, Message,/\APING :(?<sender_r>[^\n]*)\z/ do
    def to_s
      "Ping from #{sender}"
    end
  end

  Message.generate_message_class :nick, Message, Message.default_regex("NICK") do
    def to_s
      "#{print_user} changed his nick to #{content}"
    end

    alias_method :new_nick, :content
  end

  #Join, Part, Notice, PrivateMessage
  class LocatedMessage < Message

    attr_accessor :location

    alias_method :where, :location
    alias_method :place, :location

    def on_chan?
      location =~ /^#/
    end

    def private_message?
      location !~ /^#/
    end

    LocationRegex=/(?<location_r>\S*)/

    def initialize(msg,parse=nil)
      unless parse
        self.class::Motif =~ msg
        parse = $~
      end
      super(msg,parse)
      @location= (parse[:location_r] if parse.names.include? 'location_r') || ""
    end

    def self.default_regex(type)
      /\A#{UserRegex}\s#{type}\s#{LocationRegex}\s#{ContentRegex}/
    end

  end

  join_regex = /#{LocatedMessage::UserRegex}\sJOIN\s:#{LocatedMessage::LocationRegex}/

  Message.generate_message_class :join, LocatedMessage, join_regex do
    def to_s
      "#{print_user} has joined #{location}"
    end
  end

  Message.generate_message_class :part, LocatedMessage, LocatedMessage.default_regex("PART") do
    def to_s
      "#{print_user} has leaved #{location} saying: #{content}"
    end
  end

  Message.generate_message_class :notice, LocatedMessage, LocatedMessage.default_regex("NOTICE") do
    def to_s
      "#{print_user} has noticed #{location} saying: #{content}"
    end
  end

  Message.generate_message_class :priv_message, LocatedMessage, LocatedMessage.default_regex("PRIVMSG"), "PRIVMSG" do
    def to_s
      "#{print_user} said to #{location}: #{content}"
    end

    def command?
      content =~ /^!/
    end
  end


  #Kick, Mode, Invite
  class UserLocatedMessage < LocatedMessage

    attr_accessor :target

    def initialize msg
      self.class::Motif =~ msg
      super(msg,$~)
      @target= ($~[:target_r] if $~.names.include? 'target_r') || ""
    end

    TargetRegex=/(?<target_r>\S*)/

  end

  mode_regex=/\A#{UserLocatedMessage::UserRegex}\sMODE\s#{UserLocatedMessage::LocationRegex}\s(?<content_r>\S*)\s#{UserLocatedMessage::TargetRegex}/

  Message.generate_message_class :mode, UserLocatedMessage, mode_regex do
    def to_s
      "#{print_user} changed mode on #{location}: #{content} #{target} "
    end
  end

  kick_regex=/\A#{UserLocatedMessage::UserRegex}\sKICK\s#{UserLocatedMessage::LocationRegex}\s#{UserLocatedMessage::TargetRegex}\s#{UserLocatedMessage::ContentRegex}/

  Message.generate_message_class :kick, UserLocatedMessage, kick_regex do
    def to_s
      "#{print_user} kicked #{target} from #{location} for reason: #{content}"
    end
  end

  invite_regex=/\A#{UserLocatedMessage::UserRegex}\sINVITE\s#{UserLocatedMessage::TargetRegex}\s:#{UserLocatedMessage::LocationRegex}/

  Message.generate_message_class :invite, UserLocatedMessage, invite_regex do
    def to_s
      "#{print_user} invited #{target} on #{location}"
    end
  end


  #Numbered messages
  class ServerMessage < Message

    attr_accessor :code

  end

end
