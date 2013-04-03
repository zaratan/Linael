# -*- encoding : utf-8 -*-
module Linael

  class Modules::Caesar < ModuleIRCName="caesar"
  
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
    def code privMsg
      if Options.caesar? privMsg.message
        options = Options.new privMsg
        gap = options.target.index - options.source.index
        answer(privMsg,options.all.split(//).map{|c| AlphabetArray[c + gap]})
      end
    end
    
    AlphabetArray = %w(a b c d e f g h i j k l m n o p q r s t u v w x y z)
    
    class Options < ModulesOptions
      generate_to_catch :caesar => /^!caesar\s/
      generate_meth :name => "source", :regexp => /\s-s(a-z)\s/, :default => "a"
      generate_meth :name => "target", :regexp => /\s-t(a-z)\s/, :default => "b"
      
      def all
        @message.slice /^!caesar -s([a-z]) -t([a-z]) /
      end
    end
  end
end
