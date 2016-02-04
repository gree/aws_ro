require 'aws-sdk'
require 'aws_ro/elastic_load_balancing/load_balancer'
require 'aws_ro/ec2/repository'

module AwsRo
  module ElasticLoadBalancing
    class Repository
      def initialize(client_options)
        @client_options = client_options
      end

      def client
        @client ||= Aws::ElasticLoadBalancing::Client.new(@client_options)
      end

      def ec2_repository
        @ec2_repository ||= AwsRo::EC2::Repository.new(@client_options)
      end

      def all
        client.describe_load_balancers.each_with_object([]) do |page, arr|
          page.load_balancer_descriptions.each do |elb|
            arr << LoadBalancer.new(elb, ec2_repository)
          end
        end
      end

      def find_by_name(name)
        client.describe_load_balancers(load_balancer_names: [name]).first
      end
    end
  end
end
