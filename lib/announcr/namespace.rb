module Announcr
  class Namespace
    include ::Announcr::Prefix

    attr_reader :name, :events, :default_backend

    def initialize(name, opts = {})
      @name = name
      @default_backend = opts[:default_backend]
      load_prefix_config(opts)
    end

    def describe(&block)
      instance_eval(&block) if block_given?
      self
    end

    # Set or return the default backend used in `EventScope` for events
    #   dispatched from this namespace
    # @param [String] name name of backend
    def default(name = nil)
      raise "unknown backend #{name}" unless ::Announcr.has_key?(name)
      @default_backend ||= name
    end

    def event_options
      {
        namesapce: self,
        default_backend: @default_backend,
      }.merge(prefix_config)
    end

    # Register a new event
    # @param [String] name name of event
    # @param [Hash] opts event options (see `Event`)
    def event(name, opts = {}, &block)
      @events << Event.new(name, event_options.merge(opts), &block)
    end

    # Broadcast a new event
    def announce(event_name, opts = {}, &block)
      if block_given?
        e = Event.new(self, event_name, &block)
        e.track!(event_name, opts)
      end

      @events.select do |event|
        event.matches?(event_name, opts)
      end.map do |event|
        event.dispatch(event_name, opts)
      end
    end
  end
end
