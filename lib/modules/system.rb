# -*- encoding : utf-8 -*-

module Linael
  class Modules::System < ModuleIRC

    Name="system"

    Help=[
      "Module : System",
      " ",
      "=====Functions=====",
      "!bash xxx => execute with bash the xxx command"
    ]

    def startMod
      add_module :cmdAuth => [:bash]
    end

    def bash priv_msg
      if Options.bash? priv_msg.message
        options = Options.new priv_msg
        result = `#{options.all}`
        answer(priv_msg,"#{priv_msg.who}: Everything has gone as planned!")
        result.gsub("\r",'').split("\n").each do |line|
          talk(priv_msg.who,line)
        end
      end
    end

    class Options < ModulesOptions
      generate_to_catch :bash => /^!bash\s+\S/
      generate_all
    end
  end
end
