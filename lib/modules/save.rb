# -*- encoding : utf-8 -*-

require 'yaml'
require 'ya2yaml'

class Modules::Save < ModuleIRC

  Name="save"

  def startMod
  end

  def self.require_auth
    true
  end

  def self.required_mod
    ["module","blacklist"]
  end

  def save privMsg
    if Options.save? privMsg.message
      options = Options.new privMsg

      #list of module to save
      list_to_save=[]
      #module to rules them all
      mod_mod = mod("module")
      
      #fill list_to_save
      if options.what
        list_to_save << options.what if mod(options.what)
      else
        list_to_save = mod_mod.module.map{|mod| mod.class.Name}
      end

      #if list_to_save empty => error
      if list_to_save.empty?
        talk(privMsg.who,"Sorry there is no module to save :(")
        return
      end

      #if not present create dir Linael/save
      Dir.mkdir('../../save',755) unless Dir.exist? ('../../save')

      #for each mod to save
      list_to_save.each do |mod_name|
        #ya2yamlize the mod (with begin for strange mod) 
        begin
          to_write = mod(mod_name).ya2yaml
        rescue Exception
          talk(privMsg.who,"Sorry, i can't save module #{mod_name}... It's too complicated ><")
        end
        if to_write
          #write a single file in Linael/save named #{module_name}.yaml
          File.delete("#{mod_name}.yaml") if File.exist?("#{mod_name}.yaml")
          File.open("#{mod_name}.yaml") do |file|
            file.write to_write
          end
          #say everything is fine in private
          talk(privMsg.who,"Everything is perfect \o/ #{mod_name} is saved!")
        end
      end
    end
  end





  class Options < ModulesOptions
    generate_to_catch :save => /^!save\s|^!save\r|^!save\n/
                      :load => /^!load\s|^!load\r|^!load\n/
    
    generate_what
  end

end
