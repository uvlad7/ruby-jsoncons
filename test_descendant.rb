require 'jsoncons'
require 'curl'

class CurlDesc < Curl::Easy
  def initialize
  end
end

curl = CurlDesc.new
curl.url = 'http://example.com/'
begin
  curl.perform
rescue => e
  p e
end
p curl

class ArrayDesc < Array
  def initialize
  end
end

arr = ArrayDesc.new
arr.push(1)
arr.concat([2])
p arr

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
