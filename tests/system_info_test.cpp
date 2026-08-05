#include "embedded_linux_template/system_info.hpp"

#include <catch2/catch_test_macros.hpp>

#include <unistd.h>

#include <atomic>
#include <chrono>
#include <filesystem>
#include <fstream>
#include <string>

namespace {

class TemporarySystemFiles {
  public:
    TemporarySystemFiles() {
        static std::atomic_uint sequence{0};
        root_ = std::filesystem::temp_directory_path() /
                ("embedded-linux-template-tests-" + std::to_string(::getpid()) + "-" +
                 std::to_string(sequence.fetch_add(1U) + 1U));
        std::filesystem::create_directories(root_ / "proc");
    }

    TemporarySystemFiles(const TemporarySystemFiles&) = delete;
    TemporarySystemFiles& operator=(const TemporarySystemFiles&) = delete;
    TemporarySystemFiles(TemporarySystemFiles&&) = delete;
    TemporarySystemFiles& operator=(TemporarySystemFiles&&) = delete;

    ~TemporarySystemFiles() {
        std::error_code error;
        std::filesystem::remove_all(root_, error);
    }

    void write(const std::filesystem::path& relative_path, const std::string& content) const {
        std::ofstream output{root_ / relative_path};
        REQUIRE(output.good());
        output << content;
        REQUIRE(output.good());
    }

    [[nodiscard]] const std::filesystem::path& root() const {
        return root_;
    }

  private:
    std::filesystem::path root_;
};

} // namespace

TEST_CASE("uptime parsing accepts the Linux proc format", "[unit]") {
    using namespace std::chrono_literals;
    CHECK(embedded_linux_template::parse_uptime("123.45 456.78\n") == 123450ms);
    CHECK(embedded_linux_template::parse_uptime("0.001") == 1ms);
}

TEST_CASE("uptime parsing rejects invalid input", "[unit]") {
    CHECK_FALSE(embedded_linux_template::parse_uptime("not-a-number"));
    CHECK_FALSE(embedded_linux_template::parse_uptime("nan"));
    CHECK_FALSE(embedded_linux_template::parse_uptime("-1.0 0.0"));
    CHECK_FALSE(embedded_linux_template::parse_uptime("1e100"));
    CHECK_FALSE(embedded_linux_template::parse_uptime(""));
}

TEST_CASE("system information reads injectable proc and hostname paths", "[unit]") {
    TemporarySystemFiles files;
    files.write("hostname", " target-board \n");
    files.write("proc/uptime", "42.75 100.00\n");

    const auto info =
        embedded_linux_template::read_system_info(files.root() / "proc", files.root() / "hostname");

    REQUIRE(info);
    CHECK(info->hostname == "target-board");
    CHECK(info->uptime == std::chrono::milliseconds{42750});
    CHECK_FALSE(info->kernel_release.empty());
    CHECK_FALSE(info->machine.empty());
}

TEST_CASE("system information reports missing input", "[unit]") {
    TemporarySystemFiles files;
    CHECK_FALSE(
        embedded_linux_template::read_system_info(
            files.root() / "proc", files.root() / "missing-hostname"
        )
    );

    files.write("hostname", "target-board\n");
    CHECK_FALSE(
        embedded_linux_template::read_system_info(files.root() / "proc", files.root() / "hostname")
    );

    files.write("proc/uptime", "invalid\n");
    CHECK_FALSE(
        embedded_linux_template::read_system_info(files.root() / "proc", files.root() / "hostname")
    );

    files.write("hostname", "  \n");
    CHECK_FALSE(
        embedded_linux_template::read_system_info(files.root() / "proc", files.root() / "hostname")
    );
}

TEST_CASE("formatting is stable and JSON escapes text", "[unit]") {
    const embedded_linux_template::SystemInfo info{
        .hostname = "board\"one",
        .kernel_release = "6.6.1",
        .machine = "aarch64",
        .uptime = std::chrono::milliseconds{12500},
    };

    CHECK(
        embedded_linux_template::format_system_info(info) ==
        "hostname: board\"one\nkernel: 6.6.1\nmachine: aarch64\nuptime_seconds: 12"
    );
    CHECK(
        embedded_linux_template::format_system_info_json(info) ==
        R"({"hostname":"board\"one","kernel":"6.6.1","machine":"aarch64","uptime_seconds":12})"
    );
}

TEST_CASE("JSON formatting escapes every control sequence", "[unit]") {
    const embedded_linux_template::SystemInfo info{
        .hostname = std::string{"slash\\ quote\" back\b form\f line\n return\r tab\t control\x01"},
        .kernel_release = "kernel",
        .machine = "machine",
        .uptime = std::chrono::milliseconds{0},
    };

    const auto json = embedded_linux_template::format_system_info_json(info);
    CHECK(json.find(R"(slash\\ quote\")") != std::string::npos);
    CHECK(json.find(R"(back\b form\f line\n return\r tab\t control\u0001)") != std::string::npos);
}
