# TODO

## Current Session
(2026-05-20)

### Done this session
- [x] Synced fork: reset local main to upstream/main (v0.39.0), force-pushed origin/main
- [x] Abandoned `pr/trim-skill` branch (upstream incorporated trim differently)
- [x] Created `feat/trim-memory-cleanup` branch from synced main
- [x] Enhanced trim Step 4: expanded from `project_*.md` only to all memory types with type-specific caution levels, added consolidation scan (same-topic merging, subset detection, natural grouping), added MEMORY.md index rewrite after changes
- [x] Bumped version to v0.40.0 (plugin.json, marketplace.json x2)
- [x] Updated README.md trim description
- [x] Committed and pushed to origin/feat/trim-memory-cleanup

### What's Next
- [ ] Create PR to upstream (anthonymaley/Kerd) for trim memory cleanup
- [ ] Clean up stale local branches (pr/trim-skill)

### Context
- On `feat/trim-memory-cleanup` branch, tracking origin/feat/trim-memory-cleanup
- PR not yet created (deferred, late session)
- Commit: `3d6fc13` feat(trim): expand memory cleanup with consolidation and cross-type staleness scan (v0.40.0)
- Untracked: `.claude/`, `.session-start-sha`, `docs/archive/` (pre-existing, not part of this session)

## Backlog
- **First interactive smoke test of `/kerd:interrogate`** — meta path (interrogate the design doc) or real path (next upcoming idea). Watch for: declaring done before user-veto, response verbosity, multiple-choice slips, sliding sideways instead of drilling.
- **Path B (paused) — Stop hook + PostToolUse hook at genuinely different granularity.** Decision rule unchanged: ship only if Path A reframe + interrogate's structural anchors don't shift behavior measurably. User-pushback rate is the externally-anchored truth signal.
- **Spike mode v1 retro** — pending after measurable-baseline test. Watch: does N+1 batching produce useful additions or noise? Does wins+losses recording complement TODO? Does commit-graduation help mid-flight?
- Run /kerd:tend on krutho-founders, krutho-strategy, obair to migrate vaults.
- PPS marketplace.json fix from prior session — still unpushed/unregistered.
- Hook version pinning is a recurring manual burden. Consider adding hook version staleness check to /kerd:tend.
- Stale `Kerd.md` MOC version field (says 0.31.0 vs actual 0.39.0) — either update on every release or remove entirely (lean remove).
- Solicit community mode contributions.
