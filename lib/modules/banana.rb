# -*- encoding : utf-8 -*-
module Linael
  class Modules::Banana < ModuleIRC

    Name="banana"

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

    User=[
      "nayo",
      "zaratan",
      "lilin",
      "grunthi",
      "alya",
      "zag",
      "sayaelis",
      "tantraa"
    ]

    Help=[
      "Module: Banana",
      " ",
      "=====Fonctions=====",
      "!banana                       => sing the banana song",
      "!banana -[add|del] username   => add/del a user for this module"
    ]

    def startMod
      add_module({cmd: [:song],
                  cmdAuth: [:addUser,
                            :delUser]})
    end

    def song privMsg
      if (module? privMsg)
        Lyrics.each{|line| answer(privMsg,line);sleep(0.5)}
      end
    end

    def addUser privMsg
      if (privMsg.message =~ /!banana.*-add\s*(\S*)/)
        answer(privMsg,"Oki doki! #{$~[1]} can now banana :)")
        User << $~[1].downcase
      end
    end

    def delUser privMsg
      if (privMsg.message =~ /!banana\s*-del\s*(\S*)/)
        answer(privMsg,"Oki doki! #{$~[1]} won't banana anymore :(")
        User.delete $~[1].downcase
      end
    end

    def module? privMsg
      (privMsg.message.encode.downcase =~ /^!banana[^A-z]*$/) && ((User.detect {|user| privMsg.who.downcase.match(user)}) || (privMsg.private_message?))
    end

  end
end
