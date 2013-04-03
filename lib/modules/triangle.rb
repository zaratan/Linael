# -*- encoding : utf-8 -*-
module Linael
  class Modules::Triangle < ModuleIRC

    Name="triangle"
    Constructor="Aranelle"


    def startMod
      add_module :cmd => [:triangle]
    end

    def triangle privMsg
      if Options.triangle? privMsg.message
        options = Options.new privMsg
        measures = options.all.gsub(/\s+/," ").split(" ")
        if measures.size == 3 && measures.all?{|x| x.match(/^\d+$/)}
          measures = measures.map{|n| n.to_i}
          if measures.max**2 == measures.collect{|x| x**2}.reduce(:+) - measures.max**2
            answer(privMsg,"Your triangle is right-angled.")
          else
            answer(privMsg,"Your triangle isn't right-angled.")
          end
        else
          answer(privMsg,"There's an error. Try again with three integers.")
        end
      end
    end

    class Options < ModulesOptions
      generate_to_catch :triangle => /^!triangle\s/
      generate_all
    end
  end
end
