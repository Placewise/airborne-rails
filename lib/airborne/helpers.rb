# frozen_string_literal: true

module Airborne
  module Helpers
    def response
      @response
    end

    def headers
      response
        .headers
        .transform_keys { |k| k.to_s.underscore.to_sym }
        .with_indifferent_access
    end

    def body
      response.body
    end

    def json_body
      JSON.parse(response.body, symbolize_names: true)
    rescue StandardError
      raise InvalidJsonError, "API request returned invalid json"
    end
  end
end
