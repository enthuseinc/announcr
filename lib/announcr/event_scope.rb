module Announcr
  class EventScope
    attr_reader :namespace, :data, :event_name

    def initialize(event_name, opts = {})
      @event_name = event_name
      @namespace = opts.fetch(:namespace)
      @data = opts.fetch(:data, {})

      @options = opts

      @backends = @namespace.all_backends
      @default_backend = @namespace.default_backend

      setup_proxy_methods!
    end

    def key_for(key)
      @namespace.key_for(key)
    end

    private

    def setup_proxy_methods!
      singleton = class << self; self end

      @backends.each_pair do |name, backend|
        if @default_backend == name || @backends.size == 1
          backend.class.proxy_methods.each do |m|
            singleton.send(:define_method, m) do |*args|
              backend.send(m, *args)
            end
          end
        end

        singleton.send(:define_method, name) do
          backend
        end
      end
    end
  end
end
