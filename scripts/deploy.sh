#!/usr/bin/env bash
set -euo pipefail

target_host="${TARGET_HOST:-}"
target_directory="${TARGET_DIR:-/opt/embedded-linux-template/bin}"
binary="${BINARY:-build/arm64-release/bin/embedded-linux-template}"
target_service="${TARGET_SERVICE:-}"

if [[ -z "${target_host}" ]]; then
    echo "TARGET_HOST is required (for example, device.local or user@device.local)." >&2
    exit 2
fi
if [[ ! "${target_host}" =~ ^([A-Za-z0-9_][A-Za-z0-9_.-]*@)?[A-Za-z0-9][A-Za-z0-9.-]*$ ]]; then
    echo "TARGET_HOST must be a hostname or user@hostname without a port." >&2
    exit 2
fi
if [[ ! "${target_directory}" =~ ^/[A-Za-z0-9_./-]+$ ]]; then
    echo "TARGET_DIR must be an absolute path containing only safe path characters." >&2
    exit 2
fi
if [[ -n "${target_service}" && ! "${target_service}" =~ ^[A-Za-z0-9_.@-]+$ ]]; then
    echo "TARGET_SERVICE contains unsupported characters." >&2
    exit 2
fi
if [[ ! -x "${binary}" ]]; then
    echo "Deployable binary not found at ${binary}. Run 'make cross-arm64' first." >&2
    exit 1
fi

# The expanded path is intentionally sent to the remote shell after strict validation above.
# shellcheck disable=SC2029
ssh -- "${target_host}" "mkdir -p -- '${target_directory}'"
rsync --archive --checksum --chmod=F755 -- "${binary}" "${target_host}:${target_directory}/embedded-linux-template"

if [[ -n "${target_service}" ]]; then
    # The expanded unit name is intentionally sent after strict validation above.
    # shellcheck disable=SC2029
    ssh -- "${target_host}" "systemctl restart -- '${target_service}'"
fi

echo "Deployed ${binary} to ${target_host}:${target_directory}/embedded-linux-template"
