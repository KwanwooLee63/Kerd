# TODO

## Current Session
(2026-05-20, session 2)

### Done this session
- [x] Switched local Kerd plugin source from upstream (`anthonymaley/Kerd`) to local directory (`C:\Users\aweso\Documents\Work\Kerd`)
- [x] Cleared stale plugin cache (`~/.claude/plugins/cache/kerd-marketplace/`)
- [x] Verified v0.40.0 trim skill with consolidation scan loads from local path

### What's Next
- [ ] Test `/kerd:trim` in another project to validate v0.40.0 changes
- [ ] Create PR to upstream (anthonymaley/Kerd) for trim memory cleanup
- [ ] Clean up stale local branches (pr/trim-skill)
- [ ] After testing, swap plugin source back to upstream if desired

### Context
- On `feat/trim-memory-cleanup` branch, tracking origin/feat/trim-memory-cleanup
- Plugin now reads from local disk (directory source), not GitHub cache
- Change was in `~/.claude/settings.json` (not in this repo) — will not appear in this repo's git diff
- Untracked: `.claude/`, `.session-start-sha`, `docs/archive/` (pre-existing)

## Backlog
- **First interactive smoke test of `/kerd:interrogate`** — meta path (interrogate the design doc) or real path (next upcoming idea). Watch for: declaring done before user-veto, response verbosity, multiple-choice slips, sliding sideways instead of drilling.
- **Path B (paused) — Stop hook + PostToolUse hook at genuinely different granularity.** Decision rule unchanged: ship only if Path A reframe + interrogate's structural anchors don't shift behavior measurably. User-pushback rate is the externally-anchored truth signal.
- **Spike mode v1 retro** — pending after measurable-baseline test. Watch: does N+1 batching produce useful additions or noise? Does wins+losses recording complement TODO? Does commit-graduation help mid-flight?
- Run /kerd:tend on krutho-founders, krutho-strategy, obair to migrate vaults.
- PPS marketplace.json fix from prior session — still unpushed/unregistered.
- Hook version pinning is a recurring manual burden. Consider adding hook version staleness check to /kerd:tend.
- Stale `Kerd.md` MOC version field (says 0.31.0 vs actual 0.39.0) — either update on every release or remove entirely (lean remove).
- Solicit community mode contributions.
