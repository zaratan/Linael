# -*- encoding : utf-8 -*-

require 'active_support/all'
require 'active_record'
require 'socket'
require 'colorize'
require 'r18n-desktop'
require 'json'
require 'fifo'
  
#default translation you can either declare an array or a single string
LinaelLanguages = 'en' unless defined? LinaelLanguages
require_relative '../lib/core-ext/struct.rb'
require_relative '../lib/core-ext/time.rb'
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

  CONFIG = YAML::load(File.open('config/config.yml'))
  MODULES_CONFIG = YAML::load(File.open('config/modules.yml'))
  connection_details = YAML::load(File.open('config/database.yml'))
  ActiveRecord::Base.establish_connection(connection_details)

  # The server to join
  ServerAddress = ''
  # The connection port
  Port = 6667
  # Nick of the bot
  BotNick = 'Linael'
  # Name of master user
  Master = 'zaratan'

  # Char that will be used for commands
  CmdChar = '!'


  # Module which 
  MasterModule = Modules::Master
  ModulesToLoad = ['basic_auth','admin','ping']

end

