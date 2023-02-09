#include "jsoncons.h"

using namespace Rice;

using json_class_type = /* jsoncons::wojson */ jsoncons::ojson;
// wchar_t is not defined with Rice
using json_string_type = /* std::wstring */ std::string;

Module rb_mJsoncons;
Data_Type<json_class_type> rb_cJsoncons_Json;
Module rb_mJsoncons_JsonPath;
Data_Type<jsoncons::jsonpath::jsonpath_expression<json_class_type>> rb_cJsoncons_JsonPath_Expression;
Data_Type<jsoncons::jsonpath::result_options> rb_cJsoncons_JsonPath_ResultOptions;
Data_Type<jsoncons::json_storage_kind> rb_cJsoncons_StorageKind;
Data_Type<jsoncons::json_type> rb_cJsoncons_Type;

static auto evaluate(const jsoncons::jsonpath::jsonpath_expression<json_class_type> &self,
                     const json_class_type &data,
                     const std::optional<int> &options = std::nullopt) {
    if (options)
        return self.evaluate(data, static_cast<jsoncons::jsonpath::result_options>(*options));
    else return self.evaluate(data);
}

static auto json_query(const json_class_type &self, const json_string_type &path,
                       const std::optional<int> &options = std::nullopt) {
//    throw Rice::create_type_exception<jsoncons::jsonpath::jsonpath_expression<json_class_type>>(SOME_VALUE);
    if (options) // Custom functions and callbacks aren't implemented yet
        return jsoncons::jsonpath::json_query(self, path,
                                              static_cast<jsoncons::jsonpath::result_options>(*options));
    else return jsoncons::jsonpath::json_query(self, path);
}

static auto &json_at(const json_class_type &self, const VALUE value) {
    switch (rb_type(value)) {
        case RUBY_T_STRING:
            return self.at(Rice::detail::From_Ruby<json_string_type>().convert(value));
        case RUBY_T_SYMBOL:
            return self.at(Rice::detail::From_Ruby<Symbol>().convert(value).str());
        case RUBY_T_FIXNUM:
        case RUBY_T_BIGNUM:
            return self.at(Rice::detail::From_Ruby<std::size_t>().convert(value));
        default: {
            throw Exception(rb_eTypeError, "wrong argument type %s (expected % s)",
                            detail::protect(rb_obj_classname, value), "String|Symbol|Integer");
        }
    }
}

