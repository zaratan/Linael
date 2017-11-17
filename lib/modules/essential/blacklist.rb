# A module to manage black/white list
linael :blacklist, require_auth: true, required_mod: ["admin"] do
  match all: /\s-all\s/

  help [
    t.blacklist.help.description,
    t.help.helper.line.white,
    t.help.helper.line.admin,
    t.blacklist.help.function.blacklist,
    t.blacklist.help.function.whitelist,
    t.help.helper.line.white,
    t.help.helper.line.options,
    t.blacklist.help.option.all
  ]

  ["black", "white"].each do |color|
    on :cmd_auth, "#{color}list".to_sym, /^!#{color}list\s|^!#{color[0]}l\s/ do |msg, options|
      message_handler msg do
        act_anylist "#{color}list", options, msg.server_id
      end
    end
  end

  # Manage for any color list
  def act_anylist(colorlist, options, server_id)
    raise MessagingException, t.blacklist.not.loaded unless master.modules.key?(options.who)
    mod = mod(options.who)
    toAdd = [options.chan]
    toAdd = mod("admin").chans if options.all?
    if options.type == "add"
      modify_status colorlist, t.blacklist.act.added, toAdd, options, mod, true, server_id
    end
    if options.type == "del"
      modify_status colorlist, t.blacklist.act.deleted, toAdd, options, mod, false, server_id
    end
  end

  # Do the job of adding/deleting
  def modify_status(method, action_string, toAdd, options, mod, do_add, server_id)
    toAdd.each do |chan|
      talk(options.from_who, t.blacklist.act.global(chan, action_string, method, options.who), server_id)
      mod.send(("un_" + method), chan) unless do_add
      mod.send(method, chan) if do_add
    end
  end
end

module Linael
  # Modification of ModuleType to add blacklist in it
  class ModuleIRC
    # The 2 different lists
    attr_accessor :blackList, :whiteList

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
    ["black", "white"].each do |color|
      # Read colorlist
      define_method color + "list?" do
        send(color + "List")
      end

      # Anylist a chan
      define_method color + "list" do |chan|
        send(color + "List=", []) unless send(color + "list?")
        send(color + "List").<< chan.downcase
      end

      # Un-anylist a chan
      define_method "un_" + color + "list" do |chan|
        send(color + "List").delete(chan)
        send(color + "List=", nil) if send(color + "List").empty?
      end
    end

    # Check if an instance is authorized in a chan
    def act_authorized_with_blacklist?(instance, msg)
      result = act_authorized_without_blacklist?(instance, msg)
      return result unless msg.element.is_a? Linael::Irc::Privmsg
      mod = mod(instance.class::Name)
      result &= !mod.in_blacklist?(msg.place)
      result &= mod.in_whitelist?(msg.place)
      result
    end

    unless instance_methods.include?(:act_authorized_without_blacklist?)
      alias_method :act_authorized_without_blacklist?, :act_authorized?
    end
    alias_method :act_authorized?, :act_authorized_with_blacklist?
  end
end
