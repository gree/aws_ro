module AwsRo
  module EC2
    module KeyValueAccessible
      private

      def define_custom_accessors_unless_conflict(keys_values)
        keys_values.each do |k, v|
          key = underscore(k.to_s).to_sym
          unless instance_method_conflict?(key)
            define_reader_method(key, to_array_if_include_separator(v))
          end

          if like_a_boolean_value?(v) && (not instance_method_conflict?("#{key}?"))
            define_reader_method("#{key}?", to_boolean(v))
          end
        end
      end

      def instance_method_conflict?(sym)
        self.class.instance_methods(false).include?(sym.to_sym)
      end

      def like_a_boolean_value?(value)
        val = value.is_a?(String) ? value.strip : value
        ['True', 'False', 'true', 'false', true, false].include? val
      end

      def define_reader_method(sym, value)
        define_singleton_method(sym) { value }
      end

      def to_boolean(val)
        case val
        when /[Ff]alse/; then false
        else true
        end
      end

      def to_array_if_include_separator(val)
        return val unless val.is_a? String
        if val.include?(KeyValueAccessible.tag_separator)
          val.split(KeyValueAccessible.tag_separator).map(&:strip)
        else
          val.strip
        end
      end

      def underscore(str)
        str.gsub(/::/, '/').
          gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
          gsub(/([a-z\d])([A-Z])/, '\1_\2').
          tr("-", "_").
          downcase
      end

      class << self
        def tag_separator=(char)
          @separator = char.to_s
        end

        def tag_separator
          @separator ||= ' '
        end
      end
    end
  end
end
