#pragma once

#include <chrono>
#include <filesystem>
#include <optional>
#include <string>
#include <string_view>

namespace embedded_linux_template {

/** Basic information exposed by the Linux kernel and root filesystem. */
struct SystemInfo {
    /** Device hostname, normally read from /etc/hostname. */
    std::string hostname;
    /** Linux kernel release returned by uname. */
    std::string kernel_release;
    /** Hardware identifier returned by uname, such as x86_64 or aarch64. */
    std::string machine;
    /** Monotonic time elapsed since the kernel booted. */
    std::chrono::milliseconds uptime;

    /**
     * Compare every field of two snapshots.
     *
     * @param lhs Left-hand snapshot.
     * @param rhs Right-hand snapshot.
     * @return True when all fields are equal.
     */
    friend bool operator==(const SystemInfo& lhs, const SystemInfo& rhs) = default;
};

/**
 * Parse the first seconds field from Linux's /proc/uptime format.
 *
 * @param text Contents of an uptime pseudo-file.
 * @return Milliseconds since boot, or std::nullopt for invalid or out-of-range input.
 */
[[nodiscard]] std::optional<std::chrono::milliseconds> parse_uptime(std::string_view text);

/**
 * Read a system snapshot from Linux files and uname.
 *
 * @param proc_root Root containing the uptime pseudo-file; injectable for tests.
 * @param hostname_file File containing the target hostname; injectable for tests.
 * @return A complete snapshot, or std::nullopt when a required field is unavailable.
 */
[[nodiscard]] std::optional<SystemInfo> read_system_info(
    const std::filesystem::path& proc_root = "/proc",
    const std::filesystem::path& hostname_file = "/etc/hostname"
);

/**
 * Render a stable, human-readable multi-line representation.
 *
 * @param info Snapshot to render.
 * @return Plain-text representation without a trailing newline.
 */
[[nodiscard]] std::string format_system_info(const SystemInfo& info);

/**
 * Render a compact JSON object without requiring a runtime JSON dependency.
 *
 * @param info Snapshot to render.
 * @return Valid compact JSON without a trailing newline.
 */
[[nodiscard]] std::string format_system_info_json(const SystemInfo& info);

} // namespace embedded_linux_template
