#!/usr/bin/env bash
set -euo pipefail

mode="${1:---check}"
if [[ "${mode}" != "--check" && "${mode}" != "--fix" ]]; then
    echo "Usage: $0 [--check|--fix]" >&2
    exit 2
fi

if ! command -v clang-format >/dev/null 2>&1; then
    echo "clang-format is required. Use the dev container or install the LLVM formatting tools." >&2
    exit 127
fi

mapfile -d '' files < <(
    find app include src test_package tests \
        -type d -name build -prune -o \
        -type f \( -name '*.c' -o -name '*.cc' -o -name '*.cpp' -o -name '*.h' -o -name '*.hh' -o -name '*.hpp' \) -print0
)

if ((${#files[@]} == 0)); then
    echo "No C or C++ files were found." >&2
    exit 1
fi

if [[ "${mode}" == "--fix" ]]; then
    clang-format -i "${files[@]}"
else
    clang-format --dry-run --Werror "${files[@]}"
fi
