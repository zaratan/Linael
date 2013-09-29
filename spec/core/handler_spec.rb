require_relative '../../lib/core/handler.rb'

describe Linael::Handler do

  describe "is a Singleton" do
    it "has private new"
    it "respond to ::instance"
  end

  describe "#handle" do
    it "format the message"
    it "send the message to its to_do list"
  end


  describe "#format_message" do
    it "fail because it's an abstract class"
  end

  describe "::to_do" do
    it "return class instance variable @to_do"
    it "set @to_do to [] if not setted"
  end

  describe "::to_handle" do
    it "return class instance variable @to_handle"
    it "set @to_handle to [] if not setted"
  end

  describe "::add_act" do
    it "add accessor on the action list"
    it "define a new handler"
    it "add the new handled type tu to_do list"
  end

  describe "handler" do
    it "do nothing if the message do not match the handler type"
    it "pretty print the message"
    it "send the message at all the action of the handler"
  end

  describe "::create_handle" do
    it "add handler for every thing to handle"
  end

  describe "#act_types" do
    it "return every type of action handled"
  end

  describe "#add_act" do
    it "add an action to a handler"
  end

  describe "#del_act" do
    it "revome an action from a handler"
  end

  describe "#initialize" do
    it "create handlers"
    it "initialize actions lists"
  end

  describe "#configure" do
    it "set master module"
    it "start the master"
    it "start all other modules"
  end

  describe "#pretty_print_message" do
    it "fail because it's an abstract class"
  end

end
