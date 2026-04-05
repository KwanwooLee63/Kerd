# Hooks & Kerd Interchange Format Design

**Date:** 2026-04-04
**Versions:** v0.19.0 (hooks + .active-modes schema), v0.20.0 (KIF)

## Overview

Four features inspired by patterns in shodh-memory, adapted to Kerd's skill-based architecture:

1. Stop hook — remind about uncommitted changes and active modes when session ends
2. SessionStart hook — surface stale state on same-machine resume (cross-machine handoff remains `/switch in`'s job)
3. PostToolUse hook — remind about next mode step when a skill completes (read-only, no state mutation)
4. Kerd Interchange Format (KIF) — portable project context export using TOON for LLM handoff, JSON for import

## Prerequisite: .active-modes Schema

Multiple skills write to `kivna/.active-modes` today with no unified format: `dian` writes `dian: execute`, `skriv` writes `skriv: active`, and `mode` writes a multiline block. Before hooks can safely read this file, all writers must agree on a schema.

### Canonical format

```
# Each skill gets one line: <skill>: <state>
# Mode gets an additional indented block for flow state

dian: execute
skriv: active
mode: greenfield (step 3 of 9)
  instruction: focus on pricing strategy only
  steps:
    1: /kerd:switch in | open session, set context [done]
    2: /superpowers:brainstorming | explore the problem space [done]
    3: /gsd:new-project | generate roadmap and phase breakdown [current]
    4: /gsd:discuss-phase 1 | clarify requirements for phase 1 [pending]
    5: /gsd:plan-phase 1 | implementation plan for phase 1 [pending]
    6: /gsd:execute-phase 1 | build phase 1 [pending]
    7: /gsd:discuss-phase 2 | clarify requirements for phase 2 [pending]
    8: /gsd:plan-phase 2 | implementation plan for phase 2 [pending]
    9: /kerd:switch out | close session [pending]
```

Steps use the format `<id>: <skill> [<args>] | <label> [<status>]`. The `id` is a stable integer assigned at mode start. The hook matches by step id (the `[current]` marker), not by skill name. The label is the human-readable description from the mode file. For repeated skills like `/gsd:discuss-phase`, the concrete arguments are resolved when the mode flow is built (the mode skill expands "repeat per phase" into concrete steps based on the roadmap).

### Rules

- One line per skill, format: `<skill>: <state>`
- Mode's `steps:` block is indented under its line, format: `<id>: <skill> [<args>] | <label> [<status>]`. Status markers: `[done]`, `[current]`, `[pending]`, `[skipped]`. The step id is stable and unique — the hook matches by id position, not skill name.
- Skills only write their own line(s). Never touch other skills' lines.
- Removing a line means the skill is inactive (e.g., `skriv: off` is not written, the line is just deleted)
- File is ephemeral (gitignored), not committed
- `/switch out` snapshots active mode state (mode name, step, instruction) into TODO.md's `### Context` block so cross-machine handoff works without the ephemeral file

### Migration

1. Add `kivna/.active-modes` to `.gitignore`
2. Update `dian`, `skriv`, `mode`, and `switch` skills to read/write the new format
3. Update `switch out` to snapshot mode state from `.active-modes` into TODO.md Context block before committing

This is part of v0.19.0, done before hooks ship.

## Hook Architecture

### Opt-in, collaborator-local

Hooks are opt-in, wired up by `/kerd:tend` (new category 9: hook hygiene). They live in `hooks/` at the plugin root. All three are prompt-based hooks (markdown files with instructions), not shell scripts.

```
hooks/
  stop.md          # Stop event
  session-start.md # SessionStart event
  skill-complete.md # PostToolUse event (matcher: Skill)
```

### Tend wiring (category 9)

Tend checks `.claude/settings.local.json` for the project (collaborator-local, not repo-tracked). If Kerd hooks aren't registered, it shows:

```
✗ Hook hygiene
  Current: no Kerd hooks configured
  Proposed: register Stop, SessionStart, PostToolUse hooks in settings.local.json
  Reason: session boundary reminders and mode progress tracking
```

User approves, tend writes the hook config entries to `.claude/settings.local.json` pointing to `${CLAUDE_PLUGIN_ROOT}/hooks/*.md`. Each collaborator opts in independently.

## Hook 1: Stop

**File:** `hooks/stop.md`
**Event:** `Stop`

Check for uncommitted changes (`git status --porcelain`) and active mode/skill state (`kivna/.active-modes`). If either exists, output a terse reminder. If neither, stay silent.

Output examples:

```
⚠ Uncommitted changes detected. Run /switch out to wrap up.
```

```
⚠ Mode active: greenfield (step 4 of 9). Uncommitted changes detected.
  Run /switch out to persist session state.
```

Constraints:
- Never runs switch automatically, just reminds
- Never blocks the session from ending
- 1-2 lines max, no tables
- Silent when there's nothing to say

## Hook 2: SessionStart

**File:** `hooks/session-start.md`
**Event:** `SessionStart`

Same-machine resume detection. On a different machine, `.active-modes` won't exist — the hook stays silent and `/switch in` handles cross-machine recovery (it reads mode state from TODO.md's Context block, where `/switch out` snapshots it).

