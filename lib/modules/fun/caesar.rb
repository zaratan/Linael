# A module to make caesar code
linael :caesar, author: "Aranelle" do
  help [
    t.caesar.help.description,
    t.help.helper.line.white,
    t.help.helper.line.functions,
    t.caesar.help.function.caesar,
    t.help.helper.line.white,
    t.help.helper.line.options,
    t.caesar.help.option.source,
    t.caesar.help.option.target
  ]

  # encode
  on :cmd, :caesar, /^!caesar\s/ do |msg, options|
    gap = AlphabetArray.index(options.target) - AlphabetArray.index(options.source)
    result = format_all(options).split(//).map do |c|
      c = AlphabetArray[(AlphabetArray.index(c) + gap) % 26] if AlphabetArray.include? c
      c
    end
    answer(msg, result.join)
  end

  # The alphabet
  AlphabetArray = %w(a b c d e f g h i j k l m n o p q r s t u v w x y z).freeze

  value_with_default source: { regexp: /\s-s([a-z])\s/, default: "a" },
                     target: { regexp: /\s-t([a-z])\s/, default: "b" }

  def format_all(options)
    options.all.gsub(/(-s[a-z]\s+)?(-t[a-z]\s+)?/, "").delete("\r")
  end
end
