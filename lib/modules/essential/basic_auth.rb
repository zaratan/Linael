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
    ask_user Linael::Master,nil
  end

  #ask for a user status to nickserv
  def ask_user user,server
    talk("nickserv","status #{user}",server)
  end

  on :auth, :basic_auth do |msg,options|
    ask_user Linael::Master,msg.server_id
    sleep(0.3)
    msg.who.downcase == Linael::Master.downcase && 
      (@user[Linael::Master] == "3")
  end

end
