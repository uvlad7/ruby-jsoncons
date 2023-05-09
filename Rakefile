# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

require "rake/clean"

CLEAN.reject! { |f| f.start_with?("lib/jsoncons/jsoncons/") }

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

require "rubocop/rake_task"

RuboCop::RakeTask.new

require "rake/extensiontask"

task build: :compile

Rake::ExtensionTask.new("jsoncons") do |ext|
  ext.lib_dir = "lib/jsoncons"
end

Rake::ExtensionTask.new("debug") do |ext|
  ext.lib_dir = "lib/jsoncons"
end

task default: %i[clobber compile test rubocop]
