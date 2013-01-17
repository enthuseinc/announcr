module Announcr
  module Backend
    class Statsd < Base
      def target
        @statsd ||= Statsd.new(options[:server], options[:port])
      end

      def default_options
        { as: "stats", server: "localhost", port: 8125 }
      end

      def forwarded_methods
        [:increment, :decrement, :count, :gauge, :timing, :time]
      end
    end
  end
end
