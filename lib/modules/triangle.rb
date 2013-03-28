# -*- encoding : utf-8 -*-
module Linael
	class Modules::Triangle < ModuleIRC
	
	Name="triangle"
	
	def startMod
		add_module :cmd => [:triangle]
	end
	
	def triangle privMsg
		if Options.morse? privMsg.message
			options = Options.new privMsg
			measures = options.all.split(" ")
			if measures.size == 3 && measures.each{|x| x.is_a? Integer}
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
