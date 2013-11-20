require_relative '../../lib/core/message_fifo.rb'
require_relative '../../lib/core/message_struct.rb'
require_relative '../../lib/core-ext/struct.rb'

describe Linael::MessageFifo do

  describe "it is a singleton" do

    it "has a instance method" do
      Linael::MessageFifo.instance.should be_an_instance_of(Linael::MessageFifo)
    end

    it "fail when new" do
      expect {Linael::MessageFifo.new}.to raise_exception
    end

    it "share variables between instances" do
      Linael::MessageFifo.instance.instance_variable_set('@test',"OKI")
      Linael::MessageFifo.instance.instance_variable_get('@test').should eq "OKI"
    end


  end

  describe "#initialize" do

    it "initialize a pipe" do
      Linael::MessageFifo.instance.instance_variables.should include :@writter
      Linael::MessageFifo.instance.instance_variables.should include :@reader
      Linael::MessageFifo.instance.instance_variable_get(:@reader).should_not be nil

    end

  end 

  describe "#gets" do
    
    it "return a message message" do
      Linael::MessageFifo.instance.puts Linael::MessageStruct.new("te","OKI",:st).to_json
      Linael::MessageFifo.instance.gets.element.should eq "OKI"
    end

    it "return the first message" do
      Linael::MessageFifo.instance.puts Linael::MessageStruct.new("te","OKI","st").to_json
      Linael::MessageFifo.instance.puts Linael::MessageStruct.new("te","NOT OKI","st").to_json
      Linael::MessageFifo.instance.gets.element.should eq "OKI"
      Linael::MessageFifo.instance.gets.element.should eq "NOT OKI"

    end

  end

  describe "#puts" do

    it "put the message at the end" do
      Linael::MessageFifo.instance.puts Linael::MessageStruct.new("te","OKI","st").to_json
      geted = Linael::MessageFifo.instance.gets

      geted.element.should eq "OKI"
      geted.type.should eq :st
    end

  end

end
