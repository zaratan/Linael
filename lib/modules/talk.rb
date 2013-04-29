# -*- encoding : utf-8 -*-
linael :talk, require_auth: true do

  on :cmdAuth, :talking,/^!talk\s/ do |msg,options|
    talk(options.chan,options.reason)
  end

end
