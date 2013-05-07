# -*- encoding : utf-8 -*-
# 
# A module tu clac with bc
linael :calc do

  help [
    "Module: Calc",
    " ",
    "To make calculation with bc (cf man bc)",
    "#####Function#####",
    "!calc string to calc"
  ]

  on :cmd, :calc, /^!calc\s/ do |msg,options|
    result = `echo "#{options.all.gsub("\r","")}" | bc -l`
    answer(msg,result)
  end
end
