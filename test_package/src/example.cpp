#include "embedded_linux_template/system_info.hpp"
#include "embedded_linux_template/version.hpp"

#include <chrono>
#include <string>

int main() {
    const embedded_linux_template::SystemInfo info{
        .hostname = "package-test",
        .kernel_release = "test-kernel",
        .machine = "test-machine",
        .uptime = std::chrono::seconds{1},
    };
    const std::string formatted = embedded_linux_template::format_system_info(info);
    return formatted.empty() || embedded_linux_template::version.empty() ? 1 : 0;
}
