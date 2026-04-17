# claude-say Design Spec
_2026-04-17_

## Overview

`claude-say` is a Claude Code plugin that renders Claude's conversational replies as ASCII figure speech bubbles in the terminal. Tool-use events show the figure holding a relevant prop (wrench, magnifier, etc.) with a context-appropriate face expression. The figure is expressive, dynamic, and customizable.

## Goals

- Make Claude Code interactions feel more alive and playful without interfering with technical output
- Show tool-state context visually while tools are running
- Keep the plugin zero-dependency (bash only) and toggleable per-session
- Support user-defined characters via a simple override file

## Out of Scope (v1)

- Agent teams multi-figure mode (nice-to-have, future)
- Windows support

---

## Architecture

### Plugin Structure

```
claude-say/
├── .claude-plugin/
│   └── plugin.json              # Required manifest
├── hooks/
│   ├── hooks.json               # Hook event registration
│   └── scripts/
│       ├── session-start.sh     # Inject protocol at session open
│       ├── prompt-submit.sh     # Reinforce tag format per turn
│       ├── pre-tool-use.sh      # Render tool-state figure
│       └── stop.sh              # Parse <claude-say> → render bubble
├── lib/
│   ├── render.sh                # Bubble + figure renderer (core)
│   ├── moods.sh                 # Mood → face expression map
│   └── tools.sh                 # Tool name → prop + mood map
├── characters/
│   └── default.sh               # Default ASCII figure body parts
├── skills/
│   └── claude-say/
│       └── SKILL.md             # /claude-say on/off toggle skill
└── README.md
```

All intra-plugin paths use `${CLAUDE_PLUGIN_ROOT}` for portability.

### plugin.json

```json
{
  "name": "claude-say",
  "version": "1.0.0",
  "description": "Renders Claude replies as ASCII figure speech bubbles",
  "license": "MIT",
  "keywords": ["ascii", "companion", "tui", "fun"]
}
```

### hooks/hooks.json

```json
{
  "SessionStart":      [{ "hooks": [{ "type": "command", "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/session-start.sh" }] }],
  "UserPromptSubmit":  [{ "hooks": [{ "type": "command", "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/prompt-submit.sh" }] }],
  "PreToolUse":        [{ "hooks": [{ "type": "command", "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/pre-tool-use.sh" }] }],
  "Stop":              [{ "hooks": [{ "type": "command", "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/stop.sh" }] }]
}
```

---

## On/Off Switch

State is held in a flag file: `~/.claude/.claude-say-active`.

- **Exists** → figure mode on
- **Absent** → figure mode off, all hooks exit immediately (zero overhead)

The `/claude-say` skill toggles the flag and confirms with a brief figure preview.

---

## Data Flow

```
Session opens
  └─▶ session-start.sh   flag? → print <claude-say-protocol> block into context

User sends message
  └─▶ prompt-submit.sh   flag? → echo one-line reminder to stdout (injected as context)

Claude calls a tool
  └─▶ pre-tool-use.sh    read tool_name → map to (prop, mood) → render figure to terminal

Claude finishes turn
  └─▶ stop.sh            read transcript → extract last assistant message
                          grep <claude-say mood="X">...</claude-say>
                          found?  → render bubble + figure
                          absent? → silent exit (no duplicate output)
```

---

## The `<claude-say>` Protocol

`session-start.sh` injects this instruction block when the flag exists:

```
<claude-say-protocol>
When giving a conversational reply, append this tag at the very end:
<claude-say mood="MOOD">Brief 1-line summary of what you did or said</claude-say>

Available moods: happy, excited, thinking, focused, upset, error
- happy / excited → success outcomes (rotate between them for variety)
- thinking        → in-progress or uncertain
- focused         → working, running something
- upset           → warning or partial failure
- error           → actual failure

Rules:
- Keep message under 60 chars
- Do NOT add the tag to: pure code blocks, diffs, long technical output, tool-only responses
- Only chatty, conversational replies get a bubble
</claude-say-protocol>
```

`prompt-submit.sh` echoes a one-liner reminder with every user turn so Claude never drifts:
```
[claude-say: end chatty reply with <claude-say mood="X">summary</claude-say>]
```

---

## Rendering

### render.sh Interface

```bash
render.sh "<message>" "<mood>" ["<prop>" "<side>"]
```

`prop` and `side` are optional — omit both for chat-reply bubbles (Stop hook). `pre-tool-use.sh` passes all four.

1. Sources `moods.sh` → resolves face string for mood
2. Sources `tools.sh` → resolves prop string and side
3. Sources user character override (`~/.claude/claude-say/character.sh`) or `characters/default.sh`
4. Wraps message text at 45 chars
5. Assembles body line: `{left_or_prop}( body ){right_or_prop}` based on side
6. Renders Unicode bubble + figure body to stdout with ANSI colors

**Body line assembly:**

