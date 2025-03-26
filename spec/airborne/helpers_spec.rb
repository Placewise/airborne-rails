# frozen_string_literal: true

describe Airborne::Helpers, type: :request do
  it "when request is made response should be set" do
    get "/simple_get"
    expect(response).not_to be_nil
  end

  it "when request is made headers should be set" do
    get "/simple_get"
    expect(headers).not_to be_nil
  end

  context "when accessing json_body on invalid json" do
    before { get "/invalid_json" }

    it { expect(body).to eq("invalid1234") }
    it { expect { json_body }.to raise_error(Airborne::InvalidJsonError) }
  end

  describe "headers when request is made" do
    before { get "/simple_get" }

    it { expect(headers).to be_a(Hash) }
    it { expect(headers[:content_type]).to eq("application/json; charset=utf-8") }
    it { expect(headers["content_type"]).to eq("application/json; charset=utf-8") }
  end

  it "when request is made body should be set" do
    get "/simple_get"
    expect(body).not_to be_nil
  end

  describe "json body when request is made" do
    before { get "/simple_get" }

    it { expect(json_body).to be_a(Hash) }
    it { expect(json_body.first[0]).to be_a(Symbol) }
  end

  it "handles a 500 error with valid json" do
    get "/exception"
    expect(json_body).not_to be_nil
  end
end
