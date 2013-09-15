# -*- encoding : utf-8 -*-

#A module for adminsitration
linael :admin, require_auth: true do

  help [
    "Administration module",
    " ",
    "#####Functions####",
    "!admin_join|!join|!j [chan]                 => Join chan",
    "!admin_part|!part    [chan]                 => Part chan",
    "!admin_kick|!kick|!k [chan] [who] [:reason] => Kick who on chan for reason",
    "!admin_die                                  => Quit",
    "!admin_mode|!mode [chan] [what] [:args]     => Change what mode on chan with args options",
    "!admin_reload [file]                        => Reload a file",
  ]


  on_init do
    @chans =[]
  end

  #List of joined chan
  attr_accessor :chans

  #on load rejoin all the chan
  on_load do
    @chans.each {|chan| join_channel :dest => chan}
  end

  def join_act chan
    chans << chan unless chans.include? chan
    join_channel :dest => chan
  end

  def part_act chan
    talk(chan,"cya all!")
    chans.delete chan
    part_channel :dest => chan
  end

  def die_act
    quit_channel :msg => "I'll miss you!"
    exit 0
  end

  def kick_act who,chan,reason
    talk(chan,"bye #{who}!")
    kick_channel :dest => chan,
                 :who  => who, 
                 :msg  => reason
  end

  def mode_act chan,what,args
    mode_channel  :dest => chan,
                  :what => what,
                  :args => args
  end

  #join chan
  on :cmdAuth, :join, /^!admin_join\s|^!join\s|^!j\s/ do |msg,options|
    answer(msg,"Oki doki! I'll join #{options.chan}")	
    join_act options.chan
  end

  #part chan
  on :cmdAuth, :part, /^!admin_part\s|^!part\s/ do |msg,options|
    answer(msg,"Oki doki! I'll part #{options.chan}")	
    part_act options.chan
  end

  #exit 0
  on :cmdAuth, :die, /^!admin_die\s/ do |msg,options|
    answer(msg,"Oh... Ok... I'll miss you")
    die_act
  end

  #kick
  on :cmdAuth, :kick, /^!admin_kick\s|^!kick\s|^!k\s/ do |msg,options|
    answer(msg,"Oki doki! I'll kick #{options.who} on #{options.chan}")	
    kick_act options.who,options.chan,options.reason
  end

  #(re)load a file
  on :cmdAuth, :reload, /^!admin_reload\s/ do |msg,options|
    answer(msg,"Oki doki! Upgrading myself!") if load options.what
  end

  #change mode on a chan
  on :cmdAuth, :mode, /^!admin_mode\s|^!mode\s/ do |msg,options|
    answer(msg,"Oki doki! I'll change mode #{options.what} #{options.reason+" " unless options.reason.empty?}on #{options.chan}")
    mode_act options.chan,options.what,options.reason
  end

end
