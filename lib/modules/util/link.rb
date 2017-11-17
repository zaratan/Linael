linael :link, require_auth: true do
  help [
    t.link.help.description,
    t.help.helper.line.white,
    t.help.helper.line.functions,
    t.link.help.function.link,
    t.link.help.function.links,
    t.link.help.function.add,
    t.help.helper.line.white,
    t.help.helper.line.admin,
    t.link.help.function.del,
    t.link.help.function.user
  ]

  on_init do
    @links = {}
    @users = []
  end

  on :cmd, :add_link, /^!link\s+-add\s+\S+\s+\S+/ do |priv_msg, options|
    before(priv_msg) do |privmsg|
      @users.include?(privmsg.who.downcase)
    end
    @links[options.id.downcase] = ((@links[options.id.downcase] || []) << options.value)
    answer(priv_msg, t.link.act.add(options.id, options.value))
  end

  on :cmd_auth, :del_link, /^!link\s+-del\s+\S+\s+\S+/ do |priv_msg, options|
    before(priv_msg) do |privmsg|
      @users.include?(privmsg.who.downcase)
    end
    (@links[options.id.downcase] || []).delete_at(options.value.to_i - 1)
    answer(priv_msg, t.link.act.del(options.value, options.id))
  end

  on :cmd, :link, /^!link\s+[^-\s]\S*\s/ do |priv_msg, options|
    links = @links[options.link.downcase] || []
    if links.empty?
      answer(priv_msg, t.not.link(priv_msg.who))
    else
      answer(priv_msg, t.link.act.link(priv_msg.who, links.sample))
    end
  end

  on :cmd, :links, /^!links\s+\S+/ do |priv_msg, options|
    links = @links[options.link.downcase] || []
    if links.empty?
      answer(priv_msg, t.not.link(priv_msg.who))
    else
      to_print = []
      links.each_with_index { |val, i| to_print << t.link.act.links(i + 1, val) }
      talk(priv_msg.who, to_print.join(',').to_s, priv_msg.server_id)
    end
  end

  on :cmd_auth, :add_user_link, /^!link_user\s+-add\s/ do |priv_msg, options|
    @users << options.who.downcase unless @users.include? options.who.downcase
    answer(priv_msg, t.link.act.user.add(options.who))
  end

  on :cmd_auth, :del_user_link, /^!link_user\s+-del\s/ do |priv_msg, options|
    @users.delete options.who.downcase
    answer(priv_msg, t.link.act.user.del(options.who))
  end

  value link: /^!link[s]?\s+([^-\s?][^?\s]*)\s*\??/,
        id: /^!link\s+-\S*\s+([^-\s?][^?\s]*)\s/,
        value: /^!link\s+-\S*\s+\S*\s+([^\n\r]+)/
end
