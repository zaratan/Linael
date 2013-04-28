# -*- encoding : utf-8 -*-

#A module for help
linael :help do

  help [
    "Module Help:",
    "!help modName => display the help for the module modName"
  ]

  #react to !help which open class for reading Help constant
  on :cmd, :help, /^!help\s/ do |msg,options|
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

  on_init do
    @dir = Dir.new("./lib/modules")
  end

end
