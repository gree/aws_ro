module AwsRo
  module ElasticLoadBalancingV2
    class LoadBalancer
      extend Forwardable
      def_delegators :@load_balancer, :load_balancer_name, :load_balancer_arn, :vpc_id
      attr_reader :client, :load_balancer
      alias alb load_balancer
      alias name load_balancer_name
      alias arn load_balancer_arn

      def initialize(load_balancer, client)
        @load_balancer = load_balancer
        @client = client
      end

      def listeners
        @listeners ||= client.describe_listeners(load_balancer_arn: arn).listeners.map do |listener|
          Listener.new(listener, client)
        end
      end
    end

    class Listener
      extend Forwardable
      def_delegators :@listener, :listener_arn, :port, :protocol
      attr_reader :client, :listener
      alias arn listener_arn

      def initialize(listener, client)
        @listener = listener
        @client = client
      end

      def rules
        @rules ||= client.describe_rules(listener_arn: arn).rules.map do |rule|
          Rule.new(rule, client)
        end
      end
    end

    class Rule
      extend Forwardable
      def_delegators :@rule, :rule_arn, :priority, :is_default
      attr_reader :client, :rule
      alias arn rule_arn
      alias default? is_default

      def initialize(rule, client)
        @rule = rule
        @client = client
      end

      def forward_target_group
        action = rule.actions.find { |act| act.type == 'forward' }
        TargetGroup.new(action.target_group_arn, client) if action
      end

      def path_pattern
        condition = rule.conditions.find { |cond| cond.field == 'path-pattern' }
        condition.values.first if condition
      end
    end

    class TargetGroup
      attr_reader :client, :target_group_arn
      alias arn target_group_arn

      def initialize(arn, client)
        @target_group_arn = arn
        @client = client
      end

      def health(instance_id = nil)
        return health_descriptions[instance_id] if instance_id
        health_descriptions.values
      end

      def target_group
        @target_group ||= client.describe_target_groups(target_group_arns: [arn]).target_groups.first
      end

      def instances(ec2_repository = nil)
        ec2_repository ||= AwsRo::EC2::Repository.new(
          region: client.config.region,
          credentials: client.config.credentials
        )
        ec2_repository.instance_ids(health_descriptions.keys)
      end

      private

      def health_descriptions
        @health_descriptions ||= client.describe_target_health(target_group_arn: arn).target_health_descriptions.each_with_object({}) do |desc, h|
          h[desc.target.id] = desc
        end
      end
    end
  end
end
