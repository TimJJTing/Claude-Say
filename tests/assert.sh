#!/usr/bin/env bash
# Minimal assertion library. Source this file; call print_summary at end.

PASS=0
FAIL=0

assert_eq() {
  local desc="$1" actual="$2" expected="$3"
  if [[ "$actual" == "$expected" ]]; then
    echo "  ✓ $desc"
    ((PASS++)) || true
  else
    echo "  ✗ $desc"
    echo "    expected: $(printf '%q' "$expected")"
    echo "    got:      $(printf '%q' "$actual")"
    ((FAIL++)) || true
  fi
}

assert_contains() {
  local desc="$1" actual="$2" substr="$3"
  if [[ "$actual" == *"$substr"* ]]; then
    echo "  ✓ $desc"
    ((PASS++)) || true
  else
    echo "  ✗ $desc"
    echo "    expected to contain: $(printf '%q' "$substr")"
    echo "    got: $(printf '%q' "$actual")"
    ((FAIL++)) || true
  fi
}

print_summary() {
  echo ""
  echo "Results: $PASS passed, $FAIL failed"
  [[ $FAIL -eq 0 ]]
}
