linael :master, require_auth: true do
  help [
    t.master.help.description,
    t.help.helper.line.white,
    t.help.helper.line.functions,
    t.master.help.function.show,
    t.help.helper.line.admin,
    t.master.help.function.add,
    t.master.help.function.del,
    t.master.help.function.reload
  ]


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

  def add_action name
    modules.add_module(name)
  end

  def del_action name
    modules.remove(name)
  end

  def reload_action name
    raise MessagingException, t.master.not.loaded(name) unless modules.has_key?(name)
    #raise an exception if the module do not exist :)
    modules.find_file_module_by_name(name)
    modules.remove name
    modules.add_module name
  end

  def show_action msg,regex=""
    regex.gsub!(/\*/,'[^\\/]*')
    regex = Regexp.new("#{regex}[^\\/]*\.rb")
    result = modules.find_all_modules(regex).map {|path| path.gsub(/.*\//,'').gsub(/\.rb/,'') }
    result_loaded = result.select {|k| module_instance(k)}
    answer(msg, t.master.show.all(Linael::BotNick,result.join(', ')))
    answer(msg, t.master.show.loaded(result_loaded.join(', ')))
  end

  on :cmd_auth, :add, /^!module\s-add\s/ do |msg,options|
    message_handler msg, t.master.act.add(options.who) do
      add_action options.who
    end
  end

  on :cmd_auth, :del, /^!module\s-del\s/ do |msg,options|
    message_handler msg, t.master.act.del(options.who) do
      del_action options.who
    end
  end

  on :cmd_auth, :reload, /^!module\s-reload\s/ do |msg,options|
    message_handler msg, t.master.act.reload(options.who) do
      reload_action options.who
    end
  end

  on :cmd, :show, /^!module\s-show\s/ do |msg,options|
    regex = (options.who unless options.who == options.from_who ) || ""
    show_action msg,regex
  end

end  

module Linael

  class Modules::ModuleList

    include Enumerable
    include R18n::Helpers

    attr_accessor :modules,:auth_modules,:dir,:master

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
      raise MessagingException, t.master.not.loaded(name) unless has_key?(module_name)
      modules.delete_if do |mod| 
        if mod.name == module_name
          mod.stop!
          true
        end
      end
      auth_modules.delete_if do |mod|
        mod.name == module_name
      end
    end

    def find_all_modules(regex=/\.rb/)
      recursive_search dir,regex
    end

    def find_file_module_by_name(module_name)
      #The name contain a / so we only look inside the right directory
      if module_name.include? "/"
        raise MessagingException,T.master.not.exist unless File.exists(dir + module_name)    
        return module_name
      else
        #The name do not contain a / so we look EVERYWHERE and ask if many
        mod_place = recursive_search dir,/^#{module_name}\.rb/
        raise MessagingException, t.master.not.exist if mod_place.empty?
        raise MessagingException,t.master.not.unique(format_multiples_names(mod_place)) if mod_place.size > 1
        module_name= mod_place.first
      end
    end

    def format_multiples_names multiples_names
      multiples_names.map{|name| name.gsub(dir,"")}.join(" #{t.or} ")
    end

    def recursive_search(current_dir,regex_name)
      result = []
      if File.directory?(current_dir)
        Dir.foreach(current_dir) do |file|
          result += recursive_search("#{current_dir}/#{file}",regex_name) unless file[0] == "."
        end
      else
        result << current_dir if current_dir.match regex_name
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

    def good_to_add? module_name,klass
      raise MessagingException, t.master.not.unloaded if has_key? module_name
      raise MessagingException, t.master.not.enough.auth if klass.require_auth && auth_modules.empty?
      raise MessagingException, t.master.not.enough.require(klass.required_mod.join(", ")) unless match_requirement? klass.required_mod
    end

    def add_module_by_name(module_name)
      klass = load_module_class module_name
      good_to_add?(module_name,klass)
      mod = Modules::Module.new(master,klass: klass)
      add_module mod
      mod.start!
      auth_modules << mod if klass.auth?
    end

    def add_module_by_instance(instance)
      instance.master = master
      instance.launch
      mod = Modules::Module.new(master,instance: instance)
      add_module mod
      mod.start!
      auth_modules << mod if instance.class.auth?
    end

  end


  class Modules::Module

    attr_accessor :name,:instance

    def initialize master,params
      @name = (params[:klass] || params[:instance].class)::Name
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
  end

  def start!
    @instance.start!
  end

end

end
