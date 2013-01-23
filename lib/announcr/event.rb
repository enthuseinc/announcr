module Announcr
  class Event
    def initialize(name, opts = {}, &block)
      @name = name
      @action = block
      @options = opts

      @pattern = make_filter(opts.fetch(:pattern, @name))
      @requires = [opts.fetch(:requires, [])].flatten.compact

      filter = opts[:filter]
      filters = ([opts[:filters]] << filter).flatten.compact
      @filters = make_filters(filters)
    end

    def match_pattern?(event_name, opts = {})
      !!@pattern.call(event_name, opts)
    end

    def match_requires?(event_name, opts = {})
      @requires.map { |r| opts[r] }.all?
    end

    def match_filters?(event_name, opts = {})
      @filters.map do |filter|
        filter.call(event_name, opts)
      end.all?
    end

    def matches?(event_name, opts = {})
      [:pattern, :requires, :filters].map do |matcher|
        send(:"match_#{matcher}?", event_name, opts)
      end.all?
    end

    def dispatch(event_name, opts = {})
      matches?(event_name, opts) ? dispatch!(event_name, opts) : nil
    end

    def dispatch!(event_name, opts = {})
      scope = EventScope.new(event_name, @options.merge(data: opts))
      scope.instance_eval(&@action)
    end

    def make_filter(filter)
      return filter if filter.respond_to?(:call)

      if filter.is_a?(String) || filter.is_a?(Symbol)
        ->(event_name, args) { event_name.to_s.downcase == filter.to_s.downcase }
      elsif filter.is_a?(Regexp)
        ->(event_name, args) { filter.match(event_name.to_s) }
      else
        raise "invalid filter type #{filter.class}"
      end
    end

    private

    def make_filters(filter_list)
      filter_list.flatten.compact.map { |f| make_filter(f) }
    end
  end
end
