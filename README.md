# claude-say

A Claude Code plugin that renders conversational replies as ASCII figure speech
bubbles in the terminal. Tool-use events show the figure holding a relevant
prop with a context-appropriate face expression.

## Requirements

- macOS or Linux (interactive terminal required — no CI/Docker support)
- `jq` installed (`brew install jq` / `apt install jq`)

## Install

```bash
# From the Claude Code plugin marketplace, or locally:
claude plugin install claude-say
```

## Usage

Toggle on or off naturally:

```
"turn on claude-say"
"disable the figure"
"is claude-say active?"
```

Or invoke the skill directly: `/claude-say`

## Character Customization

Create `~/.claude/claude-say/character.sh` and export any subset of these
variables — missing ones fall back to defaults:

```bash
CHAR_FACE_HAPPY_A="( ^ᵕ^  )"
CHAR_FACE_HAPPY_B="( ᵕ‿ᵕ  )"
CHAR_FACE_EXCITED_A="( ^▽^  )"
CHAR_FACE_EXCITED_B="( ≧▽≦  )"
CHAR_FACE_THINKING="( ._.  )"
CHAR_FACE_FOCUSED="( -.-  )"
CHAR_FACE_UPSET="( >_<  )"
CHAR_FACE_ERROR="( x_x  )"
CHAR_TOP="    /\\__/\\"
CHAR_BODY="( ,,,, )"
CHAR_HAND_LEFT="m"
CHAR_HAND_RIGHT="m"
CHAR_BOTTOM="    ||   ||
   (_)  (_)"
```

## Known Limitations

- The raw `<claude-say>` tag appears in the terminal scrollback before the
  bubble renders (Claude streams it before the Stop hook fires). This is
  accepted for v1.
- Figures do not render in CI, `--print` mode, or non-interactive SSH sessions.
- Per-turn reminder adds ~20 tokens per turn; conditional injection is a v2 goal.

## Compatibility

Stacks naturally with the caveman plugin. Caveman compresses the main response;
claude-say bubbles the separately-written tag. No conflict. `caveman-lite`
recommended as a complementary install.
