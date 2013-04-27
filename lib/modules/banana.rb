# -*- encoding : utf-8 -*-

# Sing the banana song :)
linael :banana,require_auth: true do 

  Lyrics=[
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
  ]

  help [
    "Sing the banana song",
    " ",
    "=====Fonctions=====",
    "!banana                       => sing the banana song",
    "!banana -[add|del] username   => add/del a user for this module"
  ]

  on_init do
    @user=["zaratan"]
  end

  #sing
  on :cmd, :song, /^!banana[^A-z]*$/ do |msg,options|
    before(msg) do |msg|
      ((@user.detect {|user| msg.who.downcase.match(user)}) || (msg.private_message?))
    end
    Lyrics.each{|line| answer(msg,line);sleep(0.5)}
  end

  #add a user
  on :cmdAuth, :add_user, /!banana\s-add\s/ do |msg,options|
    answer(msg,"Oki doki! #{options.who} can now banana :)")
    @user << options.who.downcase

  end

  #del a user
  on :cmdAuth, :del_user, /!banana\s-del\s/ do |msg,options|
    answer(msg,"Oki doki! #{options.who} won't banana anymore :(")
    @user.delete options.who.downcase
  end

end
