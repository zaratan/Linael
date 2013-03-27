# -*- encoding : utf-8 -*-
module Linael
  class Modules::Morse < ModuleIRC
    
    Name="morse"

    def startMod
      add_module :cmd => :morse
    end

    def morse privMsg
      if Options.morse? privMsg.message
        options = Options.new privMsg
        answer(privMsg,options.all.split("").map{|c| MorseHash[c]}.join(" "))
      end
    end

    MorseHash = {"a" => "·−",
    "b" => "−···", 
   "c" => "−·−·", 
   "d" => "−··", 
   "e" => "·", 
   "f" => "··−·", 
   "g" => "−−·", 
   "h" => "····", 
   "i" => "··", 
   "j" => "·−−−", 
   "k" => "−·−", 
   "l" => "·−··", 
   "m" => "−−", 
   "n" => "−·", 
   "o" => "−−−", 
   "p" => "·−−·", 
   "q" => "−−·−", 
   "r" => "·−·", 
   "s" => "···", 
   "t" => "−", 
   "u" => "··−", 
   "v" => "···−", 
   "w" => "·−−", 
   "x" => "−··−", 
   "y" => "−·−−", 
   "z" => "−−··", 
   "é" => "··−··", 
   "è" => "·−··−", 
   "à" => "·−−·−", 
   " " => " ", 
   "ç" => "−·−··", 
   "." => "·−·−·−", 
   "," => "−−··−−", 
   "?" => "··−−··", 
   ";" => "−·−·−·", 
   ":" => "−−−···", 
   "!" => "−·−·−−",
   ")" => "−·−−·−", 
   "(" => "−·−−·", 
   "0" => "−−−−−",
  "1" => "·−−−−", 
  "2" => "··−−−", 
  "3" => "···−−", 
  "4" => "····−", 
  "5" => "·····", 
  "6" => "−····", 
  "7" => "−−···", 
  "8" => "−−−··", 
  "9" => "−−−−·"}

    class Options < ModulesOptions
      generate_to_catch :morse => /^!morse\s/
      generate_all
    end

  end
end
