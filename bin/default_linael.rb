# -*- encoding : utf-8 -*-

require 'active_support/all'
require 'socket'
require 'colorize'
require 'r18n-desktop'
require 'json'
require 'fifo'

#default translation you can either declare an array or a single string
LinaelLanguages = 'en' unless defined? LinaelLanguages
R18n.default_places = Place + 'translation/'
Place = File.dirname(__FILE__) +'/../'

def require_rel place
  Dir[Place + place].sort.each {|file| p file;require file }
end

require_rel 'lib/core-ext/*.rb'
require_rel 'lib/core/*.rb'
require_rel 'lib/irc/messages.rb'
require_rel 'lib/irc/*.rb'
require_rel 'lib/dsl/modules.rb'
require_rel 'lib/dsl/module_dsl.rb'
require_rel 'lib/modules/master.rb'

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

