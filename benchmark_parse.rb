require 'jsoncons'
require 'json'
require 'benchmark'

MILLION_OF_JSONS = 1_000_000.times.map { %Q`{"data":[#{rand}]}` }
MILLION_OF_ELEMENTS = %Q`{"data":[#{1_000_000.times.map { rand }.join(',')}]}`

Benchmark.bm(35) do |x|
  x.report("JSON      MILLION_OF_JSONS sym") do
    MILLION_OF_JSONS.each { |json| JSON.parse(json, symbolize_names: true)[:data] }
  end

  x.report("Jsoncons  MILLION_OF_JSONS sym") do
    MILLION_OF_JSONS.each { |json| Jsoncons::Json.parse(json)[:data] }
  end
end

Benchmark.bm(35) do |x|
  x.report("JSON      MILLION_OF_JSONS str") do
    MILLION_OF_JSONS.each { |json| JSON.parse(json)['data'] }
  end

  x.report("Jsoncons  MILLION_OF_JSONS str") do
    MILLION_OF_JSONS.each { |json| Jsoncons::Json.parse(json)['data'] }
  end
end

Benchmark.bm(35) do |x|
  x.report("JSON      MILLION_OF_ELEMENTS sym") do
    10.times { JSON.parse(MILLION_OF_ELEMENTS, symbolize_names: true)[:data] }
  end

  x.report("Jsoncons  MILLION_OF_ELEMENTS sym") do
    10.times { Jsoncons::Json.parse(MILLION_OF_ELEMENTS)[:data] }
  end
end

HUNDRED_LEVELS_JSON = '{"data":' * 100 + '1' + '}' * 100
DATA_SYM = :data
DATA_STR = 'data'

Benchmark.bm(35) do |x|
  json = JSON.parse(HUNDRED_LEVELS_JSON, symbolize_names: true)
  x.report("JSON      HUNDRED_LEVELS_JSON sym") do
    100_000.times do
      data = json
      100.times { data = data[DATA_SYM] }
    end
  end

  json = Jsoncons::Json.parse(HUNDRED_LEVELS_JSON)
  x.report("Jsoncons  HUNDRED_LEVELS_JSON sym") do
    100_000.times do
      data = json
      100.times { data = data[DATA_SYM] }
    end
  end
end

Benchmark.bm(35) do |x|
  json = JSON.parse(HUNDRED_LEVELS_JSON)
  x.report("JSON      HUNDRED_LEVELS_JSON str") do
    100_000.times do
      data = json
      100.times { data = data[DATA_STR] }
    end
  end

  json = Jsoncons::Json.parse(HUNDRED_LEVELS_JSON)
  x.report("Jsoncons  HUNDRED_LEVELS_JSON str") do
    100_000.times do
      data = json
      100.times { data = data[DATA_STR] }
    end
  end
end
