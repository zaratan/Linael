# -*- encoding : utf-8 -*-
require 'date'

module Linael

  class Birthday 

    attr_accessor :nick, :day, :year, :month, :remind

    def initialize(nick,whenz)
      @nick = nick
      @day = unparse_day(whenz)
      @month = unparse_month(whenz)
      @year = unparse_year(whenz)
      @remind = []
      end

    def unparse_day whenz
      if whenz =~ /([0-9]+)\/[0-9]+\/?[0-9]*/
        return $1
      else
        return 0
      end
    end


    def unparse_month whenz
      if whenz =~ /[0-9]+\/([0-9]+)\/?[0-9]*/
        return $1
      else
        return 0
      end
    end


    def unparse_year whenz
      if whenz =~ /[0-9]+\/[0-9]+\/([0-9]+)/
        return $1
      else
        return 0
      end
    end


    def print_birthday
      t.birthday.print(nick, Time.now.strftime("%d/%m/%Y")) +  if year.to_i != 0
              t.birtday.age(Time.now.year - year.to_i)
            else
              ""
            end
    end

    def add_remind nick
      remind << nick.downcase unless remind.include?(nick.downcase)
    end

    def del_remind nick
      remind.delete(nick.downcase)
    end

    def change_date whenz
      @day = unparse_day(whenz)
      @month = unparse_month(whenz)
      @year = unparse_year(whenz)
    end

  end
end

linael :birthday,require_auth: true,required_mod: ["tell"] do

  help [
    t.birthday.help.description,
    t.help.helper.line.white,
    t.help.helper.line.functions,
    t.birthday.function.add,
    t.birthday.function.tell,
    t.birthday.function.remind,
    t.birthday.function.unremind,
    t.help.helper.line.white,
    t.help.helper.line.admin,
    t.birthday.function.del,
    t.birthday.function.start
  ]

  on_init do
    @birthday = {}
    @started = false
  end

  on_load do
    @started = false
  end

  on :cmd,:birthday_add,/^!birthday\s+-add\s/ do |msg,options|
    if @birthday[options.who] != nil
      @birthday[options.who].change_date(options.date)
    else
      @birthday[options.who] = Linael::Birthday.new(options.who,options.date)
    end
    answer(msg,t.birthday.act.add(options.who, options.date))
  end

  on :cmd_auth,:birthday_del,/^!birthday\s+-del\s/ do |msg,options|
    @birthday[options.who] = nil
    answer(msg, t.birthday.act.del(options.who))
  end

  on :cmd,:birthday_remind,/^!birthday\s+-remind\s/ do |msg,options|
    @birthday[options.who].add_remind(options.from_who)
    answer(msg, t.birthday.act.remind(options.who))
  end

  on :cmd,:birthday_unremind,/^!birthday\s+-unremind\s/ do |msg,options|
    @birthday[options.who].del_remind(options.from_who)
    answer(msg,t.birthday.act.unremind(options.who))
  end

  on :cmd,:birthday_tell,/^!birthday\s+[A-Za-z]/ do |msg,options|
    answer(msg,t.birthday.act.tell(@birthday[options.who].day,@birthday[options.who].month},@birthday[options.who].year))
  end

  on :cmd,:birthday_test,/^!test_birthday/ do |msg,options|
    remind
  end

  def tommorow_midnight 
    Time.now.to_date.next_day.to_time
  end

  on :cmdAuth, :start, /^!start/ do
    before(@started) {|start| !start}
    @started = true
    start_remind
  end

  def start_remind
    remind
    at(tommorow_midnight) do
      start_remind
    end
  end

  def remind 
    @birthday.each do |k,v|
      if (Time.now.day == v.day.to_i and Time.now.month == v.month.to_i)
        v.remind.each do |who|
          mod("tell").add_tell(who,Linael::BotNick,v.print_birthday)
        end
      end
    end
  end

  value :date => /([0-9]+\/\S*)/

end
