# -*- encoding : utf-8 -*-

require 'yaml'
require 'ya2yaml'

#A module to save variables in others modules
linael :save, require_auth: true do

  help [
    t.savem.help.description,
    t.help.helper.line.white,
    t.help.helper.line.admin,
    t.savem.help.function.save,
    t.savem.help.function.load,
    t.savem.help.function.autosave
  ]

  def auto_save_act msg
    save_act msg
    at 1.hour.from_now do
      auto_save_act msg
    end
  end

  def save_act msg=nil, what=""
    #list of module to save
    list_to_save=[]

    #fill list_to_save
    unless what.empty? 
      list_to_save << what if what != "master" and mod(what)
    else
      list_to_save = master.modules.keys
    end

    #if list_to_save empty => error
    raise MessagingException, t.savem.not.module if list_to_save.empty?

    #if not present create dir Linael/save
    Dir.mkdir('save',770) unless Dir.exist? ('save')

    #for each mod to save
    list_to_save.each do |mod_name|
      #ya2yamlize the mod (with begin for strange mod) 
      begin
        #get instance of module
        module_to_write = mod(mod_name)
        #delete runner from instance 'cause u DON'T want to save it
        module_to_write.master = nil
        to_write = module_to_write.ya2yaml
        #restore runner
        module_to_write.master = master
      rescue Exception => e
        answer(msg, t.savem.error.saving(mod_name)) if msg
        puts e.to_s.red
        puts e.backtrace.join("\n").red
      end
      if to_write
        #write a single file in Linael/save named #{module_name}.yaml
        #File.delete("#{mod_name}.yaml") if File.exist?("#{mod_name}.yaml")
        File.open("save/#{mod_name}.yaml","w+") { |file| file.write to_write }
        #say everything is fine in private
        answer(msg, t.savem.act.save(mod_name)) if msg
      end
    end
  end

  def load_act msg=nil, what=""
    raise MessagingException, t.save.not.directory unless Dir.exist? 'save'
    #construct list to load
    list_to_load = []

    unless what.empty?
      list_to_load << what if (what != "master") and File.exist?("save/#{what}.yaml")
    else
      Dir.foreach('save'){|file| list_to_load << file.gsub(/\.yaml/,"") if file =~ /\.yaml/}
    end

    #for each mod
    list_to_load.each do |mod_name|
      #if already charged
      #stop the mod 
      master.del_action(mod_name) if master.modules.has_key?(mod_name)
      #load the right class
      klass = master.modules.load_module_class mod_name
      master.modules.good_to_add?(mod_name,klass)
      #load the module
      instance = YAML.load_file "save/#{mod_name}.yaml"
      #put the module in mod_mod
      master.modules.add_module_by_instance(instance) 
      #lauch load script
      instance.load_mod
      answer(msg, t.savem.act.load(mod_name)) if msg
    end
  end


on :cmd_auth, :auto_save, /^!auto_save\s/ do |msg|
  auto_save_act msg
end

on :cmd_auth, :save, /^!save(\s|\r|\n)/ do |msg,options|
  message_handler msg do
    save_act msg, options.what
  end
end

on :cmd_auth, :load_save, /^!load(\s|\r|\n)/ do |msg,options|
  message_handler msg do
    load_act msg, options.what
  end
end

end
