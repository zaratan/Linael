# -*- encoding : utf-8 -*-

linael :seen do

on :cmd, :seen, /!seen\s/ do |msg,options|
  to_parse= options.all.gsub("\r","").gsub(" ","").downcase
  seens = @users.find_all {|k,u| u.nick == to_parse || u.host == to_parse}
  to_print = seens.max_by {|k,u| u.last_seen}
  to_print = to_print.last
  p to_print
  answer(msg,"Last seen #{ago(to_print.last_seen)} under #{to_print.nick} with #{to_print.host} doing: #{to_print.last_act.to_s}")
end

define_method "ago" do |time|

  sec = (Time.now - time).round

  mm, ss = sec.divmod(60)
  hh, mm = mm.divmod(60)
  dd, hh = hh.divmod(24)

  result = ""
  if dd != 0
    result += "#{dd} day#{"s" if dd > 1} "
  end
  if result != "" and ss == 0 and hh != 0 and mm == 0
    result += "and "
  end
  if hh != 0
    result += "#{hh} hour#{"s" if hh >1} "
  end
  if result != "" and ss == 0 and mm != 0
    result += "and "
  end
  if mm != 0
    result += "#{mm} minute#{"s" if mm >1} "
  end
  if result != "" and ss != 0
    result += "and "
  end
  if ss != 0
    result += "#{ss} second#{"s" if ss >1} "
  end
  result += "ago"

end

[:quit,:msg,:nick,:join,:part].each do |type|
  on type, :seen_part do |msg|
    @users[msg.sender.downcase] = Linael::User.new(msg)
  end
end


on_init do
  @users={}
end

end

#represent a User for Seen module
class Linael::User

  #should be obvious
  attr_accessor :nick,:host,:last_seen,:last_act
  
  #init
  def initialize(msg)
    @nick = msg.sender.downcase
    @host = msg.identification.downcase
    @last_seen = Time.now
    @last_act = msg
  end


end
