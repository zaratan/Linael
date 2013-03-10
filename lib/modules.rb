# -*- encoding : utf-8 -*-
module Linael
  class ModuleIRC

    include Action

    def add_module_irc_behavior type
      self.class.send("define_method",("add_#{type}_behavior")) do |instance,nom,ident|
        procToAdd = Proc.new {|msg| instance.send(nom,msg) if (instance.methods.grep /act_authorized\?/).empty? or act_authorized?(instance,msg)}
        (@runner.send "#{type}Act")[(instance.class::Name+ident).to_sym]= procToAdd
        @behavior = Hash.new if !@behavior
        @behavior[type] = [] if !@behavior[type]
        @behavior[type] << ident
      end
      self.class.send("define_method",("del_#{type}_behavior")) do |instance,ident|
        p instance
        p ident
        p (@runner.send "#{type}Act")
        (@runner.send "#{type}Act").delete((instance.class::Name+ident).to_sym)
        @behavior.delete_if {|k,v| v == ident} 
      end
    end

    def mod(name)
      @runner.modules.detect {|mod| mod.class == Modules::Module}.modules[name]
    end

    Name=""

    def self.require_auth 
      false
    end

    def self.required_mod
      nil
    end

    def self.auth?
      false
    end

    Constructor="Zaratan"

    def initialize(runner)
      @runner=runner
      @runner.instance_variables.grep(/@(.*)Act/) {add_module_irc_behavior $1}
    end

    def add_module(method_hash)
      method_hash.each do |k,v|
        self.methods.grep(/add_#{k.to_s}_behavior/) do |name| 
          v.each do |behav|
            self.send (name.to_sym),self,behav,behav.to_s
          end
        end
      end
    end

    def stopMod()
      self.behavior.each {|type,ident| ident.each { |id| self.send "del_#{type}_behavior",self,id}}
    end

    attr_accessor :behavior
    attr_reader :runner

  end

  module Modules
  end

  class ModulesOptions

    attr_reader :message,:where,:from_who

    def initialize privMsg
      @message = privMsg.message
      @where = privMsg.place
      @from_who = privMsg.who
    end

    def self.generate_to_catch meths
      meths.each do |key,regex|
        self.class.send("define_method","#{key.to_s}?") do |message|
          message =~ regex
        end
      end
    end

    def self.generate_meth args
      define_method args[:name] do
        return $1 if message =~ args[:regexp]
        return self.send args[:default_meth] if args[:default_meth]
        return args[:default] if args[:default]
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
                    :regexp       => /\s+([^\s#]+)\s*/,
                    :default_meth => :from_who
    end

    def self.generate_reason
      generate_meth :name   => "reason",
                    :regexp => /\s+:(.*)/
    end

  end

end
