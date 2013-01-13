#!/usr/bin/ruby

require 'socket'
require './irc.rb'
require './message.rb'
require './mess.rb'

$SAFE = 1

def main_loop(irc,msg_handler)
	while line = irc.get_msg
		msg_handler.handle_msg(line)
	end
end

irc=IRC.new("irc.iiens.net",6667,"Zar_A_Bottes")
irc.connect
action=MessageAction.new(irc)	
action.join_channel("#Zarabotte")
action.talk("zaratan","ca marche")
main_loop(irc,action)
