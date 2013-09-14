# -*- encoding : utf-8 -*-
linael :log do

  help [
    "Module: Log",
    " ",
    "Log every recognized message in the console"
  ]

  [:msg,:kick,:nick,:part,:join,:mode,:quit,:notice,:invite,:server,:ping].each do |type|
    on type,type do |msg|
      p msg
    end
  end

end
