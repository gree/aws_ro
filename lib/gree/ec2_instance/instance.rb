require 'gree/ec2_instance/key_value_accessible'

module Gree
  module Ec2Instance
    class Instance
      extend Forwardable
      def_delegators :@ec2_instance, :instance_id, :private_ip_address, :public_ip_address, :key_name, :state

      attr_reader :ec2_instance, :tags
      include KeyValueAccessible
      alias :ec2 :ec2_instance
      alias :id :instance_id
      alias :private_ip :private_ip_address
      alias :public_ip :public_ip_address

      def initialize(ec2_instance)
        @ec2_instance = ec2_instance

        tags = format_ec2_tags(@ec2_instance.tags)
        define_custom_accessors_unless_conflict(tags)
        @tags = Struct.new(*tags.keys)[*tags.values] unless tags.empty?
      end

      def running?
        state.name == 'running'
      end

      private
      def format_ec2_tags(ec2_tags)
        ec2_tags.inject({ }) do |hash, tag|
          hash.tap { |h| h[tag.key.to_sym] = tag.value }
        end
      end

    end
  end
end
