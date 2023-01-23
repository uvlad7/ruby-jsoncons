# frozen_string_literal: true

require "test_helper"

class JsonpathTest < Minitest::Test
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def test_jsonpath
    # https://github.com/danielaparker/jsoncons/blob/
    # /doc/ref/jsonpath/jsonpath.md
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

  def test_jsonpath_return_copy
    data = Jsoncons::Json.parse('{"data":[1,2,3,4]}')
    arr = data.query("$.data")[0]
    assert_equal("[1,2,3,4]", arr.to_s)
    arr.clear
    assert_equal('{"data":[1,2,3,4]}', data.to_s)
    # rubocop:disable Lint/UselessAssignment
    data = nil
    # rubocop:enable Lint/UselessAssignment
    GC.start
    # SIGSEGV if written incorrectly
    assert arr.to_s
  end

  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
end
