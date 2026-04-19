#!/usr/bin/env bash
# render.sh — write speech bubble + ASCII character to /dev/tty (or CLAUDE_SAY_TTY).
# Usage: render.sh "<message>" "<mood>" ["<prop>" "<side>"]
set -euo pipefail

MESSAGE="${1:-}"
MOOD="${2:-happy}"
PROP="${3:-}"
SIDE="${4:-}"

[[ -n "$MESSAGE" ]] || exit 0

TTY="${CLAUDE_SAY_TTY:-/dev/tty}"
# Guard: if writing to /dev/tty (non-interactive), skip silently.
# For any TTY path, also skip if it is not writable (covers CI and bad paths).
if [[ "$TTY" == "/dev/tty" ]] && ! [[ -w /dev/tty ]]; then
  exit 0
fi
if [[ "$TTY" != "/dev/tty" ]] && ! { >> "$TTY"; } 2>/dev/null; then
  exit 0
fi

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# Load defaults, then user override (missing vars in override fall back silently)
source "${PLUGIN_ROOT}/characters/default.sh"
USER_CHAR="${HOME}/.claude/claudesay/character.sh"
[[ -f "$USER_CHAR" ]] && source "$USER_CHAR"

source "${PLUGIN_ROOT}/lib/moods.sh"
source "${PLUGIN_ROOT}/lib/character.sh"

# Wrap message at 45 chars (bash 3.2-compatible: no mapfile, use herestring)
LINES=()
while IFS= read -r l; do
  LINES+=("$l")
done <<< "$(printf '%s' "$MESSAGE" | fold -sw 45)"

# Find the longest display line (byte length — acceptable for ASCII-BMP messages)
MAX=0
for l in "${LINES[@]+"${LINES[@]}"}"; do
  clen=$(printf '%s' "$l" | wc -m | tr -d ' ')
  [[ $clen -gt $MAX ]] && MAX=$clen || true
done

# Build bubble border strings. Bubble tail ┬ lands at col 7 (character grid centerline).
INNER=$(( MAX + 2 < 9 ? 9 : MAX + 2 ))  # 1-space pad each side; min 9 so RIGHT_REST >= 3
TOP_BORDER=$(printf '─%.0s' $(seq 1 $INNER))
LEFT5=$(printf '─%.0s' $(seq 1 5))
RIGHT_REST=$(printf '─%.0s' $(seq 1 $((INNER - 6))))

CHAR_OUTPUT=$(assemble_character "$MOOD" "$PROP" "$SIDE")

{
  printf '\n'
  printf ' ╭%s╮\n' "$TOP_BORDER"
  for l in "${LINES[@]+"${LINES[@]}"}"; do
    blen=$(printf '%s' "$l" | wc -c | tr -d ' ')
    clen=$(printf '%s' "$l" | wc -m | tr -d ' ')
    printf ' │ %-*s │\n' "$(( INNER - 2 + blen - clen ))" "$l"
  done
  printf ' ╰%s┬%s╯\n' "$LEFT5" "$RIGHT_REST"
  printf '       │\n'
  printf '%s\n' "$CHAR_OUTPUT"
} > "$TTY"
