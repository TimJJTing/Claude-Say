#!/usr/bin/env bash
set -euo pipefail

FLAG="${CLAUDE_PROJECT_DIR}/.claude/.claudesay-active"
[[ -f "$FLAG" ]] || exit 0

PROTOCOL='<claudesay-protocol>
When giving a conversational reply, append this tag at the very end:
<claudesay mood="MOOD">Re-express the turn content directly</claudesay>

Available moods: happy, excited, thinking, focused, upset, error
- happy / excited → success outcomes (rotate between them for variety)
- thinking        → in-progress or uncertain
- focused         → working, running something
- upset           → warning or partial failure
- error           → actual failure

Rules:
- Keep it short — a few sentences at most. Bubble wraps at 45/line.
- Friendly, natural tone. Use active voice and pronouns freely — "I", "you", "we".
  No passive constructions ("it was done", "the test was fixed").
  No expression verbs ("I said", "I asked", "I mentioned", "I explained") — re-express
  the content directly instead: if you asked a question, write the question; if you
  stated a fact, state it.
- Cover the whole turn, not just the last sentence — if multiple things happened,
  mention them briefly.
- Do NOT add the tag to: pure code blocks, diffs, long technical output, tool-only responses.
- Only chatty, conversational replies get a bubble.
</claudesay-protocol>'

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":%s}}\n' \
  "$(printf '%s' "$PROTOCOL" | jq -Rs .)"
