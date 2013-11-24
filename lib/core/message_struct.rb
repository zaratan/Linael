# -*- encoding : utf-8 -*-
Linael::MessageStruct = Struct.new(:server_id,:element,:type) do
  def method_missing name, *args, &block 
    element.send(name)
  end
   
end
