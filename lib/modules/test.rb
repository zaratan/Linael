# -*- encoding : utf-8 -*-
linael :test,:constructor => "Skizzk",:require_auth => true,:required_mod => ["admin"] do

  match :happy => /happy/
  value :sad   => /sad(.)/

  help ["Module de test"]

  on_init do
    p "YOUPI!"
  end

  on_load do
    p "Loaded <3"
  end

  on :cmd,:test,/^!test/ do |msg,options|

    before do
      2 == 2
    end

    answer(msg,"ça marche")
    answer(msg,options.happy?)
    answer(msg,options.sad)
    answer(msg,options.who)
  end


end
