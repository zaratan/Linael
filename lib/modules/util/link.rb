# -*- encoding : utf-8 -*-

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
  ]

  def link_for(server,name)
    Linael::Link.where(server_id: server, name: name)
  end

  on :cmd, :add_link, /^!link\s+-add\s+\S+\s+\S+/ do |priv_msg,options|
    Linael::Link.create(
      server_id: priv_msg.server_id,
      name: options.id.downcase,
      definition: options.value
    )
    answer(priv_msg, t.link.act.add(options.id, options.value))
  end

  on :cmd_auth, :del_link, /^!link\s+-del\s+\S+\s+\S+/ do |priv_msg,options|
    Linael::Link.destroy(options.value.to_i)
    answer(priv_msg, t.link.act.del(options.value,options.id))
  end

  on :cmd, :link, /^!link\s+[^-\s]\S*\s/ do |priv_msg,options|
    links = link_for(priv_msg.server_id,options.link.downcase).take
    unless links
      answer(priv_msg,t.not.link(priv_msg.who))
    else
      answer(priv_msg,t.link.act.link(priv_msg.who,links.definition))
    end
  end

  on :cmd, :links, /^!links\s+\S+/ do |priv_msg,options|
    links = link_for(priv_msg.server_id,options.link.downcase)
    unless links
      answer(priv_msg,t.not.link(priv_msg.who))
    else
      to_print = links.all.map {|val| t.link.act.links(val.id, val.definition)}
      talk(priv_msg.who,"#{to_print.join(",")}",priv_msg.server_id)
    end
  end

  value :link  => /^!link[s]?\s+([^-\s?][^?\s]*)\s*\??/,
    :id    => /^!link\s+-\S*\s+([^-\s?][^?\s]*)\s/,
    :value => /^!link\s+-\S*\s+\S*\s+([^\n\r]+)/


end
