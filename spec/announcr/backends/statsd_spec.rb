require 'spec_helper'

describe Announcr::Backend::Statsd do
  describe "proxy methods" do
    subject { Announcr::Backend::Statsd.new }
    [:increment, :decrement, :count, :gauge, :timing, :time].each do |m|
      it "should respond to #{m}" do
        subject.should respond_to(m)
      end
    end
  end

  describe "configuration" do
    subject { Announcr::Backend::Statsd }

    it "should use localhost by default" do
      subject.new.options[:host].should == "localhost"
    end

    it "should use 8125 by default" do
      subject.new.options[:port].should == 8125
    end

    it "should create a new statsd" do
      statsd = mock("statsd")
      Statsd.should_receive(:new).with("example.com", 1234).and_return(statsd)
      be = subject.new(host: "example.com", port: 1234)
      be.target.should be(statsd)
    end
  end
end
