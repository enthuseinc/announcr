module Announcr
  module Backend
    class Base
      attr_reader :options

      def initialize(opts = {})
        @options = default_options.merge(opts)
      end

      def default_options
        {}
      end

      def short_name
        @options[:as]
      end

      def target
        raise "#{self.class.name} must override #target"
      end

      def forwarded_methods
        raise "#{self.class.name} must override #forwarded_methods"
      end

      def forward(action, *args)
        raise "invalid action #{action}" unless
          forwarded_methods.include?(action)
        target.send(action, *args)
      end
    end
  end
end
