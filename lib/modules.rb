# -*- encoding : utf-8 -*-
module Linael
  class ModuleIRC

    include Action

    def add_module_irc_behavior type
      define_singleton_method ("add_#{type}_behavior") do |instance,nom,ident|
        procToAdd = Proc.new {|msg| instance.send(nom,msg) if (instance.methods.grep /act_authorized\?/).empty? or actAuthorized?(instance,msg)}
        (@runner.send "#{type}Act")[(instance.class::Name+ident).to_sym]= procToAdd
        @behavior = Hash.new if @behavior.nil?
        @behavior[type] = ident
      end
      define_singleton_method("del_#{type}_behavior") do |instance,ident|
        (@runner.send "#{type}Act").delete((instance.class::Name+ident).to_sym)
        @behavior.delete_if {|k,v| v == ident} 
      end
    end

    def module(name)
      @runner.modules.detect {|mod| mod.class == Modules::Module}.modules[name]
    end

    Name=""

    Help=[]

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
      self.behavior.each {|type,ident| self.send "del_#{type}_behavior",ident}
    end

    attr_accessor :behavior
    attr_reader :runner

  end

  module Modules
  end
end
