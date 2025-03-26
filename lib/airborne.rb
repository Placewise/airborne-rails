# frozen_string_literal: true

require "airborne/path_matcher"
require "airborne/helpers"
require "airborne/expectations"

module Airborne
  class InvalidJsonError < StandardError; end
  class PathError < StandardError; end
  class ExpectationError < StandardError; end
end

RSpec.configure do |config|
  config.add_setting :airborne_match_expected
  config.add_setting :airborne_match_actual

  config.before do |e|
    config.airborne_match_expected =
      e.metadata[:airborne_match_expected].nil? ? true : e.metadata[:airborne_match_expected]
    config.airborne_match_actual =
      e.metadata[:airborne_match_actual].nil? ? false : e.metadata[:airborne_match_actual]
  end

  config.include Airborne::Helpers
  config.include Airborne::Expectations
end
