# frozen_string_literal: true

require_relative "lib/airborne/version"

Gem::Specification.new do |spec|
  spec.name = "airborne-rails"
  spec.version = AirborneRails::VERSION
  spec.required_ruby_version = ">= 3.0.0"
  spec.license = "MIT"
  spec.summary = "RSpec helpers and expectations for Rails-based JSON APIs - extracted from airborne"
  spec.homepage = "https://github.com/Placewise/airborne-rails"
  spec.authors = ["Placewise Devs"]
  spec.email = ["mpc.dev@placewise.com"]
  spec.files = `git ls-files -z`.split("\x0").select { |f| f.match(%r{^(lib)/}) }
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.add_dependency "rspec"
  spec.add_dependency "rspec-rails"
end
