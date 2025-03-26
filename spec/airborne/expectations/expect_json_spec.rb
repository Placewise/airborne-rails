# frozen_string_literal: true

describe Airborne::Expectations, "#expect_json", type: :request do
  it "ensures correct json values" do
    get "/simple_get"
    expect_json(name: "Alex", age: 32)
  end

  it "allows array response" do
    get "/array_response"
    expect_json([{ name: "Seth" }])
  end

  it "fails when incorrect json is tested" do
    get "/simple_get"
    expect { expect_json(bad: "data") }.to raise_error(ExpectationNotMetError)
  end

  it "allows full object graph" do
    get "/simple_path_get"
    expect_json(name: "Alex", address: { street: "Area 51", city: "Roswell", state: "NM" })
  end

  it "allows lambda" do
    get "/simple_get"
    expect_json(name: ->(name) { expect(name.length).to eq(4) })
  end

  describe "working with options" do
    before { get "/simple_json" }

    describe "match_expected", :airborne_match_expected, airborne_match_actual: false do
      it "requires all expected properties" do
        get "/simple_get"
        expect { expect_json(name: "Alex", other: "other") }.to raise_error(ExpectationNotMetError)
      end

      it "does not require the actual properties" do
        get "/simple_get"
        expect_json(name: "Alex")
      end
    end

    describe "match_actual", :airborne_match_actual, airborne_match_expected: false do
      it "requires all actual properties" do
        get "/simple_get"
        expect { expect_json(name: "Alex") }.to raise_error(Airborne::ExpectationError)
      end

      it "does not require the expected properties" do
        get "/simple_get"
        expect_json(name: "Alex", age: 32, address: nil, other: "other")
      end
    end

    describe "match_both", :airborne_match_actual, :airborne_match_expected do
      before { get "/simple_get" }

      it { expect { expect_json(name: "Alex") }.to raise_error(Airborne::ExpectationError) }
      it { expect { expect_json(name: "Alex", other: "other") }.to raise_error(ExpectationNotMetError) }
      it { expect { expect_json(name: "Alex", nested: {}) }.to raise_error(ExpectationNotMetError) }
    end

    describe "match_none", airborne_match_actual: false, airborne_match_expected: false do
      it "does not require the actual properties" do
        get "/simple_get"
        expect_json(name: "Alex")
      end

      it "does not require the expected properties" do
        get "/simple_get"
        expect_json(name: "Alex", age: 32, address: nil, other: "other", nested: {})
      end
    end
  end
end
