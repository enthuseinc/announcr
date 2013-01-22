require 'statsd'

module Announcr
  module Backend
    class Statsd
      extend Forward

      DEFAULTS = {
        host: "localhost",
        port: 8125
      }

      attr_reader :options

      def initialize(opts = {})
        @options = DEFAULTS.merge(opts)
      end

      def target
        @statsd ||= ::Statsd.new(@options[:host], @options[:port])
      end

      forward_methods :increment, :decrement, :count, :gauge, :timing, :time
    end
  end
end
