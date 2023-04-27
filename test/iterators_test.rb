# frozen_string_literal: true

require "test_helper"

class IteratorsTest < Minitest::Test
  def test_object_with_block
    obj = Jsoncons::Json.parse(("a".."z").map { |l| [l, l.ord] }.to_h.to_json)
    res = ("a".."z").map(&:ord).sum
    assert_equal(res, obj.map { |_, v| v.to_s.to_i }.sum)
    assert_equal(res, obj.map { |arr| arr.last.to_s.to_i }.sum)
    sum = 0
    obj.reverse_each { |_, v| sum += v.to_s.to_i }
    assert_equal(res, sum)
    sum = 0
    obj.reverse_each { |arr| sum += arr.last.to_s.to_i }
    assert_equal(res, sum)
  end

  def test_object_without_block
    obj = Jsoncons::Json.parse(("a".."z").map { |l| [l, l.ord] }.to_h.to_json)
    assert_instance_of(Enumerator, obj.each)
    assert_instance_of(Enumerator, obj.reverse_each)
    assert_equal(26, obj.size)
    assert_equal(26, obj.each.size)
    assert_equal(26, obj.reverse_each.size)
  end

  def test_array_with_block
    arr = Jsoncons::Json.parse((1..10).to_a.to_json)
    res = []
    arr.each { |v| res.push(v.to_s.to_i) }
    assert_equal((1..10).to_a, res)
    res = []
    arr.reverse_each { |v| res.push(v.to_s.to_i) }
    assert_equal((1..10).reverse_each.to_a, res)
    assert_equal(55, arr.map { |v| v.to_s.to_i }.sum)
  end

  def test_array_without_block
    arr = Jsoncons::Json.parse((1..10).to_a.to_json)
    assert_instance_of(Enumerator, arr.each)
    assert_instance_of(Enumerator, arr.reverse_each)
    assert_equal(10, arr.size)
    assert_equal(10, arr.each.size)
    assert_equal(10, arr.reverse_each.size)
  end
end
