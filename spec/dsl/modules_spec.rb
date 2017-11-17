module Linael
  module Irc
    module Action
      def test_action; end
    end
  end
end

require 'r18n-desktop'
require 'colorize'
require_relative '../../lib/dsl/modules.rb'

describe Linael::ModuleIRC do
  it "include Action for IRC" do
    Linael::ModuleIRC.instance_methods.should include :test_action
  end

  it "include Helpers for i18n" do
    Linael::ModuleIRC.instance_methods.should include :t
  end

  describe "#mod" do
    it "call master to get the right instance of module" do
      @master = double("master")
      allow(@master).to receive(:module_instance) { :module_instance }
      @module_irc = Linael::ModuleIRC.new
      @module_irc.instance_variable_set(:@master, @master)
      @module_irc.mod("test_module").should be :module_instance

      expect(@master).to have_received(:module_instance).with("test_module")
    end
  end

  describe "accessor" do
    it "give acces to its behaviors" do
      Linael::ModuleIRC.instance_methods.should include :behaviors
      Linael::ModuleIRC.instance_methods.should include :behaviors=
    end

    it "give acces to its master module" do
      Linael::ModuleIRC.instance_methods.should include :master
      Linael::ModuleIRC.instance_methods.should include :master=
    end
  end

  describe "#stop!" do
    it "remove all its behaviors from the handler" do
      @module_irc = Linael::ModuleIRC.new
      @module_irc.behaviors = { type_1: %i[A1 B1], type_2: %i[A2 B2] }
      allow(@module_irc).to receive(:del_type_1_behavior) { :type_1 }
      allow(@module_irc).to receive(:del_type_2_behavior) { :type_2 }

      @module_irc.stop!

      expect(@module_irc).to have_received(:del_type_1_behavior).with(@module_irc, :A1)
      expect(@module_irc).to have_received(:del_type_1_behavior).with(@module_irc, :B1)
      expect(@module_irc).to have_received(:del_type_2_behavior).with(@module_irc, :A2)
      expect(@module_irc).to have_received(:del_type_2_behavior).with(@module_irc, :B2)
    end
  end

  describe "protected methods" do
    describe "#message_handler" do
      before(:each) do
        @module_irc = Linael::ModuleIRC.new
        allow(@module_irc).to receive(:answer) { true }
        allow(@module_irc).to receive(:talk) { true }
        allow(@module_irc).to receive(:puts) { true }

        @yiel = double("yield")
        allow(@yiel).to receive(:owi)

        @msg = double("msg")
        allow(@msg).to receive(:who) { :who }
        allow(@msg).to receive(:server_id) { :server_id }

        @error = double("exception")
        allow(@error).to receive(:to_s) { :to_s }
        allow(@error).to receive(:backtrace) { ["backtrace"] }
      end

      it "yield the block" do
        @module_irc.send(:message_handler, "") { @yiel.owi }

        expect(@yiel).to have_received(:owi)
      end

      it "answer the result_message if no Exception" do
        @module_irc.send(:message_handler, "", :result) { @yiel.owi }
        expect(@module_irc).to have_received(:answer).with("", :result)
      end

      it "answer the error message if MessagingException" do
        allow(@yiel).to receive(:excep) { raise MessagingException, "owi" }

        @module_irc.send(:message_handler, :error, :result) { @yiel.excep }

        expect(@module_irc).to have_received(:answer).with(:error, "owi")
      end

      it "talk to the message owner and return the error message if Exception" do
        allow(@yiel).to receive(:excep) { raise "owi" }
        @module_irc.send(:message_handler, @msg, :result) { @yiel.excep }
        expect(@module_irc).to have_received(:talk).with(:who, "owi", :server_id)
      end
    end

    describe "::generate_all_options" do
      it "generate for chan, who, what, reason, type, all"
    end

    describe "#add_module" do # TODO describe it GREATLY through tests. It's better than doc
    end

    describe "#generate_proc" do
      it "generate the proc that will be stored in handler"
    end

    describe "generated proc" do
      it "verify if the method is authorized"
      it "call the right method with the message"
    end

    describe "#instance_ident" do
      it "generate identification name for a method"
    end

    describe "#define_add_behaviour" do
      it "generate a method for a behavior type"
      describe "generated #add_'type'_behavior" do
        it "generate a new proc"
        it "add the proc to master"
        it "add the newly added proc to behaviors list"
      end
    end

    describe "#define_del_behaviour" do
      it "generate a method for a behavior type"

      describe "generated #del_'type'_behavior" do
        it "remove the behavior from master"
        it "remove the behavior from behaviors list"
      end
    end

    describe "#add_module_irc_behavior" do
      it "define add behaviors"
      it "define del behaviors"
    end
  end
end

describe Linael::ModulesOptions do
  describe "readers"
  describe "#initialize"
  describe "::generate_to_catch"
  describe "::generate_meth"
  describe "::generate_chan"
  describe "::generate_who"
  describe "::generate_what"
  describe "::generate_reason"
  describe "::generate_type"
  describe "::generate_value"
  describe "::generate_value_with_default"
  describe "::generate_match"
  describe "::generate_all"
end
