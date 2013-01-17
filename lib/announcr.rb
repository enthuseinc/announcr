require "announcr/version"

require "announcr/prefix"
require "announcr/namespace"
require "announcr/event"
require "announcr/event_scope"
require "announcr/backends"

module Announcr
  extend Prefix

  def self.reset!
    @namespaces = {}
    @backends = {}
    @global_prefix = nil
  end

  def self.namespace(name, &block)
    reg_name = (opts.delete(:as) || name).to_s.downcase

    ns = Namespace.new(name)
    ns.describe(&block) if block_given?
    @namespaces[reg_name] = ns
  end

  def self.backend(klass, opts = {})
    be = klass.new(opts)
    @backends[be.short_name] = be
  end

  def self.announce_all(*args)
    @namespaces.values.each do |ns|
      ns.announce(*args)
    end
  end

  def self.backend_for(name)
    @backends.fetch(name.to_s.downcase)
  end

  def self.namespace_for(name)
    @namespaces.fetch(name.to_s.downcase)
  end

  def self.namespaces; @namespaces; end
  def self.backends; @backends; end

  reset!
end
