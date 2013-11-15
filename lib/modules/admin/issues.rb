require 'github_api'
require 'yaml'

linael :issues do

  help [
    t.issues.help.description,
    t.help.helper.line.white,
    t.help.helper.line.functions,
    t.issues.help.function.add
  ]

  on_init do  
    config = YAML.load_file('config/config.yaml')
    @issues = git = Github::Issues.new basic_auth: config["github_login"]
  end

  def add_issue user, title
    @issues.create "Skizzk","Linael",title: "#{title} (#{user})"  
  end

  on :cmd, :act_add_issue, /^!issue -add/ do |msg,options|
    add_issue(options.from_who,options.all.gsub(/\s*-add\s*/,''))
    answer(msg,t.issues.act.add)
  end
end
