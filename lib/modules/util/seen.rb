linael :seen do
  help [
    t.seen.help.description,
    t.help.helper.line.white,
    t.help.helper.line.functions,
    t.seen.help.function.seen,
    t.seen.help.function.first
  ]

  on :cmd, :seen, /^!seen\s/ do |msg, options|
    to_print = find_user(options) { |seens| seens.max_by { |_k, u| u.last_seen } }
    answer(msg, t.seen.seen(to_print.last_seen.ago, to_print.last_act.to_s))
  end

  on :cmd, :first_seen, /^!first_seen\s/ do |msg, options|
    to_print = find_user(options) { |seens| seens.min_by { |_k, u| u.first_seen } }
    answer(msg, t.seen.first(to_print.first_seen.ago, to_print.first_act.to_s))
  end

  %i[quit cmd cmd_auth msg nick join part].each do |type|
    on type, "seen_#{type}".to_sym do |msg|
      update_user(msg.sender.downcase, msg)
    end
  end

  def find_user(options)
    to_parse = options.all.delete("\r").delete(" ").downcase
    seens = users.find_all { |_k, u| u.nick == to_parse || u.host == to_parse }
    to_print = yield(seens)
    to_print.last
  end

  def update_user(user_name, msg)
    if users[user_name]
      users[user_name].update(msg)
    else
      users[user_name] = Linael::User.new(msg)
    end
  end

  attr_accessor :users

  on_init do
    @users = {}
  end
end

class Time
  include R18n::Helpers

  def ago
    sec = (Time.now - self).round
    sec = 1 if sec == 0

    mm, ss = sec.divmod(60)
    hh, mm = mm.divmod(60)
    dd, hh = hh.divmod(24)

    result = [t.day(dd), t.hour(hh), t.minute(mm), t.second(ss)]
    result.delete("")
    result.join(", ").gsub(/(, )([^,]*)$/) { |_s| " #{t.and} #{$2}" } + " #{t.ago}"
  end
end

# represent a User for Seen module
class Linael::User
  # should be obvious
  attr_accessor :nick, :host, :last_seen, :last_act, :first_seen, :first_act

  # init
  def initialize(msg)
    @nick = msg.sender.downcase
    @host = msg.identification.downcase
    @first_seen = Time.now
    @first_act = msg.element
    @last_seen = Time.now
    @last_act = msg.element
  end

  def update(msg)
    @host = msg.identification.downcase
    @last_seen = Time.now
    @last_act = msg.element
  end
end
