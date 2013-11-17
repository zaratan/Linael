# -*- encoding : utf-8 -*-

#A module to tell something to a pseudo next time the bot see it
linael :tell do

  help [
    t.tell.help.description,
    t.help.helper.line.white,
    t.help.helper.line.functions,
    t.tell.help.function.tell
  ]

  on_init do
    @tell_list = {}
  end

  attr_accessor :tell_list

  def add_tell who_tell,from,message
    @tell_list[who_tell] ||= []
    @tell_list[who_tell] << [from,message, Time::now.strftime(t.tell.time) ]
  end

  #add a tell
  on :cmd, :tell_add, /^!tell/ do |msg,options|

    who_tell = options.who.downcase.gsub(/[,:]$/,"")
    add_tell who_tell, options.from_who, options.all.gsub(/^\s*\S*\s/,"")
    answer(msg,t.tell.act.tell(who_tell))

  end

  #tell if in tell_list
  [:join,:nick,:msg].each do |type|
    on type, "tell_on_#{type}" do |msg|
      who = msg.who.downcase if type == :join
      who = msg.new_nick.downcase if type == :nick
      who = msg.who.downcase if type == :msg

      if @tell_list.has_key?(who)
        to_tell = @tell_list[who]
        @tell_list.delete(who)
        to_tell.each do |message|
          talk(who,t.tell.act.do(message[0], message[1], message[2]),msg.server_id)
          sleep(1)
        end
      end

    end
  end

end
