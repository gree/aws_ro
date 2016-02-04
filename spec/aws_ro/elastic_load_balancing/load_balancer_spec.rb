require 'spec_helper'
require 'aws_ro/elastic_load_balancing'

describe AwsRo::ElasticLoadBalancing::LoadBalancer do
  before do
    data = {
      load_balancer_descriptions: [
        { load_balancer_name: 'mylb1' }, # [0]
        { load_balancer_name: 'mylb3',   # [1]
          instances: [{ instance_id: '00000' },
                      { instance_id: '00001' },
                      { instance_id: '00002' }] },
        { load_balancer_name: 'mylb5' }, # [2]
      ],
    }
    Aws.config[:stub_responses] = true
    client.stub_responses(:describe_load_balancers, data)
  end

  let(:client) { Aws::ElasticLoadBalancing::Client.new }
  let(:lb_index) { 0 }
  let(:elb) { client.describe_load_balancers.load_balancer_descriptions[lb_index] }
  let(:load_balancer) { described_class.new(elb) }

  shared_examples_for 'a delegator of elb' do |methods|
    methods.each do |method|
      it "delegtes :#{method} to @load_balancer" do
        elb_resource = load_balancer.instance_variable_get(:@load_balancer)
        expect(elb_resource).to receive(method)
        load_balancer.__send__(method)
      end
    end
  end

  it_behaves_like 'a delegator of elb', [:vpc_id,
                                         :health_check,
                                         :load_balancer_name]

  describe "#instance_ids" do
    context "when some instances registerd" do
      let(:lb_index) { 1 }
      it "return IDs " do
        expect(load_balancer.instance_ids).to be_an Array
      end
    end

    context "no instance registerd" do
      let(:lb_index) { 0 }
      it "returns empty" do
        expect(load_balancer.instance_ids).to be_empty
      end
    end
  end
end
