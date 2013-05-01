# -*- encoding : utf-8 -*-

linael :link, require_auth: true do

  help [
    "Module : Link",
    " ",
    "A module for associate things like \"ruby\" => [\"it's so great\",\"much better than perl\"]",
    " ",
    "=====Functions=====",
    "!link XXX?                        => answer a random thing for its assoc table",
    "!links XXX?                       =>",
    "!link [-add|-del] <id> <value>    => add/del the <value> association to the <id>",
    "!link_user [-add|-del] <username> => add/del a user who can add links"
  ]

  on_init do 
    @links = Hash.new
    @users = []
  end

  on :cmd, :add_link, /^!link\s+-add\s+\S+\s+\S+/ do |priv_msg,options|
    before(priv_msg) do |priv_msg|
      @users.include?(priv_msg.who.downcase)
    end
    @links[options.id.downcase] = ((@links[options.id.downcase] || []) << options.value)
    answer(priv_msg,"#{options.id} is now : #{options.value}")
  end

  on :cmdAuth, :del_link, /^!link\s+-del\s+\S+\s+\S+/ do |priv_msg,options|
    before(priv_msg) do |priv_msg|
      @users.include?(priv_msg.who.downcase)
    end
    (@links[options.id.downcase] || []).delete_at(options.value.to_i - 1)
    answer(priv_msg,"deleting entry number #{options.value} of #{options.id}")
  end

  on :cmd, :link, /^!link\s+[^-\s]\S*\s/ do |priv_msg,options|
    links = @links[options.link] || []
    if links.empty? 
      answer(priv_msg,"#{priv_msg.who}: I'm sorry, I really don't know :(")
    else
      answer(priv_msg,"#{priv_msg.who}: #{links[Random.rand(links.size)]}")
    end
  end

  on :cmd, :links, /^!links\s+\S+/ do |priv_msg,options|
    links = @links[options.link] || []
    if links.empty?
      answer(priv_msg,"#{priv_msg.who}: I'm sorry, I really don't know :(")
    else
      to_print=[]
      links.each_with_index {|val,i| to_print << "##{i + 1}: #{val}"}
      talk(priv_msg.who,"#{to_print.join(",")}")
    end
  end

  on :cmdAuth, :add_user_link, /^!link_user\s+-add\s/ do |priv_msg,options|
    @users << options.who.downcase unless @users.include? options.who.downcase
    answer(priv_msg,"Oki doki! #{options.who.downcase.capitalize} can now link :)")
  end

  on :cmdAuth, :del_user_link, /^!link_user\s+-del\s/ do |priv_msg,options|
    @users.delete options.who.downcase
    answer(priv_msg,"Oki doki! #{options.who.downcase.capitalize} will no longer link anything")
  end

  value :link  => /^!link[s]?\s+([^-\s?][^?\s]*)\s*\??/,
    :id    => /^!link\s+-\S*\s+([^-\s?][^?\s]*)\s/,
    :value => /^!link\s+-\S*\s+\S*\s+([^\n\r]+)/


end
