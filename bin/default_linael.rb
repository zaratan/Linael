# -*- encoding : utf-8 -*-
  
#default translation you can either declare an array or a single string
LinaelLanguages = 'en' unless defined? LinaelLanguages
require_relative '../lib/core/core.rb'


module Linael

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

