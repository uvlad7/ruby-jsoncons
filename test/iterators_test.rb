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

  def iterator_with_return(iterable, check)
    iterable.each { |v, _| return v.to_s if v.to_s == check }
  end

  def iterator_with_throw(iterable, check)
    iterable.each { |v, _| throw :iterator_with_throw, v.to_s if v.to_s == check }
  end

  def iterator_with_raise(iterable, check)
    iterable.each { |v, _| raise v.to_s if v.to_s == check }
  end

  def iterator_with_return_index(iterable, index)
    iterable.each.with_index { |(v, _), i| return v.to_s if i == index }
  end

  def iterator_with_throw_index(iterable, index)
    iterable.each.with_index { |(v, _), i| throw :iterator_with_throw, v.to_s if i == index }
  end

  def iterator_with_raise_index(iterable, index)
    iterable.each.with_index { |(v, _), i| raise v.to_s if i == index }
  end

  # It actually just checks it doesn't crash
  def test_jumps
    arr = Jsoncons::Json.parse((1..10).to_a.to_json)
    obj = Jsoncons::Json.parse(("a".."z").map { |l| [l, l.ord] }.to_h.to_json)
    # 'next' is not a jump, actually
    arr.each { |v| next v.to_s }
    obj.each { |k, _| next k }
    arr.each.with_index { |v, _| next v.to_s }
    obj.each.with_index { |k, _, _| next k }
    ###
    assert_equal("3", iterator_with_return(arr, "3"))
    assert_equal("f", iterator_with_return(obj, "f"))
    assert_equal("3", arr.each { |v| break v.to_s if v.to_s == "3" })
    assert_equal("f", obj.each { |k, _| break k if k == "f" })
    assert_equal("3", catch(:iterator_with_throw) { iterator_with_throw(arr, "3") })
    assert_equal("f", catch(:iterator_with_throw) { iterator_with_throw(obj, "f") })
    error = assert_raises(RuntimeError) { iterator_with_raise(arr, "3") }
    assert_equal("3", error.message)
    error = assert_raises(RuntimeError) { iterator_with_raise(obj, "f") }
    assert_equal("f", error.message)
    ###
    assert_equal("3", iterator_with_return_index(arr, 2))
    assert_equal("f", iterator_with_return_index(obj, 5))
    assert_equal("3", arr.each.with_index { |v, i| break v.to_s if i == 2 })
    assert_equal("f", obj.each.with_index { |(k, _), i| break k if i == 5 })
    assert_equal("3", catch(:iterator_with_throw) { iterator_with_throw_index(arr, 2) })
    assert_equal("f", catch(:iterator_with_throw) { iterator_with_throw_index(obj, 5) })
    error = assert_raises(RuntimeError) { iterator_with_raise_index(arr, 2) }
    assert_equal("3", error.message)
    error = assert_raises(RuntimeError) { iterator_with_raise_index(obj, 5) }
    assert_equal("f", error.message)
  end

  def iterator_with_modification(iterable, check)
    iterable.each do |v, _|
      iterable.clear
      return v.to_s if v.to_s == check
    end
  end

  def iterator_with_modification_index(iterable, index)
    iterable.each.with_index do |(v, _), i|
      iterable.clear
      return v.to_s if i == index
    end
  end

  # It actually just checks it doesn't crash
  def test_modification_during_iteration
    arr = Jsoncons::Json.parse((1..10).to_a.to_json)
    obj = Jsoncons::Json.parse(("a".."z").map { |l| [l, l.ord] }.to_h.to_json)
    assert_equal("3", iterator_with_modification(arr, "3"))
    assert_equal("f", iterator_with_modification(obj, "f"))
    arr = Jsoncons::Json.parse((1..10).to_a.to_json)
    obj = Jsoncons::Json.parse(("a".."z").map { |l| [l, l.ord] }.to_h.to_json)
    assert_equal("3", iterator_with_modification_index(arr, 2))
    assert_equal("f", iterator_with_modification_index(obj, 5))
  end
end
