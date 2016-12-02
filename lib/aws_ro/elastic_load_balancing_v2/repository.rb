require 'aws-sdk'
require 'aws_ro/elastic_load_balancing_v2/load_balancer'
require 'aws_ro/ec2/repository'

module AwsRo
  module ElasticLoadBalancingV2
    class Repository
      attr_reader :client

      def initialize(client_or_options)
        @client = if client_or_options.is_a? Aws::ElasticLoadBalancingV2::Client
                    client_or_options
                  else
                    Aws::ElasticLoadBalancingV2::Client.new(client_or_options)
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
          page.load_balancers.each do |alb|
            arr << LoadBalancer.new(alb, client)
          end
        end
      end

      def find_by_name(name)
        alb = client.describe_load_balancers(names: [name]).load_balancers.first
        LoadBalancer.new(alb, client) if alb
      end
    end
  end
end
