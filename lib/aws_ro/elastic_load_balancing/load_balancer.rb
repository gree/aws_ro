require 'aws_ro/ec2'

module AwsRo
  module ElasticLoadBalancing
    class LoadBalancer
      extend Forwardable
      def_delegators :@load_balancer, :load_balancer_name, :vpc_id, :health_check
      attr_reader :load_balancer, :instance_states
      attr_accessor :ec2_repository
      alias elb load_balancer
      alias name load_balancer_name

      def initialize(load_balancer, ec2_repository = nil)
        @load_balancer = load_balancer
        @ec2_repository = ec2_repository
      end

      def instances
        unless ec2_repository.respond_to?(:instance_ids)
          fail "Cannot use AwsRo::EC2::Repository"
        end
        @instances ||= elb.instances.empty? ? [] : ec2_repository.instance_ids(instance_ids)
      end

      def instance_ids
        elb.instances.map(&:instance_id)
      end

      def health(instance_id)
        fail "Empty instance_states." if instance_states.nil?
        instance_states[instance_id.to_s]
      end

      def store_instance_states(instance_states)
        @instance_states = instance_states.each_with_object({}) do |state, hash|
          hash[state.instance_id] = state
        end
      end
    end
  end
end
