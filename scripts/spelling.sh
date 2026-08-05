#!/usr/bin/env bash
set -euo pipefail

if ! command -v codespell >/dev/null 2>&1; then
    echo "codespell is required. Run 'make bootstrap' or use the dev container." >&2
    exit 127
fi

codespell --config .codespellrc .
