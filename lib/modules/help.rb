# -*- encoding : utf-8 -*-

module Linael
  class Modules::Help < ModuleIRC

    Name="help"

    Help=[
      "Module Help:",
      "!help modName => display the help for the module modName"
    ]

    def startMod
      add_module :cmd => [:help]
    end

    def help privMsg
      if Options.help? privMsg.message
        options = Options.new privMsg
        modName=options.what
        if @dir.find{|file| file.sub!(/\.rb$/,""); file ==  modName} 	
          load "./lib/modules/#{modName}.rb"
          klass = "linael/modules/#{modName}".camelize.constantize
          unless !defined?(klass::Help) or klass::Help.empty?
            klass::Help.each {|helpSent| answer(privMsg,helpSent)}
          else
            answer(privMsg,"No help for the module #{modName}. Ask #{klass::Constructor} for this :)")
          end
        else
          answer(privMsg,"There is no module named #{modName}")
        end
      end
    end

    def initialize(runner)
      @dir = Dir.new("./lib/modules")
      super runner
    end

    class Options < ModulesOptions
      generate_to_catch :help => /^!help\s/
      generate_what
    end

  end
end
