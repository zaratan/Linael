# -*- encoding : utf-8 -*-
module Linael

  class Modules::Caesar < ModuleIRC
  
    Name="caesar"
    Constructor="Aranelle"
  
    Help=[
      "Module: Caesar",
      " ",
      "=====Fonctions=====",
      "!caesar [string you want to code] => display your string, replacing each letter with the one following it in the alphabet",
      " ",
      "=====Options=====",
      "!caesar -s[a-z] -t[a-z]",
      "        -s    : Source letter (default: a)",
      "        -t    : Target letter (default: b)"
      ]
    def startMod
      add_module :cmd => [:caesar]
    end
    
    def caesar privMsg
      if Options.caesar? privMsg.message
        options = Options.new privMsg
        gap = AlphabetArray.index(options.target) - AlphabetArray.index(options.source)
        result = options.all.split(//).map do |c|
          c = AlphabetArray[AlphabetArray.index(c) + gap] if AlphabetArray.include? c
          c
        end
        answer(privMsg,result.join)
      end
    end
    
    AlphabetArray = %w(a b c d e f g h i j k l m n o p q r s t u v w x y z)
    
    class Options < ModulesOptions
      generate_to_catch :caesar => /^!caesar\s/

      generate_value_with_default :source => {regexp: /\s-s([a-z])\s/,default: "a"},
                                  :target => {regexp: /\s-t([a-z])\s/,default: "b"}
      
      def all
        @message.gsub(/^!caesar (-s[a-z] )?(-t[a-z] )?/,"").gsub("\r","")
      end
    end
  end
end
