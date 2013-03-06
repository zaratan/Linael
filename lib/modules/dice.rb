# -*- encoding : utf-8 -*-
class Modules::Dice < ModuleIRC
	
	Name="dice"	

	def dice privMsg
		if (Options.dice? privMsg)
			options	= Options.new privMsg
			if (!options.to_much?) or (options.force? && privMsg.who.downcase == "zaratan")
				dices=[]
				options.number.times { dices << DiceLauncher.new(options.dice)}
				sum = dices.inject(0) {|sum,d| sum + d.value}
				answer(privMsg,"#{privMsg.who}: Dices = [#{dices.join(" - ")}]")
			else
				sum = 0
				options.number.times {sum += DiceLauncher.new(options.dice).value}
			end
				answer(privMsg,"#{privMsg.who}: Sum = #{sum}")
		end
	end

	def startMod()
		addMsgMethod(self,:dice,":dice")
	end

	def endMod()
		delMsgMethod(self,":dice")
	end

end

class Modules::Dice::DiceLauncher

	attr_reader :value

	def initialize dice
		@value = rand(dice) + 1
	end

	def to_s
		@value.to_s
	end

end

class Modules::Dice::Options
	def initialize privMsg
		@message = privMsg.message
	end

	def to_much?
		number > 20
	end

	def force?
		@message =~ /-force/
	end

	def number
		$~[1].to_i if @message =~ /([0-9]{1,3})d[0-9]{1,3}/
	end

	def dice
		$~[1].to_i if @message =~ /[0-9]{1,3}d([0-9]{1,3})/
	end

	def self.dice? privMsg
		privMsg.message =~ /^[0-9]{1,3}d[0-9]{1,3}/
	end
end
