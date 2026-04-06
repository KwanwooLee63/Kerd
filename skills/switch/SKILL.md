---
name: switch
description: "Use when the user says 'switch', 'switching machines', 'wrapping up', 'picking up', 'handoff', or needs to cleanly leave or arrive on a machine. Handles all git boundary operations (pull, push, commit of session state). Supports 'light' modifier to skip vault and reflection, or 'low' modifier for minimum viable handoff on tight token budgets."
---

# Switch (Machine Handoff)

Clean handoff between machines. Switch owns all git boundary operations: pull, push, commit of session state. No other skill should do these things.

## Usage

`/kerd:switch out` leaving this machine (full)
`/kerd:switch out light` leaving this machine (skip vault, reflection, progress tracking)
`/kerd:switch out low` leaving this machine (minimum viable handoff, tight token budget)
`/kerd:switch in` arriving on a new machine (full)
`/kerd:switch in light` arriving on a new machine (skip vault, smoke test)
`/kerd:switch in low` arriving on a new machine (minimum viable pickup, tight token budget)

If no argument is given, check for uncommitted changes. If changes exist, assume `out`. If clean, assume `in`.

### Modifier progression

| | Full | Light | Low |
|---|---|---|---|
| TODO.md update | Full session block | Full session block | Brief: 3-5 lines max |
| Session log | Full template (all sections) | Full template | Skeleton: What Was Done + What's Next only |
| Vault update | Yes (kivna save) | Skip | Skip |
| Reflection/gotchas | Yes | Skip | Skip (unless something critical) |
| Progress tracking | Yes | Skip | Skip |
| Untracked file triage | Yes | Yes | Skip (unless obviously risky files like .env) |
| Pre-commit summary | Full with evidence | Full with evidence | One-line: "Committing N files: [list]" |
| Trim suggestion | Yes | No | No |
| Final confirmation | Evidence-cited | Evidence-cited | One-line: commit hash + push target |
| **Switch-in** | | | |
| Pull | Yes | Yes | Yes |
| Handoff verification | Yes | Yes | Skip |
| Smoke test | Yes | Skip | Skip |
| Read TODO.md | Full | Full | Current Session block only |
| Read vault | Yes | Skip | Skip |
| Read session logs | Newest full, older skimmed | Newest full, older skimmed | Latest What's Next only |
| Read progress | Yes | Skip | Skip |
| Check active modes | Yes | Yes | Yes |
| Offer dian | Yes | Yes | Skip |

## Switch Out (Leaving This Machine)

Wrap up everything so the next machine can pick up cold.

### 1. Write session state to TODO.md

Create TODO.md if it doesn't exist. Update the `## Current Session` block.

**Full/light:** Include what was done (check off completed items), what's in progress, what's next, and any context that would be lost (decisions, things tried, open questions).

**Low:** Keep it to 3-5 lines max. One line per: what was done, what's next, any critical context. Skip detailed item-by-item checkoffs.

**Mode snapshot:** If `kivna/.active-modes` contains a mode block, snapshot the mode state into the `### Context` section of TODO.md so cross-machine handoff works without the ephemeral file. Include: mode name, current step number and total, session instruction (if any), and the full steps list with status markers. Example:

```
### Context
- Mode active: greenfield (step 4 of 9)
  Instruction: focus on pricing strategy only
  Steps: 1 done, 2 done, 3 done, 4 current, 5-9 pending
```

### 2. Write session log

Create `kivna/sessions/YYYY-MM-DD.md` (or append if one already exists for today).

If appending to an existing file for today (multiple sessions), add a `---` separator and a new section with a time or sequence number.

**Full/light template:**

```
# Session YYYY-MM-DD

**Machine:** [hostname from `hostname`]
**Branch:** [current branch name, e.g. `main` or `feat/trim-skill`]
**Tracking:** [upstream tracking status, e.g. `origin/main (up to date)` or `origin/feat/trim-skill (3 ahead)`]

## What Was Done
[Concrete list of what was accomplished. Be specific: files created, features built, bugs fixed, decisions made.]

## Key Decisions
[Any decisions made during the session with brief reasoning. Skip if none.]

## Commits
[List commit hashes and messages from this session]

## Gotchas
[Things that broke unexpectedly, non-obvious behavior, edge cases discovered. These are traps the next session (or the next person) should know about. Skip if none, but actually think about it first.]

## Insights
[Observations about the codebase, patterns discovered, things that surprised you. Skip if none.]

## What's Next
[What the next session should pick up]
```

