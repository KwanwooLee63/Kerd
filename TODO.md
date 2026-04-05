# TODO

## Current Session
(completed 2026-04-04)

### Done this session
- [x] Switch in — picked up from 2026-03-27 session
- [x] Explored shodh-memory repo for patterns applicable to Kerd
- [x] Brainstormed and designed 4 features: Stop hook, SessionStart hook, PostToolUse hook, KIF interchange format
- [x] Wrote design doc: docs/plans/2026-04-04-hooks-and-kif-design.md
- [x] Two rounds of design review — fixed 7 issues (step IDs, .active-modes schema, TOON import, hook wiring, parameterized steps, cross-machine scope, gitignore)
- [x] Built v0.19.0: hooks infrastructure, unified .active-modes schema, slainte release audit, tend category 9
- [x] Built v0.20.0: KIF (TOON + JSON export/import), repo-grounded kivna out
- [x] Built v0.21.0: lorg ranking (scored results, recency filtering), shared state contract
- [x] Fixed P1 hook step matching (concrete invocation not bare name), removed jq dependency, fixed doc drift
- [x] Ran /kerd:tend — fixed skill hygiene (namespace prefix) and hook hygiene (registered hooks)

## Backlog
- Merge Kwanwoo's trim PR (#1) — waiting on his approval
- ~~Live smoke test of hooks in a fresh session (validate PostToolUse payload shape)~~ ✓ confirmed 2026-04-04
- Run /kerd:tend on krutho-founders, krutho-strategy, obair to migrate vaults
- Embed demo gif in README
- Commit or decide on AGENTS.md and docs/demo-mode.* files
- Clean .DS_Store files from repo
- Solicit community mode contributions

### Context
- Version is 0.21.0 (bumped in all 3 locations)
- Hooks registered in .claude/settings.local.json but won't activate until next session restart
- PostToolUse payload shape is the one remaining uncertainty — needs a live test
- PR #1 (trim) is on pr/trim-skill branch with fix commit f1a9aa9 — Kwan needs to cherry-pick and approve
- AGENTS.md and demo media files are untracked — skipped by tend, user decision needed