extern "C"
[[maybe_unused]] void Init_jsoncons() {
    rb_mJsoncons = define_module("Jsoncons");
/**
 * Document-class: Jsoncons::Json
 *
 * A wrapper for +jsoncons::ojson+ type;
 * +o+ stands for +order_preserving+, this type was chosen as being more familiar to Ruby programmers
 * than sorted +jsoncons::json+.
 * @see https://danielaparker.github.io/jsoncons/#A11 ojson
 * And here is the only place where strategy for converting names from C++ to Ruby, according to which
 * +jsoncons::jsonpath::jsonpath_expression+ becomes +Jsoncons::JsonPath::Expression+,
 * is not followed for convenience
 */
    rb_cJsoncons_Json =
            define_class_under<json_class_type>(rb_mJsoncons, "Json")
                    .define_constructor(Constructor<json_class_type>());
/**
 * Document-module: Jsoncons::JsonPath
 *
 * A wrapper for +jsoncons::jsonpath+
 * @see https://danielaparker.github.io/jsoncons/#A8 jsoncons JSONPath documentation
 */
    rb_mJsoncons_JsonPath = define_module_under(rb_mJsoncons, "JsonPath");
    rb_cJsoncons_JsonPath_Expression =
            define_class_under<jsoncons::jsonpath::jsonpath_expression<json_class_type>>(
                    rb_mJsoncons_JsonPath,
                    "Expression")
                    .define_singleton_function("make", [](const json_string_type &json_query) {
                        return jsoncons::jsonpath::make_expression<json_class_type>(json_query);
                    })
                    .define_method("evaluate", &evaluate,
                                   Arg("options") = (std::optional<int>) std::nullopt);

    rb_cJsoncons_JsonPath_ResultOptions =
            define_enum<jsoncons::jsonpath::result_options>("ResultOptions", rb_mJsoncons_JsonPath)
//                    Names must be valid for rb_const_set
                    .define_value("Value", jsoncons::jsonpath::result_options::value)
                    .define_value("NoDups", jsoncons::jsonpath::result_options::nodups)
                    .define_value("Sort", jsoncons::jsonpath::result_options::sort)
                    .define_value("Path", jsoncons::jsonpath::result_options::path);
    rb_cJsoncons_Type =
            define_enum<jsoncons::json_type>("Type", rb_mJsoncons)
                    .define_value("Null", jsoncons::json_type::null_value)
                    .define_value("Bool", jsoncons::json_type::bool_value)
                    .define_value("Int64", jsoncons::json_type::int64_value)
                    .define_value("Uint64", jsoncons::json_type::uint64_value)
                    .define_value("Half", jsoncons::json_type::half_value)
                    .define_value("Double", jsoncons::json_type::double_value)
                    .define_value("String", jsoncons::json_type::string_value)
                    .define_value("ByteString", jsoncons::json_type::byte_string_value)
                    .define_value("Array", jsoncons::json_type::array_value)
                    .define_value("Object", jsoncons::json_type::object_value);

    rb_cJsoncons_Json.define_singleton_function("parse", [](const json_string_type &source) {
        return json_class_type::parse(source);
    });
    rb_cJsoncons_Json.define_method("to_string", &json_class_type::to_string);
    rb_define_alias(rb_cJsoncons_Json, "to_s", "to_string");
    rb_cJsoncons_Json.define_method("inspect", [](const json_class_type &self) {
        std::stringstream result;
//        VALUE rubyKlass = Data_Type<json_class_type>::klass().value();
//        jsoncons::json_type type_val = self.type();
//        result << "#<" << detail::protect(rb_class2name, rubyKlass)
        result << "#<" << rb_cJsoncons_Json << ':' << ((void *) &self)
               //               << "<" << Data_Object<jsoncons::json_type>(type_val).to_s() << ">"
               << " type=\"" << self.type() << "\""
               << " " << self << ">";
        return result.str();
    });

    rb_cJsoncons_Json.define_method("contains",
                                    [](const json_class_type &self, const json_string_type &key) {
                                        return self.contains(key);
                                    });

    rb_cJsoncons_Json.define_method("at", &json_at, Arg("value").isValue(), Return().keepAlive());
    rb_define_alias(rb_cJsoncons_Json, "[]", "at");
    rb_cJsoncons_Json.define_method("query", &json_query,
                                    Arg("options") = (std::optional<int>) std::nullopt);

    rb_cJsoncons_Json
            .define_method("size", &json_class_type::size)
            .define_method("empty", &json_class_type::empty)
            .define_method("clear", &json_class_type::clear)
            .define_method("swap", &json_class_type::swap)
//            .define_method("remove", &json_class_type::remove) // erase
//            .define_method("insert", &json_class_type::insert) // add
//            .define_method("insert_or_assign", &json_class_type::insert_or_assign) // set
//            .define_method("push_back", &json_class_type::push_back)
//            .define_method("merge", &json_class_type::merge)
//            .define_method("merge_or_update", &json_class_type::merge_or_update)
//            .define_method("array_value", &json_class_type::array_value)
//            .define_method("object_value", &json_class_type::object_value)
            .define_method("type", &json_class_type::type)
            .define_method("is_null", &json_class_type::is_null)
//            .define_method("count", &json_class_type::count) // Type is not defined with Rice
            .define_method("is_string", &json_class_type::is_string)
//            .define_method("is_string_view", &json_class_type::is_string_view)
            .define_method("is_byte_string", &json_class_type::is_byte_string)
//            .define_method("is_byte_string_view", &json_class_type::is_byte_string_view)
            .define_method("is_bignum", &json_class_type::is_bignum)
            .define_method("is_bool", &json_class_type::is_bool)
            .define_method("is_object", &json_class_type::is_object)
            .define_method("is_array", &json_class_type::is_array)
            .define_method("is_int64", &json_class_type::is_int64)
            .define_method("is_uint64", &json_class_type::is_uint64)
            .define_method("is_half", &json_class_type::is_half)
            .define_method("is_double", &json_class_type::is_double)
            .define_method("is_number", &json_class_type::is_number)
//            .define_method("capacity", &json_class_type::capacity)
//            .define_method("reserve", &json_class_type::reserve)
//            .define_method("resize", &json_class_type::resize) // resize_array
//            .define_method("shrink_to_fit", &json_class_type::shrink_to_fit)
            .define_method("as_bool", &json_class_type::as_bool)
            .define_method("as_double", &json_class_type::as_double);
//            .define_method("as_string", &json_class_type::as_string)
//            .define_method("as_cstring", &json_class_type::as_cstring)
//            .define_method("is_integer", &json_class_type::is_integer)
//            .define_method("is_longlong", &json_class_type::is_longlong) // Deprecated
//            .define_method("is_ulonglong", &json_class_type::is_ulonglong) // Deprecated
//            .define_method("as_longlong", &json_class_type::as_longlong) // Deprecated
//            .define_method("as_ulonglong", &json_class_type::as_ulonglong) // Deprecated
//            .define_method("as_int", &json_class_type::as_int) // Deprecated
//            .define_method("as_uint", &json_class_type::as_uint) // Deprecated
//            .define_method("as_long", &json_class_type::as_long) // Deprecated
//            .define_method("as_ulong", &json_class_type::as_ulong) // Deprecated
//            .define_method("as_integer", &json_class_type::as_integer)
//            .define_method("find", &json_class_type::find)
//            .define_method("at_or_null", &json_class_type::at_or_null) // Type is not defined with Rice
//            .define_method("get_value_or", &json_class_type::get_value_or)
//            .define_method("get_with_default", &json_class_type::get_with_default) // get
    rb_cJsoncons_Json.define_method("is_datetime", [](const json_class_type &self) {
                return self.tag() ==
                       jsoncons::semantic_tag::datetime; // TODO: implement semantic_tag enum instead
            })
            .define_method("is_epoch_time", [](const json_class_type &self) {
                return self.tag() ==
                       jsoncons::semantic_tag::epoch_second; // TODO: implement semantic_tag enum instead
            })
            .define_method("is_integer", [](const json_class_type &self) {
                return self.is_integer<size_t>();
            });
//    Data_Object<json_class_type> rhs(value);
    /**
     * @!parse [c]
     * rb_define_method(rb_cJsoncons_Json, "compare", compare, 1);
     */
    rb_cJsoncons_Json.define_method("compare", [](const json_class_type &self,
                                                  json_class_type &rhs) {
        return self.compare(rhs);
    });
    rb_define_alias(rb_cJsoncons_Json, "<=>", "compare");
    rb_cJsoncons_Json.include_module(rb_mComparable);
    rb_define_alias(rb_cJsoncons_Json, "empty?", "empty");

    rb_cJsoncons_Json.define_method("to_a", [](json_class_type &self) {
        Rice::Array arr;
//        for (auto &item: self.array_range()) {
//            arr.push(Data_Object<json_class_type>(item));
//        }
        for (size_t i = 0; i < self.size(); i++) {
//            Todo: clarify
//             "Be careful not to call this function more than once for the same pointer"
            arr.push(Data_Object<json_class_type>(self[i]));
//            json_class_type &item = self[i];
//            arr.push(Data_Object<json_class_type>(&item));
        }
        return arr;
    });

/*
 * WTF
2.7.0 :001 > data = Jsoncons::Json.parse('{"data":[1,2,3,4]}')
2.7.0 :002 > arr = data.to_arr
2.7.0 :003 > arr
 => [#<Jsoncons::Json:0x558e8e549dc0 type="array" [1,2,3,4]>]
2.7.0 :004 > data # that's what matters
 => #<Jsoncons::Json:0x558e8e5a53d0 type="object" {"data":[1,2,3,4]}>
2.7.0 :005 > data = nil; GC.start
 => nil
2.7.0 :006 > arr
 => [#<Jsoncons::Json:0x558e8e549dc0 type="array" [1,2,3,4]>]
2.7.0 :007 > data = Jsoncons::Json.parse('{"data":[1,2,3,4]}')
2.7.0 :008 > arr = data.to_arr
2.7.0 :009 > data = nil; GC.start
 => nil
2.7.0 :010 > arr
 => [#<Jsoncons::Json:0x558e8e7d1360 type="null" null>]
 */

/*
 * WTF x2
2.7.0 :001 > data = Jsoncons::Json.parse('{"data":[1,2,3,4]}')
2.7.0 :002 > arr = data.to_arr
2.7.0 :003 > p data; nil
#<Jsoncons::Json:0x5638e2b79f40 type="object" {"data":[1,2,3,4]}>
 => nil
2.7.0 :004 > data = nil; GC.start
 => nil
2.7.0 :005 > arr
 => [#<Jsoncons::Json:0x5638e2628870 type="null" null>]
2.7.0 :006 > data = Jsoncons::Json.parse('{"data":[1,2,3,4]}')
2.7.0 :007 > arr = data.to_arr
2.7.0 :008 > data
 => #<Jsoncons::Json:0x5638e2bd0000 type="object" {"data":[1,2,3,4]}>
2.7.0 :009 > data = nil; GC.start
 => nil
2.7.0 :010 > arr
 => [#<Jsoncons::Json:0x5638e2e5de50 type="array" [1,2,3,4]>]
 */
    rb_cJsoncons_Json.define_method("to_arr", [](json_class_type &self) {
        Rice::Array arr;
        for (size_t i = 0; i < self.size(); i++) {
//            Todo: clarify if this is how NativeFunction return values are wrapped
//            VALUE NativeFunction<Function_T, IsMethod>::operator()(int argc, VALUE* argv, VALUE self)
            json_class_type &item = self[i];
            arr.push<json_class_type &>(item);
        }
        return arr;
    });

    rb_cJsoncons_Json.define_method("debug", [](const json_class_type &self) {
        std::stringstream result;
        result << "address: " << ((void *) &self) << std::endl
               << "type: " << self.type() << std::endl
               << "tag: " << self.tag() << std::endl
               << "storage_kind: " << self.storage_kind() << std::endl
               << "ext_tag: " << self.ext_tag() << std::endl;
        auto const *p = reinterpret_cast<const unsigned char *>(&self);
        for (size_t n = 0; n < sizeof(json_class_type); ++n)
            result << std::hex << std::setw(2) << static_cast<unsigned int>(p[n]) << " ";
        result << std::endl;
        return result.str();
    });
}