Three checks:
1. `git fetch --dry-run` to see if local is behind remote
2. Read TODO.md `## Current Session` header line (date/status only, not full block)
3. Check `kivna/.active-modes` for interrupted mode (same-machine only — file is ephemeral)

Output examples:

```
📋 Local is behind remote (3 commits). Last session: 2026-04-02.
  Mode interrupted: greenfield (step 6 of 9).
  Run /switch in to sync and pick up.
```

```
📋 Last session: 2026-04-04 (current). No pending pulls.
```

Constraints:
- Fast: no file reads beyond TODO.md first 5 lines and `.active-modes`
- `git fetch` only, never `git pull`
- Doesn't duplicate `/switch in`, just flags that you should run it
- 1-3 lines max

## Hook 3: Mode Progress Reminder

**File:** `hooks/skill-complete.md`
**Event:** `PostToolUse` (matcher: `Skill`)

When a skill finishes and a mode is active, remind the user of their progress. **Read-only** — does not mutate `.active-modes`. The mode skill remains the sole writer of mode state.

Logic:
1. Check `kivna/.active-modes` — if no active mode, stay silent
2. Parse the completed skill invocation (skill name + args) from the tool use result
3. Check if it matches the `[current]` step's concrete command in the mode's `steps:` block
4. If match: output progress reminder with next step
5. If no match (off-script skill): stay silent

Output examples:

```
✓ Step 3 complete: /superpowers:brainstorming
  Instruction: focus on pricing strategy only
  Next: step 4 — /gsd:discuss-phase (capture decisions)
```

The **mode skill** is responsible for updating `.active-modes` when it processes the step completion. The hook only reads and reminds.

Constraints:
- Read-only: never writes to `.active-modes`
- Match uses the `[current]` step's skill reference from the steps block
- Off-script work ignored silently
- Resurfaces session instruction if set
- On last step: reminds that the mode is finishing (mode skill handles cleanup)

## Kerd Interchange Format (KIF)

### Purpose

Portable project context export. Primary consumer: another LLM picking up the conversation (TOON format, token-efficient). Secondary: another Kerd project importing decisions (JSON format, machine-parseable).

### File extensions

- `.kif.toon` — LLM handoff (export only, human/LLM readable)
- `.kif.json` — canonical import/export format (machine-parseable, lossless)

### Design principle

**Export both, import JSON only.** TOON is optimized for LLM consumption (40% fewer tokens). JSON is the canonical interchange format. `/kivna in` only parses `.kif.json`. This avoids the need for a TOON parser and keeps imports deterministic.

### Sections

| Section | Default | `--full` | Description |
|---------|---------|----------|-------------|
| `meta` | yes | yes | Project name, export date, Kerd version, source repo |
| `status` | yes | yes | Current status from vault Status.md |
| `backlog` | yes | yes | Active items from TODO.md (unchecked only) |
| `decisions` | yes | yes | Key decisions from last 3 session logs |
| `playbook` | no | yes | Playbook summary (tech stack, setup, architecture) |
| `architecture` | no | yes | Architecture decisions from vault |
| `memory` | no | yes | Project-type memory entries |
| `mode` | no | yes | Active mode state and progress |

### TOON format example (export only)

```toon
meta:
  project: Kerd
  exported: 2026-04-04
  version: 0.18.0
  repo: github.com/anthonymaley/Kerd

status:
  phase: active development
  summary: Trim PR under review, modes shipped in v0.17.1

backlog[4]{id,item,priority}:
  1,Merge trim PR after Kwan approves,high
  2,Add trim to maintain mode flow,medium
  3,Embed demo gif in README,low
  4,Run tend on other repos for vault migration,medium

decisions[2]{date,decision,reasoning}:
  2026-04-04,Version trim as 0.18.0,New skill = minor bump per semver rules
  2026-03-27,Remove plan doc from PR,Personal Windows paths not appropriate for upstream
```

