class Linael::Birthday 

  attr_accessor :nick, :when, :remind

  def initialize(nick,when)
    @nick = nick
    @day = unparse_day(when)
    @month = unparse_month(when)
    @year = unparse_year(when)
    @remind = []
    end

  def unparse_day when
    if when =~ /([0-9]+)\/[0-9]+\/?[0-9]*/
      return $1
    else
      p "ERROR in when: #{when}"
      return 0
    end
  end


  def unparse_month
    if when =~ /[0-9]+\/([0-9]+)\/?[0-9]*/
      return $1
    else
      p "ERROR in when: #{when}"
      return 0
    end
  end


  def unparse_year
    if when =~ /[0-9]+\/[0-9]+\/([0-9]+)/
      return $1
    else
      return 0
    end
  end


  def print_birthday
    "Hey! It's #{nick} birthday today (#{Time.now.strftime("%d/%m/%Y") })!#{"(S)He is #{Time.now.year - year} years old!" if year != 0}"
  end

  def add_remind nick
    remind << nick.downcase unless remind.include?(nick.downcase)
  end

  def del_remind nick
    remind.delete(nick.downcase)
  end

  end

linael :birthday,require_auth: true,required_mod: ["tell"] do

  help [
    "Module to remind of birthday",
    " ",
    "######Functions######",
    "!birthday -add XXX DD/MM/YYYY => add a birthday for someone",
    "!birthday -del XXX            => del a birthday for someone",
    "!birthday XXX                 => show XXX birthday",
    "!birthday -remind XXX         => remind you of XXX birthday",
    "!birthday -unremind XXX       => un-remind you of XXX birthday"
  ]

  on_init do
    @birthday={}
  end

  on :cmd,:birthday_add,/^!birthday\s+-add\s/ do
    @birthday[options.who] = Linael::Birthday.new(options.who,options.date)
    answer(msg,"Oki doki! #{options.who} birthday is now #{options.date}.")
  end

  on :cmd,:birthday_del,/^!birthday\s+-del\s/ do
    @birthday[options.who] = nil
    answer(msg,"Oki... I won't remind #{options.who} birthday anymore.")
  end

  on :cmd,:birthday_remind,/^!birthday\s+-remind\s/ do
    @birthday[options.who].add_remind(options.from_who)
    answer(msg,"I'll remind you of #{options.who} birthday.")
  end

  on :cmd,:birthday_unremind,/^!birthday\s+-unremind\s/ do
    @birthday[options.who].del_remind(options.from_who)
    answer(msg,"I won't remind you anymore of #{options.who} birthday :(")
  end

  on :cmd,:birthday_tell,/^!birthday\s+[A-Za-z]/ do
    answer(msg,"(S)he was born on #{@birthday[options.who].day}/#{@birthday[options.who].month}#{"/#{@birthday[options.who].year}" if @birthday[options.who].year != 0}!")
  end

  define_method :start_remind do
      remind
    at("demain minuit") do
      start_remind
    end
  end

  define_method :remind do
    @birthday.each do |k,v|
      if (Time.now.day == v.day and Time.now.month == v.month)
        v.remind.each do |who|
          mod("tell").tell_list[who] ||= []
          mod("tell").tell_list[who] << ["Linael",v.print_birthday]
        end
      end
    end
  end

  value :date => /([0-9]+\/\S*)/

end
