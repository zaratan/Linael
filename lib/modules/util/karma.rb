# -*- encoding : utf-8 -*-

#A module to count ++ on people
linael :karma do

  help [
    t.karma.help.description,
    t.help.helper.line.white,
    t.help.helper.line.functions,
    t.karma.help.function.self,
    t.karma.help.function.karma,
    t.karma.help.function.plus_one,
    t.karma.help.function.minus_one
  ]

  on :msg, :add_karma, /\S\s*(\+\+|\+1)/ do |msg,options|
    to_karma(msg.server_id,options) {|k| k.karma += 1}
  end

  on :msg, :del_karma, /\S\s*(--|-1)/ do |msg,options|
    to_karma(msg.server_id,options) {|k| k.karma -= 1}
  end

  def to_karma(server,options,&block)
    to_who = options.karma.downcase
    unless options.from_who.downcase == to_who
      k = karma_for(msg.server_id, to_who)
      block.call(k) if block_given?
      k.save
    end

  end

  def karma_for(server,name)
    Linael::Karma.find_or_create_by(server_id: server, name: name)
  end

  on :cmd, :karma, /^!karma\s/ do |msg,options|
    karma = karma_for(msg.server_id,options.who.downcase).karma
    answer(msg, t.karma.karma(options.who,karma))
  end

  value :karma => /(\w*)\S*\s*(\+|-)/

end