### JSON format example (import + export)

```json
{
  "kif_version": "1.0",
  "meta": {
    "project": "Kerd",
    "exported": "2026-04-04",
    "version": "0.18.0",
    "repo": "github.com/anthonymaley/Kerd"
  },
  "status": {
    "phase": "active development",
    "summary": "Trim PR under review, modes shipped in v0.17.1"
  },
  "backlog": [
    {"id": 1, "item": "Merge trim PR after Kwan approves", "priority": "high"},
    {"id": 2, "item": "Add trim to maintain mode flow", "priority": "medium"}
  ],
  "decisions": [
    {"date": "2026-04-04", "decision": "Version trim as 0.18.0", "reasoning": "New skill = minor bump per semver rules"}
  ]
}
```

### TOON serialization approach

No runtime dependency. Claude generates TOON following the spec embedded in the kivna skill instructions, referencing the TOON grammar (https://github.com/toon-format/toon). JSON is standard `JSON.stringify` equivalent — Claude writes it directly.

Both files are always produced on export. Import only reads `.kif.json`.

### Commands

**Export:** `/kivna out` produces both `.kif.toon` and `.kif.json` in `kivna/output/`. Add `--full` for all sections.

**Import:** `/kivna in` detects `.kif.json` files in `kivna/input/`, parses them, presents each section for the user to accept or skip. `.kif.toon` files are ignored on import (inform user to use the `.kif.json` companion).

## Version Plan

- **v0.19.0** — `.active-modes` schema + hooks infrastructure + all three hooks + tend category 9
- **v0.20.0** — KIF format spec + kivna out/in updates

## Implementation Order

1. Add `kivna/.active-modes` to `.gitignore`
2. Define `.active-modes` schema, update `dian`, `skriv`, `mode`, `switch` skills to use it
3. Update `switch out` to snapshot mode state into TODO.md Context block
4. Create `hooks/` directory, write three hook markdown files
5. Add tend category 9 (hook hygiene) to tend skill
6. Test hooks end-to-end (stop, session-start, skill-complete)
7. Write KIF JSON schema as reference doc
8. Update kivna skill: `/kivna out` produces `.kif.toon` + `.kif.json`, `/kivna in` consumes `.kif.json`

## Review Resolution Log

Issues raised during design review, round 1 (2026-04-04):

1. **P1: PostToolUse can't match steps** — Resolved: hook downgraded to read-only reminder. Mode skill remains sole writer of `.active-modes`. Added `steps:` block to schema so hook can read the current step's skill reference.
2. **P1: .active-modes has no unified schema** — Resolved: canonical schema defined as prerequisite (see above). All skills updated to use it before hooks ship.
3. **P1: TOON import has no parser** — Resolved: JSON is the canonical import format. TOON is export-only for LLM consumption. No TOON parser needed.
4. **P2: Hook wiring location ambiguous** — Resolved: tend writes to `.claude/settings.local.json` (collaborator-local), not repo-tracked settings.

Issues raised during design review, round 2 (2026-04-04):

5. **P1: Parameterized/repeated steps not uniquely identifiable** — Resolved: steps now use format `<id>: <skill> [<args>] | <label> [<status>]`. Hook matches by step id (the `[current]` marker), not skill name. Mode skill expands repeated steps into concrete entries with arguments at flow setup time.
6. **P2: SessionStart implies cross-machine but .active-modes is ephemeral** — Resolved: narrowed SessionStart to same-machine resume. `/switch out` snapshots mode state into TODO.md Context block for cross-machine handoff. `/switch in` reads it from there.
7. **P2: .active-modes not in .gitignore** — Resolved: added to `.gitignore` as implementation step 1. Also noted in schema rules.

## PostToolUse Payload Shape (confirmed 2026-04-04)

Live smoke test confirmed the PostToolUse stdin payload is a full envelope, not just `tool_input`:

```json
{
  "session_id": "<uuid>",
  "transcript_path": "<path to session .jsonl>",
  "cwd": "<working directory>",
  "permission_mode": "<e.g. bypassPermissions>",
  "hook_event_name": "PostToolUse",
  "tool_name": "Skill",
  "tool_input": {"skill": "kerd:tend"},
  "tool_response": {"success": true, "commandName": "kerd:tend"},
  "tool_use_id": "<tool use id>"
}
```

The hook's sed parser extracts `"skill"` from anywhere in the JSON, so it handles this envelope correctly without needing to unwrap `tool_input` first. The `tool_response` field is also available but not currently used.
