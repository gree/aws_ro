# AwsRo

Wrapper class of AWS Resource objects to enable to access properties more easily, more ruby-likely.

The targets of this library are small and medium scale AWS systems.

Now supported only `Aws::EC2` and `Aws::ElasticLoadBalancing`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'aws_ro', '~> 1.1'
```

And then execute:

    $ bundle

<!-- Or install it yourself as: -->

<!--     $ gem install aws_ro -->

## Purpose of this gem

Easy access to AWS Resources.

For example, I'd like to print values of 'MyTag' tag of instances which also contains 'MyEnv'=='develop' tag.

By using plain AWS SDK v2:

```ruby
client = Aws::EC2::Client.new(some_options)
res = clinet.describe_instances(filters: [{name: 'tag:MyEnv', values: ['develop']}, {name: 'tag:MyTag', values: ['*']}])
instances = res.reservations.flat_map(&:instances)
instances.each do |i|
  v = i.tags.find { |t| t.key == 'MyTag' }.value
  puts "ID: #{i.instance_id}, MyTag value: #{v}"
end
```

This is not difficult, but is a little boring.

On the other hand, by using the `aws_ro` gem:

```ruby
repo = AwsRo::EC2::Repository.new(some_options)
repo.tags({'MyEnv' => 'develop', 'MyTag' => '*'}).each |i|
  puts "ID: #{i.instance_id}, MyTag value: #{i.my_tag}"
end
```

This is simplified and keeping readability.


## Usage
### Basic Usage

```ruby
ec2_options = { region: 'ap-northeast-1' }
repo = AwsRo::EC2::Repository.new(ec2_options)
instances = repo.running.tags({'MyAttrName' => 'MyValue'})
instances.each do |i|
  puts "#{i.name} #{i.public_ip_address}, #{i.my_attr_name}"
end
```

### Classes
#### class : `AwsRo::EC2::Repository`

Repository is wrapper of EC2 client. It supports chainable queries to describe instances.


##### Initialize
```ruby
# initialize with Aws::EC2::Client
client.class
# => Aws::EC2::Client
repo = AwsRo::EC2::Repository.new(client)

# initialize with option hash
repo = AwsRo::EC2::Repository.new({ region: 'ap-northeast-1' })
```

##### accessor

```ruby
# get raw client
repo.client
# => Aws::EC2::Client
```

##### query methods

```ruby
# all running instance
repo.running.all? do |i|
  i.class
  # => AwsRo::EC2::Instance
  i.state.name == 'running'
end
# => true

# All query methods are chainable and return an `Array` like object.
## list security group of running-public-instances
repo.running.filters([{name: 'ip-address', values: ['*'] }]).each do |i|
  puts i.ec2.security_groups.map(&:group_name)}
end

## list my 'InUse' tag instances
repo.not_terminated.tags('InUse' => '*').map(&:instance_id)
# => ["i-xxxxxxxx","i-yyyyyyyy","i-zzzzzzzz", ...]
```

#### class : `AwsRo::EC2::Instance`

Instance is wrapper of EC2 instace object.

```ruby
ins = repo.all.first
```

##### static accessors

```ruby
# get raw ec2 object
ins.ec2
# => Aws::EC2::Instance

# some delegated methods and aliases for accessibility
[
  ins.instance_id == ins.ec2.instance_id,
  ins.public_ip_address == ins.ec2.public_ip_address && ins.public_ip_address == ins.public_ip,
  ins.private_ip_address == ins.ec2.private_ip_address && ins.private_ip == ins.private_ip,
  ins.key_name == ins.ec2.key_name,
  ins.state == ins.ec2.state
].all?
# => true
```

##### dynamic tag accessors

```ruby
# Instance#tags returns `Struct` of tags.
ins.tags.name
# => 'Value of Name tag'
ins.tags.roles
# => 'staging, somerole'
ins.tags.xyz_enabled
# => 'True'

## and dynamically-defined reader methods are available as snake_case-ed tag name.
## their values are stripped and formatted as `Array` if the value include whitespaces,
## as boolean if the value like  boolean and when use `?`-terminated method.
ins.name
# => 'Value of Name tag'
ins.roles
# => ['staging', 'somerole']
ins.xyz_enabled?
# => true
```

## Development

After checking out the repo`, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/gree/aws_ro/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

This library is distributed under the Apache License, version 2.0

```no-highlight
copyright 2016. GREE, Inc. all rights reserved.

licensed under the apache license, version 2.0 (the "license");
you may not use this file except in compliance with the license.
you may obtain a copy of the license at

    http://www.apache.org/licenses/license-2.0

unless required by applicable law or agreed to in writing, software
distributed under the license is distributed on an "as is" basis,
without warranties or conditions of any kind, either express or implied.
see the license for the specific language governing permissions and
limitations under the license.
```
