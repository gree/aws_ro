require 'aws_ro/ec2'

module AwsRo
  module ElasticLoadBalancing
    class LoadBalancer
      extend Forwardable
      def_delegators :@load_balancer, :load_balancer_name, :vpc_id, :health_check
      attr_reader :load_balancer
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
        @instances ||= ec2_repository.instance_ids(elb.instances.map(&:instance_id))
      end

      def instance_ids
        elb.instances.map(&:instance_id)
      end
    end
  end
end
