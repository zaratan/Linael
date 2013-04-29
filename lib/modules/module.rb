# -*- encoding : utf-8 -*-

#A module to load them all
linael :module,require_auth: true do

  #Hack 'cause this module is quite special
  define_method "initialize" do |runner|
    @dir = Dir.new("./lib/modules")
    @modules=Linael::Modules::ModuleList.new(runner)
    @modules.addMod(Linael::Modules::ModuleType.new(runner,instance: self,name: self.class::Name))
    super(runner)
  end

  help [
    "Module for loading modules",
    " ",
    "#####Functions#####",
    "!module -add name    => Load name module",
    "!module -del name    => Unload name module",
    "!module -reload name => Reload name module",
    "!module -show        => Show a list of modules. A * mean that the module is loaded",
  ]

  #list of modules
  attr_reader :modules

  #add a module
  on :cmdAuth, :add, /^!module\s-add\s/ do |msg,options|
    @modules.add(options.who,msg)
  end

  #del a module
  on :cmdAuth, :del, /^!module\s-del\s/ do |msg,options|
    @modules.remove(options.who,msg)
  end

  #show module list with * for loaded ones
  on :cmd, :show, /^!module\s-show\s/ do |msg,options|
    @dir.each do |file| 
      if file.match /^[A-z]/
        file.sub!(/\.rb$/,"")
        file.sub!(/^/,"*\s") if @modules.has_key? file
        answer(msg,file)
      end
    end
  end

  #reload a module
  on :cmdAuth, :reload, /^!module\s-reload\s/ do |msg,options|
    modName = options.who
    if (!@modules.has_key?(modName))
      answer(msg,"Module not loaded")
      return
    end
    if !(@dir.find{|file| file.sub!(/\.rb$/,""); file ==  modName})
      answer(msg,"The module don't exist")
      return
    end

    @modules.remove modName,msg
    @modules.add modName,msg
  end

end


module Linael

  #A container for a module.
  #It contain his name, his runner and its instance
  class Modules::ModuleType

    include Action

    # Initialize method.
    # There is 2 way of initialize:
    # * If you don't have an instance, you have to provide:
    #   * +:klass+::
    #   * +:privMsg+::
    # * If you have an instance, provide:
    #   * +:name+::
    #   * +:instance+::
    # Params:
    # +:klass+::    the class of the new module
    # +:privMsg+::  the calling message (to know where answer)
    # +:name+::     name of the module
    # +:instance+:: the instance
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
          p $!
          raise $!
        end
      else
        @name=params[:name]
        @instance=params[:instance]
      end
    end

    #name, and instance of the module
    attr_accessor :name,:instance

    #halt the module
    def destroy!
      @instance.stopMod
      true
    end

    #equals
    def ==(mod)
      @name == mod.name
    end

  end

  #List for modules
  class Modules::ModuleList

    include Enumerable
    include Action

    # Initialiez the list
    def initialize runner
      @modules=[]
      @runner=runner
      @dir = Dir.new("./lib/modules")
      @authModule = []
    end

    #list of modules and authentification modules
    attr_accessor :modules,:authModules

    #each
    def each(&block)
      @modules.each &block
    end

    # Delete a module from the list
    def removeMod(modName)
      @modules = @modules.delete_if {|mod| mod.destroy! if mod.name == modName}
      @authModule.delete modName
    end

    # Ask for removing a mod with a msg for answer
    def remove(modName,privMsg)
      begin
        unless has_key?(modName)
          answer(privMsg,"Module not loaded")	
        else
          removeMod(modName)
          answer(privMsg,"Module #{modName} unloaded!")
        end
      rescue Exception
        answer(privMsg,"Problem when deleting the module")
        talk(privMsg.who,$!)
      end
    end

    #add a module
    def addMod(mod)
      @modules << mod
    end

    # Ask for adding a module
    # TODO add a nil privateMessage to handle adding from self
    def add(modName,privMsg=false)
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
              answer(privMsg,"Here is the list of requirement: #{klass.required_mod.join(" - ")}.") 
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

    # Is a module with this name present
    def has_key?(key)
      any? {|mod| mod.name == key}
    end

    # Is list contains all the modules listed
    def matchRequirement?(modules)
      modules.nil? or modules.all? {|mod| has_key?(mod)}
    end

    # return a module by his name
    def [](name)
      detect {|mod| mod.name == name}
    end

  end
end

