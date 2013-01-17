require 'logger'

module Announcr
  module Backend
    class Logger < Base
      def target
        @logger ||= options[:logger] ||
          defined?(Rails) ? Rails.logger : ::Logger.new(options[:out])
      end

      def default_options
        { as: "log", out: STDOUT, logger: nil }
      end

      def forwarded_methods
        [:debug, :info, :warn, :error, :fatal]
      end
    end
  end
end
