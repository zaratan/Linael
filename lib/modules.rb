# -*- encoding : utf-8 -*-
module Linael
  class ModuleIRC

    include Action

    def add_module_irc_behavior type
      self.class.send("define_method",("add_#{type}_behavior")) do |instance,nom,ident|
        procToAdd = Proc.new {|msg| instance.send(nom,msg) if (instance.methods.grep /act_authorized\?/).empty? or actAuthorized?(instance,msg)}
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
end
