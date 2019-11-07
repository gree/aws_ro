require 'spec_helper'
require 'aws_ro/elastic_load_balancing_v2'

shared_examples_for "a delegator of the AWS resource object" do |methods, target|
  methods.each do |method|
    it "delegtes ##{method} to the AWS resouce object" do
      aws_resource = subject.instance_variable_get(target)
      expect(aws_resource).to receive(method)
      subject.__send__(method)
    end
  end
end

shared_examples_for 'a shorthand accessors' do |methods, targets|
  methods.each_with_index do |method, i|
    it "can access ##{targets[i]} by ##{method}" do
      expect(subject.method(method)).to eq subject.method(targets[i])
    end
  end
end

describe AwsRo::ElasticLoadBalancingV2::LoadBalancer do
  before do
    data = {
      load_balancers: [
        {
          load_balancer_arn: "arn:aws:elasticloadbalancing:zzz",
          dns_name: "my-alb-name.ap-northeast-1.elb.amazonaws.com",
          load_balancer_name: "my-alb-name",
        },
      ],
    }
    Aws.config[:stub_responses] = true
    client.stub_responses(:describe_load_balancers, data)
  end
  let(:client) { Aws::ElasticLoadBalancingV2::Client.new }
  let(:aws_alb) { client.describe_load_balancers.load_balancers.first }
  let(:alb) { described_class.new(aws_alb, client) }
  subject { alb }

  it_behaves_like 'a delegator of the AWS resource object',
                  Aws::ElasticLoadBalancingV2::Types::LoadBalancer.members,
                  :@load_balancer

  it_behaves_like 'a shorthand accessors',
                  [:name, :arn],
                  [:load_balancer_name, :load_balancer_arn]

  describe "#listeners" do
    it "returns an Array of AwsRo::ElasticLoadBalancingV2::Listener"
  end
end

describe AwsRo::ElasticLoadBalancingV2::Listener do
  before do
    data = {
      listeners: [
        {
          listener_arn: "arn:aws:elasticloadbalancing:xxx",
          port: 443,
          protocol: "HTTPS",
        },
      ],
    }
    Aws.config[:stub_responses] = true
    client.stub_responses(:describe_listeners, data)
  end

  let(:client) { Aws::ElasticLoadBalancingV2::Client.new }
  let(:aws_listener) { client.describe_listeners.listeners.first }
  let(:listener) { described_class.new(aws_listener, client) }
  subject { listener }

  it_behaves_like 'a delegator of the AWS resource object',
                  Aws::ElasticLoadBalancingV2::Types::Listener.members,
                  :@listener

  describe "#rules" do
    it "returns an Array of AwsRo::ElasticLoadBalancingV2::Rule"
  end
end

describe AwsRo::ElasticLoadBalancingV2::Rule do
  before do
    data = {
      rules: [
        { priority: '1', conditions: [{ field: 'path-pattern', values: ['/path/of/rule1'] }],
          actions: [{ type: 'forward', target_group_arn: 'rule1targetarn' }] },
        { priority: 'default', is_default: true,
          actions: [{ type: 'forward', target_group_arn: 'xxx' }] },
      ],
    }
    Aws.config[:stub_responses] = true
    client.stub_responses(:describe_rules, data)
  end

  let(:client) { Aws::ElasticLoadBalancingV2::Client.new }
  let(:aws_rule) { client.describe_rules.rules.first }
  let(:rule) { described_class.new(aws_rule, client) }
  subject { rule }
  it_behaves_like 'a delegator of the AWS resource object',
                  Aws::ElasticLoadBalancingV2::Types::Rule.members,
                  :@rule

  it_behaves_like 'a shorthand accessors',
                  [:arn, :default?],
                  [:rule_arn, :is_default]

  describe "#forward_target_group" do
    it "finds a forward TargetGroup of this rule" do
      expect(rule.forward_target_group).to be_a AwsRo::ElasticLoadBalancingV2::TargetGroup
    end
  end

  describe "#path_pattern" do
    it "find a path-pattern of this rule" do
      expect(rule.path_pattern).to eq '/path/of/rule1'
    end
  end
end

describe AwsRo::ElasticLoadBalancingV2::TargetGroup do
  before do
    Aws.config[:stub_responses] = true
    client.stub_responses(:describe_target_health, data)
  end

  let(:data) {
    {
      target_health_descriptions: [
        { target: { id: 'i-xxxxaaaa', port: 80 },
          target_health: { state: 'healthy' } },
        { target: { id: 'i-xxxxbbbb', port: 80 },
          target_health: { state: 'unhealthy', reason: 'Target.FailedHealthChecks' } },
      ],
    }
  }
  let(:client) { Aws::ElasticLoadBalancingV2::Client.new }
  let(:arn) { "arn:aws:elasticloadbalancing:ap-northeast-1:555555666666:targetgroup/mytarget1/abcdef1234567890" }
  let(:target_group) { described_class.new(arn, client) }

  RSpec::Matchers.define :be_a_health_description do
    match do |act|
      [:target, :target_health].all? do |property|
        act.respond_to? property
      end
    end
  end

  describe "#health" do
    context "with instance_id" do
      it "returns health_descriptions of the instance" do
        expect(target_group.health('i-xxxxbbbb').target_health.state).to eq 'unhealthy'
      end
    end

    context "with IP (target-type: ip)" do
      let(:data) {
        {
          target_health_descriptions: [
            { target: { id: '10.111.38.50', port: 80 },
              target_health: { state: 'healthy' } },
            { target: { id: '10.111.41.47', port: 80 },
              target_health: { state: 'unhealthy', reason: 'Target.FailedHealthChecks' } },
          ],
        }
      }
      it "returns health_descriptions of the IPs" do
        expect(target_group.health('10.111.38.50').target_health.state).to eq 'healthy'
        expect(target_group.health('10.111.41.47').target_health.state).to eq 'unhealthy'
      end

    end

    context "with lambda function (target-type: lambda)" do
      let(:data) {
        {
          target_health_descriptions: [
            { target: { id: 'arn:aws:lambda:us-east-1:123456789012:function:my-lambda', port: nil, availability_zone: 'all' },
              target_health: { state: 'healthy' } },
            { target: { id: 'arn:aws:lambda:ap-northeast-1:123456789012:function:my-function', port: nil, availability_zone: 'all' },
              target_health: { state: 'unavailable' }, health_check_port: nil },
          ],
        }
      }
      it "returns health_descriptions of the lambdas" do
        expect(target_group.health('arn:aws:lambda:us-east-1:123456789012:function:my-lambda').target_health.state).to eq 'healthy'
        expect(target_group.health('arn:aws:lambda:ap-northeast-1:123456789012:function:my-function').target_health.state).to eq 'unavailable'
      end
    end

    context "with no arguments" do
      it "returns health_descriptions of instances associated with this target" do
        expect(target_group.health).to all(be_a_health_description)
      end
    end
  end

  describe "#instances" do
    it "returns an Array of AwsRo::EC2::Instance"
  end
end
