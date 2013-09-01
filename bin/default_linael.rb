# -*- encoding : utf-8 -*-

require_relative '../lib/irc.rb'

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
  MasterModule = Modules::Module
  ModulesToLoad = ['basic_auth','admin']

end

