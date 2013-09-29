require_relative '../../lib/core/socketable'

require 'socket'

describe Linael::Socketable do

  before(:each) do
    @opened_socket = double("socket")
    allow(@opened_socket).to receive(:close) { true }
    allow(@opened_socket).to receive(:gets)  { "Message" }
    allow(@opened_socket).to receive(:puts)  { true }
    
    @socket_stub = double("TCPSocket")
    allow(@socket_stub).to   receive(:open)  { @opened_socket }
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
    
    before(:each) do
      Linael::Socketable.any_instance.stub(socket_klass: @socket_stub)
      @instance = Linael::Socketable.new(name: :test)
      allow(@instance).to receive(:sleep) {true}
      allow(@instance).to receive(:type) {:type}
    end

    it "close socket" do
      @instance.restart
      expect(@opened_socket).to have_received :close
    end

    it "re-open the socket" do
      @instance.restart
      #open should have been called twice: once for new and once for restart
      expect(@socket_stub).to have_received(:open).twice
    end

    it "don't do anything if on_restart" do
      @instance.instance_variable_set(:@on_restart,true)
      @instance.restart
      expect(@socket_stub).to have_received(:open).once
      expect(@opened_socket).to_not have_received :close
    end

    it "sleep for some time" do
      @instance.restart
      expect(@instance).to have_received(:sleep).with be > 100

    end

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
      @instance = Linael::Socketable.new(name: :test)
      allow(@instance).to receive(:type) {:type}
      allow(@instance).to receive(:restart) {true}
    end

    it "gets from its socket" do
      @instance.gets
      expect(@opened_socket).to have_received(:gets)
    end

    it "return a MessageStruct" do
      Linael::MessageStruct = double("struct")
      allow(Linael::MessageStruct).to receive(:new) { "MessageStruct" }
      
      @instance.gets.should eq "MessageStruct" 

      expect(Linael::MessageStruct).to have_received(:new).with(:test, "Message", :type)
    end

    it "do not call gets when on restart" do
      @instance.instance_variable_set(:@on_restart,true)
      @instance.gets.should be nil
      expect(@opened_socket).to_not have_received(:gets)
    end

    it "call restart on Exception"  do
      allow(@opened_socket).to receive(:gets) { raise Exception }
      @instance.gets.should be nil
      expect(@instance).to have_received :restart
    end
    
  end

  describe "#puts" do
    before(:each) do
      Linael::Socketable.any_instance.stub(socket_klass: @socket_stub)
      @instance = Linael::Socketable.new(name: :test)
      allow(@instance).to receive(:type) {:type}
      allow(@instance).to receive(:restart) {true}
    end

    it "put msg inside the socket" do
      @instance.puts "owi"
      expect(@opened_socket).to have_received(:puts).with("owi\n")
    end

    it "don't do anything when on restart" do
      @instance.instance_variable_set(:@on_restart,true)
      @instance.puts("owi").should be nil
      expect(@opened_socket).to_not have_received :puts
    end

    it "call restart on Exception" do
      allow(@opened_socket).to receive(:puts) { raise Exception }
      @instance.puts ""
      expect(@instance).to have_received :restart
    end

  end

  describe "#listen" do
    before(:each) do

      Linael::Socketable.any_instance.stub(socket_klass: @socket_stub)
      
      @instance = Linael::Socketable.new(name: :test)
      allow(@instance).to receive(:gets) {@new_message}
      allow(@instance).to receive(:while) {true}
      allow(@instance).to receive(:sleep) {true}
      allow(@instance).to receive(:type) {:type}

      @new_message = Struct.new(:element).new("true")

      @fifo = double("fifo")
      allow(@fifo).to receive(:puts) {true}

      Linael::MessageFifo = double("fifo")
      allow(Linael::MessageFifo).to receive(:instance) {@fifo}


    end

    it "puts the line into the fifo" do
      @instance.send(:listening,@fifo)
      expect(@fifo).to have_received(:puts).with @new_message
    end

    it "don't gets when on restart" do
      @instance.instance_variable_set(:@on_restart,true)
      expect(@instance).to_not have_received(:gets)
    end

    it "sleep for some time between gets" do
      @instance.send(:listening,@fifo)
      expect(@instance).to have_received(:sleep).with be >= 0.001
    end
    
    it "create a new thread" do
      Thread = double("thread")
      allow(Thread).to receive(:new) {true}
      @instance.listen.should be true
      expect(Thread).to have_received(:new)
    end

  end

end
