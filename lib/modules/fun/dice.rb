# -*- encoding : utf-8 -*-

#A module to launch dice
linael :dice do
  
  before(options) {|opt| opt.dice.to_i != 0}
  
  help [
    t.dice.help.description,
    t.help.helper.line.white,
    t.help.helper.line.function,
    t.dice.help.function.dice
  ]

  #DRY for regex
  number = "[0-9]{1,3}"

  #number of dice and value of dice
  value :number => Regexp.new("("+number+")"+"d"+number),
        :dice   => Regexp.new(number + "d" + "("+number+")")

  #launch dices
  on :msg, :dice, Regexp.new("^#{number}d#{number}") do |msg,options|
    unless to_much?(options)
      dices=[]
      options.number.to_i.times { dices << Linael::DiceLauncher.new(options.dice.to_i)}
      sum = dices.inject(0) {|sum,d| sum + d.value}
      answer(msg, t.dice.act.dice(options.from_who,dices.join(" - ")))
    else
      sum = 0
      options.number.to_i.times {sum += Linael::DiceLauncher.new(options.dice.to_i).value}
    end
    answer(msg, t.dice.act.sum(options.from_who, sum))
  end

  #to much to be printed separatly
  def to_much? options
    options.number.to_i > 20
  end

end


module Linael

  #A module representing a dice
  class DiceLauncher

    #result of the dice
    attr_reader :value
    
    #init with dice value
    def initialize dice
      @value = rand(dice) + 1
    end

    #to_s
    def to_s
      @value.to_s
    end

  end

end