**Low template:** Skeleton only. Two sections, no metadata headers.

```
# Session YYYY-MM-DD

## What Was Done
[Bullet list, 3-5 items max]

## What's Next
[1-2 lines]
```

### 3. Update the vault

**Skip this step if `light` or `low` modifier is set.**

If a `/kerd:dian` session was active, close-out should have already called `/kerd:kivna save`. Verify vault `[Name] Status.md` reflects this session and move on. If no `/kerd:dian` session was running (quick switch without formal session), call `/kerd:kivna save` now. This updates Status.md and proposes updates to other vault files, each with user approval.

### 4. Update progress tracking

**Skip this step if `light` or `low` modifier is set.**

If progress tracking exists (check for `docs/project/progress.md`, `progress.md`, or similar), update it.

### 5. Reflect and capture learnings

**Skip this step if `light` or `low` modifier is set** — with one exception: if something genuinely critical broke or a dangerous gotcha was discovered during the session, capture it even in low mode. One line in the session log is enough. The bar for "critical" in low mode is: would the next person waste significant time without this information?

Before committing, reflect on the session:

- **What broke unexpectedly?** Any gotchas, edge cases, or non-obvious behavior discovered? These go in the session log `## Gotchas` section AND in `docs/playbook.md` Gotchas section (so they survive beyond session logs).
- **What patterns emerged?** Any recurring problems, useful approaches, or workflow improvements worth codifying?
- **What should be remembered?** Best practices discovered, conventions that worked well or didn't.
- **What would make the next session better?** Anything about the project, tooling, or workflow that should be adjusted.

