# -*- encoding : utf-8 -*-

linael :seen do

  help [
    t.seen.help.description,
    t.help.helper.line.white,
    t.help.helper.line.functions,
    t.seen.help.function.seen,
    t.seen.help.function.first
  ]

  on :cmd, :seen, /^!seen\s/ do |msg,options|
    to_print = find_seen(msg, options) 
    answer(msg,t.seen.seen(to_print.last_seen_time.ago, to_print.last_seen))
    answer(msg,t.seen.previous(to_print.previous_last_seen_time.ago, to_print.previous_last_seen)) if to_print.previous_last_seen
  end

  on :cmd, :first_seen, /^!first_seen\s/ do |msg,options|
    to_print = find_seen(msg, options) 
    answer(msg,t.seen.first(to_print.first_seen_time.ago, to_print.first_seen.to_s))
  end

  [:quit,:cmd,:cmd_auth,:msg,:nick,:join,:part].each do |type|
    on type, "seen_#{type}".to_sym do |msg|
      update_seen(msg, msg.sender.downcase)
    end
  end

  def find_seen(msg, options, user = nil, &block)
    p user ||= options.all.gsub("\r","").gsub(" ","").gsub("*","%").downcase 
    seen = Linael::SeenUser.where('server_id == ? AND (user LIKE ? OR ident LIKE ?)', msg.server_id,user,user).order(last_seen_time: :desc).first
    if block_given? 
      block.call(seen)
    else
      seen
    end
  end

  def update_seen(msg, user)
    find_seen(msg, nil, user) do |u|
      return create_seen(msg , msg.server_id) unless u
      u.previous_last_seen_time = u.last_seen_time
      u.previous_last_seen = u.last_seen
      u.last_seen_time = Time.now
      u.last_seen = msg.element.to_s
      u.save
    end 
  end

  def create_seen(msg, server)
    Linael::SeenUser.create(
      server_id: server,
      user: msg.sender.downcase,
      ident: msg.identification.downcase,
      last_seen:  msg.element.to_s,
      last_seen_time: Time.now,
      first_seen: msg.element.to_s,
      first_seen_time: Time.now
    ) 
  end

end
