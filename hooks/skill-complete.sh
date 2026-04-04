#!/bin/bash
# Kerd PostToolUse Hook (Skill matcher)
# Read-only: reminds about mode progress when a skill completes.
# Does NOT mutate .active-modes. The mode skill handles state transitions.
# Silent when no mode is active or the skill doesn't match the current step.
set -euo pipefail

cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || exit 0

# Only proceed if a mode is active
[ -f "kivna/.active-modes" ] || exit 0

mode_line=$(grep '^mode:' "kivna/.active-modes" 2>/dev/null || true)
[ -n "$mode_line" ] || exit 0

# Read the completed skill from stdin (PostToolUse provides tool_input)
input=$(cat)
skill_name=$(echo "$input" | jq -r '.tool_input.skill // empty' 2>/dev/null || true)
[ -n "$skill_name" ] || exit 0

# Find the [current] step
current_step=$(grep '\[current\]' "kivna/.active-modes" 2>/dev/null || true)
[ -n "$current_step" ] || exit 0

# Extract skill reference from current step (format: "N: /plugin:skill [args] | label [current]")
current_skill=$(echo "$current_step" | sed -E 's/^[[:space:]]*[0-9]+:[[:space:]]*//' | sed -E 's/[[:space:]]*\|.*$//' | xargs)

# Check if completed skill matches (compare skill name, ignoring leading /)
current_skill_clean=$(echo "$current_skill" | sed 's|^/||')

if [ "$skill_name" != "$current_skill_clean" ] && ! echo "$current_skill_clean" | grep -q "^${skill_name}"; then
  # No match, stay silent
  exit 0
fi

# Extract mode state
mode_state=$(echo "$mode_line" | sed 's/^mode: //')
instruction=$(grep '^  instruction:' "kivna/.active-modes" 2>/dev/null | sed 's/^  instruction: //' || true)

# Find next pending step
next_step=$(grep '\[pending\]' "kivna/.active-modes" 2>/dev/null | head -1 || true)

if [ -n "$next_step" ]; then
  # Extract step details
  next_id=$(echo "$next_step" | sed -E 's/^[[:space:]]*([0-9]+):.*/\1/')
  next_label=$(echo "$next_step" | sed -E 's/^[^|]*\|[[:space:]]*//' | sed -E 's/[[:space:]]*\[pending\]//')
  next_skill=$(echo "$next_step" | sed -E 's/^[[:space:]]*[0-9]+:[[:space:]]*//' | sed -E 's/[[:space:]]*\|.*$//' | xargs)

  output="✓ Step complete: /$current_skill_clean"
  if [ -n "$instruction" ]; then
    output+="\n  Instruction: $instruction"
  fi
  output+="\n  Next: step $next_id — $next_skill ($next_label)"
else
  # Last step
  output="✓ Final step complete: /$current_skill_clean"
  output+="\n  Mode finishing: $mode_state"
fi

echo -e "$output"
