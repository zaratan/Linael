linael :version do

  on :msg, :vers, /\001version\001/ do |msg,options|
    notice_channel dest: msg.who, msg: "\001VERSION #{t.version}\001"
  end

end