```bash
if [[ -n "$prop" && "$side" == "left" ]]; then
  body_line="${prop}=( body )${CHAR_HAND_RIGHT}"   # e.g. 📖=( ,,,, )m
elif [[ -n "$prop" && "$side" == "right" ]]; then
  body_line="${CHAR_HAND_LEFT}( body )=${prop}"    # e.g. m( ,,,, )=🪄
else
  body_line="${CHAR_HAND_LEFT}( body )${CHAR_HAND_RIGHT}"  # e.g. m( ,,,, )m
fi
```

### Mood Expressions

| Mood      | Face       | When used                        |
|-----------|------------|----------------------------------|
| happy-a   | `( ^ᵕ^  )` | Normal success (variant A)       |
| happy-b   | `( ᵕ‿ᵕ  )` | Normal success (variant B)       |
| excited   | `( ^▽^  )` | Big win                          |
| excited-b | `( ≧▽≦  )` | Very excited                     |
| thinking  | `( ._.  )` | In progress / uncertain          |
| focused   | `( -.-  )` | Running a tool                   |
| upset     | `( >_<  )` | Warning or partial failure       |
| error     | `( x_x  )` | Actual error                     |

Positive moods rotate between variants on each render to avoid repetition.

### Tool Props (PreToolUse)

Each tool entry has a `side` field (`left`/`right`) controlling which hand holds the prop. "Reaching out" tools (searching, reading, fetching) use the left hand; "doing" tools (editing, running, spawning) use the right.

| Tool(s)              | Prop          | Mood     | Side  |
|----------------------|---------------|----------|-------|
| Edit, Write          | 🔧 wrench     | focused  | left  |
| Bash                 | 🪄 magic wand | focused  | right |
| Grep, Glob           | 🔍 magnifier  | thinking | left  |
| Read                 | 📖 book       | thinking | left  |
| WebFetch, WebSearch  | 📡 antenna    | thinking | right |
| Agent (spawn)        | 🤖 buddy      | excited  | right |
| TodoWrite            | 📋 clipboard  | focused  | left  |
| default              | (none)        | focused  | —     |

### Rendered Output Examples

**Chat reply (Stop hook):**
```
...Claude's full response above...
<claude-say mood="excited">All 3 tests pass now!</claude-say>

 ╭────────────────────────────────╮
 │   All 3 tests pass now!        │
 ╰────╮───────────────────────────╯
      │                 
    /\__/\
   ( ≧▽≦  )
  m( ,,,, )m
    ||   ||`~~>
   (_)  (_)
```

**Tool state (PreToolUse), prop on right (Edit):**
```
 ╭─────────────────────────────────╮
 │   Edit → src/utils.py           │
 ╰────╮────────────────────────────╯
      │
    /\__/\
   ( -.-  )
🔧=( ,,,, )m
    ||   ||`~~>
   (_)  (_)
```

**Tool state (PreToolUse), prop on left (Read):**
```
 ╭─────────────────────────────────╮
 │   Read → src/utils.py           │
 ╰────╮────────────────────────────╯
      │
    /\__/\
   ( ._.  )
📖=( ,,,, )m
    ||   ||`~~>
   (_)  (_)
```

---

## Character Customization

Users create `~/.claude/claude-say/character.sh` exporting these variables:

```bash
CHAR_FACE_HAPPY="( ^ᵕ^  )"
CHAR_FACE_EXCITED="( ^▽^  )"
CHAR_FACE_THINKING="( ._.  )"
CHAR_FACE_FOCUSED="( -.-  )"
CHAR_FACE_UPSET="( >_<  )"
CHAR_FACE_ERROR="( x_x  )"
CHAR_TOP="    /\__/\\" # the top of the character, above face
CHAR_BODY="( ,,,, )" # the body of the character, below face
CHAR_HAND_LEFT="m"           # left-side hand
CHAR_HAND_RIGHT="m"          # right-side hand
CHAR_BOTTOM="    ||   ||\`~~>\n   (_)  (_)" # the rest of the character, can have multiple lines
```

`render.sh` sources the user file first; any missing variable falls back to `characters/default.sh`.

---

## Edge Cases

| Scenario | Behaviour |
|---|---|
| Claude omits `<claude-say>` tag | stop.sh exits silently — no duplicate output |
| Multiple tags in one response | Take the last one |
| Tool input path > 50 chars | Truncate with `…` |
| Message > 45 chars wide | Wrap to multiple bubble lines |
| Custom character missing a mood | Fall back to default figure expression |
| Custom character missing `CHAR_HAND_LEFT` or `CHAR_HAND_RIGHT` | Fall back to `m` for each |
| Tool entry has no `side` or side is `—` | No prop shown, both hands rendered normally |
| Flag absent | All hooks exit at line 2 — zero overhead |

---

## Caveman Compatibility

`claude-say` stacks naturally with the caveman plugin. Caveman compresses the main response body; `claude-say` bubbles the separately-written summary tag. No conflict. README recommends `caveman-lite` as a complementary install.
