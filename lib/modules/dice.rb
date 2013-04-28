# -*- encoding : utf-8 -*-

#A module to launch dice
linael :dice do

  help [
    "A module to launch dice",
    " ",
    "#####Functions#####",
    "XXXdYYY => launch XXX dice YYY (for exemple 3d6 launch 3 dice with 6 face each)"
  ]

  #DRY for regex
  number = "[0-9]{1,3}"

  #number of dice and value of dice
  value :number => Regexp.new("("+number+")"+"d"+number),
        :dice   => Regexp.new(number + "d" + "("+number+")")

  #launch dices
  on :msg, :dice, Regexp.new("^#{number}d#{number}") do |msg,options|
    if (!to_much?(options))
      dices=[]
      options.number.to_i.times { dices << Linael::DiceLauncher.new(options.dice.to_i)}
      sum = dices.inject(0) {|sum,d| sum + d.value}
      answer(msg,"#{msg.who}: Dices = [#{dices.join(" - ")}]")
    else
      sum = 0
      options.number.to_i.times {sum += Linael::DiceLauncher.new(options.dice.to_i).value}
    end
    answer(msg,"#{msg.who}: Sum = #{sum}")
  end

  #to much to be printed separatly
  define_method("to_much?") do |options|
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
