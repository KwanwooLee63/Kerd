# TODO

## Current Session
(completed 2026-04-25, second of two sessions today)

### Done this session (post first switch-out)
- [x] v0.35.0 — spike v1.1 (six structural additions after first dogfood retro from 3of3 tvOS deep-link work). Pre-flight inventory + empirical-primitive-first in Setup; per-variant verify + provisional-decline zone + WebFetch-fail-3-alternates + matrix trimming in Try.
- [x] v0.36.0 — spike v1.2 (three additions imported from parallel sensei A3). Strong-language gate with explicit downgrade vocabulary list, mid-flow tripwires, self-audit at close-out against measurable 33-42% confident-wrong baseline.
- [x] Global `~/.claude/CLAUDE.md` "Claim Discipline" section (sensei's 5 gates, adapted to second-person prose).
- [x] v0.37.0 — dian claim-discipline at all four phases. Step-boundary markers within execute (`[dian: execute step N/M]`), pre-flight inventory in orient, plan-step prediction citations, strong-language gate during execute, close-out summary discipline.
- [x] v0.38.0 — slainte and tend gain evidence-pointer discipline for audit findings. Each finding cites the specific check; tend's "Why" includes a post-fix verification step. Switch surveyed — considered already covered by v0.33.0 + global Claim Discipline.
- [x] Vault: created `Kerd Skill Lessons.md` capturing both the spike retro and the sensei A3 + 8 generalizable principles.
- [x] 3of3: captured sensei A3 from `kivna/output/` (gitignored) to `docs/research/sensei-calibration-failure/` for durable record.
- [x] **Sensei review of A3 caught the recursive trap** — countermeasures live at the same granularity the diagnosis identified as broken. The Kerd v0.34.0-v0.38.0 work committed the same anti-pattern in real-time.
- [x] Path A reframe (chosen over Path B, which is paused). Editorial notes added to README, playbook, and vault Skill Lessons. Vault file revised: "convergence" principle scoped to "agreement, not correctness"; new "right-column collapse on self-improvement A3s" principle named; user-pushback rate flagged as the only externally-anchored signal.
- [x] 3of3: captured the sensei review HTML to `docs/research/sensei-calibration-failure/` alongside the original A3.

### Context
- Version is 0.38.0 (six minor releases shipped today: 0.33 → 0.38)
- **Cached plugin still at 0.32.0 — now SIX versions behind.** Needs `claude plugins install kerd` urgently if any of today's work is to take effect.
- Path B (Stop/PostToolUse hooks at genuinely different granularity) **paused pending empirical measurement** of whether Path A reframe changes anything in the next investigation session.
- All v0.34.0-v0.38.0 interventions are hypotheses by my own framing (per Path A reframe). User-pushback rate is the load-bearing measurement signal.
- The recursive trap is genuinely deep — Path A is itself text-in-markdown at turn-start. Reframe makes the trap visible to the reader; doesn't escape it.

## Backlog
- **Spike mode v1 retro** — partially done via the 3of3 dogfood + sensei A3, but the formal retro after measurable-baseline test still pending. Watch: does N+1 batching produce useful additions or noise? Does wins+losses recording complement TODO? Does commit-graduation help mid-flight?
- **Path B (paused) — Stop hook + PostToolUse hook at different granularity.** Build only after Path A reframe is empirically tested in the next investigation session against the 33-42% baseline. If nothing shifts, Path B becomes more urgent. If something shifts, Path A might be enough on its own.
- Run /kerd:tend on krutho-founders, krutho-strategy, obair to migrate vaults
- PPS marketplace.json fix from prior session — still unpushed/unregistered
- Hook version pinning is a recurring manual burden. Consider adding hook version staleness check to /kerd:tend.
- Stale `Kerd.md` MOC version field (says 0.31.0 vs actual 0.38.0) — either update on every release or remove entirely (lean remove).
- Solicit community mode contributions
