#!/usr/bin/ruby

require 'socket'
require './irc.rb'
require './message.rb'

$SAFE = 1

def main_loop(irc,msg_handler)
	while line = irc.get_msg
		msg_handler.handle_msg(line)
		print line
	end
end

irc=IRC.new("irc.iiens.net",6667,"Zar_A_Bottes")
irc.connect
action=Action.new(irc)
msg_handler=MessageAction.new(action)	
action.join_channel("#zarabotte")
action.talk("zaratan","ca marche")
main_loop(irc,msg_handler)
