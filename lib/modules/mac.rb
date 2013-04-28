# -*- encoding : utf-8 -*-
linael :mac do

    on :msg, :macboue, /(^m|\sm)ac\s/ do |msg,options|
      answer(msg,"#{msg.who}: Apple, c'est de la boue :)")
    end

end
