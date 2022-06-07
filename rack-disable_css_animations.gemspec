# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/disable_css_animations/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-disable_css_animations"
  spec.version       = Rack::DisableCSSAnimations::VERSION
  spec.authors       = ["Micah Geisel"]
  spec.email         = ["micah@botandrose.com"]
  spec.summary       = %q{Rack middleware to disable CSS animations sitewide.}
  spec.description   = %q{Rack middleware to disable CSS animations sitewide. Useful for making acceptance tests quicker and more deterministic.}
  spec.homepage      = "https://github.com/botandrose/rack-disable_css_animations"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rack"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end
