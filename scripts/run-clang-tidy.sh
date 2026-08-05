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

"${clang_tidy_command}" -p "${build_directory}" "${extra_arguments[@]}" "${sources[@]}"
