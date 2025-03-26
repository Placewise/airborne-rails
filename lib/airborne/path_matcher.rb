# frozen_string_literal: true

module Airborne
  class PathMatcher
    ALL = "?"
    ANY = "*"

    def self.call(...)
      new.call(...)
    end

    # rubocop:todo Metrics/AbcSize,Metrics/MethodLength
    def call(path, json, &)
      raise PathError, "Invalid Path, contains '..'" if path.include?("..")

      type = false
      parts = path.split(".")
      parts.each_with_index do |part, index|
        if [ALL, ANY].include?(part)
          ensure_array(path, json)
          type = part

          if index < parts.length.pred
            walk_with_path(type, index, path, parts, json, &)
            return # rubocop:todo Lint/NonLocalExitFromIterator
          end

          next
        end

        json = process_json(part, json)
      end

      if type == ANY
        expect_all(json, &)
      elsif type == ALL
        expect_one(path, json, &)
      else
        yield json
      end
    end
    # rubocop:enable Metrics/AbcSize,Metrics/MethodLength

    private

    # rubocop:todo Metrics/MethodLength
    def walk_with_path(type, index, path, parts, json, &)
      last_error = nil
      item_count = json.length
      error_count = 0
      json.each do |element|
        begin
          sub_path = parts[(index.next)...(parts.length)].join(".")
          self.class.call(sub_path, element, &)
        rescue RSpec::Expectations::ExpectationNotMetError => e
          last_error = e
          error_count += 1
        end

        ensure_match_all(last_error) if type == "*"
        ensure_match_one(path, item_count, error_count) if type == "?"
      end
    end
    # rubocop:enable Metrics/MethodLength

    def process_json(part, json)
      if index?(part) && json.is_a?(Array)
        json[part.to_i]
      else
        json[part.to_sym]
      end
    end

    def index?(part)
      part =~ /^\d+$/
    end

    def expect_one(path, json)
      item_count = json.length
      error_count = 0
      json.each do |part|
        yield part
      rescue RSpec::Expectations::ExpectationNotMetError
        error_count += 1
        ensure_match_one(path, item_count, error_count)
      end
    end

    def expect_all(json, &)
      last_error = nil
      begin
        json.each(&)
      rescue RSpec::Expectations::ExpectationNotMetError => e
        last_error = e
      end
      ensure_match_all(last_error)
    end

    def ensure_match_one(path, item_count, error_count)
      return unless item_count == error_count

      raise RSpec::Expectations::ExpectationNotMetError,
            "Expected one object in path #{path} to match provided JSON values"
    end

    def ensure_match_all(error)
      raise error unless error.nil?
    end

    def ensure_array(path, json)
      return if json.is_a?(Array)

      raise RSpec::Expectations::ExpectationNotMetError,
            "Expected #{path} to be array got #{json.class} from JSON response"
    end
  end
end
