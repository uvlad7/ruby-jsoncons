# frozen_string_literal: true

unless defined?(RICE_EXT_LOADED)
  RICE_EXT_LOADED = true
  # handle rice classes
  class RiceClassHandler < YARD::Handlers::C::Base
    MATCH = /(rb_c[\w.]+)\s* = \s*(?:Rice::)?define_class<(.+?)>\s*
            \(
               \s*"(\w[\wd:]+)"\s*
               (?:,\s*(\w[\wd]*)\s*)?
            \)/mx.freeze

    MATCH_UNDER = /(rb_c[\w.]+)\s* = \s*(?:Rice::)?define_class_under<(.+?)>\s*
            \(
               \s*([\w.]+)\s*,
               \s*"(\w[\wd]+)"
               (?:\s*,\s*(\w[\wd]*)\s*)?
            \s*\)/mx.freeze

    MATCH_ENUM = /(rb_c[\w.]+)\s* = \s*(?:Rice::)?define_enum<(.+?)>\s*
            \(
               \s*"(\w[\wd:]+)"\s*
               (?:,\s*([\w.]+)\s*)?
            \)/mx.freeze
    handles MATCH
    handles MATCH_UNDER
    handles MATCH_ENUM
    statement_class BodyStatement

    process do
      statement.source.scan(MATCH) do |var_name, cpp_type, class_name, parent|
        cls = handle_class(var_name, class_name, parent&.strip || "rb_cObject")
        register_docstring(cls, "Wraps +#{cpp_type}+")
      end
      statement.source.scan(MATCH_UNDER) do |var_name, cpp_type, in_module, class_name, parent|
        cls = handle_class(var_name, class_name, parent&.strip || "rb_cObject", in_module)
        register_docstring(cls, "Wraps +#{cpp_type}+")
      end
      statement.source.scan(MATCH_ENUM) do |var_name, cpp_type, class_name, in_module|
        cls = handle_class(var_name, class_name, "rb_cObject", in_module&.strip || "rb_cObject")
        register_docstring(cls, "Wraps +#{cpp_type}+")
        from_int = handle_method("singleton_method", var_name, "from_int", "rice_from_int")
        register_docstring(
          from_int,
          [
            "Returns ruby representation of a +#{cpp_type}+ enum member",
            "@param value [Integer] a valid +#{cpp_type}+",
            "@return [#{cls}]"
          ]
        )
        each = handle_method("singleton_method", var_name, "each", "rice_each")
        register_docstring(
          each,
          [
            "Iterates over all +#{cpp_type}+ enum members",
            "@yieldparam value [#{cls}] ruby representation of a +#{cpp_type}+ enum member",
            "@return [nil]"
          ]
        )
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
