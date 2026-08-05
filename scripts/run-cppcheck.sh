#!/usr/bin/env bash
set -euo pipefail

if ! command -v cppcheck >/dev/null 2>&1; then
    echo "cppcheck is required. Use the dev container or install cppcheck." >&2
    exit 127
fi

cppcheck \
    --enable=warning,style,performance,portability \
    --error-exitcode=1 \
    --inline-suppr \
    --std=c++20 \
    --suppress=missingIncludeSystem \
    --quiet \
    -I include \
    app src
