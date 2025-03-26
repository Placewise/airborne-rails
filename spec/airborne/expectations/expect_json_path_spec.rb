# frozen_string_literal: true

describe Airborne::Expectations, "#expect_json", type: :request do
  it "allows simple path and verify only that path" do
    get "/simple_path_get"
    expect_json("address", street: "Area 51", city: "Roswell", state: "NM")
  end

  it "allows nested paths" do
    get "/simple_nested_path"
    expect_json("address.coordinates", latitude: 33.3872, longitutde: 104.5281)
  end

  it "indexes into array and test against specific element" do
    get "/array_with_index"
    expect_json("cars.0", make: "Tesla", model: "Model S")
  end

  describe "testing against all elements in the array" do
    before { get "/array_with_index" }

    it { expect_json("cars.?", make: "Tesla", model: "Model S") }
    it { expect_json("cars.?", make: "Lamborghini", model: "Aventador") }
    it { expect { expect_json("foo.?", make: "Tesla") }.to raise_error(RSpec::Expectations::ExpectationNotMetError) }
  end

  describe "testing against properties in the array" do
    before { get "/array_with_index" }

    it { expect_json("cars.?.make", "Tesla") }
    it { expect { expect_json("cars.?.make", "Teslas") }.to raise_error(ExpectationNotMetError) }
  end

  describe "testing at least one match" do
    before { get "/array_with_nested" }

    it { expect_json("cars.?.owners.?", name: "Bart Simpson") }
    it { expect { expect_json("cars.?.owners.?", name: "Bart Simpsons") }.to raise_error(ExpectationNotMetError) }
  end

  it "checks for one match that matches all" do
    get "/array_with_nested"
    expect_json("cars.?.owners.*", name: "Bart Simpson")
  end

  it "checks for one match that matches all with lambda" do
    get "/array_with_nested"
    expect_json("cars.?.owners.*", name: ->(name) { expect(name).to eq("Bart Simpson") })
  end

  it "ensures one match that matches all with lambda" do # rubocop:disable RSpec/MultipleExpectations
    get "/array_with_nested"
    expect do
      expect_json("cars.?.owners.*", name: ->(name) { expect(name).to eq("Bart Simpsons") })
    end.to raise_error(ExpectationNotMetError)
  end

  it "ensures one match that matches all" do
    get "/array_with_nested"
    expect { expect_json("cars.?.owners.*", name: "Bart Simpsons") }.to raise_error(ExpectationNotMetError)
  end

  it "allows indexing" do
    get "/array_with_nested"
    expect_json("cars.0.owners.0", name: "Bart Simpson")
  end

  it "allows strings (String) to be tested against a path" do
    get "/simple_nested_path"
    expect_json("address.city", "Roswell")
  end

  it "allows floats (Float) to be tested against a path" do
    get "/simple_nested_path"
    expect_json("address.coordinates.latitude", 33.3872)
  end

  it 'raises exception when path contains ".."' do
    get "/simple_nested_path"
    expect { expect_json("address.coordinates..latitude", 33.3872) }.to raise_error(Airborne::PathError)
  end

  it "allows integers (Fixnum, Bignum) to be tested against a path" do
    get "/simple_get"
    expect_json("age", 32)
  end

  it "raises Airborne::ExpectationError when expectation expects an object instead of value" do
    get "/array_with_index"
    expect do
      expect_json("cars.0.make", make: "Tesla")
    end.to raise_error(Airborne::ExpectationError, "Expected String Tesla\nto be an object with property make")
  end
end
