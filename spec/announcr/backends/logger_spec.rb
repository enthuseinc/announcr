require 'spec_helper'

describe Announcr::Backend::Logger do
  describe "proxy methods" do
    subject { Announcr::Backend::Logger.new }
    [:debug, :info, :warn, :error, :fatal].each do |m|
      it "should respond to #{m}" do
        subject.should respond_to(m)
      end
    end
  end

  describe "configuration" do
    subject { Announcr::Backend::Logger }
    it "should use stdout by default" do
      subject.new.options[:out].should be(STDOUT)
    end

    it "should allow a logger to be passed in" do
      logger = mock("logger")
      be = subject.new(logger: logger)
      be.target.should be(logger)
    end

    it "should create a new logger" do
      logger = mock("logger")
      Logger.should_receive(:new).with("foobar").and_return(logger)
      be = subject.new(out: "foobar")
      be.target.should be(logger)
    end
  end
end
