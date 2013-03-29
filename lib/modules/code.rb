# -*- encoding : utf-8 -*-
module Linael
	class Modules::Code < ModuleIRC

		Name="code"

		Help=[
			"Module: Code",
			" ",
			"=====Fonctions=====",
			"!name [string you want to code] => display your string, replacing each letter with the one following it in the alphabet",
			" ",
			"=====Options=====",
			"!name -s[a-z] -t[a-z]",
			"      -s    : Source letter (default: a)",
			"      -t    : Target letter (default: b)"
		]

		def startMod
			add_module :cmd => [:code]
		end

		def code privMsg
			if Options.code? privMsg.message
				options = Options.new privMsg
				answer(privMsg,options.all.split(//).map{|c| AlphabetArray[c + (options.target.index - options.source.index)]})
			end
		end

		AlphabetArray = %w(a b c d e f g h i j k l m n o p q r s t u v w x y z)


		class Options < ModulesOptions

			generate_to_catch :code => /^!code\s/

			def initialize privMsg
				@message = privMsg.message
			end

			def source
				if @message =~ /\s-s([a-z])\s/
					$~[1]
				else
					"a"
				end
			end

			def target
				if @message =~ /\s-t([a-z])\s/
					$~[1]
				else
					"b"
				end
			end

			def all
				@message.slice! /^!code -s([a-z]) -t([a-z]) /
			end
		end
	end
end
