#!/usr/bin/env bash
set -euo pipefail

./tools/openapi_codegen/generate.py >/dev/null

if ! git diff --quiet -- apps/capital_com/lib/capital_com/generated/endpoints.ex; then
  echo "Generated files are stale. Run ./tools/openapi_codegen/generate.py"
  exit 1
fi

echo "Codegen output is up to date"
