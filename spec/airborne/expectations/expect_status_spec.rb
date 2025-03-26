# frozen_string_literal: true

describe Airborne::Expectations, "#expect_status", type: :request do
  it "verifies correct status code" do
    get "/simple_get"
    expect_status 200
  end

  it "fails when incorrect status code is returned" do
    get "/simple_get"
    expect { expect_status 123 }.to raise_error(ExpectationNotMetError)
  end

  it "translates symbol codes to whatever is appropriate for the request" do
    get "/simple_get"
    expect_status :ok
    expect_status 200
    expect_status "200"
  end
end
