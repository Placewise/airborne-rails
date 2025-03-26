# frozen_string_literal: true

describe Airborne::Expectations, "#expect_json_keys", type: :request do
  it "ensures correct json keys" do
    get "/simple_json"
    expect_json_keys(%i[foo bar baz])
  end

  it "ensures correct partial json keys" do
    get "/simple_json"
    expect_json_keys(%i[foo bar])
  end

  it "ensures json keys with path" do
    get "/simple_nested_path"
    expect_json_keys("address", %i[street city])
  end

  it "fails when keys are missing with path" do
    get "/simple_nested_path"
    expect { expect_json_keys("address", [:bad]) }.to raise_error(ExpectationNotMetError)
  end
end
