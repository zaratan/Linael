# -*- encoding : utf-8 -*-
module Linael
  class ModuleIRC

    include Action

    # *Intern method, don't use it*::
    # It's a methode made for generate the add_type_behaviour
    def add_module_irc_behavior type
      self.class.send("define_method",("add_#{type}_behavior")) do |instance,nom,ident|
        procToAdd = Proc.new {|msg| instance.send(nom,msg) if (instance.methods.grep /act_authorized\?/).empty? or act_authorized?(instance,msg)}
        (@runner.send "#{type}Act")[(instance.class::Name+ident).to_sym]= procToAdd
        @behavior = Hash.new if !@behavior
        @behavior[type] = [] if !@behavior[type]
        @behavior[type] << ident
      end
      self.class.send("define_method",("del_#{type}_behavior")) do |instance,ident|
        (@runner.send "#{type}Act").delete((instance.class::Name+ident).to_sym)
        @behavior.delete_if {|k,v| v == ident} 
      end
    end

    # Return the current instance of a module return nil if no mod
    # Params:
    # +name+:: name of the module
    #
    #   mod("admin") #=> return admin module
    #   mod("dfgh")  #=> nil
    def mod(name)
      @runner.modules.detect {|mod| mod.class == Modules::Module}.modules[name]
    end

    # Name of the module. Must be equal to class name downcase
    Name=""

    # *OLD DSL method*:: Must be overided to True if you need authentification
    def self.require_auth 
      false
    end

    # *OLD DSL method*:: Must be overided if you need other modules
    def self.required_mod
      nil
    end

    # *OLD DSL method*:: Must be overided if you want to do something @load
    def load_mod

    end

    # *OLD DSL method*:: Must be overired to True if it's an authentification module
    def self.auth?
      false
    end

    # Name of module constructor.
    # Zaratan by defalut
    #
    # In new DSL should be setted in linael command.
    Constructor="Zaratan"

    # *Don't really instanciate this class*::
    def initialize(runner)
      @runner=runner
      @runner.instance_variables.grep(/@(.*)Act/) {add_module_irc_behavior $1}
    end


    # *OLD DSL method*:: use it to declare which method tu use
    # +method_hash+:: 
    # * +key+:: place to load (:cmd,:join,...)
    # * +value+:: name of the method
    def add_module(method_hash)
      method_hash.each do |k,v|
        self.methods.grep(/add_#{k.to_s}_behavior/) do |name| 
          v.each do |behav|
            self.send (name.to_sym),self,behav,behav.to_s
          end
        end
      end
    end

    # *Internal method, don't use it*
    def stopMod()
      self.behavior.each {|type,ident| ident.each { |id| self.send "del_#{type}_behavior",self,id}}
    end

    attr_accessor :behavior,:runner

  end

  module Modules
  end

  #Super class for Options in modules. Don't use it directly since there is a new DSL for this
  class ModulesOptions

    attr_reader :message,:where,:from_who

    def initialize privMsg
      @message = privMsg.message
      @where = privMsg.place
      @from_who = privMsg.who
    end

    def self.generate_to_catch meths
      meths.each do |key,regex|
        self.send("define_singleton_method","#{key.to_s}?") do |message|
          message.downcase =~ regex
        end
      end
    end

    def self.generate_meth args
      define_method args[:name] do
        return $1 if message =~ args[:regexp]
        return self.send args[:default_meth] if args[:default_meth]
        return args[:default] unless args[:default].nil?
        ""
      end
    end

    def self.generate_chan
      generate_meth :name         => "chan",
        :regexp       => /\s(#\S*)\s/,
        :default_meth => :where
    end

    def self.generate_who
      generate_meth :name         => "who",
        :regexp       => /\s+([^\s\-#][^\s#]*)\s*/,
      :default_meth => :from_who
    end

    def self.generate_what
      generate_meth :name         => "what",
        :regexp       => /\s+([^\s#][^\s#]*)\s*/
    end

    def self.generate_reason
      generate_meth :name   => "reason",
        :regexp => /\s+:([^\n\r]*)/
    end

    def self.generate_type
      generate_meth :name   => "type",
        :regexp => /\s-(\S*)\s/
    end

    def self.generate_value args
      args.each do |name,regexp|
        generate_meth :name   => name.to_s,
          :regexp => regexp
      end
    end

    def self.generate_value_with_default args
      args.each do |name,arg|
        generate_meth :name    => name.to_s,
          :regexp  => arg[:regexp],
          :default => arg[:default]
      end
    end

    def self.generate_match args
      args.each do |name,regexp|
        generate_meth :name    => name.to_s + "?",
          :regexp  => Regexp.new("(" + regexp.to_s + ")"),
          :default => false
      end
    end

    def self.generate_all
      generate_meth :name   => "all",
        :regexp => /\s(.*)/
    end

  end

end
