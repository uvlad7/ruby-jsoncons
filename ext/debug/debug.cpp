#include "../jsoncons.h"

extern "C"
[[maybe_unused]] void Init_debug() {
    Data_Type<json_class_type>().define_method("deep_inspect", [](VALUE self_value) {
        const json_class_type &self = Rice::detail::From_Ruby<json_class_type &>().convert(
                self_value);
        std::stringstream result;
        result << "object: " << self_value << std::endl
               << "address: " << ((void *) &self) << std::endl
               << "type: " << self.type() << std::endl
               << "tag: " << self.tag() << std::endl
               << "storage_kind: " << self.storage_kind() << std::endl
               << "ext_tag: " << self.ext_tag() << std::endl
               << "dump_pretty: ";
        self.dump_pretty(result);
        result << std::endl;
        auto const *p = reinterpret_cast<const unsigned char *>(&self);
        for (size_t n = 0; n < sizeof(json_class_type); ++n)
            result << std::hex << std::setw(2) << static_cast<unsigned int>(p[n]) << " ";
        result << std::endl;
        return result.str();
    });
}
