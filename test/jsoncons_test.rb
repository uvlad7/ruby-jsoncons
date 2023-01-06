# frozen_string_literal: true

require "test_helper"

Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(color: true)]

class JsonconsTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Jsoncons::VERSION
  end
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize

  def test_single_values_parsing
    assert_instance_of(Jsoncons::Json, Jsoncons::Json.parse("{}"))
    assert_raises(RuntimeError) { Jsoncons::Json.parse("") }
    assert_instance_of(Jsoncons::Json, Jsoncons::Json.parse("false"))
    assert_instance_of(Jsoncons::Json, Jsoncons::Json.parse("null"))
    assert_instance_of(Jsoncons::Json, Jsoncons::Json.parse("0.0000000000001"))
    assert_instance_of(Jsoncons::Json, Jsoncons::Json.parse('"Hello, World"'))
  end

  def test_simple_object
    data = Jsoncons::Json.parse('{"first":1,"second":2,"fourth":3,"fifth":4}')
    assert(!data.empty)
    assert_equal(4, data.size)
    assert(data.contains("second"))
    assert(!data.contains("sixth"))
    assert_raises(RangeError) { data["sixth"] }
    assert_instance_of(Jsoncons::Json, data["second"])
    assert_instance_of(TrueClass, data["second"].is_number)
    assert_instance_of(FalseClass, data["second"].is_double)
    data.clear
    assert(data.empty)
    assert_equal(0, data.size)
  end

  def test_values_are_accessible_by_index
    data = Jsoncons::Json.parse('{"first":1,"second":2,"fourth":3,"fifth":4}')
    assert_equal(data[1].to_s, "2")
  end

  def test_ruby_wrappers_for_method_result_are_different_every_time
    data = Jsoncons::Json.parse('{"first":1,"second":2,"fourth":3,"fifth":4}')
    assert(data[1] != data["second"])
    assert(data[1].object_id != data["second"].object_id)
    # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
    assert(data["second"].object_id != data["second"].object_id)
    assert(data["second"] != data["second"])
    # rubocop:enable Lint/BinaryOperatorWithIdenticalOperands:
  end

  def test_original_order_is_kept
    data = Jsoncons::Json.parse('{
    "street_number" : "100",
    "street_name" : "Queen St W",
    "city" : "Toronto",
    "country" : "Canada"}')
    assert_equal('{"street_number":"100","street_name":"Queen St W","city":"Toronto","country":"Canada"}', data.to_s)
  end

  def test_jsonpath
    # https://github.com/danielaparker/jsoncons/blob/master/doc/ref/jsonpath/jsonpath.md
    # https://github.com/danielaparker/jsoncons/blob/master/doc/ref/jsonpath/json_query.md
    data = load_json("books")
    res = data.query("$.books[1,1,3].title")
    assert_instance_of(Jsoncons::Json, res)
    assert_equal('["The Night Watch","The Night Watch","The Night Watch"]', res.to_s)
    assert_equal(
      '["The Night Watch","The Night Watch"]',
      # yeah, that's strange
      data.query("$.books[1,1,3].title", Jsoncons::JsonPath::ResultOptions::NoDups.to_i).to_s
    )
    paths = data.query("$.books[1,1,3].title", Jsoncons::JsonPath::ResultOptions::Path.to_i)
    assert_instance_of(Jsoncons::Json, paths)
    assert_instance_of(Jsoncons::Json, paths[0])
    assert_equal(%q(["$['books'][1]['title']","$['books'][1]['title']","$['books'][3]['title']"]), paths.to_s)
    assert_equal(
      %q(["$['books'][1]['title']","$['books'][3]['title']"]),
      data.query(
        "$.books[1,1,3].title",
        Jsoncons::JsonPath::ResultOptions::Path.to_i | Jsoncons::JsonPath::ResultOptions::NoDups.to_i
      ).to_s
    )
  end

  def test_make_expression
    #  https://github.com/danielaparker/jsoncons/blob/master/doc/ref/jsonpath/make_expression.md
    data = load_json("books")
    expr = Jsoncons::JsonPath::Expression.make("$.books[?(@.price > avg($.books[*].price))].title")
    assert_instance_of(Jsoncons::JsonPath::Expression, expr)
    res = expr.evaluate(data)
    assert_equal('["The Night Watch"]', res.to_s)
    expr = Jsoncons::JsonPath::Expression.make("$.books[1,1,3].title")
    assert_equal('["The Night Watch","The Night Watch","The Night Watch"]', expr.evaluate(data).to_s)
    assert_equal(
      %q(["$['books'][1]['title']","$['books'][3]['title']"]),
      expr.evaluate(
        data,
        Jsoncons::JsonPath::ResultOptions::Path.to_i | Jsoncons::JsonPath::ResultOptions::NoDups.to_i
      ).to_s
    )
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  def load_json(name)
    Jsoncons::Json.parse(File.read("lib/jsoncons/jsoncons/examples/input/#{name}.json"))
  end
end