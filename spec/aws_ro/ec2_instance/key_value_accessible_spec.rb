require 'spec_helper'
require 'gree/ec2_instance/key_value_accessible'

describe Gree::Ec2Instance::KeyValueAccessible do
  let(:klass) { Class.new {
                  include Gree::Ec2Instance::KeyValueAccessible
                  def initialize(key_value)
                    define_custom_accessors_unless_conflict(key_value)
                  end
                } }
  let(:instance) { klass.new(key_value) }
  let(:key_value) { {  } }

  context "when include the module" do
    it "responds to private method :define_custom_accessors_unless_conflict" do
      expect(instance.respond_to?(:define_custom_accessors_unless_conflict, true)).to be_truthy
    end
  end

  describe "#define_custom_accessors_unless_conflict" do
    let(:key_value) {
      {
        'my_attr' => 1,
        'CapitalizedAttr' => 2,
        'csv_attr' => 'foo, bar',
        'boolean_attr' => 'True',
      }
    }
    context "with { 'my_attr' => value }" do
      it "define #my_attr method and return a value" do
        expect(instance.my_attr).to be 1
      end
    end
    context "with { 'CapitalizedAttr' => value }" do
      it "define #capitalized_attr method and return a value" do
        expect(instance.capitalized_attr).to be 2
      end
    end
    context "with CSV string such as { 'csv_attr' => 'foo, bar' }" do
      it "define #my_attr method and return an Array ['foo', 'bar']" do
        expect(instance.csv_attr).to eq ['foo', 'bar']
      end
    end
    context "with boolean string such as { 'boolean_attr' => 'True' }" do
      it "define #boolean_attr? method and return True or False" do
        expect(instance.boolean_attr?).to be_a TrueClass
      end
    end
  end

  context "when new accessor name conflict with existant method" do
    before do
      klass.class_exec do
        def my_attr
          0 # original method returns zero
        end
      end
    end
    let(:key_value) { { 'MyAttr' => 1 , 'my_attr' => 2 } }
    it "does not add new accessor" do
      expect(instance.my_attr).to be 0 # original method called
    end
  end
end
