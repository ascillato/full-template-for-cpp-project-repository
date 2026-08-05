#!/usr/bin/env bash
set -euo pipefail

jobs="${1:-}"
if ! command -v gcovr >/dev/null 2>&1; then
    echo "gcovr is required. Run 'make bootstrap' or use the dev container." >&2
    exit 127
fi

cmake --preset coverage
if [[ -n "${jobs}" ]]; then
    cmake --build --preset coverage --parallel "${jobs}"
    find build/coverage -type f -name '*.gcda' -delete
    ctest --preset coverage --parallel "${jobs}"
else
    cmake --build --preset coverage --parallel
    find build/coverage -type f -name '*.gcda' -delete
    ctest --preset coverage --parallel
fi

mkdir -p build/coverage/html
gcovr \
    --root . \
    --filter '^(app|include|src)/' \
    --exclude 'tests/' \
    --exclude 'build/' \
    --html-details build/coverage/html/index.html \
    --xml-pretty --output build/coverage/coverage.xml \
    --json-summary build/coverage/coverage-summary.json \
    --print-summary \
    --fail-under-line 85
