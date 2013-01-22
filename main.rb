#!/usr/bin/ruby

require 'active_support/inflector'
require 'socket'
require './irc.rb'
require './mess.rb'
require "./module.rb"
require './modules/module.rb'
require './message.rb'

$SAFE = 0

def main_loop(irc,msg_handler)
	while line = irc.get_msg
		msg_handler.handle_msg(line)
	end
end

irc=IRC.new("irc.rizon.net",6667,"Linael")
irc.connect
action=MessageAction.new(irc,[Modules::Module])	
action.join_channel("#Zaratan")
action.talk("zaratan","ca marche")
main_loop(irc,action)
