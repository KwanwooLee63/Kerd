# TODO

## Current Session
(completed 2026-04-25)

### Done this session
- [x] v0.33.0 — switch + kivna template fix. Dropped fill-in brackets in session log template, added three rules above the fence: anti-hallucination ("omit empty sections, don't write None/N/A"), okay-not-to-know ("'I don't know' is a valid log entry"), match-vocabulary-to-work (covers code, writing, strategy, sales, research). Same vocabulary fix to kivna Weekly Achievements.
- [x] v0.34.0 — new spike mode. Directional but exploratory, no plan, no decomposition. Captures wins AND losses with evidence. Batch-hard for hardware loops (default N+1 variants). Commit graduation at close-out (keep-as-is / extract-and-promote / discard). Removed-from-backlog log for disproven hypotheses.
- [x] Discussed Karpathy's LLM Council pattern — decided NOT to bundle into Kerd (identity dilution, composition over containment).

### Context
- Version is 0.34.0
- Cached plugin still at 0.32.0 — needs `claude plugins install kerd` to pick up v0.33.0 + v0.34.0
- Spike mode untested in real spike work. 3of3 deep-link work is the natural first dogfood.
- Plan file at `/Users/anthonymaley/.claude/plans/preamble-and-fill-in-indexed-chipmunk.md` (the v0.33.0 design plan)

## Backlog
- **Spike mode v1 retro** — after first real use (likely 3of3 deep-link spike), check whether rules match work shape. Specifically watch: does N+1 batching produce useful additions or noise? Does wins-and-losses recording duplicate TODO.md or complement it? Does commit-graduation help mid-flight or only at end?
- Run /kerd:tend on krutho-founders, krutho-strategy, obair to migrate vaults
- PPS marketplace.json fix from prior session — still unpushed/unregistered
- Hook version pinning is a recurring manual burden. Consider adding hook version staleness check to /kerd:tend.
- Stale `Kerd.md` MOC version field (says 0.31.0) — either update on every release or remove entirely (single source of truth = plugin.json). Leaning remove.
- Solicit community mode contributions
