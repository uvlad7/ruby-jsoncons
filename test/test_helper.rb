# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "jsoncons"

require "minitest/autorun"
require "minitest/reporters"

Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(color: true)]

def load_json(name)
  Jsoncons::Json.parse(File.read("lib/jsoncons/jsoncons/examples/input/#{name}.json"))
end
