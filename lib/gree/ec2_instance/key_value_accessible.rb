module Gree
  module Ec2Instance
    module KeyValueAccessible
      private

      def define_custom_accessors_unless_conflict(keys_values)
        keys_values.each do |k,v|
          unless instance_method_conflict?(k)
            define_reader_method(k, to_array_if_csv(v))
          end

          if like_a_boolean_value?(v) && (not instance_method_conflict?("#{k}?"))
            define_reader_method("#{k}?", to_boolean(v))
          end
        end
      end

      def instance_method_conflict?(sym)
        self.class.instance_methods(false).include?(sym.to_sym)
      end

      def like_a_boolean_value?(value)
        ['True', 'False', 'true', 'false'].include? value.strip
      end

      def define_reader_method(sym, value)
        define_singleton_method(sym) { value }
      end

      def to_boolean(str)
        case str
        when /[Ff]alse/; then false
        else true
        end
      end

      def to_array_if_csv(str)
        if str.include?(',')
          str.split(',').map(&:strip)
        else
          str.strip
        end
      end
    end
  end
end
