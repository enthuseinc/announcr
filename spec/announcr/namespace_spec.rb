require 'spec_helper'

class TestBackend
  extend Announcr::Backend::Forward
  def self.proxy_methods; [:doit] end
  def initialize(opts = {})
    @target = opts.delete(:target)
  end
  def doit(*args)
    @target.doit(*args) if @target
  end
end

describe Announcr::Namespace do
  let(:ns) { Announcr::Namespace.new(:test) }

  describe "getter/setters" do
    [:name, :prefix, :separator, :default_backend].each do |o|
      it "should get/set #{o}" do
        val = "foobar"
        ns.send("set_#{o}", val)
        ns.send(o).should == val.to_sym
      end
    end
  end

  describe "parent attributes" do
    context "as root" do
      it "should #get own value" do
        ns.get(:prefix).should == :test
      end

      it "should #get default if value unset" do
        ns.get(:foobar, 123).should == 123
      end

      it "should #collect own value" do
        ns.collect(:prefix).should == [:test]
      end
    end

    context "as nested" do
      let(:nested) { ns.namespace(:nested) }

      it "should #get own value if set" do
        nested.get(:prefix).should == nested.prefix
      end

      it "should #get parent value if set" do
        ns.set_default_backend :stats
        nested.get(:default_backend).should == :stats
      end

      it "should #get default value if unset" do
        nested.get(:default_backend, "derp").should == "derp"
      end

      it "should #collect own and parent values" do
        nested.collect(:prefix).should == [:test, :nested]
      end
    end
  end

  describe "#all_backends" do
    context "as root" do
      it "should get backends" do
        ns.backend :log, TestBackend
        ns.all_backends.should == ns.backends
      end
    end

    context "as nested" do
      let(:nested) { ns.namespace(:nested) }

      it "should get local and parent backends" do
        ns.backend :log, TestBackend
        nested.backend :stats, TestBackend
        nested.all_backends.should == ns.backends.merge(nested.backends)
      end
    end
  end

  describe "DSL component" do
    before(:each) { ns }

    context "namespace" do
      it "should create a child namespace" do
        Announcr::Namespace.should_receive(:new).with("nested", {parent: ns})
        ns.namespace("nested")
      end
    end

    context "backend" do
      it "should create a backend" do
        TestBackend
        ns.backend :stats, TestBackend
      end
    end

    context "event" do
      it "should create an event" do
        Announcr::Event.should_receive(:new).with("e", {namespace: ns})
        ns.event "e"
      end
    end
  end

  describe "announce" do
    before :each do
      @event = Announcr::Event.new(:test, namespace: ns) do
        doit 123
      end

      @target = mock("target").as_null_object
      ns.backend :t, TestBackend, target: @target
      ns.events << @event
    end

    context "local" do
      it "should dispatch events" do
        @event.should_receive(:dispatch).with("test", {}).and_return(true)
        ns.announce_local("test")
      end
    end

    context "with children" do
      let(:nested) { ns.namespace("nested") }

      it "should announce to children" do
        nested.should_receive(:announce).with("test", {}).and_return(true)
        ns.announce("test")
      end
    end
  end
end
