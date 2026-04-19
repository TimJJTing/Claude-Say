#!/usr/bin/env bash
set -euo pipefail

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PASS=0
FAIL=0
FAILED_FILES=()

for test_file in "$TESTS_DIR"/test-*.sh; do
  echo ">>> $(basename "$test_file")"
  if bash "$test_file"; then
    ((PASS++)) || true
  else
    ((FAIL++)) || true
    FAILED_FILES+=("$(basename "$test_file")")
  fi
  echo ""
done

echo "=============================="
echo "Suites: $PASS passed, $FAIL failed"
if [[ ${#FAILED_FILES[@]} -gt 0 ]]; then
  for f in "${FAILED_FILES[@]}"; do echo "  ✗ $f"; done
  exit 1
fi
