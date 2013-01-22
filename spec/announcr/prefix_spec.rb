require 'spec_helper'

describe Announcr::Prefix do
  before :each do
    @c = Class.new do
      include Announcr::Prefix
    end
    @i = @c.new
  end

  describe "prefixes" do
    it "should normalize a list of prefixes" do
      @i.set_prefixes(["ABC", nil, ["123aB"]])
      @i.prefixes.should == ["abc", "123ab"]
    end

    it "should append a prefix" do
      @i.set_prefixes(["one"])
      @i.append_prefix("two")
      @i.prefixes == ["one", "two"]
    end

    it "should append a prefix" do
      @i.set_prefixes(["two"])
      @i.prepend_prefix("one")
      @i.prefixes == ["one", "two"]
    end

    it "should create a key with prefixes and separator" do
      @i.set_prefixes(["one", "two"])
      @i.key_for("three").should == "one.two.three"
    end
  end

  # This is mostly a sanity check block and can safely be removed or disabled
  describe "mixin methods" do
    context "getters" do
      [:separator, :prefixes, :prefix_config].each do |m|
        it "should have a #{m} method" do
          @i.should respond_to(m)
        end
      end
    end

    context "setters" do
      [:set_separator, :set_prefixes, :load_prefix_config].each do |m|
        it "should have a #{m} method" do
          @i.should respond_to(m)
        end
      end
    end

    context "mutators" do
      [:append_prefix, :prepend_prefix].each do |m|
        it "should have a #{m} method" do
          @i.should respond_to(m)
        end
      end
    end

    it "should have a key_for method" do
      @i.should respond_to(:key_for)
    end
  end
end
