# frozen_string_literal: true

require_relative "jsoncons/version"
require_relative "jsoncons/jsoncons"

# A wrapper for a part of {https://github.com/danielaparker/jsoncons jsoncons} library,
# mostly for its jsonpath implementation
module Jsoncons
  class JsonconsError < StandardError; end
end
