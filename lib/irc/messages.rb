module Linael::Irc
  # General class for messages
  # It covers Quit, Ping and Nick messages
  class Message
    include R18n::Helpers

    # date of message, sender of message, ident of sender, content of message
    attr_accessor :date, :sender, :identification, :content

    alias_method :who, :sender
    alias_method :message, :content

    # DSL method to generate final classes of messages
    def self.generate_message_class(name, super_class, motif = nil, &block)
      motif ||= super_class.default_regex(name.to_s.upcase)
      new_message_class = Class.new(super_class) { const_set('Motif', motif) }
      Linael::Irc.const_set(name.to_s.camelize, new_message_class)
      "Linael::Irc::#{name.to_s.camelize}".constantize.class_eval &block if block_given?
    end

    # Is matching motif?
    def self.match?(msg)
      msg =~ self::Motif
    end

    def parse_msg(msg)
      self.class::Motif =~ msg
      $~
    end

    def parse_item(item, parse)
      tag = (item.to_s.gsub(/^@/, "") + "_r").to_sym
      instance_variable_set(item, (parse[tag] if parse.names.include? tag.to_s) || "")
    end

    # Initialize the message
    def initialize(msg, var = [])
      @date = Time.now
      parse = parse_msg(msg)
      (%i[@sender @identification @content] + var).each { |var| parse_item(var, parse) }
    end

    # Pretty print the user
    def print_user
      "#{sender}(#{identification})"
    end

    # Regex for matching user
    UserRegex = /:(?<sender_r>[^!]*)!(?<identification_r>\S*)/

    # Regex for matching content
    ContentRegex = /:?(?<content_r>[^\n]*)/

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
    LocationRegex = /(?<location_r>\S*)/

    # initialize
    def initialize(msg, var = [])
      super(msg, [:@location] + var)
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
    def initialize(msg)
      super(msg, [:@target])
    end

    # Regex for matching target
    TargetRegex = /(?<target_r>\S*)/
  end

  # Numbered messages
  class NumberedMessage < LocatedMessage
    attr_accessor :code

    def initialize(msg)
      super(msg, [:@code])
    end

    def self.regex
      /:(?<sender_r>\S*)\s+(?<code_r>\d*)\s+(?<location_r>[^:]*):(?<content_r>[^\n]*)/
    end
  end

  # Unregular Regex for join
  join_regex = /#{LocatedMessage::UserRegex}\sJOIN\s:#{LocatedMessage::LocationRegex}/
  # Unregular Regex for mode
  mode_regex = /\A#{UserLocatedMessage::UserRegex}\sMODE\s#{UserLocatedMessage::LocationRegex}\s(?<content_r>\S*)\s#{UserLocatedMessage::TargetRegex}/
  # Unregular Regex for kick
  kick_regex = /\A#{UserLocatedMessage::UserRegex}\sKICK\s#{UserLocatedMessage::LocationRegex}\s#{UserLocatedMessage::TargetRegex}\s#{UserLocatedMessage::ContentRegex}/
  # Unregular Regex for invite
  invite_regex = /\A#{UserLocatedMessage::UserRegex}\sINVITE\s#{UserLocatedMessage::TargetRegex}\s:#{UserLocatedMessage::LocationRegex}/

  Message.generate_message_class :join, LocatedMessage, join_regex do
    def to_s
      t.message.join print_user, location
    end
  end

  %i[part notice].each do |args|
    Message.generate_message_class args, LocatedMessage do
      define_method "to_s" do
        t.message.send args, print_user, location, content
      end
    end
  end

  Message.generate_message_class :privmsg, LocatedMessage do
    def to_s
      t.message.privmsg(print_user, location, content)
    end

    def command?
      content =~ /^#{Linael::CmdChar}/
    end
  end

  Message.generate_message_class :quit, Message do
    def to_s
      t.message.quit print_user, message
    end
  end

  Message.generate_message_class :ping, Message, /\APING :(?<sender_r>[^\n]*)/ do
    def to_s
      t.message.ping sender
    end
  end

  Message.generate_message_class :nick, Message do
    def to_s
      t.message.nick print_user, content
    end

    alias_method :new_nick, :content
  end

  Message.generate_message_class :mode, UserLocatedMessage, mode_regex do
    def to_s
      t.message.mode print_user, location, content, target
    end
  end

  Message.generate_message_class :kick, UserLocatedMessage, kick_regex do
    def to_s
      t.message.kick print_user, target, location, content
    end
  end

  Message.generate_message_class :invite, UserLocatedMessage, invite_regex do
    def to_s
      t.message.invite print_user, target, location
    end
  end

  Message.generate_message_class :server, NumberedMessage, NumberedMessage.regex do
    def to_s
      t.message.server sender, code, location, content
    end
  end
end
