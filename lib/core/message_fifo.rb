# -*- encoding : utf-8 -*-
require 'monitor.rb'
require 'thread'
require 'singleton'
require 'json'

module Linael


  class SocketFifo
    def initialize name
      pipe = Queue.new
      @writter = pipe
      @reader = pipe
    end

    def gets 
      begin
        encode_utf8(p CGI::unescapeHTML(@reader.pop).chomp)
      rescue Exception
        "\"bad charset\""
      end
    end

    def puts msg
      @writter.push encode_utf8(msg.encode('utf-8'))
    end
    def encode_utf8(new_value)
      begin
        # Try it as UTF-8 directly
        cleaned = new_value.dup.force_encoding('UTF-8')
        unless cleaned.valid_encoding?
          #                     # Some of it might be old Windows code page
          cleaned = new_value.encode( 'UTF-8', 'ISO-8859-1' )
        end
        new_value = cleaned
      rescue EncodingError
        #                                                   # Force it to UTF-8, throwing out invalid bits
        new_value.encode!( 'UTF-8', invalid: :replace, undef: :replace )
      end
      new_value
    end

  end

  class MessageFifo < SocketFifo

    include Singleton

    def initialize
      super "messages"
    end

    def gets
      begin
        result = JSON.parse(encode_utf8(p super))
        MessageStruct.new(result["server_id"].to_sym,CGI::unescapeHTML(encode_utf8(result["element"])),result["type"].to_sym)
      rescue Exception
        MessageStruct.new(:irc,"non\r\n",:irc)
      end
    end


  end
end
