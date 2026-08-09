#!/usr/bin/env bash
set -euo pipefail

build_directory="${1:-build/analysis}"
clang_tidy_command="${CLANG_TIDY:-clang-tidy}"

if ! command -v "${clang_tidy_command}" >/dev/null 2>&1; then
    echo "clang-tidy is required. Use the dev container or install the LLVM analysis tools." >&2
    exit 127
fi

if [[ ! -f "${build_directory}/compile_commands.json" ]]; then
    echo "Missing ${build_directory}/compile_commands.json; configure the analysis preset first." >&2
    exit 1
fi

mapfile -d '' sources < <(find app src -type f -name '*.cpp' -print0)

extra_arguments=(--extra-arg-before=-Wno-unknown-warning-option)
if command -v g++ >/dev/null 2>&1; then
    gcc_library="$(g++ -print-libgcc-file-name)"
    gcc_install_directory="$(dirname "${gcc_library}")"
    if [[ -d "${gcc_install_directory}" ]]; then
        extra_arguments+=("--extra-arg-before=--gcc-install-dir=${gcc_install_directory}")
    fi
fi

tidy_arguments=(--quiet -p "${build_directory}")
case "${TIDY_SYSTEM_HEADERS:-0}" in
    0)
        echo "clang-tidy: reporting diagnostics from project sources and headers."
        echo "clang-tidy: set TIDY_SYSTEM_HEADERS=1 to include toolchain and system headers."
        ;;
    1)
        tidy_arguments=(--header-filter='.*' --system-headers -p "${build_directory}")
        echo "clang-tidy: reporting diagnostics from project, toolchain, and system headers."
        ;;
    *)
        echo "TIDY_SYSTEM_HEADERS must be 0 or 1." >&2
        exit 2
        ;;
esac

"${clang_tidy_command}" "${tidy_arguments[@]}" "${extra_arguments[@]}" "${sources[@]}"
echo "clang-tidy: analysis passed with no reportable diagnostics."
