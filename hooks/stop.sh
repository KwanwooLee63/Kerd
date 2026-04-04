#!/bin/bash
# Kerd Stop Hook
# Reminds about uncommitted changes and active modes when a session ends.
# Silent when there's nothing to report.
set -euo pipefail

cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || exit 0

messages=()

# Check for uncommitted changes
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
  messages+=("uncommitted changes detected")
fi

# Check for active mode
if [ -f "kivna/.active-modes" ]; then
  mode_line=$(grep '^mode:' "kivna/.active-modes" 2>/dev/null || true)
  if [ -n "$mode_line" ]; then
    mode_state=$(echo "$mode_line" | sed 's/^mode: //')
    messages+=("mode active: $mode_state")
  fi

  # Check for active dian
  dian_line=$(grep '^dian:' "kivna/.active-modes" 2>/dev/null || true)
  if [ -n "$dian_line" ]; then
    dian_state=$(echo "$dian_line" | sed 's/^dian: //')
    messages+=("dian: $dian_state")
  fi
fi

# If nothing to report, stay silent
if [ ${#messages[@]} -eq 0 ]; then
  exit 0
fi

# Build output
output="⚠ "
output+=$(printf '%s. ' "${messages[@]}" | sed 's/\. $//')
output+=". Run /switch out to wrap up."

echo "$output"
