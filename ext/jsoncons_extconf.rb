# frozen_string_literal: true

require "mkmf-rice"

# git submodule add git@github.com:danielaparker/jsoncons.git lib/jsoncons/jsoncons

# # # git clone --sparse --no-checkout --depth 1 --filter=tree:0 \
# # # git@github.com:danielaparker/jsoncons.git lib/jsoncons/jsoncons
# cd lib/jsoncons/jsoncons
# git sparse-checkout set /include /examples/input
# git checkout master # v0.169.0

gem_root = File.expand_path("..", __dir__)
default_include_dir = File.join(gem_root, "lib", "jsoncons", "jsoncons", "include")

puts "Default include dir: #{default_include_dir}"

# Override with
# gem install jsoncons -- --with-jsoncons-dir=/path/to/jsoncons
# or
# gem install jsoncons -- --with-jsoncons-include=/path/to/jsoncons/include
# or with rake
# CONFIGURE_ARGS='--with-jsoncons-dir=/path/to/jsoncons' rake compile && rake install
# or install
# gem install pkg/jsoncons-0.1.0.gem -- --with-jsoncons-dir=/path/to/jsoncons
include_dir, _lib_dir = dir_config("jsoncons", default_include_dir, "")

puts "Include dir: #{include_dir}"

unless have_header("jsoncons/json.hpp") && have_header("jsoncons_ext/jsonpath/jsonpath.hpp")
  raise <<-MESSAGE
  Can't find "jsoncons/json.hpp" or "jsoncons_ext/jsonpath/jsonpath.hpp"

  Make sure https://github.com/danielaparker/jsoncons
  is installed on the system.

  Try passing --with-jsoncons-dir or --with-jsoncons-include
  options to extconf.
  MESSAGE
end

# $CPPFLAGS << " -I./lib/jsoncons/jsoncons/include "
