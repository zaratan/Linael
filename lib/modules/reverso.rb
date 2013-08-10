# -*- encoding : utf-8 -*-
require 'reverso'
linael :reverso do


Linael::Translation=[
  'Arabic', 
  'Chinese',
  'Dutch', 
  'English',
  'French',
  'Hebrew',
  'German',
  'Italian',
  'Japanese',
  'Portuguese',
  'Russian',
  'Spanish',
  'Romanian'
]

  help [
    "Translate with reverso.net",
    " ",
    "!reverso -f[from] -t[to] message => convert a message from a language to another.",
    "!reverso_lang                    => Answer the different languages"
  ]

  on :cmd, :reverso, /^!reverso\s/ do |msg,options|
    result=Reverso::Translator.translate(options.trans, :from => options.from, :to => options.to)
    answer(msg,"#{options.from_who}: #{result}")
  end

  on :cmd, :reverso_lang, /^!reverso_lang/ do |msg,options|
    talk(options.from_who,"[#{Linael::Translation.join(", ")}]") 

  end

  value :from  => /-f(\S*)\s/,
        :to    => /-t(\S*)\s/,
        :trans => /\s([^-][^\r\n]*)/

end
