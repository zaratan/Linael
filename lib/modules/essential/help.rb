# -*- encoding : utf-8 -*-

#A module for help
linael :help do

  help [
    t.help.help.description,
    t.help.helper.line.white,
    t.help.helper.line.functions,
    t.help.help.function.help
  ]


  Default = [
    t.help.default.master,
    t.help.default.help
  ]

  def default_act msg
    Default.each {|helpSent| answer(msg,helpSent)}
  end

  def help_act msg,name
    return default_act(msg) unless name != ""
    klass = master.module_class_from_name(name)
    p !defined?(klass::Help)
    raise MessagingException, t.help.none(name,klass::Constructor) if !defined?(klass::Help) || klass::Help.empty?
    klass::Help.each {|helpSent| answer(msg,helpSent)}
  end

  #react to !help which open class for reading Help constant
  on :cmd, :help, /^!help\s/ do |msg,options|
    message_handler msg do
      help_act(msg,options.what)
    end
  end


end
