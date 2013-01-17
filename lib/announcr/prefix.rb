module Announcr
  module Prefix
    def separator
      @separator ||= "."
    end

    def set_separator(sep)
      @separator = sep
    end

    def prefixes
      @prefixes ||= []
    end

    def set_prefixes(prefix)
      if prefix.is_a?(Array)
        @prefixes = prefix.flatten.compact.map do |p|
          normalize(p)
        end
      else
        @prefixes = [normalize(prefix)]
      end
    end

    def append_prefix(prefix)
      @prefixes << normalize(prefix)
    end

    def prepend_prefix(prefix)
      @prefixes.unshift normalize(prefix)
    end

    def key_for(key, ignore_prefixes = false)
      return key if ignore_prefixes
      [@prefixes, key].flatten.compact.join(@separator)
    end

    def prefix_config
      {separator: separator, prefixes: prefixes.dup}
    end

    def load_prefix_config(opts = {})
      set_separator opts.fetch(:separator, separator)
      set_prefixes opts.fetch(:prefixes, prefixes)
    end

    private

    def normalize(k)
      k.to_s.downcase
    end
  end
end
