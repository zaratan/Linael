# -*- encoding : utf-8 -*-
require 'singleton'

module Linael
  class Handler
    include Singleton

    def handle message
      begin
        message.element = format_message message
        self.class.to_do.detect{|m| self.send(m,message)}
      rescue Exception => e
        puts e.to_s.red	
        puts e.backtrace.join("\n").red
      end
    end

    def format_message msg
      raise NotImplementedError
    end
    
    # To get ToDo list
    def self.to_do
      @to_do ||= []
    end
    
    # To get to_handle list
    def self.to_handle
      @to_handle ||= []
    end

    
    def self.add_act (klass)
      klass_name = klass.name.gsub(/.*:/,"").downcase
      attr_accessor "#{klass_name}_act".to_sym
      define_method "handle_#{klass_name}" do |message|
        if klass.match?(message.element)
          message.element = klass.new message.element
          pretty_print_message message
          instance_variable_get("@#{klass_name}_act").values.each {|act| act.call message}
          true
        end
      end
      to_do << "handle_#{klass_name}".to_sym
    end

    def self.create_handle
      to_handle.each {|handle| add_act(handle)}
    end

    def act_types
      instance_variables.grep(/@(.*)_act/) {$1.to_sym}
    end

    def add_act(type,proc_name,prok)
      send("#{type}_act")[proc_name.to_sym]= prok
    end

    def del_act(type,proc_name)
      send("#{type}_act").delete(proc_name.to_sym)
    end

    def initialize
      self.class.create_handle
      self.class.to_handle.each {|klass| instance_variable_set "@#{klass.name.gsub(/.*:/,"").downcase}_act",{}}
    end

    def configure options
      @master = options[:master_module].new(self)
      @master.start!
      options[:modules].each {|modName| @master.add_action(modName)}
    end

    private

    def pretty_print_message msg
      raise NotImplementedError
    end

  end
end
