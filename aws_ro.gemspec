# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aws_ro/version'

Gem::Specification.new do |spec|
  spec.name          = "aws_ro"
  spec.version       = AwsRo::VERSION
  spec.authors       = ["takuto.komazaki"]
  spec.email         = ["takuto.komazaki@gree.net"]

  spec.summary       = %q{Wrpper library of AWS SDK objects.}
  spec.description   = <<-EOS
Wrpper library of AWS SDK objects to enable to access properties
 more easily, more ruby-likely.
  EOS
  spec.homepage      = "https://github.com/gree/aws_ro"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  #  if spec.respond_to?(:metadata)
  #    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  #  else
  #    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  #  end

  spec.required_ruby_version = '>= 1.9.3'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-sdk", "~> 2.0"
  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "pry"
end
