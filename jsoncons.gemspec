# frozen_string_literal: true

require_relative "lib/jsoncons/version"

Gem::Specification.new do |spec|
  spec.name          = "jsoncons"
  spec.version       = Jsoncons::VERSION
  spec.authors       = ["uvlad7"]
  spec.email         = ["uvlad7@gmail.com"]

  spec.summary       = "Ruby wrapper for https://github.com/danielaparker/jsoncons"
  spec.homepage      = "https://github.com/uvlad7/ruby-jsoncons"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/uvlad7/ruby-jsoncons"
  spec.metadata["changelog_uri"] = "https://github.com/uvlad7/ruby-jsoncons"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.extensions    = ["ext/jsoncons/extconf.rb"]

  spec.add_dependency "rice", "~> 4.0"
  spec.add_development_dependency "get_process_mem"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
