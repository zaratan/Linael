#default translation you can either declare an array or a single string
LinaelLanguages ||= 'en' 

#requirement
Dir[ROOT + '/lib/core-ext/*.rb'].each {|f| p f;require f}
Dir[ROOT + '/lib/models/*.rb'].each {|f| p f;require f}
require ROOT + '/lib/core/core'
require ROOT + '/lib/core/message_struct'
require ROOT + '/lib/core/message_fifo'
require ROOT + '/lib/core/socket_list'
require ROOT + '/lib/core/socketable'
require ROOT + '/lib/core/handler'
require ROOT + '/lib/irc/messages.rb'
require ROOT + '/lib//irc/irc_handler.rb'
require ROOT + '/lib/irc/irc_socket.rb'
require ROOT + '/lib/irc/irc_act.rb'

require ROOT + '/lib/dsl/modules.rb'
require ROOT + '/lib/dsl/module_dsl.rb'
require ROOT + '/lib/modules/master.rb'

module Linael
  CONFIG = YAML::load(File.open(File.join(ROOT,'config','config.yml')))
  MODULES_CONFIG = YAML::load(File.open('config/modules.yml'))
  
  #database connection
  connection_details = YAML::load(File.open('config/database.yml'))
  ActiveRecord::Base.establish_connection(connection_details["linael"])
  ActiveRecord::Base.logger = Logger.new(STDERR)

  #default configuration
  
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
