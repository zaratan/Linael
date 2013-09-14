# -*- encoding : utf-8 -*-

# A module to remind things
linael :remind,require_auth: true do

  help [
    "Module: Remind",
    " ",
    "A module to remind things",
    "#####Functions#####",
    "!remind me in [time] to something => remind you in [time] to do something",
    "!remind somebody in [time] to something => remind somebody in [time] to do something (only bot op)",
    " ",
    "#####Time#####",
    "It can take seconds,minutes,hours,days,weeks,months and years",
    "It add time with 'and'",
    "Example: 1 day and 2 hours and 30 minutes"
  ]

  #transform string to date
  define_method "make_time" do |stime|

    stime.gsub!(/\s+and\s+/,"+")
    stime.gsub!(/\s+/,".")
    stime = "(" + stime
    stime += ").seconds.from_now"
    eval(stime)

  end

  define_method "remind_aux" do |options,time,who|
    who ||= options.from_who
    unless time
      time = make_time(options.time)
      @reminds << [options,time]
    end
    at(time,options) do |options|
      talk(who,"Hey! Remind to #{options.action.gsub("\r","")}")
      @reminds.delete_if {|rem| rem[1] < Time.now}
    end
  end

  on_init do
    @reminds = []
  end

  on_load do
    @reminds.each do |rem|
      p rem
      remind_aux(rem[0],rem[1],nil) if Time.now < rem[1]
    end
  end

  #only catch a date (no exit or whatever)
  value :time   => /in\s+((seconds?|minutes?|hours?|days?|weeks?|months?|years?|and|[0-9]|\s)*)\s+to/,
        :action => /\sto\s+(.*)/

  #remind me
  on :cmd, :remind, /^!remind\s+me\s/ do |msg,options|

    remind_aux(options,nil,nil)
    answer(msg,"Oki doki! I'll remind you this in #{options.time}")
    
  end
  
  #remind somebody else
  on :cmdAuth, :remind_auth, /^!remind\s/ do |msg,options|
    before(options) do |options|
      options.who != "me"
    end

    remind_aux(options,nil,options.who)
    answer(msg,"Oki doki! I'll remind this to #{options.who} in #{options.time}")

  end

end
