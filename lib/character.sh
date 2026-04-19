#!/usr/bin/env bash
# character.sh — assemble grid character to stdout.
#
# Grid: 9 cells in a 3×3 layout. Each cell 5 cols × 3 rows, except the
# top-center column which splits into top (5×2) over face (5×1).
# Total: 15 cols × 9 rows.
#
# Caller sources characters/default.sh, optional user override, lib/moods.sh,
# then this file, then calls:
#   assemble_character <mood> [prop] [side]
# where side ∈ {left, right} when prop set; prop replaces left or right cell.

# _pad_cell <content> <width> <height>
# Right-pads each line to width chars and appends blank lines to height.
# Truncates with stderr warning if content exceeds height.
_pad_cell() {
  local content="$1" width="$2" height="$3"
  # Strip one trailing newline so `read -d ''` and `$(...)` capture
  # mechanisms produce the same line count.
  content="${content%$'\n'}"
  local -a lines=()
  local line
  while IFS= read -r line; do
    lines+=("$line")
  done <<< "$content"

  local n=${#lines[@]}
  if (( n > height )); then
    printf 'character.sh: cell exceeds height (%d > %d), truncating\n' "$n" "$height" >&2
    n=$height
  fi

  local i pad
  pad=$(printf '%*s' "$width" "")
  for ((i=0; i<n; i++)); do
    local l="${lines[$i]}"
    local clen
    clen=$(printf '%s' "$l" | wc -m | tr -d ' ')
    if (( clen < width )); then
      printf '%s%*s\n' "$l" $((width - clen)) ""
    else
      printf '%s\n' "$l"
    fi
  done
  while (( n < height )); do
    printf '%s\n' "$pad"
    n=$((n+1))
  done
}

# _prop_cell <prop>
# Render a 5×3 cell with a single emoji prop centered on the middle row.
# Visual width is 5 cells (2 spaces + 2-cell emoji + 1 space).
_prop_cell() {
  printf '     \n'
  printf '  %s \n' "$1"
  printf '     \n'
}

# _color_lines <content> <ansi-bg-code>
# When CLAUDESAY_DEBUG_COLORS is set, wrap each line with a background color
# escape so that each cell's footprint (including padding spaces) is visible.
_color_lines() {
  if [[ -z "${CLAUDESAY_DEBUG_COLORS:-}" ]]; then
    printf '%s' "$1"
    return
  fi
  local content="${1%$'\n'}" code="$2" line first=1
  while IFS= read -r line; do
    [[ $first -eq 1 ]] && first=0 || printf '\n'
    printf '\e[%sm%s\e[0m' "$code" "$line"
  done <<< "$content"
}

# _read_lines <var-name> <content>
# Bash-3.2-compatible: read multi-line content into a named array, one line per index.
_read_lines() {
  local var="$1" content="$2" line
  eval "$var=()"
  while IFS= read -r line; do
    eval "$var+=(\"\$line\")"
  done <<< "$content"
}

assemble_character() {
  local mood="${1:-happy}" prop="${2:-}" side="${3:-}"
  local face
  face=$(get_face "$mood")

  # Pad each cell to its target dimensions, then optionally wrap with a
  # debug background color (one per cell name) when CLAUDESAY_DEBUG_COLORS=1.
  local tl t tr fc lc bc rc bl bt br
  tl=$(_color_lines "$(_pad_cell "${CHAR_TOP_LEFT:-}"     5 3)"  41)
  t=$(_color_lines  "$(_pad_cell "${CHAR_TOP:-}"          5 2)"  42)
  tr=$(_color_lines "$(_pad_cell "${CHAR_TOP_RIGHT:-}"    5 3)"  43)
  fc=$(_color_lines "$(_pad_cell "$face"                  5 1)"  45)
  if [[ -n "$prop" && "$side" == "left" ]]; then
    lc=$(_color_lines "$(_prop_cell "$prop")"                    44)
  else
    lc=$(_color_lines "$(_pad_cell "${CHAR_LEFT:-}"       5 3)"  44)
  fi
  bc=$(_color_lines "$(_pad_cell "${CHAR_BODY:-}"         5 3)"  46)
  if [[ -n "$prop" && "$side" == "right" ]]; then
    rc=$(_color_lines "$(_prop_cell "$prop")"                    101)
  else
    rc=$(_color_lines "$(_pad_cell "${CHAR_RIGHT:-}"      5 3)"  101)
  fi
  bl=$(_color_lines "$(_pad_cell "${CHAR_BOTTOM_LEFT:-}"  5 3)"  102)
  bt=$(_color_lines "$(_pad_cell "${CHAR_BOTTOM:-}"       5 3)"  103)
  br=$(_color_lines "$(_pad_cell "${CHAR_BOTTOM_RIGHT:-}" 5 3)"  105)

  local -a TL T TR FC L B R BL BT BR
  _read_lines TL "$tl"
  _read_lines T  "$t"
  _read_lines TR "$tr"
  _read_lines FC "$fc"
  _read_lines L  "$lc"
  _read_lines B  "$bc"
  _read_lines R  "$rc"
  _read_lines BL "$bl"
  _read_lines BT "$bt"
  _read_lines BR "$br"

  printf '%s%s%s\n' "${TL[0]}" "${T[0]}"  "${TR[0]}"
  printf '%s%s%s\n' "${TL[1]}" "${T[1]}"  "${TR[1]}"
  printf '%s%s%s\n' "${TL[2]}" "${FC[0]}" "${TR[2]}"
  printf '%s%s%s\n' "${L[0]}"  "${B[0]}"  "${R[0]}"
  printf '%s%s%s\n' "${L[1]}"  "${B[1]}"  "${R[1]}"
  printf '%s%s%s\n' "${L[2]}"  "${B[2]}"  "${R[2]}"
  printf '%s%s%s\n' "${BL[0]}" "${BT[0]}" "${BR[0]}"
  printf '%s%s%s\n' "${BL[1]}" "${BT[1]}" "${BR[1]}"
  printf '%s%s%s\n' "${BL[2]}" "${BT[2]}" "${BR[2]}"
}
