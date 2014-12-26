# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hijiri/version'

Gem::Specification.new do |spec|
  spec.name          = "hijiri"
  spec.version       = Hijiri::VERSION
  spec.authors       = ["kkosuge"]
  spec.email         = ["root@kksg.net"]
  spec.summary       = %q{Derive Time from Time expression with Japanese language.}
  spec.description   = %q{日本語の文中に含まれる時刻表現をパースします。}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "hashie"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
