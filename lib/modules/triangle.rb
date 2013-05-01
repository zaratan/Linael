# -*- encoding : utf-8 -*-

#A module to say if a triangle is right angled
linael :triangle, constructor: "Aranelle" do

    on :cmd, :triangle, /^!triangle\s/ do |msg,options|
        measures = options.all.gsub(/\s+/," ").split(" ")
        if measures.size == 3 && measures.all?{|x| x.match(/^\d+$/)}
          measures = measures.map{|n| n.to_i}
          if measures.max**2 == measures.collect{|x| x**2}.reduce(:+) - measures.max**2
            answer(msg,"Your triangle is right-angled.")
          else
            answer(msg,"Your triangle isn't right-angled.")
          end
        else
          answer(msg,"There's an error. Try again with three integers.")
        end
    end

end
