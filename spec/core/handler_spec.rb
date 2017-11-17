require_relative '../../lib/core/handler.rb'

describe Linael::Handler do
  before(:each) do
    @instance = Linael::Handler.instance

    @handler = double("handler")
    allow(@handler).to receive(:delete) { :delete }
    allow(@handler).to receive(:[]=) { :[]= }

    allow(@instance).to receive(:owi_act) { @handler }
  end

  describe "is a Singleton" do
    it "has private new" do
      expect{ Linael::Handler.new }.to raise_exception NoMethodError
    end

    it "respond to ::instance" do
      Linael::Handler.instance.should be_an_instance_of Linael::Handler
    end
  end

  describe "#handle" do
    before(:each) do
      @message = Struct.new(:element).new(:e)
      @instance.class.to_do << :owi_act
      allow(@instance).to receive(:format_message) { @message }
    end

    it "format the message" do
      @instance.handle(@message)
      expect(@instance).to have_received(:format_message).with(@message)
    end

    it "send the message to its to_do list" do
      @instance.handle(@message)
      expect(@instance).to have_received(:owi_act).with(@message)
    end
  end

  describe "#format_message" do
    it "fail because it's an abstract class" do
      expect{ @instance.format_message "" }.to raise_exception NotImplementedError
    end
  end

  describe "::to_do" do
    it "return class instance variable @to_do" do
      Linael::Handler.instance_variable_set(:@to_do, :todo)
      Linael::Handler.to_do.should eq :todo
    end

    it "set @to_do to [] if not setted" do
      Linael::Handler.instance_variable_set(:@to_do, nil)
      Linael::Handler.to_do.should eq []
    end
  end

  describe "::to_handle" do
    it "return class instance variable @to_handle" do
      Linael::Handler.instance_variable_set(:@to_handle, :tohandle)
      Linael::Handler.to_handle.should eq :tohandle
    end
    it "set @to_handle to [] if not setted" do
      Linael::Handler.instance_variable_set(:@to_handle, nil)
      Linael::Handler.to_handle.should eq []
    end
  end

  describe "::add_act" do
    before(:each) do
      allow(Linael::Handler).to receive(:define_method) { :define }
      allow(Linael::Handler).to receive(:attr_accessor) { :attr_accessor }
    end

    it "add accessor on the action list" do
      Linael::Handler.add_act(String)
      expect(Linael::Handler).to have_received(:attr_accessor).with(:string_act)
    end

    it "only take the class name (noting before \":\")" do
      Linael::Handler.add_act(Linael::Handler)
      expect(Linael::Handler).to have_received(:attr_accessor).with(:handler_act)
    end

    it "define a new handler" do
      Linael::Handler.add_act(String)
      expect(Linael::Handler).to have_received(:define_method).with("handle_string")
    end

    it "add the new handled type to to_do list" do
      Linael::Handler.add_act(String)
      Linael::Handler.to_do.should include :handle_string
    end
  end

  describe "handler" do
    before(:each) do
      @message = Struct.new(:element).new(:element)

      @testh = double("test_handler")
      allow(@testh).to receive(:match?) { true }
      allow(@testh).to receive(:new) { @message }
      allow(@testh).to receive(:name) { "test" }

      @act = double("act")
      allow(@act).to receive(:call) { true }

      allow(@instance).to receive(:pretty_print_message) { :pretty }

      Linael::Handler.add_act(@testh)
      @instance.instance_variable_set(:@test_act, first: @act)
    end

    it "do nothing if the message do not match the handler type" do
      allow(@testh).to receive(:match?) { false }
      @instance.handle_test(@message).should be nil
    end

    it "pretty print the message" do
      @instance.handle_test(@message).should be true
      expect(@instance).to have_received(:pretty_print_message).with @message
    end

    it "send the message at all the action of the handler" do
      @instance.handle_test(@message).should be true
      expect(@act).to have_received(:call).with @message
    end
  end

  describe "::create_handle" do
    it "add handler for every thing to handle" do
      allow(Linael::Handler).to receive(:add_act) { :add }
      Linael::Handler.to_handle << :owi
      Linael::Handler.to_handle << :onoes

      Linael::Handler.create_handle

      expect(Linael::Handler).to have_received(:add_act).with(:owi)
      expect(Linael::Handler).to have_received(:add_act).with(:onoes)
    end
  end

  describe "#act_types" do
    it "return every type of action handled" do
      @instance.instance_variable_set(:@owi_act, "")
      @instance.instance_variable_set(:@onoes_act, "")
      @instance.act_types.should include :owi
      @instance.act_types.should include :onoes
    end
  end

  describe "#add_act" do
    it "add an action to a handler" do
      @instance.add_act("owi", "test", :prok)
      expect(@handler).to have_received(:[]=).with(:test, :prok)
    end
  end

  describe "#del_act" do
    it "revome an action from a handler" do
      @instance.del_act("owi", "test")

      expect(@handler).to have_received(:delete).with(:test)
    end
  end

  describe "#initialize" do
    before(:each) do
      allow(Linael::Handler).to receive(:create_handle) { :ch }
      allow(Linael::Handler).to receive(:to_handle) { [String] }
      @instance.send(:initialize)
    end

    it "create handlers" do
      expect(Linael::Handler).to have_received(:create_handle)
    end

    it "only take the class name (nothing before \":\")" do
      allow(Linael::Handler).to receive(:to_handle) { [Linael::Handler] }
      @instance.send(:initialize)
      @instance.instance_variable_get(:@handler_act).should be {}
    end

    it "initialize actions lists" do
      @instance.instance_variable_get(:@string_act).should be {}
    end
  end

  describe "#configure" do
    before(:each) do
      @masta = double("master")
      allow(@masta).to receive(:new) { @masta }
      allow(@masta).to receive(:start!) { :start! }
      allow(@masta).to receive(:add_action) { :add_action }
      @instance.configure master_module: @masta, modules: %i[mod1 mod2]
    end

    it "set master module" do
      @instance.instance_variable_get(:@master).should be @masta
    end

    it "start the master" do
      expect(@masta).to have_received(:start!)
    end

    it "start all other modules" do
      expect(@masta).to have_received(:add_action).with(:mod1)
      expect(@masta).to have_received(:add_action).with(:mod2)
    end
  end

  describe "#pretty_print_message" do
    it "fail because it's an abstract class" do
      expect{ @instance.send(:pretty_print_message, "") }.to raise_exception NotImplementedError
    end
  end
end
