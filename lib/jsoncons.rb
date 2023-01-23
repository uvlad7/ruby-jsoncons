# frozen_string_literal: true

require_relative "jsoncons/version"
require_relative "jsoncons/jsoncons"

# A wrapper for a part of {https://github.com/danielaparker/jsoncons jsoncons} library,
# mostly for its jsonpath implementation
module Jsoncons
  class JsonconsError < StandardError; end

  # A wrapper for +jsoncons::ojson+ type;
  # +o+ stands for +order_preserving+, this type was chosen as being more familiar to Ruby programmers
  # than sorted +jsoncons::json+.
  # And here is the only place where strategy for converting names from C++ to Ruby, according to which
  # +jsoncons::jsonpath::jsonpath_expression+ becomes +Jsoncons::JsonPath::Expression+,
  # is not followed for convenience
  class Json
    include Comparable
  end
end
