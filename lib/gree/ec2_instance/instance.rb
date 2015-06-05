module Gree
  module Ec2Instance
    class Instance
      extend Forwardable
      def_delegators :@ec2_instance, :instance_id, :private_ip_address, :public_ip_address, :key_name, :state

      attr_reader :ec2_instance, :tags
      alias :ec2 :ec2_instance
      alias :id :instance_id
      alias :private_ip :private_ip_address
      alias :public_ip :public_ip_address

      def initialize(ec2_instance)
        @ec2_instance = ec2_instance

        tags = format_ec2_tags(@ec2_instance.tags)
        define_accessors_unless_conflict(tags)
        @tags = Struct.new(*tags.keys)[*tags.values]
      end

      def running?
        state.name == 'running'
      end

      private
      def underscore(str)
        str.gsub(/::/, '/').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr("-", "_").
          downcase
      end

      def format_ec2_tags(ec2_tags)
        ec2_tags.inject({ }) do |hash, tag|
          hash.tap { |h| h[underscore(tag.key).to_sym] = tag.value }
        end
      end

      def define_accessors_unless_conflict(keys_values)
        keys_values.each do |k,v|
          unless self.class.instance_methods(false).include? k
            define_singleton_method(k) { v }
          end
        end
      end
    end
  end
end
