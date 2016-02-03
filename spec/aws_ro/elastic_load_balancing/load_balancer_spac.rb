require 'spec_helper'
require 'aws_ro/elastic_load_balancing'

describe AwsRo::ElasticLoadBalancing::LoadBalancer do
  before do
    data = {}
    Aws.config[:stub_responses] = true
    client.stub_response(:describe_load_balancers, data)
  end

  let(:client) { Aws::ElasticLoadBalancing::Client.new }
  let(:elb) { nil } # client.describe_load_balancers
  let(:load_balancer) { described_class.new(elb) }

  shared_examples_for 'a delegator of elb' do |methods|
    methods.each do |method|
      it "delegtes :#{method} to @load_balancer" do
        load_balancer = instance.instance_variable_get(:@load_balancer)
        expect(load_balancer).to receive(method)
        instance.__send__(method)
      end
    end
  end

  it_behaves_like 'a delegator of elb', [:vpc_id,
                                         :health_check,
                                         :load_balancer_name]
end
