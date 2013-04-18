# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'license_header/version'

Gem::Specification.new do |spec|
  spec.name          = "license_header"
  spec.version       = LicenseHeader::VERSION
  spec.authors       = ["Nathan Rogers", "Michael Klein", "Chris Colvard"]
  spec.email         = ["rogersna@indiana.edu"]
  spec.description   = %q{License header block auditing/updating}
  spec.summary       = %q{This gem will assist in making sure that all files have the right license block as a header.}

  spec.files         = Dir["lib/**/*"] + Dir["bin/**/*"] + ["README.md"]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "highline"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
