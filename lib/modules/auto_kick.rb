# -*- encoding : utf-8 -*-
module Linael
  class Modules::AutoKick < ModuleIRC

    Name="auto_kick"

    Help=[
      "Module: Auto_Kick",
      " ",
      "=====Functions=====",
      "!akick -[add|del|show] where <options>",
      " ",
      "=====Options=====",
      "-add   : add a rule of auto kick. can match nick or vhost. Can match regexp with *",
      "-del   : delete the rule by its number",
      "-show  : print the rule for the chan"
    ]

    def self.require_auth
      true
    end

    def initialize runner
      @akick = Hash.new
      super(runner)
    end

    def startMod
      add_module({cmdAuth: [:addAkick,
                            :delAkick,
                            :printAkick],
                  join:[:autokick]})
    end

    def autokick joinMsg
      if !@akick[joinMsg.where.downcase].nil?
        if @akick[joinMsg.where.downcase].detect {|regexp| ((joinMsg.who.downcase.match regexp) || (joinMsg.identification.downcase.match regexp))}
          talk(joinMsg.where,"sorry #{joinMsg.who} you are akick from #{joinMsg.where}.")
          kick_channel({dest:joinMsg.where,who:joinMsg.who,msg:"sorry ♥"})
        end
      end
    end

    def addAkick privMsg
      if Options.akick_add? privMsg.message
        options = Options.new privMsg
        answer(privMsg,"Oki doki! #{options.who} will be auto kick on #{options.chan}.")
        addAkickRule options.chan.downcase,options.who.downcase
      end
    end

    def delAkick privMsg
      if Options.akick_del? privMsg.message
        options = Options.new privMsg
        answer(privMsg,"Oki doki! I'll no longuer match rule #{options.who} on #{options.chan}.")
        delAkickRule options.chan.downcase,(options.who.to_i)
      end
    end

    def printAkick privMsg
      if Options.akick_show? privMsg.message
        options = Options.new privMsg
        printRules options.chan.downcase,privMsg.who
      end
    end

    def addAkickRule where,rule
      rule.gsub!("*",".*")
      if @akick[where].nil?
        @akick[where] = [rule]
      else
        @akick[where] << rule
      end
    end

    def delAkickRule where,ruleNum
      if !@akick[where].nil?
        @akick[where].delete_at (ruleNum - 1)
      end
    end

    def printRules where,who
      if !@akick[where].nil?
        @akick[where].each_with_index {|rule,index| talk(who,"#{(index + 1)} - #{rule}")}
      end
    end

  
    class Options < ModulesOptions
      generate_to_catch :akick_add  => /^!akick\s-add/,
                        :akick_del  => /^!akick\s-del/,
                        :akick_show => /^!akick\s-show/
      generate_chan
      generate_who
    end

  end
end
