# -*- encoding : utf-8 -*-

# A module to manage black/white list
linael :blacklist, require_auth: true,required_mod: ["module","admin"] do

  match :all => /\s-all\s/

  help [
    "A module to whitelist/blacklist modules from chan",
    " ",
    "#####Functions#####",
    "!blacklist|!bl -[add|del] chan module => add or remove a chan from blacklist",
    "!blacklist|!bl -[add|del] chan module => add or remove a chan from blacklist",
    " ",
    "#####Options#####",
    "-all => do the job for all chans"
  ]

  # Manage blacklist
  on :cmdAuth, :blacklist, /^!blacklist\s|^!bl\s/ do |msg,options|
    act_anylist msg,"blacklist",options
  end

  # Manage whitelist
  on :cmdAuth, :whitelist, /^!whitelist\s|^!wl\s/ do |msg,options|
    act_anylist msg,"whitelist",options
  end

  # Manage for any color list
  define_method "act_anylist" do |privMsg,colorlist,options|
    if (mod("module").instance.modules.has_key?(options.who))
      mod=mod("module").instance.modules[options.who]
      toAdd = [options.chan]
      toAdd = mod("admin").instance.chan if options.all?
      if (options.type == "add")
        modify_status colorlist,"added",toAdd,options,mod,true
      end
      if (options.type == "del")
        modify_status colorlist,"deleted",toAdd,options,mod,false
      end
    else
      answer(privMsg,"The module #{options.module} is not loaded :(")
    end
  end

  # Do the job of adding/deleting
  define_method "modify_status" do |method,action_string,toAdd,options,mod,do_add|
    toAdd.each do |chan|
      talk(options.from_who,"The chan #{chan} have been #{action_string} from the #{method} of the module #{options.who}")
      mod.send(("un_"+method),chan) unless do_add
      mod.send(method,chan) if do_add
    end
  end

end

module Linael
  # Modification of ModuleType to add blacklist in it
  class Modules::ModuleType
  
    # The 2 different lists
    attr_accessor :blackList,:whiteList

    # Is the chan blacklisted?
    def in_blacklist?(chan)
      @blackList.include?(chan.downcase) if blacklist?
    end

    # Is the chan whitelisted?
    def in_whitelist?(chan)
      return @whiteList.include?(chan.downcase) if whitelist?
      true
    end

    # Same methods for black and white lists
    ["black","white"].each do |color|
      
      # Read colorlist
      define_method color+"list?" do
        send(color+"List")
      end

      # Anylist a chan
      define_method color+"list" do |chan|
        (send(color+"List=",[])) unless send(color+"list?")
        send(color+"List").<< chan.downcase
      end

      # Un-anylist a chan
      define_method "un_"+color+"list" do |chan|
        send(color+"List").delete(chan)
        send(color+"List=",nil) if send(color+"List").empty?
      end
    end

  end
  
  # Modification of ModuleIRC to add act_authorized
  class ModuleIRC

    # Check if an instance is authorized in a chan
    def act_authorized?(instance,msg)
      return true unless msg.kind_of? PrivMessage
      moduleAdmin = @runner.master
      mod = moduleAdmin.modules[instance.class::Name]
      result = true
      result &= !mod.in_blacklist?(msg.place) 
      result &= mod.in_whitelist?(msg.place) 
      result
    end

  end

end

