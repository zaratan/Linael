require 'json'

linael :linael_translation, require_auth: true do

  help [
    t.linaeltranslation.help.description,
    t.help.helper.line.white,
    t.help.helper.line.functions,
    t.linaeltranslation.help.function.reload,
    t.linaeltranslation.help.function.set
  ]

  def load_translation
    if translations.kind_of? Array
      R18n.set (translations + ['en'])
    else
      R18n.set [translations, 'en']
    end
    R18n.get.reload!
  end

  attr_accessor :translations

  on_init do
    @translations = LinaelLanguages
  end

  on_load do
    load_translation
  end

  on :cmdAuth, :reload, /^!translation\s-reload\s/ do |msg|
    load_translation
    answer(msg,t.linaeltranslation.act.reload)
  end

  on :cmdAuth, :set, /^!translation\s-set\s/ do |msg,options|
    @translations = JSON.parse(options.who)
    load_translation
    answer(msg,t.linaeltranslation.act.set(options.who))
  end

end
