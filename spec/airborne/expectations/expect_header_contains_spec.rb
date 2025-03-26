# frozen_string_literal: true

describe Airborne::Expectations, "#expect_header_contains", type: :request do
  before { get "/simple_get" }

  it { expect_header_contains(:content_type, "json") }
  it { expect { expect_header_contains(:foo, "bar") }.to raise_error(ExpectationNotMetError) }
  it { expect { expect_header_contains(:content_type, "bar") }.to raise_error(ExpectationNotMetError) }
end
