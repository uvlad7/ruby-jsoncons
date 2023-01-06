# Jsoncons

This gem is a thin Ruby wrapper over a C++ [jsoncons](https://github.com/danielaparker/jsoncons) library.
Now the version used by the gem is [master](https://github.com/danielaparker/jsoncons/tree/73c85182dc56d4441cdcd97255b23aa6f15b9121)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jsoncons'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install jsoncons

Or, if you downloaded the archive:

    $ rake compile && rake install

If you want to install the gem with a different version of the `jsoncons` library, you can use the following commands:

    $ gem install jsoncons -- --with-jsoncons-dir=/path/to/jsoncons

or

    $ gem install jsoncons -- --with-jsoncons-include=/path/to/jsoncons/include

or when building from source

    $ CONFIGURE_ARGS='--with-jsoncons-dir=/path/to/jsoncons' rake compile && rake install

## Usage

[Tests](https://github.com/uvlad7/ruby-jsoncons/blob/master/test/jsoncons_test.rb) are the best example

Parse data from [this example](https://github.com/danielaparker/jsoncons/blob/master/doc/ref/jsonpath/json_query.md)

```ruby
require 'jsoncons'
data = Jsoncons::Json.parse(File.read("store.json"))
#  => {"store":{"book":[{"category":"reference","author":"Nigel Rees","title":"Sayings of the Century","price":8.95},{"category":"fiction","author":"Evelyn Waugh","title":"Sword of Honour","price":12.99},{"category":"fiction","author":"Herman Melville","title":"Moby Dick","isbn":"0-553-21311-3","price":8.99},{"category":"fiction","author":"J. R. R. Tolkien","title":"The Lord of the Rings","isbn":"0-395-19395-8","price":22.99}]}} 

# The authors of books that are cheaper than $10
data.query("$.store.book[?(@.price < 10)].author")
# => ["Nigel Rees","Herman Melville"]

# The number of books
data.query("length($..book)")
# => [1] 

# The third book
data.query("$..book[2]")
# => [{"category":"fiction","author":"Herman Melville","title":"Moby Dick","isbn":"0-553-21311-3","price":8.99}] 

# All books whose author's name starts with Evelyn (C++ regex)
data.query("$.store.book[?(@.author =~ /Evelyn.*?/)]")
# => [{"category":"fiction","author":"Evelyn Waugh","title":"Sword of Honour","price":12.99}]

# The titles of all books that have isbn number
data.query("$..book[?(@.isbn)].title")
# => ["Moby Dick","The Lord of the Rings"]

# And so on
```

Please note that this is the very first version of the gem and its API is likely to change in the future.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/uvlad7/jsoncons.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
