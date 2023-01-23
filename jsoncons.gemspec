# frozen_string_literal: true

require_relative "lib/jsoncons/version"

Gem::Specification.new do |spec|
  spec.name = "jsoncons"
  spec.version = Jsoncons::VERSION
  spec.authors = ["uvlad7"]
  spec.email = ["uvlad7@gmail.com"]

  spec.summary = "Ruby wrapper for jsoncons library and jsonpath"
  spec.description = "Ruby wrapper for a part of [jsoncons](https://github.com/danielaparker/jsoncons) library," \
"mostly for its jsonpath implementation"
  spec.homepage = "https://github.com/uvlad7/ruby-jsoncons"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.5"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/uvlad7/ruby-jsoncons"
  spec.metadata["changelog_uri"] = "https://github.com/uvlad7/ruby-jsoncons"
  spec.metadata["documentation_uri"] = "https://rubydoc.info/gems/jsoncons/frames"
  spec.metadata["library_uri"] = "https://github.com/danielaparker/jsoncons"

  # Specify which files should be added to the gem when it is released.
  spec.files = [
    *Dir["lib/jsoncons/jsoncons/include/**/*"].reject { |f| File.directory?(f) },
    "ext/jsoncons/jsoncons.cpp", "ext/jsoncons/jsoncons.h", "jsoncons.gemspec", "lib/jsoncons.rb",
    "lib/jsoncons/version.rb",
    "yard_extensions.rb", ".yardopts"
  ]
  spec.test_files = [
    *Dir["lib/jsoncons/jsoncons/examples/input/**/*"].reject { |f| File.directory?(f) },
    "test/jsoncons_test.rb", "test/test_helper.rb"
  ]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.extensions = ["ext/jsoncons/extconf.rb"]

  spec.add_dependency "rice", "~> 4.0"
  spec.add_development_dependency "get_process_mem"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "yard"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
