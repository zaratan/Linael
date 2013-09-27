require 'singleton'

module Linael
  class Handler
    include Singleton

    def handle message
      begin
        message.element = format_message message
        Handler.to_do.detect{|m| self.send(m,msg)}
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
      @to_do
    end
    
    # To get to_handle list
    def self.to_handle
      @to_handle
    end

    @to_handle = []
    
    def self.add_act (klass)
      klass_name = klass.name.gsub(/.*:/,"").downcase
      attr_accessor "#{klass_name}Act".to_sym
      define_method "handle_#{klass_name}" do |message|
        if klass.match?(message)
          message.element = klass.new message.element
          pretty_print_message message
          instance_variable_get("@#{klass_name}Act").values.each {|act| act.call message}
          true
        end
      end
      @to_do = [] if @to_do.nil?
      @to_do << "handle_#{klass_name}".to_sym
    end

    def self.create_handle
      @to_handle.each {|handle| add_act(handle)}
    end

    def act_types
      instance_variables.grep(/@(.*)Act/) {$1.to_sym}
    end

    def add_act(type,proc_name,prok)
      send("#{type}Act")[proc_name.to_sym]= prok
    end

    def del_act(type,proc_name)
      send("#{type}Act").delete(proc_name.to_sym)
    end

    def initialize(master_module,modules)
      self.create_handle
      self.to_handle.each {|klass| instance_variable_set "@#{klass.name.gsub(/.*:/,"").downcase}Act",Hash.new}
      @master = master_module.new(self)
      @master.start!
      modules.each {|modName| @master.add_action(modName)}
    end

    private

    def pretty_print_message
      raise NotImplementedError
    end

  end
end
