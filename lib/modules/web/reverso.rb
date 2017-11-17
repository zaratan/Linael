
require 'reverso'
linael :reverso do
  Linael::Translation = [
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
  ].freeze

  help [
    t.reverso.help.description,
    t.reverso.help.source,
    t.help.helper.line.white,
    t.help.helper.line.functions,
    t.reverso.help.function.reverso,
    t.reverso.help.function.lang
  ]

  on :cmd, :reverso, /^!reverso\s/ do |msg, options|
    result = Reverso::Translator.translate(options.trans, from: options.from, to: options.to)
    answer(msg, t.reverso.act.reverso(options.from_who, result))
  end

  on :cmd, :reverso_lang, /^!reverso_lang/ do |msg, options|
    talk(options.from_who, t.reverso.act.lang(Linael::Translation.join(", ")), msg.server_id)
  end

  value from: /-f(\S*)\s/,
        to: /-t(\S*)\s/,
        trans: /\s([^-][^\r\n]*)/
end
