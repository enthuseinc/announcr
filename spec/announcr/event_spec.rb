require 'spec_helper'

describe Announcr::Event do
  subject { Announcr::Event }

  describe "pattern" do
    it "should use the event name as the default pattern" do
      e = subject.new("foobar")
      e.match_pattern?("foobar").should be_true
      e.match_pattern?("FOOBAR").should be_true
      e.match_pattern?("foo").should be_false
    end

    it "should use pattern option as a replacement pattern" do
      e = subject.new("foobar", pattern: /us.*/)
      e.match_pattern?("foobar").should be_false
      e.match_pattern?("us123").should be_true
    end
  end

  describe "filters" do
    it "should have no filters by default" do
      e = subject.new("foobar")
      e.match_filters?("foobar").should be_true
    end

    it "should accept a single filter" do
      e = subject.new("foobar", filters: /.*bAr/)
      e.match_filters?("foobAr").should be_true
      e.match_filters?("foobar").should be_false
    end

    it "should accept multiple filters" do
      f1 = /.*bAr/
      f2 = ->(evt, opts) { opts[:a].is_a? Fixnum }
      e = subject.new("foobar", filters: [f1, f2])
      e.match_filters?("foobAr", a: 1).should be_true
      e.match_filters?("foobAr", a: "1").should be_false
    end
  end

  describe "requires" do
    it "should have no requires by default" do
      e = subject.new("foobar")
      e.match_requires?("foobar").should be_true
    end

    it "should accept a single require" do
      e = subject.new("foobar", requires: :a)
      e.match_requires?("foobar", a: 1).should be_true
      e.match_requires?("foobar").should be_false
    end

    it "should accept multiple requires" do
      e = subject.new("foobar", requires: [:a, :b])
      e.match_requires?("foobar", a: 1, b: 2).should be_true
      e.match_requires?("foobar", a: 1).should be_false
      e.match_requires?("foobar").should be_false
    end
  end

  describe "matching" do
    let(:event) { subject.new("foobar") }
    before :each do
      event.stub!(:match_pattern?).and_return(true)
      event.stub!(:match_requires?).and_return(true)
      event.stub!(:match_filters?).and_return(true)
      @e, @o = "foobar", {}
    end

    it "should require a pattern match" do
      event.should_receive(:match_pattern?).with(@e, @o)
      event.matches?(@e, @o)
    end

    it "should require a filter match" do
      event.should_receive(:match_filters?).with(@e, @o)
      event.matches?(@e, @o)
    end

    it "should require a requires match" do
      event.should_receive(:match_requires?).with(@e, @o)
      event.matches?(@e, @o)
    end
  end

  # make_filter should probably exist in its own module, but for now we'll test
  # it alongside Announce::Event. TODO: Factor this functionality out.
  describe "#make_filter" do
    let(:event) { Announcr::Event.new("foobar") }

    it "should make an event_name matcher by string" do
      m = event.make_filter("foobar")
      m.call("foobar", {}).should be_true
      m.call("FOOBAR", {}).should be_true
      m.call(:foobar, {}).should be_true
      m.call("foo", {}).should be_false
    end

    it "should make an event_name matcher by symbol" do
      m = event.make_filter(:foobar)
      m.call(:foobar, {}).should be_true
      m.call(:FOOBAR, {}).should be_true
      m.call("foobar", {}).should be_true
      m.call(:foo, {}).should be_false
    end

    it "should make an event_name matcher by regex" do
      m = event.make_filter(/us\d\d/)
      m.call("us99", {}).should be_true
      m.call("1234", {}).should be_false
    end

    it "should return a passed in lambda" do
      l = ->(){}
      event.make_filter(l).should be(l)
    end

    it "should error for invalid matcher type" do
      lambda do
        event.make_filter(123)
      end.should raise_error
    end
  end
end
