require 'spec_helper'
require 'aws_ro/ec2'

describe AwsRo::EC2::Instance do
  before do
    data = {
      reservations:
        [{ instances: [{ instance_id: 'a-11111', tags: tag_data }] }]
    }
    Aws.config[:stub_responses] = true
    client.stub_responses(:describe_instances, data)
  end
  let(:tag_data) { [{ key: 'Name', value: 'ins-a1' }] }
  let(:client) { Aws::EC2::Client.new }
  let(:ec2) { client.describe_instances.reservations.map(&:instances).flatten.first }
  let(:instance) { described_class.new(ec2) }

  shared_examples_for "a delegator of ec2" do |methods|
    methods.each do |method|
      it "delegtes :#{method} to @ec2_instance" do
        ec2_instance = instance.instance_variable_get(:@ec2_instance)
        expect(ec2_instance).to receive(method)
        instance.__send__(method)
      end
    end
  end

  it_behaves_like "a delegator of ec2", [:instance_id,
                                         :private_ip_address,
                                         :public_ip_address,
                                         :key_name,
                                         :state]

  describe "#tags" do
    context "when ec2 has some tags" do
      it "is accessible to Struct contains each tags" do
        expect(instance.tags).to be_a Struct
      end
    end

    context "when ec2 has no tag" do
      let(:tag_data) { [] }

      it "returns nil" do
        expect(instance.tags).to be nil
      end
    end
  end
end
