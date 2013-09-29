require_relative '../../lib/core/socket_list.rb'

describe Linael::SocketList do

  describe "include Enumerable" do
    it "has a #each method"
    it "has a #detect method"
  end

  describe "#initialize" do
    it "initialize the socket list"
    it "get the fifo"
  end

  describe "#each" do
    it "cycle on sockets"
  end

  describe "#add" do
    it "add a new socket to the list"
    it "raise an exception if the name is already used"
    it "generate a name from url and port if name isn't given"
  end

  describe "#connect" do
    it "launch the listen loop on a socket"
  end

  describe "#remove" do
    it "close the socket"
    it "remove eventual listener"
    it "remove the socket from the socket list"
  end

  describe "#[] or #server_by_name" do
    it "raise Exception if the sockets list is empty"
    it "give the first socket if no name is specified"
    it "raise Exception if no socket have the right net"
    it "give the socket with the right name"
  end

  describe "#send_message" do
    it "send the message to the right socket"
  end

  describe "gets" do
    it "get the first message from fifo"
  end

end
