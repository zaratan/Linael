# -*- encoding : utf-8 -*-

#A module to exclude a particular user
linael :exclude, require_auth: true, required_mod: ["blacklist"] do

  help [
    "A module to remove a user from a Linael",
    " ",
    "#####Functions#####",
    "!exclude user   => exclude a *user* from Linael",
    "!unexclude user => unexclude a *user* from Linael"
  ]

  on :cmdAuth, :exclude, /^!exclude\s/ do |msg,options|
    p options.who
    act_exclude(options.who)
    p "LOL"
  end

  on :cmdAuth, :unexclude, /^!unexclude\s/ do |msg,options|
    act_unexclude(options.who)
  end

  define_method "act_exclude" do |who|
    p who
    @runner.master.instance_variable_get(:@exclusions) << who.downcase
  end

  define_method "act_unexclude" do |who|
    @runner.master.instance_variable_get(:@exclusions).delete(who.downcase)
  end

  on_init do
    @runner.master.instance_variable_set(:@exclusions,[])
  end
end


module Linael
  class ModuleIRC

    def act_authorized_with_exclude?(instance,msg)
      result= act_authorized_without_exclude?(instance,msg)
      return result unless msg.kind_of? PrivMessage
      exclusions = @runner.master.instance_variable_get(:@exclusions)
      return result unless exclusions.include?(msg.who.downcase) || exclusions.include?(msg.identification.downcase)
    end


    unless instance_methods.include?(:act_authorized_without_exclude?)
      alias_method :act_authorized_without_exclude?, :act_authorized? 
      alias_method :act_authorized?, :act_authorized_with_exclude?
    end
  end

end
