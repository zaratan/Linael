# -*- encoding : utf-8 -*-

#A module for managing auto kick
linael :auto_kick,require_auth: true do

    help [
      t.autokick.help.description,
      t.help.helper.line.white,
      t.help.helper.line.admin,
      t.autokick.function.add,
      t.autokick.function.del,
      t.autokick.function.show
    ]

    
    on_init do
      @akick = Hash.new
    end

    #autokick on join
    on :join, :autokick, /./ do |join|

      before(join) do |join|
        !@akick[join.where.downcase].nil? and 
          @akick[joinMsg.where.downcase].detect do |regexp| 
          (joinMsg.who.downcase.match regexp) or 
            (joinMsg.identification.downcase.match regexp)
          end
      end

      talk(join.where,t.autokick.act.akick.answer(join.who),join.server_id)
      kick_channel join.server_id, dest: join.where, who: join.who, msg: t.autokick.act.akick.kick

    end

    #add rule
    on :cmdAuth, :add_akick, /^!akick\s-add\s/ do |msg,options|
      answer(msg, t.autokick.act.add(options.who, options.chan))
      add_akick_rule options.chan.downcase,options.who.downcase
    end

    #del rule
    on :cmdAuth, :del_akick, /^!akick\s-del\s/ do |msg,options|
      answer(msg,"Oki doki! I'll no longuer match rule #{options.who} on #{options.chan}.")
      del_akick_rule options.chan.downcase,(options.who.to_i)
    end

    #show rules for a chan
    on :cmdAuth, :show_akick, /!akick\s-show\s/ do |msg,options|
      print_rules options.chan.downcase,msg.who,msg.server_id
    end

    def add_akick_rule(where,rule)
      rule.gsub!("*",".*")
      if @akick[where].nil?
        @akick[where] = [rule]
      else
        @akick[where] << rule
      end
    end

    def del_akick_rule(where,ruleNum)
      if !@akick[where].nil?
        @akick[where].delete_at (ruleNum - 1)
      end
    end

    def print_rules(where,who,server_id)
      if !@akick[where].nil?
        @akick[where].each_with_index {|rule,index| talk(who,"#{(index + 1)} - #{rule}",server_id)}
      end
    end

end
