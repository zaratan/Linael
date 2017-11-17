require_relative '../../lib/core/socket_list.rb'

describe Linael::SocketList do
  before(:each) do
    @fifo_mock = double("fifo")
    allow(@fifo_mock).to receive(:gets) { :gets }

    Linael::SocketList::MessageFifo = double("fifo_class")
    allow(Linael::SocketList::MessageFifo).to receive(:instance) { @fifo_mock }

    @instance = Linael::SocketList.new

    @owi = double("ow")
    allow(@owi).to receive(:name) { :owi }
    allow(@owi).to receive(:listen) { :listen }
    allow(@owi).to receive(:stop_listen) { :stop_listen }
    allow(@owi).to receive(:close) { :close }
    allow(@owi).to receive(:puts) { :puts }
    allow(@owi).to receive(:write) { :write }

    Owi = double("owi")
    allow(Owi).to receive(:new) { @owi }
  end

  describe "include Enumerable" do
    it "has a #each method" do
      Linael::SocketList.instance_methods.should include :each
    end

    it "has a #detect method" do
      Linael::SocketList.instance_methods.should include :detect
    end
  end

  describe "accessors" do
    it "has sockets" do
      Linael::SocketList.instance_methods.should include :sockets
      Linael::SocketList.instance_methods.should include :sockets=
    end
  end

  describe "#initialize" do
    it "initialize the socket list" do
      @instance.instance_variable_get(:@sockets).should be_an_instance_of Array
    end

    it "get the fifo" do
      @instance.instance_variable_get(:@fifo).should be @fifo_mock
    end
  end

  describe "#each" do
    it "cycle on sockets" do
      @instance.sockets << :owi
      @instance.map(&:to_s).should eq ["owi"]
    end
  end

  describe "#add" do
    it "add a new socket to the list" do
      @instance.add Owi, name: :test
      @instance.sockets.should include {}
    end

    it "raise an exception if the name is already used" do
      @instance.add Owi, name: :owi
      expect{ @instance.add(Owi, name: :owi) }.to raise_exception
    end

    it "generate a name from url and port if name isn't given" do
      @instance.add(Owi, url: "owi", port: 1234).should eq "owi:1234"
    end

    it "return the name" do
      @instance.add(Owi, name: :owi).should be :owi
    end
  end

  describe "#connect" do
    it "launch the listen loop on a socket" do
      @instance.add(Owi, name: :owi)
      @instance.connect :owi
      expect(@owi).to have_received(:listen)
    end
  end

  describe "#remove" do
    it "close the socket" do
      @instance.add(Owi, name: :owi)
      @instance.remove(:owi)
      expect(@owi).to have_received(:close)
    end

    it "remove eventual listener" do
      @instance.add(Owi, name: :owi)
      @instance.remove(:owi)
      expect(@owi).to have_received(:stop_listen)
    end

    it "remove the socket from the socket list" do
      @instance.add(Owi, name: :owi)
      @instance.remove(:owi)
      expect{ @instance[:owi] }.to raise_exception
    end
  end

  describe "#[] or #socket_by_name" do
    it "raise Exception if the sockets list is empty" do
      expect{ @instance[:owi] }.to raise_exception
    end

    it "give the first socket if no name is specified" do
      @instance.add(Owi, name: :owi)
      @instance[].should be @owi
    end

    it "raise Exception if no socket have the right net" do
      @instance.add(Owi, name: :owi)
      expect{ @instance[:onoes] }.to raise_exception
    end

    it "give the socket with the right name" do
      @instance.add(Owi, name: :owi)
      @instance[:owi].should be @owi
    end
  end

  describe "#send_message" do
    it "send the message to the right socket" do
      @instance.add(Owi, name: :owi)
      @instance.send_message(Struct.new(:server_id, :element).new(:owi, :message))
      expect(@owi).to have_received(:write).with(:message)
    end
  end

  describe "gets" do
    it "get the first message from fifo" do
      @instance.gets.should be :gets
    end
  end
end
