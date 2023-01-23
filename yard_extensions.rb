# frozen_string_literal: true

unless defined?(RICE_EXT_LOADED)
  RICE_EXT_LOADED = true
  # handle rice classes
  class RiceClassHandler < YARD::Handlers::C::Base
    MATCH = /(rb_c[\w.]+)\s* = \s*(?:Rice::)?define_class<.+?>\s*
            \(
               \s*"(\w[\wd:]+)"\s*
               (?:,\s*(\w[\wd]*)\s*)?
            \)/mx.freeze

    MATCH_UNDER = /(rb_c[\w.]+)\s* = \s*(?:Rice::)?define_class_under<.+?>\s*
            \(
               \s*([\w.]+)\s*,
               \s*"(\w[\wd]+)"
               (?:\s*,\s*(\w[\wd]*)\s*)?
            \s*\)/mx.freeze
    handles MATCH
    handles MATCH_UNDER
    statement_class BodyStatement

    process do
      statement.source.scan(MATCH) do |var_name, class_name, parent|
        handle_class(var_name, class_name, parent&.strip || "rb_cObject")
      end
      statement.source.scan(MATCH_UNDER) do |var_name, in_module, class_name, parent|
        handle_class(var_name, class_name, parent&.strip || "rb_cObject", in_module)
      end
    end
  end

  # handle rice modules
  class RiceModuleHandler < YARD::Handlers::C::Base
    MATCH = /(rb_m[\w.]+)\s* = \s*(?:Rice::)?define_module\s*
            \(
               \s*"(\w[\wd:]+)"\s*
            \)/mx.freeze

    MATCH_UNDER = /(rb_m[\w.]+)\s* = \s*(?:Rice::)?define_module_under\s*
            \(
               \s*([\w.]+)\s*,
               \s*"(\w[\wd]+)"
            \s*\)/mx.freeze
    handles MATCH
    handles MATCH_UNDER
    statement_class BodyStatement

    process do
      statement.source.scan(MATCH) do |var_name, module_name|
        handle_module(var_name, module_name)
      end
      statement.source.scan(MATCH_UNDER) do |var_name, in_module, module_name|
        handle_module(var_name, module_name, in_module)
      end
    end
  end
end
