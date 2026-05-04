# TODO

## Current Session
(2026-05-04, completed)

### Done this session
- [x] Witnessed first interactive smoke test of `/kerd:interrogate` against `3of3/docs/plans/integration-spike.md`. Live trace shared. Failure modes on turn 1: question-bundling, implicit multiple-choice ("plan as written / current state / revised plan"), wrong "guess". Agent self-corrected after pushback. Structural anchors did partial work — frontmatter session state gave deterministic resume despite bumpy path. **2 user-pushback signals on turn 1** — first concrete data points against the 33-42% confident-wrong baseline.
- [x] Diagnosed **closing-section "What I don't know" anti-pattern** (from a non-Kerd, non-interrogate session) as drift in global `~/.claude/CLAUDE.md`. The Thinking Discipline rule "Surface the gap so we can work on it together" had degraded into a closing-template cop-out — passive multiple-choice dumping decisions on user.
- [x] Added **Closing-uncertainty gate** to `~/.claude/CLAUDE.md` (gate #6). Locates failure at response-end formation; three downgrades (single direct question / explicit default / silence); priority rule (most-blocking question only).
- [x] Audited entire global CLAUDE.md. Three findings: (a) source rule at line 9-11 still seeded the pathology; (b) Claim Discipline intro framed layering as binary when actual is three-layer; (c) yesterday's TODO-staleness pattern had no corresponding gate.
- [x] Shipped 4 more edits: tightened line 9-13 ("ask a question now, not append a list of doubts later" — directive replaces cooperative); rewrote Claim Discipline intro for three layers (turn-start, mid-claim, response-end) with each gate located on the layer map; added **Question-formation gate** (#7) covering bundling/multiple-choice/verbose-framing — promoting interrogate-internal discipline to global floor; added **Memory-citation gate** (#8) with internal-vs-external distinction to keep it operationally cheap.
- [x] Net: 5 → 8 gates over 3 days. No Kerd repo commits — all work in global file. Vault Skill Lessons gained two new entries (cooperative-wording trap, skill-internal-discipline-that-should-be-global).

### Context
- **New gates on disk but not active in this conversation.** Current Claude Code session loaded `~/.claude/CLAUDE.md` before today's edits. Restart needed before the gates bind decisions. Same lag as plugin cache.
- **Interrogate test on 3of3 left mid-stream** at Scope axis, gather-level. Document at `3of3/docs/interrogations/2026-05-02-integration-spike.md`. Pending question: which artifact is under interrogation (original plan as written / current state of execution / revised plan).
- **Question-formation gate makes interrogate's bundling-prevention partially redundant.** Two parallel experiments now: skill-layer structural anchors (frontmatter session state, user-veto on stop) and global-layer text gates. If both grip, text rules at the right granularity work. If both fail in the same shape, text rules anywhere are insufficient and Path B (Stop hooks scanning for structural patterns) is next.
- **Cadence is high.** 3 gates added in 3 days. Layer-map approach proving its worth, but file is in active growth mode — worth watching whether new patterns continue to surface or whether the gates catch them.

## Backlog
- **First interactive smoke test of `/kerd:interrogate`** — meta path (interrogate the design doc) or real path (next upcoming idea). Watch for: declaring done before user-veto, response verbosity, multiple-choice slips, sliding sideways instead of drilling.
- **Path B (paused) — Stop hook + PostToolUse hook at genuinely different granularity.** Decision rule unchanged: ship only if Path A reframe + interrogate's structural anchors don't shift behavior measurably. User-pushback rate is the externally-anchored truth signal.
- **Spike mode v1 retro** — pending after measurable-baseline test. Watch: does N+1 batching produce useful additions or noise? Does wins+losses recording complement TODO? Does commit-graduation help mid-flight?
- Run /kerd:tend on krutho-founders, krutho-strategy, obair to migrate vaults.
- PPS marketplace.json fix from prior session — still unpushed/unregistered.
- Hook version pinning is a recurring manual burden. Consider adding hook version staleness check to /kerd:tend.
- Stale `Kerd.md` MOC version field (says 0.31.0 vs actual 0.39.0) — either update on every release or remove entirely (lean remove).
- Solicit community mode contributions.
