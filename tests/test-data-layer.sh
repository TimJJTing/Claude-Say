#!/usr/bin/env bash
set -euo pipefail
PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PLUGIN_ROOT/tests/assert.sh"
source "$PLUGIN_ROOT/characters/default.sh"
source "$PLUGIN_ROOT/lib/moods.sh"
source "$PLUGIN_ROOT/lib/tools.sh"

echo "=== characters/default.sh ==="
# All 9 grid cell vars must be defined (non-null). Content is design-dependent.
assert_var_set "CHAR_TOP_LEFT defined"     CHAR_TOP_LEFT
assert_var_set "CHAR_TOP defined"          CHAR_TOP
assert_var_set "CHAR_TOP_RIGHT defined"    CHAR_TOP_RIGHT
assert_var_set "CHAR_LEFT defined"         CHAR_LEFT
assert_var_set "CHAR_BODY defined"         CHAR_BODY
assert_var_set "CHAR_RIGHT defined"        CHAR_RIGHT
assert_var_set "CHAR_BOTTOM_LEFT defined"  CHAR_BOTTOM_LEFT
assert_var_set "CHAR_BOTTOM defined"       CHAR_BOTTOM
assert_var_set "CHAR_BOTTOM_RIGHT defined" CHAR_BOTTOM_RIGHT

echo ""
echo "=== lib/moods.sh ==="
# Match the mood substring only — the surrounding face artwork is design-dependent.
assert_contains "thinking face"        "$(get_face thinking)" "._."
assert_contains "focused face"         "$(get_face focused)"  "-.-"
assert_contains "upset face"           "$(get_face upset)"    ">_<"
assert_contains "error face"           "$(get_face error)"    "x_x"
assert_contains "happy returns face"   "$(get_face happy)"    "ᵕ"
assert_contains "excited returns face" "$(get_face excited)"  "▽"
assert_contains "unknown mood → thinking" "$(get_face blorp)" "._."

echo ""
echo "=== lib/tools.sh ==="
assert_eq "Edit info"    "$(get_tool_info Edit)"       "🔧 focused left"
assert_eq "Bash info"    "$(get_tool_info Bash)"       "🪄 excited right"
assert_eq "Read info"    "$(get_tool_info Read)"       "📖 focused left"
assert_eq "Grep info"    "$(get_tool_info Grep)"       "🔍 focused left"
assert_eq "Agent info"   "$(get_tool_info Agent)"      "🤖 excited right"
assert_eq "TodoWrite"    "$(get_tool_info TodoWrite)"  "📋 focused left"
assert_eq "default info" "$(get_tool_info UnknownTool)" "none happy none"

print_summary
