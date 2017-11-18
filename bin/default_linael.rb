require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
Bundler.require(:development) if ENV['DEBUG']
require 'socket'

# default translation you can either declare an array or a single string
LinaelLanguages = 'en'.freeze unless defined? LinaelLanguages
require_relative '../lib/core/core'
require_relative '../lib/core/message_struct'
require_relative '../lib/core/message_fifo'
require_relative '../lib/core/socket_list'
require_relative '../lib/core/socketable'
require_relative '../lib/core/handler'
require_relative '../lib/irc/messages.rb'
require_relative '../lib//irc/irc_handler.rb'
require_relative '../lib/irc/irc_socket.rb'
require_relative '../lib/irc/irc_act.rb'

require_relative '../lib/dsl/modules.rb'
require_relative '../lib/dsl/module_dsl.rb'
require_relative '../lib/modules/master.rb'

module Linael
  # The server to join
  ServerAddress = ''.freeze
  # The connection port
  Port = '6667'.to_i
  # Nick of the bot
  BotNick = 'Linael'.freeze
  # Name of master user
  Master = 'zaratan'.freeze

  # Char that will be used for commands
  CmdChar = '!'.freeze

  REDIS_ADDRESS = ENV.fetch('REDIS_ADDRESS', '127.0.0.1')
  REDIS_PORT = ENV.fetch('REDIS_PORT', '6379')

  Redis::Objects.redis = ConnectionPool.new(size: 5, timeout: 5) { Redis.new(host: REDIS_ADDRESS, port: REDIS_PORT) }

  # Module which
  MasterModule = Modules::Master
  ModulesToLoad = %w[basic_auth admin ping version lovely test].freeze
end
