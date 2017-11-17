require 'active_support/all'
require 'socket'
require 'colorize'
require 'r18n-desktop'

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
  PORT = 6667
  # Nick of the bot
  BotNick = 'Linael'.freeze
  # Name of master user
  Master = 'zaratan'.freeze

  # Char that will be used for commands
  CmdChar = '!'.freeze

  # Module which
  MasterModule = Modules::Master
  ModulesToLoad = ['basic_auth', 'admin', 'ping'].freeze
end
