
require 'date'

module Linael
  class Birthday
    attr_accessor :nick, :day, :year, :month, :remind

    def initialize(nick, whenz)
      @nick = nick
      @day = unparse_day(whenz)
      @month = unparse_month(whenz)
      @year = unparse_year(whenz)
      @remind = []
    end

    TIME_REGEX = /([0-9]+)\/([0-9]+)\/([0-9]+)/

    def unparse_day(whenz)
      whenz.match(TIME_REGEX)[1] || 0
    end

    def unparse_month(whenz)
      whenz.match(TIME_REGEX)[2] || 0
    end

    def unparse_year(whenz)
      whenz.match(TIME_REGEX)[3] || 0
    end

    def add_remind(nick)
      remind << nick.downcase unless remind.include?(nick.downcase)
      self
    end

    def del_remind(nick)
      remind.delete(nick.downcase)
      self
    end

    def change_date(whenz)
      @day = unparse_day(whenz)
      @month = unparse_month(whenz)
      @year = unparse_year(whenz)
      self
    end
  end
end

linael :birthday, require_auth: true, required_mod: ["tell"] do
  help [
    t.birthday.help.description,
    t.help.helper.line.white,
    t.help.helper.line.functions,
    t.birthday.help.function.add,
    t.birthday.help.function.tell,
    t.birthday.help.function.remind,
    t.birthday.help.function.unremind,
    t.help.helper.line.white,
    t.help.helper.line.admin,
    t.birthday.help.function.del,
  ]

  on_init do
    start_remind
  end

  db_hash :birthdays

  on :cmd, :birthday_add, /^!birthday\s+-add\s/ do |msg, options|
    birthdays[options.who] =
      if birthdays[options.who]
        birthdays[options.who].change_date(options.date)
      else
        Linael::Birthday.new(options.who, options.date)
      end
    answer(msg, t.birthday.act.add(options.who, options.date))
  end

  on :cmd_auth, :birthday_del, /^!birthday\s+-del\s/ do |msg, options|
    birthdays[options.who] = nil
    answer(msg, t.birthday.act.del(options.who))
  end

  on :cmd, :birthday_remind, /^!birthday\s+-remind\s/ do |msg, options|
    birthdays[options.who] = birthdays[options.who].add_remind(options.from_who)
    answer(msg, t.birthday.act.remind(options.who))
  end

  on :cmd, :birthday_unremind, /^!birthday\s+-unremind\s/ do |msg, options|
    birthdays[options.who] = birthdays[options.who].del_remind(options.from_who)
    answer(msg, t.birthday.act.unremind(options.who))
  end

  on :cmd, :birthday_tell, /^!birthday\s+[A-Za-z]/ do |msg, options|
    birthday = birthdays[options.who.downcase]
    before(options) do
      !birthday.nil?
    end
    answer(msg, "#{t.birthday.act.tell(birthday.day, birthday.month, birthday.year)} #{age(birthday.year)}")
  end

  on :cmd, :birthday_test, /^!test_birthday/ do |_msg, _options|
    remind
  end

  def tommorow_midnight
    Time.now.to_date.next_day.to_time
  end

  def start_remind
    remind
    at(tommorow_midnight) do
      start_remind
    end
  end

  def remind
    birthdays.each_value do |v|
      next unless (Time.now.day == v.day.to_i) && (Time.now.month == v.month.to_i)
      v.remind.each do |who|
        birthday_string = "#{t.birthday.print(v.nick, Time.now.strftime("%d/%m/%Y"))} #{age(v.year)}"
        mod("tell").add_tell(who, Linael::BotNick, birthday_string)
      end
    end
  end

  def age(year)
    if year.to_i != 0
      t.birthday.age(Time.now.year - year.to_i)
    else
      ""
    end
  end

  value date: /([0-9]+\/\S*)/
end
