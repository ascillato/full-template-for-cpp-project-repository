#include "embedded_linux_template/system_info.hpp"
#include "embedded_linux_template/version.hpp"

#include <iostream>
#include <string_view>

namespace {

void print_help(const std::string_view program_name) {
    std::cout << "Usage: " << program_name << " [--json | --help | --version]\n\n"
              << "Read a small, dependency-free snapshot from an embedded Linux target.\n";
}

} // namespace

int main(const int argument_count, const char* const argument_values[]) {
    bool json_output = false;

    for (int index = 1; index < argument_count; ++index) {
        const std::string_view argument{argument_values[index]};
        if (argument == "--help" || argument == "-h") {
            print_help(argument_values[0]);
            return 0;
        }
        if (argument == "--version") {
            std::cout << "embedded-linux-template " << embedded_linux_template::version << '\n';
            return 0;
        }
        if (argument == "--json") {
            json_output = true;
            continue;
        }

        std::cerr << "Unknown option: " << argument << '\n';
        print_help(argument_values[0]);
        return 2;
    }

    const auto system_info = embedded_linux_template::read_system_info();
    if (!system_info) {
        std::cerr << "Unable to read system information from this Linux target.\n";
        return 1;
    }

    if (json_output) {
        std::cout << embedded_linux_template::format_system_info_json(*system_info) << '\n';
    } else {
        std::cout << embedded_linux_template::format_system_info(*system_info) << '\n';
    }
    return 0;
}
