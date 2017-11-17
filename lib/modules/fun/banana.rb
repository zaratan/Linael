# Sing the banana song :)
linael :banana, require_auth: true do
  # Lyrics of the banana song
  Linael::Lyrics = [
    "http://www.youtube.com/watch?v=vNie6hVM8ZI",
    " ",
    "ba-ba-ba-ba-ba-nana (2x)",
    " ",
    "banana-ah-ah (ba-ba-ba-ba-ba-nana)",
    "potato-na-ah-ah (ba-ba-ba-ba-ba-nana)",
    "banana-ah-ah (ba-ba-ba-ba-ba-nana)",
    "togari noh pocato-li kani malo mani kano",
    "chi ka-baba, ba-ba-nana",
    " ",
    "yoh plano boo la planonoh too",
    "ma bana-na la-ka moobi talamoo",
    "ba-na-na",
    " ",
    "ba-ba (ba-ba-ba-ba-banana)",
    "PO-TAE-TOH-OH-OH (ba-ba-ba-ba-banana)",
    "togari noh pocato li kani malo mani kano",
    "chi ka-ba-ba, ba-ba-naNAAAHHHH!!!!"
  ].freeze

  help [
    t.banana.help.description,
    t.help.helper.line.white,
    t.help.helper.line.functions,
    t.banana.function.banana,
    t.help.helper.line.white,
    t.help.helper.line.admin,
    t.banana.function.user
  ]

  on_init do
    @user = [Linael::Master]
  end

  # sing
  on :cmd, :song, /^!banana[^A-z]*$/ do |msg, _options|
    before(msg) do |msg|
      ((@user.detect { |user| msg.who.downcase.match(user) }) || msg.private_message?)
    end
    Linael::Lyrics.each{ |line| answer(msg, line); sleep(0.5) }
  end

  # add a user
  on :cmd_auth, :add_user, /!banana\s-add\s/ do |msg, options|
    answer(msg, t.banana.user.add(options.who))
    @user << options.who.downcase
  end

  # del a user
  on :cmd_auth, :del_user, /!banana\s-del\s/ do |msg, options|
    answer(msg, t.banana.user.del(options.who))
    @user.delete options.who.downcase
  end
end
