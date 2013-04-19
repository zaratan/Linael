# -*- encoding : utf-8 -*-

module Linael
  class Modules::Karma < ModuleIRC

    Name="karma"

    Help=[
      "Module : Karma",
      " ",
      "=====Functions=====",
      "!karma => show your karma",
      "!karma XXX => show the karma of XXX",
      "!karma_list [regex] => private answer for karma matching regex",
      "XXX +1 or XXX ++ => add 1 to XXX karma",
      "XXX -1 or XXX -- => del 1 to XXX karma",
      " ",
      "=====Options=====",
      "!karma_list regex => an irc regex * for a wildcard"
    ]

    def initialize runner
      @karma = Hash.new(0)
      super runner
    end

    def startMod
      add_module :msg => [:add_karma,:del_karma],
                 :cmd => [:karma,:karma_list]
      
    end

    def add_karma privMsg
      if Options.add_karma? privMsg.message
      
        options = Options.new privMsg
        @karma[options.karma.downcase] = @karma[options.karma.downcase] + 1

      end
    end
    
    def del_karma privMsg
      if Options.del_karma? privMsg.message
      
        options = Options.new privMsg
        @karma[options.karma.downcase] = @karma[options.karma.downcase] - 1

      end
    end

    def karma privMsg
      if Options.karma? privMsg.message
        options = Options.new privMsg
        answer(privMsg,"Karma for #{options.who} is : #{@karma[options.who.downcase]}!")
      end
    end

    def karma_list privMsg
      if Options.karma_list? privMsg.message
        options = Options.new privMsg

        @karma.each do |key,value|
          talk(privMsg.who, "Karma for #{key}: #{value}") if  options.regex == "" || key.match("^#{options.regex.downcase.gsub("*",".*")}$")
        end

      end
    end


    class Options < ModulesOptions
      generate_to_catch :add_karma  => /\S\s(\+\+|\+1)/,
                        :del_karma  => /\S\s(--|-1)/,
                        :karma      => /^!karma\s/,
                        :karma_list => /^!karma_list\s/

      generate_who
      generate_value    :karma      => /(\S*)\s(\+|-)/,
                        :regex      => /^!karma_list\s([A-z\*]*)/

    end
  end
end
