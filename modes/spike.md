---
name: spike
description: "Throw multiple ideas at the wall to learn what works. Directional but exploratory — no plan, no decomposition. Captures wins AND losses with evidence; commits cleanly so working solutions are extractable for the real build. Use when uncertainty is high, tries are cheap, and a plan would be premature."
category: development
core_skills:
  - kerd:switch
  - kerd:kivna
discover_keywords:
  - "spike"
  - "prototype"
  - "throw at the wall"
  - "see what sticks"
  - "try a bunch"
  - "experiment"
  - "validate"
  - "explore"
  - "rapid"
---

## Setup

- [ ] `/kerd:switch` in light -- minimal session open, no smoke test
- [ ] Extract the bigger idea -- read CLAUDE.md, TODO.md "Current Session" block, and any `docs/research/` files. State the bigger idea in one line for confirmation. Do NOT decompose into tasks. The direction is the constraint; the spike is the surface area.
- [ ] Identify or create the captured-evidence file -- look for `docs/research/[topic]-spec.md` or equivalent. If one exists, append to it. If not, propose a path and create on first capture, not upfront.

## Try

- [ ] Generate the try matrix -- batch hard. For hardware/long-loop tests, default to N+1 variants over what was asked. Add the obvious next variants without asking. The round-trip is the bottleneck.
- [ ] Ship the build -- the user runs the tests on real hardware, real users, real environment. Do not simulate when the real test loop is the whole point.
- [ ] Record results immediately as they come in:
  - **Wins** → captured-evidence file with: what worked, what variant, when verified, what evidence
  - **Losses** → same file, separate section: what was tried, what failed, when, what evidence (error, decline behavior, output)
  - Both wins and losses must cite specific session moments. Do not infer outcomes from theory.
- [ ] Loop back to "Generate the try matrix" with what was learned. Continue until either (a) enough wins to graduate, (b) enough losses to redirect, or (c) the user calls wrap-up.

## Close

- [ ] Removed-from-backlog log -- ask "what did we learn we don't need?" Append disproven hypotheses to a Removed/Disproven section. Spike work generates as much value from disproven assumptions as from confirmed ones, but only if recorded.
- [ ] Commit graduation -- review the spike's working code. For each output, classify explicitly: `keep-as-is` (production-ready), `extract-and-promote` (move into real code), or `discard` (was a try, not a keeper). Make the decision visible before committing.
- [ ] Clean commits -- each confirmed-working solution gets its own commit with evidence in the message (e.g. "spike: Peacock iOS-share URL works, verified on Apple TV 4K 2026-04-25"). Disproven attempts get committed separately as "spike: confirmed [X] declines, evidence in [file]" so they're discoverable but not mistaken for working code.
- [ ] `/kerd:kivna` save -- update vault if the spike produced strategically-significant findings. Skip if outcomes are purely tactical.
- [ ] `/kerd:switch` out -- close session
