# -*- encoding : utf-8 -*-
# 
# A module tu clac with bc
linael :calc do

  help [
    t.calc.help.description,
    t.help.helper.line.white,
    t.help.helper.line.functions,
    t.calc.help.function.calc
  ]

  value to_calc: /\s([0-9A-Za-z\/\*\-\+\(\)\s\.<>!=&|]*)/

  on :cmd, :calc, /^!calc\s/ do |msg,options|
    result = `echo "#{options.to_calc.gsub("\r","")}" | bc -l`
    answer(msg,t.calc.result(options.from_who,result))
  end
end
