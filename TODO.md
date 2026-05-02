# TODO

## Current Session
(2026-05-02, completed)

### Done this session
- [x] Brainstormed and shipped **v0.39.0 interrogate skill** — `/kerd:interrogate` produces a co-signed plan-readiness document by interviewing across all viability axes. Standalone skill (option A over mode or dian flag). Discipline anchored in user-veto on stop, mandatory frontmatter session state for deterministic resume, structural document check before recitation gate.
- [x] Multi-round design refinement before freezing the spec: sign-off ritual evolved (typed `signed` over commit-message); `final-session-state:` block at sign-off; status semantics (one sentence each for viable/not-yet-viable/blocked/deferred); scope reframed as boundary concept (in + out together); axis renamed `Scope` → `Scope viability` and `Viability conditions` → `Overall viability` to avoid collisions; structural doc check on Unknown↔Status; canonical template + zero-path initialization note.
- [x] Implementation via SDD with spec review only (option b — skip code-quality reviewer for markdown/JSON tasks). 11 tasks, 11 spec reviews, all PASS. One real finding caught by Task 8 spec mismatch (metadata.description drift).
- [x] Two commits shipped to origin/main:
  - `6e0faf8` feat(interrogate): new skill for plan-readiness interrogation (v0.39.0)
  - `ed824de` docs(claude-md): release checklist — describe metadata.description as separate shape
- [x] CLAUDE.md release checklist updated: only the two capability-list locations (plugin.json description + plugins[0].description) need byte-identical sync. metadata.description is intentionally a separate marketplace one-liner, updated only as its own decision.
- [x] User caught calibration error: cache was 0.38.0 (not 0.32.0 as I'd been claiming all session, citing 2026-04-25 TODO.md as current state). Concrete user-pushback signal — exactly the externally-anchored truth signal yesterday's sensei review named as load-bearing.

### Context
- **Plugin cache now at 0.39.0** (user installed during this session; was 0.38.0 before). Restart Claude Code to pick up v0.39.0 in active sessions — current running session still loads 0.38.0 from cache.
- **Interrogate skill is on disk + cached, NOT yet invokable in this session.** The `/kerd:interrogate` command in this conversation returned "Unknown command" because the running session was loaded with 0.38.0 cache. Post-restart, it'll be live.
- **First interactive smoke test pending.** Recommend: `/kerd:interrogate docs/plans/2026-05-02-interrogate-design.md` (meta — interrogate the design itself; failure modes easier to spot when you know what should be there). Or zero-path on a real upcoming idea. Either tells you something.
- **Empirical test against the recursive trap.** The interrogate skill ships as text-rules-at-turn-start — same layer yesterday's sensei review flagged as wrong granularity for calibration. Discipline is structurally anchored (user-veto, frontmatter session state, structural doc check) which should make it more robust than pure text rules — but "should" is a hypothesis. First real session is the test bed. If the agent declares done unilaterally, pads responses, or offers multiple-choice during interview, that's data toward Path B.

## Backlog
- **First interactive smoke test of `/kerd:interrogate`** — meta path (interrogate the design doc) or real path (next upcoming idea). Watch for: declaring done before user-veto, response verbosity, multiple-choice slips, sliding sideways instead of drilling.
- **Path B (paused) — Stop hook + PostToolUse hook at genuinely different granularity.** Decision rule unchanged: ship only if Path A reframe + interrogate's structural anchors don't shift behavior measurably. User-pushback rate is the externally-anchored truth signal.
- **Spike mode v1 retro** — pending after measurable-baseline test. Watch: does N+1 batching produce useful additions or noise? Does wins+losses recording complement TODO? Does commit-graduation help mid-flight?
- Run /kerd:tend on krutho-founders, krutho-strategy, obair to migrate vaults.
- PPS marketplace.json fix from prior session — still unpushed/unregistered.
- Hook version pinning is a recurring manual burden. Consider adding hook version staleness check to /kerd:tend.
- Stale `Kerd.md` MOC version field (says 0.31.0 vs actual 0.39.0) — either update on every release or remove entirely (lean remove).
- Solicit community mode contributions.
