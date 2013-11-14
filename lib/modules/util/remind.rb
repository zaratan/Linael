# -*- encoding : utf-8 -*-

# A module to remind things
linael :remind,require_auth: true do

  help [
    t.remind.help.description,
    t.help.helper.line.white,
    t.help.helper.line.functions,
    t.remind.help.function.me,
    t.help.helper.line.white,
    t.help.helper.line.admin,
    t.remind.help.function.else,
    t.help.helper.line.white,
    t.remind.help.time.head,
    t.remind.help.time.line1,
    t.remind.help.time.line2,
    t.remind.help.time.line3
  ]

  #transform string to date
  def make_time stime

    stime.gsub!(/\s+and\s+/,"+")
    stime.gsub!(/\s+/,".")
    stime = "(" + stime
    stime += ").seconds.from_now"
    eval(stime)

  end

  def remind_aux options, time, who, server_id=nil
    who ||= options.from_who
    unless time
      time = make_time(options.time)
      @reminds << [options,time,server_id]
    end
    at(time,options) do |options|
      talk(who,t.remind.remind(options.action.gsub("\r","")),server_id)
      @reminds.delete_if {|rem| rem[1] < Time.now}
    end
  end

  on_init do
    @reminds = []
  end

  on_load do
    @reminds.each do |rem|
      remind_aux(rem[0],rem[1],nil,rem[2]) if Time.now < rem[1]
    end
  end

  #only catch a date (no exit or whatever)
  value :time   => /in\s+((seconds?|minutes?|hours?|days?|weeks?|months?|years?|and|[0-9]|\s)*)\s+to/,
        :action => /\sto\s+(.*)/

  #remind me
  on :cmd, :remind, /^!remind\s+me\s/ do |msg,options|

    remind_aux(options,nil,nil,msg.server_id)
    answer(msg,t.remind.act.me(options.time))
    
  end
  
  #remind somebody else
  on :cmd_auth, :remind_auth, /^!remind\s/ do |msg,options|
    before(options) do |options|
      options.who != "me"
    end

    remind_aux(options,nil,options.who,msg.server_id)
    answer(msg,t.remind.act.else(options.who, options.time))

  end

end
