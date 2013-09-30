# -*- encoding : utf-8 -*-

#a method to manage talk with chanserv and nickserv
linael :identify, require_auth: true do

  #identify Linael
  on :cmd_auth, :identify, /^!identify\s/ do |msg,options|
    talk("nickserv","identify #{options.who}",msg.server_id)
  end

  #ask for op
  on :cmd_auth, :ask_op, /^!op\s/ do |msg,options|
    talk("chanserv","op #{options.chan} #{options.who}",msg.server_id)
  end

  #ask for voice
  on :cmd, :ask_voice, /^!voice\s/ do |msg,options|
    talk("chanserv","voice #{msg.place} #{options.who}", msg.server_id)
  end

end
