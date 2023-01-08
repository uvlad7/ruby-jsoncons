# frozen_string_literal: true

require_relative "jsoncons/version"
require_relative "jsoncons/jsoncons"

module Jsoncons
  class JsonconsError < StandardError; end

  # A wrapper for [jsoncons](https://github.com/danielaparker/jsoncons)
  # jsoncons::json class
  class Json
    # @raise [RangeError] bignum too big to convert into `unsigned long'
    # @raise [RangeError] Invalid array subscript
    # @raise [FloatDomainError] Index on non-array value not supported
    # @raise [RangeError] Key not found
    # @raise [RuntimeError] Attempting to access a member of a value that is not an object
    # @param [String|Symbol|Integer] arg
    # @return [Jsoncons::Json]
    # def [](arg)
    # end
  end
end
