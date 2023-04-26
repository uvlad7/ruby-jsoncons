# frozen_string_literal: true

require "test_helper"

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

  def test_ruby_wrappers_for_method_result_are_different_every_time_but_equal
    data = Jsoncons::Json.parse('{"first":1,"second":2,"fourth":3,"fifth":4}')
    assert(data[1] == data["second"])
    assert(data[1].object_id != data["second"].object_id)
    # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
    assert(data["second"].object_id != data["second"].object_id)
    assert(data["second"] == data["second"])
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

  def test_square_brakes_return_original_content
    data = Jsoncons::Json.parse('{"data":[1,2,3,4]}')
    arr = data["data"]
    assert_equal("[1,2,3,4]", arr.to_s)
    arr.clear
    assert_equal('{"data":[]}', data.to_s)
    assert_equal("[]", arr.to_s)
  end

  def test_square_brakes_crash
    data = Jsoncons::Json.parse('{"data":[1,2,3,4]}')
    arr = data["data"]
    arr.clear
    # rubocop:disable Lint/UselessAssignment
    data = nil
    # rubocop:enable Lint/UselessAssignment
    GC.start
    # SIGSEGV if written incorrectly
    assert_equal("[]", arr.to_s)
    GC.start
    arr.inspect
  end

  def test_enum_object
    data = Jsoncons::Json.parse('{"data":[1,2,3,4]}')
    arr = data.find(&:itself).last
    assert_equal("[1,2,3,4]", arr.to_s)
    arr.clear
    assert_equal('{"data":[]}', data.to_s)
    assert_equal("[]", arr.to_s)
  end

  def test_enum_object_crash
    data = Jsoncons::Json.parse('{"data":[1,2,3,4]}')
    arr = data.find(&:itself).last
    arr.clear
    # rubocop:disable Lint/UselessAssignment
    data = nil
    # rubocop:enable Lint/UselessAssignment
    GC.start
    # SIGSEGV if written incorrectly
    assert_equal("[]", arr.to_s)
    GC.start
    arr.inspect
  end

  def test_enum_array
    data = Jsoncons::Json.parse('[{"a":1,"b":2}]')
    obj = data.find(&:itself)
    assert_equal('{"a":1,"b":2}', obj.to_s)
    obj.clear
    assert_equal("[{}]", data.to_s)
    assert_equal("{}", obj.to_s)
  end

  def test_enum_array_crash
    data = Jsoncons::Json.parse('[{"a":1,"b":2}]')
    obj = data.find(&:itself)
    obj.clear
    # rubocop:disable Lint/UselessAssignment
    data = nil
    # rubocop:enable Lint/UselessAssignment
    GC.start
    # SIGSEGV if written incorrectly
    assert_equal("{}", obj.to_s)
    GC.start
    obj.inspect
  end

  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
end
