#!/usr/bin/env bash
# Default ASCII character body parts. Override any variable in
# ~/.claude/claudesay/character.sh — missing vars fall back here.
#
# Grid layout (15 cols × 9 rows total):
#
#   ┌─────┬─────┬─────┐
#   │ TL  │  T  │ TR  │  rows 0-1  (T is 5×2)
#   │     │ FACE│     │  row  2    (FACE is 5×1)
#   ├─────┼─────┼─────┤
#   │  L  │  B  │  R  │  rows 3-5  (each 5×3)
#   ├─────┼─────┼─────┤
#   │ BL  │ BT  │ BR  │  rows 6-8  (each 5×3)
#   └─────┴─────┴─────┘
#
# Each cell is right-padded to 5 cols and bottom-padded to its row count
# automatically — short cells are forgiving. Trailing blank lines can be
# omitted; leading blank lines must be written. Run `bin/preview.sh` to iterate.

# ── Faces (5 cols × 1 row, mood-specific) ────────────────────────────────────
CHAR_FACE_HAPPY_A="( ^ᵕ^"
CHAR_FACE_HAPPY_B="( ᵕ‿ᵕ"
CHAR_FACE_EXCITED_A="( ^▽^"
CHAR_FACE_EXCITED_B="( ≧▽≦"
CHAR_FACE_THINKING="( ._."
CHAR_FACE_FOCUSED="( -.-"
CHAR_FACE_UPSET="( >_<"
CHAR_FACE_ERROR="( x_x"

# ── Top row (rows 0-2) ───────────────────────────────────────────────────────
CHAR_TOP_LEFT="

     "

CHAR_TOP="
 /\\__"

CHAR_TOP_RIGHT="
/\\
  )"

# ── Middle row (rows 3-5) ────────────────────────────────────────────────────
CHAR_LEFT="
   m"

CHAR_BODY=" ,,,,
(,,,)
"

CHAR_RIGHT="
 m"

# ── Bottom row (rows 6-8) ────────────────────────────────────────────────────
CHAR_BOTTOM_LEFT="
    |
   (_"

CHAR_BOTTOM="
|   |
)  (_"

CHAR_BOTTOM_RIGHT="
|\`~~>
)"
