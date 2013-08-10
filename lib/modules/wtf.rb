linael :wtf do

  on :cmd, :wtf, /^!wtf\s/ do |msg,options|
    answer(msg,`wtf #{options.wtf}`)
  end

  value :wtf => /\s([A-Za-z0-9]*)/

end
