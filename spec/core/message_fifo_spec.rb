require_relative '../../lib/core/message_fifo.rb'

describe Linael::MessageFifo do
  describe "it is a singleton" do
    it "has a instance method" do
      Linael::MessageFifo.instance.should be_an_instance_of(Linael::MessageFifo)
    end

    it "fail when new" do
      expect { Linael::MessageFifo.new }.to raise_exception
    end

    it "share variables between instances" do
      Linael::MessageFifo.instance.instance_variable_set('@test', "OKI")
      Linael::MessageFifo.instance.instance_variable_get('@test').should eq "OKI"
    end
  end

  describe "#initialize" do
    it "initialize messages" do
      Linael::MessageFifo.instance.instance_variable_get('@messages').should be_an_instance_of Array
    end

    it "is thread safe" do
      Linael::MessageFifo.instance.instance_variable_get('@messages').methods.should include :mon_enter
    end
  end

  describe "#gets" do
    before(:each) do
      Linael::MessageFifo.instance.instance_variable_get('@messages').clear
    end

    it "return :none when empty" do
      Linael::MessageFifo.instance.gets.should be :none
    end

    it "return a message message" do
      Linael::MessageFifo.instance.instance_variable_get('@messages') << "OKI"
      Linael::MessageFifo.instance.gets.should eq "OKI"
    end

    it "return the first message" do
      Linael::MessageFifo.instance.puts "OKI"
      Linael::MessageFifo.instance.puts "NOT OKI"
      Linael::MessageFifo.instance.gets.should eq "OKI"
    end
  end

  describe "#puts" do
    it "put the message at the end" do
      Linael::MessageFifo.instance.puts "OKI"
      Linael::MessageFifo.instance.instance_variable_get('@messages').should include "OKI"
    end
  end
end
