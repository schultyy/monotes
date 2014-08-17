# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'monotes/version'

Gem::Specification.new do |spec|
  spec.name          = "monotes"
  spec.version       = Monotes::VERSION
  spec.authors       = ["Jan Schulte"]
  spec.email         = ["schulte@unexpected-co.de"]
  spec.summary       = %q{GitHub Issues commandline client}
  spec.description   = %q{GitHub Issues commandline client}
  spec.homepage      = "https://github.com/schultyy/monotes"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_dependency "octokit", "~> 3.0"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
