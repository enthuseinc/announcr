module Announcr
  class Event
    def initialize(name, opts = {}, &block)
      @name = name
      @action = block
      @options = opts

      @pattern = make_filter(opts.delete(:pattern) || @name)
      @filters = make_filters([opts.delete(:filters)])
      @requires = [opts.delete(:requires)].flatten.compact
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
