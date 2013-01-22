module Announcr
  module Backend
    module Forward
      def forward_method(method_name)
        meth = method_name.to_sym
        proxy_methods << meth

        define_method(meth) do |*args|
          target.send(meth, *args)
        end
      end

      def forward_methods(*methods)
        methods.each { |m| forward_method m }
      end

      def proxy_methods
        @forwarded ||= []
      end
    end
  end
end
