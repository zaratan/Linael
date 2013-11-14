# -*- encoding : utf-8 -*-
linael :talk, require_auth: true do

  help [
    t.talk.help.description,
    t.help.helper.line.white,
    t.help.helper.line.admin,
    t.talk.help.function.talk
  ]

  on :cmd_auth, :talking,/^!talk\s/ do |msg,options|
    talk(options.chan,options.reason,msg.server_id)
  end

end
