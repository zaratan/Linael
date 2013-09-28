# -*- encoding : utf-8 -*-
linael :grands_anciens do

  on_init do
    @not_invoqued=Linael::GrandsAnciens.keys
  end

  on :cmd, :sacrifice, /^!sacrifice/ do |msg,options|
    sacrifice = options.who 
    sacrifice = msg.sender if sacrifice.downcase == "cultiste" or sacrifice.downcase == "zaratan"
    old= choose_old_one
    talk(msg.where,"#{old}, #{Linael::GrandsAnciens[old]}, Je t'invoque! Viens à moi!",msg.server_id)

    kick_channel msg.server_id,
                  :dest => msg.where,
                  :who  => sacrifice,
                  :msg  => "For greater good!"
  end

  def choose_old_one
    @not_invoqued.sample
  end

  on :join, :praise do |msg|
    talk(msg.where,Linael::GrandsAnciens[msg.who],msg.server_id)
  end

end

Linael::GrandsAnciens = {"Arwassa" => "Celui qui crie silencieusement sur la colline",
"Aphoom-Zhah" => "La Flamme Froide, Seigneur du Pôle",
"Atlach-Nacha" => "Le Dieu-Araignée",
"Baoht_Zuqqa-Mogg" => "Celui qui amène la Pestilence",
"Basatan" => "Le maître des Crabes",
"Bokrug" => "Le Grand Lézard d’eau, la malédiction de Sarnath",
"Bugg-Shash" => "The Drowner, le Noir",
"Byatis" => "le Crapaud de Berkeley, celui qui a une barbe de serpents",
"Chaugnar_Faugn" => "l’Horreur dans les Collines, le Nourrisseur",
"Cthugha" => "la Flamme Vivante, le Dévoreur",
"Cthulhu" => "Le Dieu Dormeur, Maître de R’lyeh, Kthulhut",
"Cthylla" => "Secret Seed of Cthulhu",
"Cyaegha" => "l’oeil Destructeur, les Ténèbres qui Marchent",
"Cynothoglys" => "The Mortician God",
"Dagon" => "Père des Profonds",
"Eihort" => "la Bête Pâle, Dieu du Labyrinthe",
"Ghatanothoa" => "l’Usurpateur, Dieu du Volcan",
"Glaaki" => "l’Habitant du Lac, Seigneur des Rêves Défunts",
"Gloon" => "Corrupteur de la Chair, Maître du Temple",
"Gol-Goroth" => "le Dieu de la Pierre Sombre",
"Hastur" => "l’Innommable, Celui dont le Nom ne doit pas être dit",
"Mother_Hydra" => "Mère des Profonds",
"Iod" => "le Chasseur Etincelant",
"Ithaqua" => "le Marcheur du Vent, le Wendigo, Dieu du Grand Silence Blanc",
"Juk-Shabb" => "Dieu de Yekub",
"Lloigor" => "Arpenteur des Etoiles",
"MNagalah" => "le Grand Dieu Cancer, le Tout-dévorant",
"Mordiggian" => "le Dieu Charnel, la Grande goule, Seigneur de Zul-Bha-Sair",
"Nug_and_Yeb" => "les Blasphèmes Jumeaux",
"Nyogtha" => "la Chose qui ne devrait pas être, celui qui hante l’abîme rouge",
"Quachil_Uttaus" => "Celui qui marche dans la poussière (du temps)",
"Rhan-Tegoth" => "celui du Trône d’Ivoire",
"Rlim-Shaikorth" => "le Ver Blanc",
"Shudde_Mell" => "le Grand Chthonien",
"Tsathoggua" => "Le Dormeur de N’kai, le Dieu-Crapaud, Zhothaqqua, Sadagowah",
"Vulthoom" => "Gsarthotegga, Le Dormeur de Ravermos",
"Xchllat-aa" => "Seigneur des Grands Anciens, le Dieu Non-né, l’Ennemi de toute Vie",
"YGolonac" => "le Profanateur",
"Yhkmaat" => "Queen of a Thousand Eyes",
"Yhoundeh" => "la Déesse Cerf",
"Yig" => "Père des Serpents",
"Ythogtha" => "la Chose dans la Fosse",
"Zhar" => "l’Obscénité Jumelle",
"Zushakon" => "Nuit Ancienne, Zul-Che-Quon",
"Zvilpoggua" => "Ossadagowah, le Diable du Ciel",
"Zystulzhemgni" => "Matriarche des Essaims",
"Hagarg Ryonis" => "Celui qui attend à l’affût",
"Bast" => "Déesse des Chats, Pasht",
"Hypnos" => "Seigneur du Sommeil",
"Ntse-Kaambl" => "dont la Splendeur a brisé des Mondes",
"Nodens" => "le Chasseur, Seigneur du Grand Abîme",
"Vordavoss" => "Celui qui trouble les Sables, Celui qui attend dans les Ténèbres Extérieures",
"Abhoth" => "Source de l’Impureté",
"Azathoth" => "Celui du Gouffre, Sultan des Démons, Chaos Atomique bouillonnant",
"Cthalpa" => "l’Intérieur",
"Daoloth" => "Celui qui écarte les voiles",
"Ghroth" => "Celui qui Passe dans les Ténèbres",
"Mormo" => "L’Hydre, la Lune aux Mille Visages",
"Nyarlathotep" => "le Chaos Rampant, Messager d’Azathoth, L’Homme Noir",
"Shub-Niggurath" => "la Chèvre Noire des Bois, la Chèvre aux Mille Chevreaux, épouse de Celui-qu’il-ne faut-pas-nommer",
"Tulzscha" => "la Flamme Verte",
"Ubbo-Sathla" => "le Démiurge, la Source Inengendrée",
"Xiurhn" => "Gardien du Sombre Joyau",
"Yidhra" => "Sorcière des Rêves",
"Yog-Sothoth" => "le Tout en Un, la Clé et la Porte",
"LAbomination_de_Dunwich" => "fils de Yog-Sothoth",
"Saboth_lAncien" => "la Goule Souriante",
"Ubb" => "Père des Vers"}
