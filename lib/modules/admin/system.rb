# -*- encoding : utf-8 -*-

linael :system,require_auth: true do

  help [
    "Module : System",
    " ",
    "=====Functions=====",
    "!bash xxx => execute with bash the xxx command"
  ]

  on :cmdAuth, :bash, /^!bash\s+\S/ do |priv_msg,options|
    result = `#{options.all}`
    answer(priv_msg,"#{priv_msg.who}: Everything has gone as planned!")
    result.gsub("\r",'').split("\n").each do |line|
      talk(priv_msg.who,line)
    end
  end

end
