# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant/hivemind/version'

Gem::Specification.new do |spec|
  spec.name          = "vagrant-hivemind"
  spec.version       = Vagrant::Hivemind::VERSION
  spec.authors       = ["Nap Ramirez"]
  spec.email         = ["napramirez@gmail.com"]

  spec.summary       = "Vagrant extension directives for the Hivemind platform"
  spec.description   = "Vagrant extension directives for the Hivemind platform..."
  spec.homepage      = "https://github.com/napramirez/vagrant-hivemind"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
