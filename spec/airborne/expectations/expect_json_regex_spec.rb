# frozen_string_literal: true

describe Airborne::Expectations, "#expect_json", type: :request do
  it "tests against regex" do
    get "/simple_get"
    expect_json(name: Regexp.new("^A"))
  end

  it "raises an error if regex does not match" do
    get "/simple_get"
    expect { expect_json(name: Regexp.new("^B")) }.to raise_error(ExpectationNotMetError)
  end

  it "allows Regexp to be tested against a path" do
    get "/simple_nested_path"
    expect_json("address.city", Regexp.new("^R"))
  end

  it "allows testing regex against numbers directly" do
    get "/simple_nested_path"
    expect_json("address.coordinates.latitude", Regexp.new("^3"))
  end

  it "allows testing regex against numbers in the hash" do
    get "/simple_nested_path"
    expect_json("address.coordinates", latitude: Regexp.new("^3"))
  end
end
