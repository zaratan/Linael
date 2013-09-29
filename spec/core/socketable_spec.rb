require_relative '../../lib/core/message_fifo.rb'
require_relative '../../lib/core/message_struct'
require_relative '../../lib/core/socketable'

require 'socket'

describe Linael::Socketable do

  before(:each) do
    @socket_stub = double("TCPSocket")
    @opened_socket = double("socket")
    allow(@socket_stub).to receive(:open)    { @opened_socket }
    allow(@opened_socket).to receive(:close) { true }
    allow(@opened_socket).to receive(:gets) { "Message" }
    allow(@opened_socket).to receive(:puts) { true }
  end

  describe "accessors" do

    it "contain server" do
      Linael::Socketable.instance_methods.should include :server
      Linael::Socketable.instance_methods.should include :server=
    end

    it "contain name" do
      Linael::Socketable.instance_methods.should include :name
      Linael::Socketable.instance_methods.should include :name=
    end

    it "contain on_restart" do
      Linael::Socketable.instance_methods.should include :on_restart
      Linael::Socketable.instance_methods.should include :on_restart=
    end

    it "contain port" do
      Linael::Socketable.instance_methods.should include :port
      Linael::Socketable.instance_methods.should include :port=
    end

    it "do not contain socket" do
      Linael::Socketable.instance_methods.should_not include :socket
      Linael::Socketable.instance_methods.should_not include :socket=
    end

  end

  describe "#restart" do
    it "close socket"
    it "re-open the socket"
    it "don't do anything if on_restart"
    it "sleep for some time"
    it "should be on restart"
  end

  describe "#socket_klass" do
    it "fail 'cause it's an abstract class" do
      expect{Linael::Socketable.new(name: "test")}.to raise_exception NotImplementedError
    end
  end

  describe "#type" do

    before(:each) do
      Linael::Socketable.any_instance.stub(socket_klass: @socket_stub)
      @instance = Linael::Socketable.new(name: :test)
    end

    it "fail 'cause it's an abstract class" do
      expect{@instance.type}.to raise_exception NotImplementedError
    end
  end

  describe "#gets" do
    
    before(:each) do
      Linael::Socketable.any_instance.stub(socket_klass: @socket_stub)
      Linael::Socketable.any_instance.stub(type: :type)
      @instance = Linael::Socketable.new(name: :test)
    end

    it "gets from its socket" do
      @instance.gets
      expect(@opened_socket).to have_received(:gets)
    end

    it "return a MessageStruct" do
      @instance.gets.should be_an_instance_of Linael::MessageStruct
      @instance.gets.server_id.should be :test
      @instance.gets.type.should be :type
      @instance.gets.element.should eq "Message"
    end

    it "do not call gets when on restart" do
      @instance.instance_variable_set(:@on_restart,true)
      @instance.gets.should be nil
      expect(@opened_socket).to_not have_received(:gets)
    end

    it "call restart on Exception" 
    
  end

  describe "#puts" do
    before(:each) do
      Linael::Socketable.any_instance.stub(socket_klass: @socket_stub)
      Linael::Socketable.any_instance.stub(type: :test)
      @instance = Linael::Socketable.new(name: :test)
    end

    it "put msg inside the socket"
    it "don't do anything when on restart"
    it "call restart on Exception"
  end

  describe "#listen" do
    before(:each) do
      Linael::Socketable.any_instance.stub(socket_klass: @socket_stub)
      Linael::Socketable.any_instance.stub(type: :test)
      @instance = Linael::Socketable.new(name: :test)
    end

    it "create a new thread"
    it "call gets in a while(true)"
    it "puts the line into the fifo"
    it "don't gets when on restart"
    it "sleep for some time between gets"

  end

end
