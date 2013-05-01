# -*- encoding : utf-8 -*-

#A module for managing auto kick
linael :auto_kick,require_auth: true do

    help [
      "Module for manage Auto_Kick",
      " ",
      "=====Functions=====",
      "!akick -[add|del|show] where <options>",
      " ",
      "=====Options=====",
      "-add   : add a rule of auto kick. can match nick or vhost. Can match regexp with *",
      "-del   : delete the rule by its number",
      "-show  : print the rule for the chan"
    ]

    
    on_init do
      @akick = Hash.new
    end

    #autokick on join
    on :join, :autokick, /./ do

      before(join) do |join|
        !@akick[join.where.downcase].nil? and 
          @akick[joinMsg.where.downcase].detect do |regexp| 
          (joinMsg.who.downcase.match regexp) or 
            (joinMsg.identification.downcase.match regexp)
          end
      end

      talk(join.where,"sorry #{join.who} you are akick from #{join.where}.")
      kick_channel({dest:join.where,who:join.who,msg:"sorry ♥"})

    end

    #add rule
    on :cmdAuth, :add_akick, /^!akick\s-add\s/ do |msg,options|
      answer(msg,"Oki doki! #{options.who} will be auto kick on #{options.chan}.")
      add_akick_rule options.chan.downcase,options.who.downcase
    end

    #del rule
    on :cmdAuth, :del_akick, /^!akick\s-del\s/ do |msg,options|
      answer(msg,"Oki doki! I'll no longuer match rule #{options.who} on #{options.chan}.")
      del_akick_rule options.chan.downcase,(options.who.to_i)
    end

    #show rules for a chan
    on :cmdAuth, :show_akick, /!akick\s-show\s/ do |msg,options|
      print_rules options.chan.downcase,msg.who
    end

    define_method "add_akick_rule" do |where,rule|
      rule.gsub!("*",".*")
      if @akick[where].nil?
        @akick[where] = [rule]
      else
        @akick[where] << rule
      end
    end

    define_method "del_akick_rule" do |where,ruleNum|
      if !@akick[where].nil?
        @akick[where].delete_at (ruleNum - 1)
      end
    end

    define_method "print_rules" do |where,who|
      if !@akick[where].nil?
        @akick[where].each_with_index {|rule,index| talk(who,"#{(index + 1)} - #{rule}")}
      end
    end

end
