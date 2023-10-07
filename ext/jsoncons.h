#ifndef JSONCONS_H
#define JSONCONS_H 1

#include <rice/rice.hpp>
#include <rice/stl.hpp>

#undef isfinite
#define JSONCONS_NO_DEPRECATED 1

#include "jsoncons/json.hpp"
#include "jsoncons_ext/jsonpath/jsonpath.hpp"

#endif /* JSONCONS_H */

using namespace Rice;

using json_class_type = /* jsoncons::wojson */ jsoncons::ojson;
// wchar_t is not defined with Rice
using json_string_type = /* std::wstring */ std::string;
using json_int_type = std::size_t;
using json_custom_functions = jsoncons::jsonpath::custom_functions<json_class_type>;
using json_params_type = jsoncons::jsonpath::parameter<json_class_type>;
using json_span_type = jsoncons::span<const json_params_type>;
