# -*- encoding : utf-8 -*-

#A module to tell something to a pseudo next time the bot see it
linael :tell do

  help [
    "A module to tell something to somebody next time the bot see her",
    " ",
    "#####Function#####",
    "!tell somebody : something => tell something to somebody"
  ]

  on_init do
    @tell_list = Hash.new()
  end

  #add a tell
  on :cmd, :tell_add, /^!tell/ do |msg,options|

    who_tell = options.who.gsub(":","")

    @tell_list[who_tell] ||= []
    @tell_list[who_tell] = @tell_list[who_tell] << [options.from_who,options.all.gsub(/^.*:/,"")]
    answer(msg,"Oki doki! I'll tell this to #{who_tell} :)")

  end

  #tell if in tell_list
  [:join,:nick].each do |type|
    on type, "tell_on_#{type}" do |msg|
      who = msg.who if type == :join
      who = msg.newNick if type == :nick

      if @tell_list.has_key?(who)
        @tell_list[who].each do |message|
          talk(who,"Hey! #{message[0]} told me this: #{message[1]}")
        end
        @tell_list.delete(who)
      end

    end
  end

end
