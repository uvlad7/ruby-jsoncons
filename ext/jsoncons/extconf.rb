# frozen_string_literal: true

require "mkmf-rice"
# git clone --sparse --no-checkout --depth 1 --filter=tree:0 git@github.com:danielaparker/jsoncons.git
# cd jsoncons/
# git sparse-checkout set /include/jsoncons/
# git checkout master

$CXXFLAGS += " -I#{File.expand_path(__dir__)}/include "
create_makefile("jsoncons/jsoncons")
