# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'announcr/version'

Gem::Specification.new do |gem|
  gem.name          = "announcr"
  gem.version       = Announcr::VERSION
  gem.authors       = ["Michael-Keith Bernard"]
  gem.email         = ["mkbernard.dev@gmail.com"]
  gem.description   = %q{A small event DSL}
  gem.summary       = %q{Ruby DSL for describing and recording system events.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "statsd-ruby", "~> 1.2"

  gem.add_development_dependency "rspec", "~> 2.12.0"
  gem.add_development_dependency "simplecov"
end
