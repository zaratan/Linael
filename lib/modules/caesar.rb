# -*- encoding : utf-8 -*-

# A module to make caesar code
linael :caesar, constructor:"Aranelle" do

  help [
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

  #encode
  on :cmd,:caesar,/^!caesar\s/ do |msg,options|
    gap = AlphabetArray.index(options.target) - AlphabetArray.index(options.source)
    result = all(options).split(//).map do |c|
      c = AlphabetArray[(AlphabetArray.index(c) + gap) % 26] if AlphabetArray.include? c
      c
    end
    answer(msg,result.join)
  end

  #The alphabet
  AlphabetArray = %w(a b c d e f g h i j k l m n o p q r s t u v w x y z)


  value_with_default :source => {regexp: /\s-s([a-z])\s/,default: "a"},
    :target => {regexp: /\s-t([a-z])\s/,default: "b"}

  define_method "all" do |options|
    options.all.gsub(/^!caesar\s+(-s[a-z]\s+)?(-t[a-z]\s+)?/,"").gsub("\r","")
  end
end
