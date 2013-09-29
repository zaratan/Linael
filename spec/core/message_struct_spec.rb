module Linael
end

require_relative '../../lib/core/message_struct'

describe Linael::MessageStruct do

  describe "it's a Struct for messages" do
    
    before(:all) do
      @struct = Linael::MessageStruct.new(:server_id,:element,:type)
    end

    it "contain a server_id and be the first" do
      @struct.server_id.should be :server_id
    end

    it "contain a element and be the second" do
      @struct.element.should be :element
    end

    it "contain a type and be the third" do
      @struct.type.should be :type
    end

  end  

  it "forward every unknown method to it's element" do
    Linael::MessageStruct.new(nil,"OKI",nil).downcase.should eq "oki"
  end

end
