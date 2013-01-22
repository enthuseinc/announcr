require 'logger'

module Announcr
  module Backend
    class Logger
      extend Forward

      DEFAULTS = {
        out: STDOUT,
        logger: nil
      }

      attr_reader :options

      def initialize(opts = {})
        @options = DEFAULTS.merge(opts)
      end

      def target
        @logger ||= @options[:logger] || ::Logger.new(@options[:out])
      end

      forward_methods :debug, :info, :warn, :error, :fatal
    end
  end
end
