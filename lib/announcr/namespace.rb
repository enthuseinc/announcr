module Announcr
  class Namespace
    attr_reader :parent, :children, :backends, :events

    [:name, :prefix, :separator, :default_backend].each do |o|
      attr_reader o
      define_method("set_#{o}") do |new_val|
        new_val = new_val.to_s.strip.downcase.to_sym
        instance_variable_set("@#{o}", new_val)
      end
    end

    def initialize(name, opts = {}, &block)
      @name = name
      @parent = opts.delete(:parent)
      @children = []
      @backends = {}
      @events = []

      @default_backend = nil
      @prefix = name.downcase.to_sym
      @separator = "."

      configure(&block) if block_given?
    end

    def collect(key, default = nil)
      values, target = [], self
      while target
        res = target.send(key) rescue nil
        values << res || default
        target = target.parent
      end
      values.compact.reverse
    end

    def get(key, default = nil)
      target = self
      while target
        res = target.respond_to?(key) ? target.send(key) : nil
        return res if res
        target = target.parent
      end
      default
    end

    def key_for(key)
      (collect(:prefix) << key).join(get(:separator))
    end

    def all_backends
      collect(:backends).inject({}) do |m, be|
        m.merge(be)
      end
    end

    def configure(&block)
      return self unless block_given?
      block.arity == 1 ? yield(self) : instance_eval(&block)
      self
    end

    def namespace(name, opts = {}, &block)
      child = Namespace.new(name, opts.merge(parent: self))
      child.configure(&block) if block_given?
      @children << child
      child
    end

    def backend(name, klass, opts = {})
      backend = klass.new(opts)
      name = name.downcase.to_sym
      @backends[name] = backend
      backend
    end

    # Register a new event
    # @param [String] name name of event
    # @param [Hash] opts event options (see `Event`)
    def event(name, opts = {}, &block)
      event = Event.new(name, opts.merge(namespace: self), &block)
      @events << event
      event
    end

    # Broadcast a new event
    def announce(event_name, opts = {}, &block)
      announce_local(event_name, opts, &block)
      @children.each { |c| c.announce(event_name, opts, &block) }
    end

    def announce_local(event_name, opts = {}, &block)
      if block_given?
        e = Event.new(event_name, opts.merge(namespace: self), &block)
        e.dispatch!(event_name, opts)
      end

      @events.each do |event|
        event.dispatch(event_name, opts)
      end
    end
  end
end