Write actionable learnings to the appropriate place:
- **Gotchas** → add to `docs/playbook.md` Gotchas section (duplicates what's in the session log, but the playbook is the living reference; session logs are archives)
- **Project conventions and enforcement rules** → add to `CLAUDE.md` (so they're enforced in future sessions)
- **Conventions and patterns** → flag for the appropriate vault file (Architecture Decisions, Positioning Contract, etc.), these get proposed during the `/kerd:kivna save` step

Skip this step if the session was trivial (quick fix, single file change). But for any session with meaningful work, take the time. Compounding small improvements across sessions is how projects stay healthy.

### 6. Pre-commit summary and triage

Before staging anything, run `git status` to see the actual state of the working tree.

**Full/light:** Present a detailed summary, triage untracked files, suggest trim if completed plan docs exist.

```
About to commit:
  Modified:  TODO.md, docs/playbook.md, kivna/sessions/2026-04-05.md
  Untracked: [any new files created this session]
  
  Untracked (not part of this session):
    docs/demo-mode.gif
    docs/demo-mode.mp4
```

**Untracked file triage (full/light only):** If there are untracked files that were NOT created by this session (they existed before switch-out started), surface each one and ask: commit it, add to `.gitignore`, or leave for later? Do not silently ignore untracked files. Do not batch-stage with `git add -A`. Stage files by name.

**Trim suggestion (full only):** If `docs/plans/` or `docs/` contains spec, plan, or design docs whose features are marked complete in TODO.md or playbook, suggest: "Completed plan docs detected. Consider `/kerd:trim` to archive them." This is a suggestion, not a required step.

Wait for the user to confirm what should be committed before staging.

**Low:** One-line summary only. Skip triage unless an obviously risky file is untracked (`.env`, credentials, secrets). Skip trim suggestion. Stage session files (TODO.md, session log) without detailed confirmation.

```
Committing: TODO.md, kivna/sessions/2026-04-05.md
```

### 7. Stage and commit

Stage the confirmed files by name. Use a descriptive commit message.

### 8. Push

Push to remote. Verify the push succeeds.

### 9. Verify and confirm

Run `git status` and `git log --oneline -1` fresh. Read the output. Report with evidence:

```
Pushed: [commit-hash] [commit-message]
  → origin/[branch] ([N files], [session log], [doc updates])
  Tree: clean (0 modified, 0 staged, N untracked)
  Next session: [what to pick up]
```

If the tree is not clean, report what remains and why (e.g., "3 untracked files left per triage decision"). If the push failed, stop and surface the error.

If `light` modifier was used, note: "Light handoff: vault and reflection skipped."

**Low:** Compress to one line:

```
Pushed: [commit-hash] → origin/[branch]. Next: [what to pick up]
```

## Switch In (Arriving on This Machine)

Pick up where the other machine left off.

### 1. Pull

`git pull`. If there are conflicts, resolve them before proceeding.

### 2. Handoff contract verification

**Skip this step if `low` modifier is set.**

After pulling, verify the outgoing machine completed its handoff. Check:

- Does `TODO.md` exist and have a `## Current Session` block?
- Does the latest file in `kivna/sessions/` have a `## What's Next` section?

If both are present, proceed normally. If either is missing, flag it explicitly:

```
⚠ Partial handoff detected:
  - TODO.md missing ## Current Session block
  - Latest session log missing ## What's Next
  
  Proceeding with available context. Some state may be missing.
```

Do not pretend the pickup is clean when the handoff was incomplete.

### 3. Smoke test

**Skip this step if `light` or `low` modifier is set.**

If the project has a test command (check `package.json` scripts, `Makefile`, `pyproject.toml`, or similar), run it. If tests fail, report the failures in the summary. The user should know the state of the codebase before planning new work. If no test command exists, skip this step.

### 4. Read TODO.md

Focus on the `## Current Session` block. This is where the last session left off.

**Low:** Read only the `## Current Session` block. Do not read the Backlog or any other sections.

### 5. Read vault

**Skip this step if `light` or `low` modifier is set.**

Discover the vault path using `kivna/vault.json` or convention (see `/kerd:kivna` vault discovery). Read `[Name] Status.md` for where the project stands. Read the MOC (`[Name].md`) to discover what other vault files exist and read any that are relevant (Architecture Decisions, Playbook, etc.).

### 6. Check session logs

**Full/light:** Read the most recent file in `kivna/sessions/` in full. For older session logs (if any exist), skim only the `## What's Next`, `## Key Decisions`, and `## Gotchas` sections to find the pickup point and any unresolved issues. Do not read older logs in full unless the user asks.

**Low:** Read only the `## What's Next` section of the latest session log. Skip everything else.

### 7. Read progress tracking

**Skip this step if `light` or `low` modifier is set.**

If progress tracking exists, read it.

### 8. Check active modes

Check two sources for mode state:

1. **`kivna/.active-modes`** (same-machine resume): if it exists and is non-empty, read it and report active modes.
2. **`TODO.md` Context block** (cross-machine handoff): if `.active-modes` doesn't exist or is empty, check TODO.md's `### Context` section for a mode snapshot. If found, report it and offer to restore it to `.active-modes`.

Report any active modes in the summary (e.g., "**Active modes:** `greenfield (step 4 of 9)`"). If neither source has mode state, skip this. Don't mention modes.

### 9. Summarize

Tell the user:
- What was done last session
- What's in progress or queued next
- Any open questions or decisions from the previous session
- Any test failures from the smoke test (if applicable, full mode only)
- Any handoff issues detected in step 2
- Suggest what to work on

If `light` modifier was used, note: "Light pickup: vault and smoke test skipped. Run `/kerd:switch in` for full context."

**Low:** Compress the summary to 2-3 lines: what was done last, what's next, active mode if any. Skip suggestions, skip open questions. Example:

```
Last session: fixed hook paths in krutho-founders and krutho-strategy (v0.29.1)
Next: tend on other repos, community mode contributions
```

### 10. Offer dian

**Skip this step if `low` modifier is set.**

Ask: "Start a `/kerd:dian` session?" If yes, flow into `/kerd:dian` orient. If no, stop. The user wants to do something quick without full session discipline.

## Fallback Behavior

If no TODO.md or session logs exist (fresh repo), say so cleanly:

"Fresh repo. No previous session state found. No TODO.md, no session logs in kivna/sessions/. Ready to start from scratch."

If no vault is found (no `kivna/vault.json` and no vault folder at `~/eolas/vault/[folder]/`), report this gracefully. Suggest running `/kerd:kivna scaffold` to set up the vault.

Do not fail silently or produce errors for missing files.
