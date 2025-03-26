# frozen_string_literal: true

describe Airborne::Expectations, "#expect_json_types", type: :request do
  it "detects current type" do
    get "/simple_get"
    expect_json_types(name: :string, age: :int)
  end

  it "fails when incorrect json types tested" do
    get "/simple_get"
    expect { expect_json_types(bad: :bool) }.to raise_error(ExpectationNotMetError)
  end

  it "does not fail when optional property is not present" do
    get "/simple_get"
    expect_json_types(name: :string, age: :int, optional: :bool_or_null)
  end

  it "allows full object graph" do
    get "/simple_path_get"
    expect_json_types({ name: :string, address: { street: :string, city: :string, state: :string } })
  end

  it "checks all types in a simple array" do
    get "/array_of_values"
    expect_json_types(grades: :array_of_ints)
  end

  it "ensures all valid types in a simple array" do
    get "/array_of_values"
    expect { expect_json_types(bad: :array_of_ints) }.to raise_error(ExpectationNotMetError)
  end

  describe "allowing array of types to be null" do
    before { get "/array_of_types" }

    it { expect_json_types(nil_array: :array_or_null) }
    it { expect_json_types(nil_array: :array_of_integers_or_null) }
    it { expect_json_types(nil_array: :array_of_ints_or_null) }
    it { expect_json_types(nil_array: :array_of_floats_or_null) }
    it { expect_json_types(nil_array: :array_of_strings_or_null) }
    it { expect_json_types(nil_array: :array_of_booleans_or_null) }
    it { expect_json_types(nil_array: :array_of_bools_or_null) }
    it { expect_json_types(nil_array: :array_of_objects_or_null) }
    it { expect_json_types(nil_array: :array_of_arrays_or_null) }
  end

  describe "checking array types when not null" do
    before { get "/array_of_types" }

    it { expect_json_types(array_of_ints: :array_or_null) }
    it { expect_json_types(array_of_ints: :array_of_integers_or_null) }
    it { expect_json_types(array_of_ints: :array_of_ints_or_null) }
    it { expect_json_types(array_of_floats: :array_of_floats_or_null) }
    it { expect_json_types(array_of_strings: :array_of_strings_or_null) }
    it { expect_json_types(array_of_bools: :array_of_booleans_or_null) }
    it { expect_json_types(array_of_bools: :array_of_bools_or_null) }
    it { expect_json_types(array_of_objects: :array_of_objects_or_null) }
    it { expect_json_types(array_of_arrays: :array_of_arrays_or_null) }
  end

  it "allows empty array" do
    get "/array_of_values"
    expect_json_types(emptyArray: :array_of_ints)
  end

  it "is able to test for a nil type" do
    get "/simple_get"
    expect_json_types(name: :string, age: :int, address: :null)
  end

  it "throws bad type error" do
    get "/simple_get"
    expect do
      expect_json_types(name: :foo)
    end.to raise_error(Airborne::ExpectationError, "Expected type foo\nis an invalid type")
  end

  it "verifies lambda" do
    get "/simple_get"
    expect_json_types(name: ->(name) { expect(name.length).to eq(4) })
  end

  it "verifies correct date types" do
    get "/date_response"
    expect_json_types(createdAt: :date)
  end

  it "verifies correct date types with path" do
    get "/date_response"
    expect_json_types("createdAt", :date)
  end

  it "verifies date_or_null when date is null" do
    get "/date_is_null_response"
    expect_json_types(dateDeleted: :date_or_null)
  end

  it "verifies date_or_null when date is null with path" do
    get "/date_is_null_response"
    expect_json_types("dateDeleted", :date_or_null)
  end

  it "verifies date_or_null with date" do
    get "/date_response"
    expect_json_types(createdAt: :date_or_null)
  end

  it "verifies date_or_null with date with path" do
    get "/date_response"
    expect_json_types("createdAt", :date_or_null)
  end

  it "allows simple path and verify only that path" do
    get "/simple_path_get"
    expect_json_types("address", street: :string, city: :string, state: :string)
  end

  it "allows nested paths" do
    get "/simple_nested_path"
    expect_json_types("address.coordinates", latitude: :float, longitutde: :float)
  end

  it "indexes into array and test against specific element" do
    get "/array_with_index"
    expect_json_types("cars.0", make: :string, model: :string)
  end

  it "allows properties to be tested against a path" do
    get "/array_with_index"
    expect_json_types("cars.0.make", :string)
  end

  it "tests against all elements in the array" do
    get "/array_with_index"
    expect_json_types("cars.*", make: :string, model: :string)
  end

  it "ensures all elements of array are valid" do
    get "/array_with_index"
    expect { expect_json_types("cars.*", make: :string, model: :int) }.to raise_error(ExpectationNotMetError)
  end

  it "deeps symbolize array responses" do
    get "/array_response"
    expect_json_types("*", name: :string)
  end

  it "checks all nested arrays for specified elements" do
    get "/array_with_nested"
    expect_json_types("cars.*.owners.*", name: :string)
  end

  it "ensures all nested arrays contain correct data" do
    get "/array_with_nested_bad_data"
    expect { expect_json_types("cars.*.owners.*", name: :string) }.to raise_error(ExpectationNotMetError)
  end

  it "raises Airborne::ExpectationError when expectation expects an object instead of type" do
    get "/array_with_index"
    expect do
      expect_json_types("cars.0.make", make: :string)
    end.to raise_error(Airborne::ExpectationError, "Expected String Tesla\nto be an object with property make")
  end

  describe "working with options" do
    describe "match_expected", :airborne_match_expected, airborne_match_actual: false do
      it "requires all expected properties" do
        get "/simple_get"
        expect { expect_json_types(name: :string, other: :string) }.to raise_error(ExpectationNotMetError)
      end

      it "does not require the actual properties" do
        get "/simple_get"
        expect_json_types(name: :string)
      end
    end

    describe "match_actual", :airborne_match_actual, airborne_match_expected: false do
      it "requires all actual properties" do
        get "/simple_get"
        expect { expect_json_types(name: :string) }.to raise_error(Airborne::ExpectationError)
      end

      it "does not require the expected properties" do
        get "/simple_get"
        expect_json_types(name: :string, age: :int, address: :null, other: :string)
      end
    end

    describe "match_both", :airborne_match_actual, :airborne_match_expected do
      it "requires all actual properties" do
        get "/simple_get"
        expect { expect_json_types(name: :string) }.to raise_error(Airborne::ExpectationError)
      end

      it "requires all expected properties" do
        get "/simple_get"
        expect { expect_json_types(name: :string, other: :string) }.to raise_error(ExpectationNotMetError)
      end
    end

    describe "match_none", airborne_match_actual: false, airborne_match_expected: false do
      it "does not require the actual properties" do
        get "/simple_get"
        expect_json_types(name: :string)
      end

      it "does not require the expected properties" do
        get "/simple_get"
        expect_json_types(name: :string, age: :int, address: :null, other: :string)
      end
    end
  end
end
