#!/usr/bin/env bash
set -euo pipefail

FLAG="${CLAUDE_PROJECT_DIR}/.claude/.claudesay-active"
[[ -f "$FLAG" ]] || exit 0

PROTOCOL='<claudesay-protocol>
When giving a conversational reply, append this tag at the very end:
<claudesay mood="MOOD">First-person summary of what I just did or said</claudesay>

Available moods: happy, excited, thinking, focused, upset, error
- happy / excited → success outcomes (rotate between them for variety)
- thinking        → in-progress or uncertain
- focused         → working, running something
- upset           → warning or partial failure
- error           → actual failure

Rules:
- Up to ~120 chars. Bubble wraps at 45/line, so 1-2 short sentences.
- First-person voice ("I fixed the flaky test and re-ran CI", not "Fixed the flaky test").
  The character speaks AS the agent.
- Cover the whole turn, not just the last sentence — if multiple things happened,
  mention them briefly ("I read the hooks and drafted a plan.").
- Do NOT add the tag to: pure code blocks, diffs, long technical output, tool-only responses.
- Only chatty, conversational replies get a bubble.
</claudesay-protocol>'

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":%s}}\n' \
  "$(printf '%s' "$PROTOCOL" | jq -Rs .)"
