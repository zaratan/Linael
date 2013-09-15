# -*- encoding : utf-8 -*-

#A module for help
linael :help do

  help [
    "Module Help:",
    "!help module_name => display the help for the module modName"
  ]

  def help_act msg,name
    klass = master.module_class_from_name(name)
    p !defined?(klass::Help)
    raise MessagingException, "No help for the module #{name}. Ask #{klass::Constructor} for this :)" if !defined?(klass::Help) || klass::Help.empty?
    klass::Help.each {|helpSent| answer(msg,helpSent)}
  end

  #react to !help which open class for reading Help constant
  on :cmd, :help, /^!help\s/ do |msg,options|
    message_handler msg do
      help_act(msg,options.what)
    end
  end


end
