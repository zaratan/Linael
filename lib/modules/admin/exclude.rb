# -*- encoding : utf-8 -*-

#A module to exclude a particular user
linael :exclude, require_auth: true, required_mod: ["blacklist"] do

  help [
    t.exclude.help.description,
    t.help.helper.line.white,
    t.help.helper.line.functions,
    t.exclude.help.function.exclude,
    t.exclude.help.function.unexclude
  ]

  on :cmdAuth, :exclude, /^!exclude\s/ do |msg,options|
    act_exclude(options.who)
    answer(msg,t.exclude.act.exclude(options.who))
  end

  on :cmdAuth, :unexclude, /^!unexclude\s/ do |msg,options|
    act_unexclude(options.who)
    answer(msg,t.exclude.act.unexclude(options.who))
  end

  define_method "act_exclude" do |who|
    @master.instance_variable_get(:@exclusions) << who.downcase
  end

  define_method "act_unexclude" do |who|
    @master.instance_variable_get(:@exclusions).delete(who.downcase)
  end

  on_init do
    @master.instance_variable_set(:@exclusions,[])
  end
end


module Linael
  class ModuleIRC

    def act_authorized_with_exclude?(instance,msg)
      result= act_authorized_without_exclude?(instance,msg)
      return result unless msg.kind_of? PrivMessage
      exclusions = @master.instance_variable_get(:@exclusions)
      return result unless exclusions.include?(msg.who.downcase) || exclusions.include?(msg.identification.downcase)
    end


    unless instance_methods.include?(:act_authorized_without_exclude?)
      alias_method :act_authorized_without_exclude?, :act_authorized? 
      alias_method :act_authorized?, :act_authorized_with_exclude?
    end
  end

end
