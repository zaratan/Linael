# -*- encoding : utf-8 -*-

require 'yaml'
require 'ya2yaml'

#A module to save variables in others modules
linael :save, require_auth: true, required_mod: ["module","blacklist"] do

  on :cmdAuth, :auto_save, /^!auto_save\s/ do |msg,options|
      msg.content = "!save\s"
      save(msg)
    at 1.hour.from_now do
      msg.content = "!auto_save\s"
      auto_save(msg)
    end
  end

  on :cmdAuth, :save, /^!save(\s|\r|\n)/ do |msg,options|
    #list of module to save
    list_to_save=[]
    #module to rules them all
    mod_mod = mod("module")

    #fill list_to_save
    unless options.what.empty? 
      list_to_save << options.what if options.what != "module" and mod(options.what)
    else
      list_to_save = mod_mod.instance.modules.map{|mod| mod.name}
      list_to_save.delete("module")
    end

    #if list_to_save empty => error
    if list_to_save.empty?
      answer(msg,"Sorry there is no module to save :(")
      return
    end

    #if not present create dir Linael/save
    Dir.mkdir('save',755) unless Dir.exist? ('save')

    #for each mod to save
    list_to_save.each do |mod_name|
      #ya2yamlize the mod (with begin for strange mod) 
      begin
        #get instance of module
        module_to_write = mod(mod_name).instance
        #save runner
        runner = module_to_write.runner
        #delete runner from instance 'cause u DON'T want to save it
        module_to_write.runner =nil
        to_write=module_to_write.ya2yaml
        #restore runner
        module_to_write.runner=runner
      rescue Exception 
        answer(msg,"Sorry, i can't save module #{mod_name}... It's too complicated ><")
        #debug
        p $!
      end
      if to_write
        #write a single file in Linael/save named #{module_name}.yaml
        #File.delete("#{mod_name}.yaml") if File.exist?("#{mod_name}.yaml")
        File.open("save/#{mod_name}.yaml","w+") { |file| file.write to_write }
        #say everything is fine in private
        answer(msg,"Everything is perfect \\o/ #{mod_name} is saved!")
      end
    end
  end

  on :cmdAuth, :load_save, /^!load(\s|\r|\n)/ do |msg,options|
    if Dir.exist? 'save'
      #construct list to load
      list_to_load = []
      mod_mod = mod("module").instance

      unless options.what.empty?
        list_to_load << options.what if (options.what != "module") and File.exist?("save/#{options.what}.yaml")
      else
        Dir.foreach('save'){|file| list_to_load << file.gsub(/\.yaml/,"") if file =~ /\.yaml/}
      end

      #for each mod
      list_to_load.each do |mod_name|
        #if already charged
        #stop the mod 
        mod_mod.modules.removeMod(mod_name) if mod_mod.modules.has_key?(mod_name)
        #load the right class
        if File.exist? "lib/modules/#{mod_name}.rb"
          begin
            #hack degeux pour generer les methodes
            "Linael::Modules::#{mod_name.camelize}".constantize.new @runner
          rescue Exception
            answer(msg,"I can't load the module #{mod_name} you should module -add it first")
            #debug
            p $!
            return
          end
        else
          answer(msg,"I can't find the module file: #{mod_name}.rb :(")
          return
        end
        #load the module
        mod = YAML.load_file "save/#{mod_name}.yaml"
        #set the runner
        mod.runner = @runner
        #put the module in mod_mod
        mod_mod.modules.addMod(Linael::Modules::ModuleType.new @runner,{name: mod_name,instance: mod})

        #start the module
        mod.startMod
        #lauch load script
        mod.load_mod
        answer(msg,"Yaye! Module #{mod_name} loaded!")
      end
    end
  end

end
