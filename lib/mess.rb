# -*- encoding : utf-8 -*-

module Linael

  # General class for messages 
  # It covers Quit, Ping and Nick messages
  class Message

    # date of message, sender of message, ident of sender, content of message
    attr_accessor :date, :sender, :identification, :content

    alias_method :who, :sender
    alias_method :message, :content

    # DSL method to generate final classes of messages
    def self.generate_message_class (name,super_class,motif=nil,&block)
      motif ||= super_class.default_regex(name.to_s.upcase)
      new_message_class = Class.new(super_class) {self.const_set('Motif', motif)}
      Linael.const_set(name.to_s.camelize,new_message_class)
      "Linael::#{name.to_s.camelize}".constantize.class_eval &block if block_given?
    end

    # Is matching motif?
    def self.match? msg
      msg =~ self::Motif
    end

    def parse_msg(msg,parse=nil)
      unless parse
        self.class::Motif =~ msg
        parse = $~
      end
      parse      
    end

    # Initialize the message
    def initialize(msg,parse=nil)
      @date = Time.now
      parse= parse_msg(msg,parse)
      @sender= (parse[:sender_r] if parse.names.include? 'sender_r') || ""
      @identification= (parse[:identification_r] if parse.names.include? 'identification_r') || ""
      @content= (parse[:content_r] if parse.names.include? 'content_r') || ""
    end

    # Pretty print the user
    def print_user
      "#{sender}(#{identification})"
    end

    # Regex for matching user
    UserRegex=/:(?<sender_r>[^!]*)!(?<identification_r>\S*)/

    # Regex for matching content
    ContentRegex=/:?(?<content_r>[^\n]*)/

    # Default regex for Messages
    def self.default_regex(type)
      /\A#{UserRegex}\s#{type}\s#{ContentRegex}/
    end

  end

  # General class for located messages
  # It cover Join, Part, Notice and PrivateMessage messages
  class LocatedMessage < Message

    # Location of the message
    attr_accessor :location

    alias_method :where, :location
    alias_method :place, :location

    # Is it on a chan?
    def on_chan?
      location =~ /^#/
    end

    # Is it a private message?
    def private_message?
      !on_chan?
    end

    # Regex for matching location
    LocationRegex=/(?<location_r>\S*)/

    # initialize
    def initialize(msg,parse=nil)
      parse= parse_msg(msg,parse)
      super(msg,parse)
      @location= (parse[:location_r] if parse.names.include? 'location_r') || ""
    end

    # Default regex for LocatedMessage
    def self.default_regex(type)
      /\A#{UserRegex}\s#{type}\s#{LocationRegex}\s#{ContentRegex}/
    end

  end

  # General class for messgaes with user and location
  # It covers Kick, Mode and Invite messages
  class UserLocatedMessage < LocatedMessage

    # Target of the message
    attr_accessor :target

    # Initialize
    def initialize msg
      parse= parse_msg(msg)
      super(msg,parse)
      @target= (parse[:target_r] if parse.names.include? 'target_r') || ""
    end

    # Regex for matching target
    TargetRegex=/(?<target_r>\S*)/

  end
  
  
  #Numbered messages
  class NumberedMessage < LocatedMessage

    attr_accessor :code

    def initialize msg
      parse= parse_msg(msg)
      super(msg,parse)
      @code= (parse[:code_r] if parse.names.include? 'code_r') || ""
    end

    def self.regex 
      /:(?<sender_r>\S*)\s(?<code_r>\d*)\s(?<location_r>[^:]*):(?<content_r>[^\n]*)/
    end

  end

  
  #Unregular Regex for join 
  join_regex = /#{LocatedMessage::UserRegex}\sJOIN\s:#{LocatedMessage::LocationRegex}/
  #Unregular Regex for mode 
  mode_regex=/\A#{UserLocatedMessage::UserRegex}\sMODE\s#{UserLocatedMessage::LocationRegex}\s(?<content_r>\S*)\s#{UserLocatedMessage::TargetRegex}/
  #Unregular Regex for kick 
  kick_regex=/\A#{UserLocatedMessage::UserRegex}\sKICK\s#{UserLocatedMessage::LocationRegex}\s#{UserLocatedMessage::TargetRegex}\s#{UserLocatedMessage::ContentRegex}/
  #Unregular Regex for invite 
  invite_regex=/\A#{UserLocatedMessage::UserRegex}\sINVITE\s#{UserLocatedMessage::TargetRegex}\s:#{UserLocatedMessage::LocationRegex}/


  Message.generate_message_class :join, LocatedMessage, join_regex do
    def to_s
      "#{print_user} has joined #{location}"
    end
  end
  
  [[:part,'leaved'],[:notice,'noticed']].each do |args|
    Message.generate_message_class args.first, LocatedMessage do
      define_method "to_s" do
        "#{print_user} has #{args.last} #{location} saying: #{content}"
      end
    end
  end

  Message.generate_message_class :privmsg, LocatedMessage do
    def to_s
      "#{print_user} said to #{location}: #{content}"
    end

    def command?
      content =~ /^#{Linael::CmdChar}/
    end
  end
  
  Message.generate_message_class :quit, Linael::Message do
    def to_s
      "#{print_user} has quit: #{message}"
    end
  end

  Message.generate_message_class :ping, Message,/\APING :(?<sender_r>[^\n]*)/ do
    def to_s
      "Ping from #{sender}"
    end
  end

  Message.generate_message_class :nick, Message do
    def to_s
      "#{print_user} changed his nick to #{content}"
    end

    alias_method :new_nick, :content
  end

  Message.generate_message_class :mode, UserLocatedMessage, mode_regex do
    def to_s
      "#{print_user} changed mode on #{location}: #{content} #{target} "
    end
  end

  Message.generate_message_class :kick, UserLocatedMessage, kick_regex do
    def to_s
      "#{print_user} kicked #{target} from #{location} for reason: #{content}"
    end
  end

  Message.generate_message_class :invite, UserLocatedMessage, invite_regex do
    def to_s
      "#{print_user} invited #{target} on #{location}"
    end
  end

  Message.generate_message_class :server, NumberedMessage, NumberedMessage.regex do
    def to_s
      "#{sender} #{code} #{location}: #{content}"
    end
  end

end
