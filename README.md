# Airborne Rails

[![CI](https://github.com/Placewise/airborne-rails/actions/workflows/build.yml/badge.svg)](https://github.com/Placewise/airborne-rails/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/Placewise/airborne-rails/badge.svg?branch=master)](https://coveralls.io/github/Placewise/airborne-rails?branch=master)
[![airborne-rails gem version](http://img.shields.io/gem/v/airborne-rails.svg?style=flat-square)](http://rubygems.org/gems/airborne-rails)

RSpec helpers and expectations for Rails-based JSON APIs - extracted from [airborne](https://github.com/brooklynDev/airborne/).

## Quick Start

Add airborne-rails to your Gemfile, most likely you want to have it in the `test` group:

```ruby
gem "airborne-rails", group: %i[test]
```

Add a dependency in spec_helper.rb:

```ruby
require "airborne"
```

Write a test:

```ruby
describe "GET /person", type: :request do
  before { get "/person" } # JSON API that returns { "name": "Susan", "age": 30 }

  it "returns specific value" do
    expect_json(name: "OK")
  end
  
  it "returns specific type" do
    expect_json_types(age: :int)
  end
end
```

## Helpers

This gems also exposes following helpers that may be utilized in your tests:

* `response` - The HTTP response returned from the request
* `headers` - A symbolized hash of the response headers returned by the request
* `body` - The raw HTTP body returned from the request
* `json_body` - A symbolized hash representation of the JSON returned by the request

For example:

```ruby
get "/person" # JSON API that returns { "name" : "John Doe" }
expect(json_body[:name]).to eq "John Doe"
expect(headers[:content_type]).to eq("application/json")
```

## Expectations

* `expect_json` - Tests the values of the JSON property values returned
* `expect_json_types` - Tests the types of the JSON property values returned
* `expect_json_keys` - Tests the existence of the specified keys in the JSON object
* `expect_json_sizes` - Tests the sizes of the JSON property values returned, also test if the values are arrays
* `expect_status` - Tests the HTTP status code returned
* `expect_header` - Tests for a specified header in the response
* `expect_header_contains` - Partial match test on a specified header

### Testing JSON types

When calling `expect_json_types`, these are the valid types that can be tested against:

* `:int` or `:integer`
* `:float`
* `:bool` or `:boolean`
* `:string`
* `:date`
* `:object`
* `:null`
* `:array`
* `:array_of_integers` or `:array_of_ints`
* `:array_of_floats`
* `:array_of_strings`
* `:array_of_booleans` or `:array_of_bools`
* `:array_of_objects`
* `:array_of_arrays`

If the properties are optional and may not appear in the response, you can append `_or_null` to the types above.

```ruby
it "returns specific data types" do
  get "/person" # JSON API that returns { "name" : "John Doe" } or { "name" : "John Doe", "age" : 45 }
  expect_json_types(name: :string, age: :int_or_null)
end
```

### Testing against a block

When calling `expect_json` or `expect_json_types`, you can optionally provide a block and run your own expectations:

```ruby
it "returns name of specific length" do
  get "/person" # JSON API that returns { "name" : "John Doe" }
  expect_json(name: -> (name){ expect(name.length).to eq(8) })
end
```

### Path Matching

When calling `expect_json_types`, `expect_json`, `expect_json_keys` or `expect_json_sizes` you can optionally specify 
a path as a first parameter.

This test would only test the address object:

```ruby
describe "Example" do
  # The API returns the following JSON response:
  # {
  #   "name": "Alex",
  #   "address": {
  #     "street": "Area 51", "city": "Roswell", "state": "NM",
  #     "coordinates": { "latitude": 33.3872, "longitude": 104.5281 }
  #   }
  # }
  before { get "http://example.com/api/v1/simple_path_get" }

  # Tests JSON types in the "address" path
  it "has address" do
    expect_json_types("address", street: :string, city: :string, state: :string, coordinates: :object)
  end

  # Tests JSON keys in the "address" path
  it "should allow nested paths" do
    expect_json_keys("address", [:street, :city, :state, :coordinates])
  end

  # Tests JSON values in the "address.coordinates" path
  it "should allow nested paths" do
    expect_json("address.coordinates", latitude: 33.3872, longitude: 104.5281)
  end
end
```

When dealing with `arrays`, you can test:

* all: `*`, 
* any : `?`,
* specific: `<index>` (e.g. `0`)

element of the array:

```ruby
describe "Example" do
  # The API returns the following JSON response:
  # {
  #   "cars": [
  #     { "make": "Tesla", "model": "Model S" },
  #     { "make": "Lamborghini", "model": "Aventador" }
  #   ]
  # }
  before { get "/cars" }

  it "returns Tesla Model S as a first car" do
    expect_json("cars.0", make: "Tesla", model: "Model S")
  end

  it "returns at least one car that is Tesla Model S" do
    expect_json("cars.?", make: "Tesla", model: "Model S")
  end

  it "returns make and model as strings for all cars" do
    expect_json_types("cars.*", make: :string, model: :string)
  end
end
```

`*` and `?` work for nested arrays as well:

```ruby
describe "Example" do
  # The API returns the following JSON response:
  # {
  #   "cars": [
  #     { "make": "Tesla", "model": "Model S", "owners": [{ "name": "Bart Simpson" }] },
  #     { "make": "Lamborghini", "model": "Aventador", "owners": [{ "name": "Peter Griffin" }] }
  #   ]
  # }
  before { get "/cars" }

  it "returns make and model as strings for all cars" do
    expect_json_types("cars.*.owners.*", name: :string)
  end
end
```

## Matching strictness

You can control the strictness of `expect_json` and `expect_json_types` with the global 
settings `airborne_match_expected` and `airborne_match_actual` like this:

```ruby
RSpec.configure do |config|
  # (...)
  config.airborne_match_expected = true
  config.airborne_match_actual = false
end
```

`airborne_match_expected` requires all the keys in the expected JSON are present in the response.<br />
`airborne_match_actual` requires that the keys in the response are tested in the expected Hash.

So you can do the following combinations:

* `match_expected=false`, `match_actual=false` - checks only intersection
* `match_expected=false`, `match_actual=true` - raises on extra key in response
* `match_expected=true`, `match_actual=false` - **raises on missing key in response (DEFAULT)**
* `match_expected=true`, `match_actual=true` - expect exact match

You can override the `airborne_match_expected` and `airborne_match_actual` settings on scenario/group level like this:

```ruby
describe "test something", airborne_match_expected: true, airborne_match_actual: false do
end
```

## Comparison against original airborne

This gem was forked from [airborne](https://github.com/brooklynDev/airborne/) that is not maintained for years.

There are following differences:

* Obviously, it's intended to work only in Rails-based projects 
* Config options have been renamed to have `airborne_` prefix
* Helpers: `date` and `regex` were removed

## License

The MIT License

Copyright (c) 2014 [brooklyndev](https://github.com/brooklynDev), [sethpollack](https://github.com/sethpollack)<br /> 
Copyright (c) 2025 [piotr-switlicki](https://github.com/piotr-switlicki), [Placewise](https://github.com/Placewise)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

