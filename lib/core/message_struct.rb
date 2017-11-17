Linael::MessageStruct = Struct.new(:server_id, :element, :type) do
  def method_missing(name, *_args)
    element.send(name)
  end
end
