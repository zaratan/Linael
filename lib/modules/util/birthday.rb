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
        p "ERROR in when: #{whenz}"
        return 0
      end
    end


    def unparse_month whenz
      if whenz =~ /[0-9]+\/([0-9]+)\/?[0-9]*/
        return $1
      else
        p "ERROR in when: #{whenz}"
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
      "Hey! It's #{nick} birthday today (#{Time.now.strftime("%d/%m/%Y") })!#{"(S)He is #{Time.now.year - year.to_i} years old!" if year.to_i != 0}"
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
    "Module to remind of birthday",
    " ",
    "######Functions######",
    "!birthday -add XXX DD/MM/YYYY => add a birthday for someone",
    "!birthday -del XXX            => del a birthday for someone (Admin)",
    "!birthday XXX                 => show XXX birthday",
    "!birthday -remind XXX         => remind you of XXX birthday",
    "!birthday -unremind XXX       => un-remind you of XXX birthday",
    "!start                        => start remind (Admin)"
  ]

  on_init do
    @birthday = {}
    @started = false
    start_remind
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
    answer(msg,"Oki doki! #{options.who} birthday is now #{options.date}.")
  end

  on :cmd_auth,:birthday_del,/^!birthday\s+-del\s/ do |msg,options|
    @birthday[options.who] = nil
    answer(msg,"Oki... I won't remind #{options.who} birthday anymore.")
  end

  on :cmd,:birthday_remind,/^!birthday\s+-remind\s/ do |msg,options|
    @birthday[options.who].add_remind(options.from_who)
    answer(msg,"I'll remind you of #{options.who} birthday.")
  end

  on :cmd,:birthday_unremind,/^!birthday\s+-unremind\s/ do |msg,options|
    @birthday[options.who].del_remind(options.from_who)
    answer(msg,"I won't remind you anymore of #{options.who} birthday :(")
  end

  on :cmd,:birthday_tell,/^!birthday\s+[A-Za-z]/ do |msg,options|
    answer(msg,"(S)he was born on #{@birthday[options.who].day}/#{@birthday[options.who].month}#{"/#{@birthday[options.who].year}" if @birthday[options.who].year != 0}!")
  end

  on :cmd,:birthday_test,/^!test_birthday/ do |msg,options|
    remind
  end

  define_method :tommorow_midnight do
    Time.now.to_date.next_day.to_time
  end

  on :cmdAuth, :start, /^!start/ do
    before(@started) {|start| !start}
    @started = true
    start_remind
  end

  define_method :start_remind do
    remind
    at(tommorow_midnight) do
      start_remind
    end
  end

  define_method :remind do
    @birthday.each do |k,v|
      if (Time.now.day == v.day.to_i and Time.now.month == v.month.to_i)
        v.remind.each do |who|
          mod("tell").instance.tell_list[who] ||= []
          mod("tell").instance.tell_list[who] << [Linael::BotNick,v.print_birthday]
        end
      end
    end
  end

  value :date => /([0-9]+\/\S*)/

end
