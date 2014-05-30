# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'faked_csv/version'

Gem::Specification.new do |spec|
  spec.name          = "faked_csv"
  spec.version       = FakedCSV::VERSION
  spec.authors       = ["Jianan Lu"]
  spec.email         = ["jianan.lu@salesforce.com"]
  spec.summary       = %q{Generate faked CSV data in the specified way.}
  spec.description   = %q{Makes generating CSV file with faked, random data easy to do.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.3"
  spec.add_development_dependency "rspec", "~> 2.14"
  spec.add_development_dependency "cucumber", "~> 1.3"
  spec.add_development_dependency "aruba", "~> 0.5"
  spec.add_development_dependency "byebug", "~> 3.1"

  spec.add_dependency "thor", "~> 0.19"
  spec.add_dependency "faker", "~> 1.3"
  spec.add_dependency "json", "~> 1.8"
end
