#include "embedded_linux_template/system_info.hpp"

#include <sys/utsname.h>

#include <algorithm>
#include <cctype>
#include <cmath>
#include <cstdint>
#include <fstream>
#include <iomanip>
#include <limits>
#include <locale>
#include <sstream>
#include <system_error>
#include <utility>

namespace embedded_linux_template {
namespace {

[[nodiscard]] std::string trim(std::string value) {
    const auto is_space = [](const unsigned char character) {
        return std::isspace(character) != 0;
    };
    const auto first = std::find_if_not(value.begin(), value.end(), is_space);
    const auto last = std::find_if_not(value.rbegin(), value.rend(), is_space).base();
    if (first >= last) {
        return {};
    }
    return {first, last};
}

[[nodiscard]] std::optional<std::string> read_line(const std::filesystem::path& path) {
    std::ifstream input{path};
    std::string line;
    if (!input || !std::getline(input, line)) {
        return std::nullopt;
    }
    line = trim(std::move(line));
    if (line.empty()) {
        return std::nullopt;
    }
    return line;
}

[[nodiscard]] std::string escape_json(std::string_view value) {
    std::ostringstream output;
    for (const char raw_character : value) {
        const auto character = static_cast<unsigned char>(raw_character);
        switch (character) {
        case '"':
            output << "\\\"";
            break;
        case '\\':
            output << "\\\\";
            break;
        case '\b':
            output << "\\b";
            break;
        case '\f':
            output << "\\f";
            break;
        case '\n':
            output << "\\n";
            break;
        case '\r':
            output << "\\r";
            break;
        case '\t':
            output << "\\t";
            break;
        default:
            if (character < 0x20U) {
                output << "\\u" << std::hex << std::setw(4) << std::setfill('0')
                       << static_cast<unsigned int>(character) << std::dec;
            } else {
                output << static_cast<char>(character);
            }
        }
    }
    return output.str();
}

} // namespace

std::optional<std::chrono::milliseconds> parse_uptime(const std::string_view text) {
    std::istringstream input{std::string{text}};
    input.imbue(std::locale::classic());

    long double seconds = 0.0L;
    if (!(input >> seconds) || !std::isfinite(seconds) || seconds < 0.0L) {
        return std::nullopt;
    }

    using Milliseconds = std::chrono::milliseconds;
    constexpr auto maximum =
        static_cast<long double>(std::numeric_limits<Milliseconds::rep>::max());
    if (seconds > maximum / 1000.0L) {
        return std::nullopt;
    }

    return Milliseconds{static_cast<Milliseconds::rep>(std::round(seconds * 1000.0L))};
}

std::optional<SystemInfo> read_system_info(
    const std::filesystem::path& proc_root, const std::filesystem::path& hostname_file
) {
    const auto hostname = read_line(hostname_file);
    const auto uptime_text = read_line(proc_root / "uptime");
    if (!hostname || !uptime_text) {
        return std::nullopt;
    }

    const auto uptime = parse_uptime(*uptime_text);
    if (!uptime) {
        return std::nullopt;
    }

    utsname kernel_info{};
    if (::uname(&kernel_info) != 0) {
        return std::nullopt;
    }

    return SystemInfo{
        .hostname = *hostname,
        .kernel_release = kernel_info.release,
        .machine = kernel_info.machine,
        .uptime = *uptime,
    };
}

std::string format_system_info(const SystemInfo& info) {
    const auto uptime_seconds =
        std::chrono::duration_cast<std::chrono::seconds>(info.uptime).count();
    std::ostringstream output;
    output << "hostname: " << info.hostname << '\n'
           << "kernel: " << info.kernel_release << '\n'
           << "machine: " << info.machine << '\n'
           << "uptime_seconds: " << uptime_seconds;
    return output.str();
}

std::string format_system_info_json(const SystemInfo& info) {
    const auto uptime_seconds =
        std::chrono::duration_cast<std::chrono::seconds>(info.uptime).count();
    std::ostringstream output;
    output << R"({"hostname":")" << escape_json(info.hostname) << R"(","kernel":")"
           << escape_json(info.kernel_release) << R"(","machine":")" << escape_json(info.machine)
           << R"(","uptime_seconds":)" << uptime_seconds << '}';
    return output.str();
}

} // namespace embedded_linux_template
