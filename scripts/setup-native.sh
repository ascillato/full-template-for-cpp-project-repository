#!/usr/bin/env bash
set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dry_run="${NATIVE_SETUP_DRY_RUN:-0}"

case "${dry_run}" in
    0 | 1) ;;
    *)
        echo "NATIVE_SETUP_DRY_RUN must be 0 or 1." >&2
        exit 2
        ;;
esac

if ! command -v apt-get >/dev/null 2>&1; then
    echo "Native setup currently supports Debian and Ubuntu hosts with apt-get." >&2
    echo "Use the development container or install the tools listed in docs/tooling.md manually." >&2
    exit 1
fi

if [[ "${EUID}" -eq 0 ]]; then
    elevate=()
elif command -v sudo >/dev/null 2>&1; then
    elevate=(sudo)
else
    echo "Native setup needs root privileges or sudo to install system packages." >&2
    exit 1
fi

# Keep this list aligned with the developer tooling in .devcontainer/Dockerfile.
packages=(
    bash-completion
    build-essential
    ca-certificates
    ccache
    clang
    clang-tidy
    clang-tools
    clangd
    cloc
    cmake
    cppcheck
    curl
    doxygen
    file
    g++-aarch64-linux-gnu
    g++-arm-linux-gnueabihf
    gcc-aarch64-linux-gnu
    gcc-arm-linux-gnueabihf
    gdb
    gdb-multiarch
    git
    graphviz
    lldb
    ninja-build
    openssh-client
    pkg-config
    python3
    python3-pip
    python3-venv
    qemu-user
    rsync
    shellcheck
    unzip
    xz-utils
    zip
)

run_command() {
    if [[ "${dry_run}" -eq 1 ]]; then
        printf '  '
        printf '%q ' "$@"
        printf '\n'
    else
        "$@"
    fi
}

echo "Native setup installs system packages with apt and Python tools in ${repository_root}/.venv."
if [[ "${dry_run}" -eq 1 ]]; then
    echo "Dry run: no changes will be made."
fi

run_command "${elevate[@]}" apt-get update
run_command "${elevate[@]}" apt-get install --yes --no-install-recommends "${packages[@]}"

if [[ "${dry_run}" -eq 1 ]]; then
    cd "${repository_root}"
    run_command make --no-print-directory bootstrap
    exit 0
fi

python_version="$(python3 --version | awk '{print $2}')"
if ! dpkg --compare-versions "${python_version}" ge "3.10"; then
    echo "Python 3.10 or newer is required; apt installed ${python_version}." >&2
    echo "Enable a newer distribution repository or use the development container." >&2
    exit 1
fi

cd "${repository_root}"
make --no-print-directory bootstrap

export PATH="${repository_root}/.venv/bin:${PATH}"
cmake_version="$(cmake --version | awk 'NR == 1 {print $3}')"
if ! dpkg --compare-versions "${cmake_version}" ge "3.25"; then
    echo "CMake 3.25 or newer is required; native setup found ${cmake_version}." >&2
    exit 1
fi

required_commands=(
    aarch64-linux-gnu-g++
    arm-linux-gnueabihf-g++
    clang
    clang-format
    clang-tidy
    clangd
    cloc
    cmake
    conan
    cppcheck
    doxygen
    dot
    g++
    gcovr
    gdb
    gdb-multiarch
    git
    make
    ninja
    pre-commit
    qemu-aarch64
    qemu-arm
    rsync
    shellcheck
    sphinx-build
    ssh
)

missing_commands=()
for command_name in "${required_commands[@]}"; do
    if ! command -v "${command_name}" >/dev/null 2>&1; then
        missing_commands+=("${command_name}")
    fi
done

if [[ "${#missing_commands[@]}" -ne 0 ]]; then
    printf 'Native setup did not provide these required commands:' >&2
    printf ' %s' "${missing_commands[@]}" >&2
    printf '\n' >&2
    exit 1
fi

echo "Native development setup complete. Run 'make test' and 'make check' to verify the host."
