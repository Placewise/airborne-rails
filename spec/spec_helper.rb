# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  coverage_dir "tmp/coverage"
  enable_coverage :branch
end

require "airborne"

require "action_controller/railtie"
require "rspec/rails"

require "support/rails_app"

ExpectationNotMetError = RSpec::Expectations::ExpectationNotMetError

RSpec.configure do |config|
  config.example_status_persistence_file_path = "tmp/spec_examples.txt"
end
