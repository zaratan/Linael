# -*- encoding : utf-8 -*-

module Linael

  class Modules::ModuleType

    include Action

    def initialize runner,params

      if !params[:privMsg].nil?
        @name = params[:klass]::Name
        @runner = runner
        begin
          instKlass = params[:klass].new(@runner)
          instKlass.startMod
          @instance = instKlass
        rescue Exception
          answer(params[:privMsg],"Problem when loading the module")
          talk(params[:privMsg].who,$!)
          raise $!
        end
      else
        @name=params[:name]
        @instance=params[:instance]
      end
    end

    attr_accessor :name,:irc,:instance


    def destroy!
      @instance.stopMod
      true
    end


    def ==(mod)
      @name == mod.name
    end

  end



  class Modules::ModuleList

    include Enumerable
    include Action

    def initialize runner
      @modules=[]
      @runner=runner
      @dir = Dir.new("./lib/modules")
      @authModule = []
    end

    attr_accessor :modules,:authModules

    def each(&block)
      @modules.each &block
    end

    def remove(modName,privMsg)
      begin
        if (!has_key?(modName))
          answer(privMsg,"Module not loaded")	
        else
          @modules = @modules.delete_if do |mod| 
            mod.destroy! if mod.name == modName
          end
          @authModule.delete(modName)
          answer(privMsg,"Module #{modName} unloaded!")
        end
      rescue Exception
        answer(privMsg,"Problem when deleting the module")
        talk(privMsg.who,$!)
      end
    end

    def addMod(mod)
      @modules << mod
    end

    def add(modName,privMsg)
      begin
        if @dir.find{|file| file.sub!(/\.rb$/,""); file ==  modName} 	
          load "./lib/modules/#{modName}.rb"
          klass = "linael/modules/#{modName}".camelize.constantize
          if (has_key?(klass::Name))
            answer(privMsg,"Module already loaded, please unload first")	
          else
            if (klass.require_auth && @authModule.empty?)
              answer(privMsg,"You need at least one authMethod to load this module")
            else
              if matchRequirement?(klass.required_mod)
                mod = Modules::ModuleType.new(@runner,klass: klass,privMsg: privMsg)
                addMod(mod)
                @authModule << klass::Name if klass::auth?
                answer(privMsg,"Module #{modName} loaded!")
              else
                answer(privMsg,"You do not have loaded all the modules required for this module.")
                answer(privMsg,"Here is the list of requirement: #{klass.requiredMod.join " - "}.")
              end
            end
          end
        end
      rescue Exception
        puts $!
        answer(privMsg,"Problem when loading the module")
        talk(privMsg.who,$!)
      end
    end

    def has_key?(key)
      any? {|mod| mod.name == key}
    end

    def matchRequirement?(modules)
      modules.nil? or modules.all? {|mod| has_key?(mod)}
    end

    def [](name)
      detect {|mod| mod.name == name}
    end

  end


  class Modules::Module < ModuleIRC

    attr_reader :modules

    Name="module"

    def initialize(runner)
      @dir = Dir.new("./lib/modules")
      @modules=Modules::ModuleList.new(runner)
      super runner
    end



    def whichModule privMsg
      if (module? privMsg) && (list? privMsg)
        @dir.each do |file| 
          if file.match /^[A-z]/
            file.sub!(/\.rb$/,"")
            file.sub!(/^/,"*\s") if @modules.has_key? file
            answer(privMsg,file)
          end
        end
      end
    end

    def addModule privMsg
      if (module? privMsg) &&
        (add? privMsg)
        if privMsg.message.match /^!modules\sadd\s([A-z0-9]*)/
          modName = "#{$~[1]}"
          @modules.add modName,privMsg
        end
      end
    end

    def delModule(privMsg)
      if (module? privMsg) &&
        (del? privMsg)
        if privMsg.message.match /^!modules\sdel\s([A-z0-9]*)/
          modName = "#{$~[1]}"
          @modules.remove(modName,privMsg)
        end
      end
    end

    def reloadModule privMsg
      if (module? privMsg) &&
        (reload? privMsg)
        if privMsg.message =~ /^!modules\sreload\s([A-z0-9]*)/
          modName = $~[1]
          if (!@modules.has_key?(modName))
            answer(privMsg,"Module not loaded")
            return
          end
          if !(@dir.find{|file| file.sub!(/\.rb$/,""); file ==  modName})
            answer(privMsg,"The module don't exist")
            return
          end

          @modules.remove modName,privMsg
          @modules.add modName,privMsg

        end

      end
    end

    def reload? privMsg
      privMsg.message =~ /^!modules\sreload/
    end

    def self.require_auth  
      true 
    end

    def add? privMsg
      privMsg.message.match '^!modules\sadd'
    end

    def del? privMsg
      privMsg.message.match '^!modules\sdel'
    end


    def list? privMsg
      privMsg.message.match '^!modules\slist'
    end

    def authorized? privMsg
      privMsg.who == "Zaratan" && (privMsg.identification.match '^~Zaratan@.*$')
    end

    def module? privMsg
      privMsg.message.match '^!modules\s.*$' 
    end

    def startMod()
      @modules.addMod(Modules::ModuleType.new(@runner,instance: self,name: Name))
      add_module({cmd: [:whichModule],
                  cmdAuth: [:addModule,
                            :delModule,
                            :reloadModule]})
    end


  end
end
