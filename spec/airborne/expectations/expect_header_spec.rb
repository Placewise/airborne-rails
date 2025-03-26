# frozen_string_literal: true

describe Airborne::Expectations, "#expect_header", type: :request do
  before { get "/simple_get" }

  it { expect_header(:content_type, "application/json; charset=utf-8") }
  it { expect { expect_header(:content_type, "application/json") }.to raise_error(ExpectationNotMetError) }
  it { expect { expect_header(:foo, "bar") }.to raise_error(ExpectationNotMetError) }
end
