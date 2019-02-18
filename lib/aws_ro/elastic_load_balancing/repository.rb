require 'aws-sdk-elasticloadbalancing'
require 'aws_ro/elastic_load_balancing/load_balancer'
require 'aws_ro/ec2/repository'

module AwsRo
  module ElasticLoadBalancing
    class Repository
      attr_reader :client

      def initialize(client_or_options)
        @client = if client_or_options.is_a? Aws::ElasticLoadBalancing::Client
                    client_or_options
                  else
                    Aws::ElasticLoadBalancing::Client.new(client_or_options)
                  end
      end

      def ec2_repository
        @ec2_repository ||= AwsRo::EC2::Repository.new(
          region: client.config.region,
          credentials: client.config.credentials
        )
      end

      def all
        client.describe_load_balancers.each_with_object([]) do |page, arr|
          page.load_balancer_descriptions.each do |elb|
            lb = LoadBalancer.new(elb, ec2_repository)
            lb.store_instance_states(client.describe_instance_health(load_balancer_name: lb.name).instance_states)
            arr << lb
          end
        end
      end

      def find_by_name(name)
        client.describe_load_balancers(load_balancer_names: [name]).first
      end
    end
  end
end
