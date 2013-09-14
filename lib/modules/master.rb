linael :master, require_auth: true do

  attr_reader :modules

  def module_instance(name)
    return self if name == self.class::Name
    return nil unless result = @modules[name]
    result.instance
  end

  def module_class_from_name(name)
    modules.load_module_class name
  end

  def add_act(type,proc_name,prok)
    @handler.add_act(type,proc_name,prok)
  end

  def del_act(type,proc_name)
    @handler.del_act(type,proc_name)
  end

  def act_types
    @handler.act_types
  end

  def initialize handler
    @handler=handler
    @modules = Linael::Modules::ModuleList.new(self,"./lib/modules/")
    super self
  end

  def message_handler msg,result_message
    begin
      yield
    rescue MessagingException => error_message
      answer(msg,error_message)
      return
    rescue Exception => error
      talk(msg.who,error.to_s)
      p error.backtrace.join("\n").red
      return
    end
    answer(msg,result_message)
  end

  def add_action name
    modules.add_module(name)
  end

  def del_action name
    modules.remove(name)
  end

  def reload_action name
    raise MessagingException, "Module not Loaded." unless modules.has_key?(name)
    #raise an exception if the module do not exist :)
    modules.find_file_module_by_name(name)
    modules.remove name
    modules.add_module name
  end

  def show_action msg,regex
    result = modules.keys.select {|k| k.match regex}
    result_loaded = result.select {|k| module_instance(k)}
    answer(msg,"List of #{BotNick} modules: [#{result.join(' ,')}]")
    answer(msg,"List of loaded modules: [#{result_loaded.join(' ,')}]")
  end

  on :cmdAuth, :add, /^!module\s-add\s/ do |msg,options|
    message_handler msg,"Module #{options.who} added :)" do
      add_action options.who
    end
  end

  on :cmdAuth, :del, /^!module\s-del\s/ do |msg,options|
    message_handler msg,"Module #{options.who} removed :(" do
      del_action options.who
    end
  end

  on :cmdAuth, :reload, /^!module\s-del\s/ do |msg,options|
    message_handler msg,"Module #{options.who} reloaded \o/" do
      reload_action options.who
    end
  end

  on :cmd, :show, /^!module\s-show\s/ do |msg,options|
    show_action msg,options.who
  end

end  

module Linael

  class Modules::ModuleList

    include Enumerable

    attr_reader :modules,:auth_modules,:dir,:master

    def initialize(master,dir)
      @master=master
      @modules=[]
      @auth_modules=[]
      @dir= dir
    end

    def each(&block)
      modules.each &block
    end

    def [](name)
      detect {|mod| mod.name == name}
    end

    def match_requirement?(required_modules)
      !required_modules || required_modules.all? {|mod| has_key? mod}
    end
    
    def has_key?(key)
      any? {|mod| mod.name == key}
    end

    def keys
      map {|m| m.name}
    end

    def <<(mod)
      if mod.kind_of? String
        add_module_by_name(mod)
      else
        modules << mod
      end
    end

    def remove(mod)
      if mod.kind_of? String
        delete_module_by_name(mod)
      else
        modules.delete(mod)
      end
    end

    alias_method :push, :<<
    alias_method :add_module, :<<
    
    def delete_module_by_name(module_name)
      raise MessagingException, "Module #{module_name} not loaded." unless has_key?(module_name)
      modules = modules.delete_if do |mod| 
        mod.stop! if mod.name == module_name
      end
      auth_modules.delete module_name
    end

    def find_file_module_by_name(module_name)
      #The name contain a / so we only look inside the right directory
      if module_name.include? "/"
        raise MessagingException,"This module doesn't exist." unless File.exists(dir + module_name)    
        return module_name
      else
        #The name do not contain a / so we look EVERYWHERE and ask if many
        mod_place = recursive_search dir,module_name
        raise MessagingException,"This module doesn't exist." if mod_place.empty?
        raise MessagingException,"There is multiple module with this name. Do you mean #{format_multiples_names(mod_place)}?" if mod_place.size > 1
        module_name= mod_place.first
      end
    end

    def format_multiples_names multiples_names
      multiples_names.map{|name| name.gsub(dir,"")}.join(" or ")
    end

    def recursive_search(current_dir,module_name)
      result = []
      if File.directory?(current_dir)
        Dir.foreach(current_dir) do |file|
          result += recursive_search("#{current_dir}/#{file}",module_name) unless file[0] == "."
        end
      else
        result << current_dir if current_dir.include? "#{module_name}.rb"
      end
      return result
    end

    def load_module_class(module_name)
      module_file=find_file_module_by_name(module_name)
      load module_file
      module_class module_name
    end

    def module_class(module_name)
      "Linael::Modules::#{module_name.camelize}".constantize
    end

    def add_module_by_name(module_name)
      klass = load_module_class module_name
      raise MessagingException, "Module already loaded, please unload first." if has_key? module_name
      raise MessagingException, "You need at least one authentication module to load this module." if klass.require_auth && auth_modules.empty?
      raise MessagingException, "You do not have loaded all the requirement for this module.(#{klass.required_mod.join(", ")})" unless match_requirement? klass.required_mod
      mod = Modules::Module.new(master,klass: klass)
      add_module mod
      mod.start!
      auth_modules << mod if klass.auth?
    end

  end


  class Modules::Module

    attr_accessor :name,:instance

    def initialize master,params
      @name = params[:klass]::name
      @instance = (if params[:klass]
                    params[:klass].new(master)
                  else
                    params[:instance]
                  end)
    end

    def ==(mod)
      name == mod.name
    end

    def stop!
      @instance.stop!
      true
    end

    def start!
      @instance.start!
    end
    
  end

end
