# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'maicoin/version'

Gem::Specification.new do |spec|
  spec.name          = "maicoin"
  spec.version       = MaiCoin::VERSION
  spec.authors       = ["MaiCoin"]
  spec.email         = [""]
  spec.summary       = [""]
  spec.description   = [""]
  spec.homepage      = ""

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "fakeweb", "~> 1.3.0"
  spec.add_development_dependency 'simplecov', '~> 0.7.1'

  spec.add_dependency "httparty", ">= 0.8.3"
  spec.add_dependency "multi_json", ">= 1.3.4"
  spec.add_dependency "money", "~> 6.0"
  spec.add_dependency "monetize", "~> 0.3.0"
  spec.add_dependency "hashie", ">= 1.2.0"
  spec.add_dependency "oauth2", "~> 1.0"
end
