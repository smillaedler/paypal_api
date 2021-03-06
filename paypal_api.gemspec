# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "paypal_api/version"

Gem::Specification.new do |s|
  s.name        = "paypal_api"
  s.version     = Paypal::VERSION
  s.authors     = ["Matt Handler"]
  s.email       = ["matt.handler@gmail.com"]
  s.homepage    = "https://github.com/matthandlersux/paypal_api"
  s.summary     = %q{an interface to paypals api}
  s.description = %q{alpha - currently covers part of payments pro and all of mass pay}

  s.rubyforge_project = "paypal_api"

  s.files         = `git ls-files`.split("\n") + ["init.rb"]
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # s.add_dependency "activesupport", "~> 3.1"
  s.add_dependency "rails", "~> 3.1"

  s.add_development_dependency "ruby-debug19"
  s.add_development_dependency "rspec-rails", "~> 2.6"
  s.add_development_dependency "generator_spec", "0.8.5"
  # s.add_development_dependency "rake", "0.8.7"
end
