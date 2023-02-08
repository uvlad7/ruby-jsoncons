require 'jsoncons'
require 'curl'

class CurlDesc < Curl::Easy
  def initialize
  end
end

puts CurlDesc.new.inspect

class ArrayDesc < Array
  def initialize
  end
end

puts ArrayDesc.new.inspect

module Jsoncons
  class Json
    def ruby_method
      'no_crash'
    end
  end
end

class BadSon < Jsoncons::Json
  def initialize
  end
end

p BadSon.new.ruby_method
# p BadSon.new.every_call_causes_crash
