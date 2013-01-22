require "announcr/version"

require "announcr/namespace"
require "announcr/event"
require "announcr/event_scope"
require "announcr/backends"

module Announcr
  def self.root_namespace
    @root_namespace ||= Namespace.new(:root)
  end

  def self.configure(&block)
    root_namespace.configure(&block)
  end

  def self.namespace(name, opts = {}, &block)
    root_namespace.namespace(name, opts, &block)
  end

  def self.announce(event_name, opts = {}, &block)
    root_namespace.announce(event_name, opts, &block)
  end

  def self.announce_local(event_name, opts = {}, &block)
    root_namespace.announce_local(event_name, opts, &block)
  end

  def self.reset!
    @root_namespace = nil
  end
end
