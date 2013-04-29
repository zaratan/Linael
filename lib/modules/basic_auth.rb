# -*- encoding : utf-8 -*-
linael :basic_auth,:auth => true do

  help=["A really basic authentification"]

  on :notice, :add_user, /status\s\S*\s[0-3]/ do |notice|
    before(notice) do |notice|
      notice.sender.downcase == "nickserv"
    end
    notice.message.downcase =~ /status\s(\S*)\s([0-3])/
    @user[($1.downcase)]=$2
  end

  on_init do
    @user = Hash.new
    ask_user Linael::Master
  end

  #ask for a user status to nickserv
  define_method "ask_user" do |user|
    talk("nickserv","status #{user}")
  end
  
  on :auth, :basic_auth, /./ do |msg,options|
      ask_user Linael::Master
      sleep(0.3)
      msg.who.downcase == Linael::Master.downcase and 
        (@user[Linael::Master] == "3")
  end

end
