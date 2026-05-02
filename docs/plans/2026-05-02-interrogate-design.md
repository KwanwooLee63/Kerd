# Kerd Interrogate: Design

A standalone Kerd skill that produces a co-signed plan-readiness document by interviewing the user relentlessly across every viability axis of a plan or idea. The interview is structurally constrained to prevent the convergence pull that existing brainstorming skills exhibit — verbose framing, premature multiple-choice, and unilateral declarations of "done."

## Why this exists

Existing brainstorming and design skills (`superpowers:brainstorming`, `sensei:coach`, dian's orient/plan phases) tend to converge before shared understanding is reached. The agent extrapolates from partial answers, sketches the plan ahead of the user's articulation, and offers easy multiple-choice ratifications that let the user agree without engaging. Verbose responses signal lack of understanding; multiple-choice questions let the user select rather than articulate; ratification books misunderstanding as resolved. Plans ship with hidden gaps that surface as code rewrites, logic gaps, or compliance failures downstream.

Interrogate is the countermeasure: granular Q&A that cannot be ratified with a yes/no, traversing every axis the plan needs to be viable on (technical, business, legal, operational), producing a co-signed document with mutual sign-off as the exit ritual.

This skill addresses requirements-formation calibration, distinct from claim-formation calibration. Yesterday's work (v0.34.0–v0.38.0 + global Claim Discipline) addressed "do my assertions match my evidence?" Interrogate addresses "does my understanding match the user's?"

## Invocation

```
/kerd:interrogate                  start from zero — "what's the idea?"
/kerd:interrogate <plan-ref>       interrogate an existing plan
```

`<plan-ref>` is a file path, an idea description, or a reference like "current TODO" or "the latest session log."

## Entry paths

**Plan-ref path:** agent reads the plan first, *proposes* the viability axes it infers as relevant from the plan content (not a mandatory exhaustive checklist — inferred from the plan itself), and asks the user to prune: which axes to keep in scope, mark out-of-scope, or defer. Then enters the interview loop.

**Zero path:** agent asks one open question — "what's the idea?" — and builds the document from blank. Axis identification happens organically during the interview as ideas surface.

Both paths converge on the same artifact (a co-signed plan-readiness document) under the same exit rules.

## Interview discipline

Eight rules govern the interaction during a session. They are structural — they prevent the failure modes named in the "Why this exists" section.

1. **One question per turn.** No "Question 1 of N." No bundled questions. Each turn surfaces exactly one open thread.

2. **No multiple choice unless genuinely discrete and small.** Default open-ended. Force articulation, not selection. Multiple choice is a cop-out that lets the user agree without thinking.

3. **No extrapolation.** Agent does not sketch the plan from partial answers. No "so it sounds like you want X, Y, Z." That pre-shapes the design before understanding is reached.

4. **Response shape constrained.** Agent's response in the interview = at most one sentence of acknowledgment + the next question. No insight blocks, no padding, no "let's think about." Verbosity is a tell of lack of understanding; the discipline forbids it during the interview itself.

5. **User-veto on stop.** Agent never declares the session done. The interview continues until the user explicitly says stop. (The agent *may* propose intermediate transitions — like "I've exhausted my known unknowns; ready to enter recitation?" — but the user can veto any proposal to continue interviewing.)

6. **Three "done" gates, all required for sign-off.**
   - (a) Agent has exhausted its known unknowns AND the document passes a structural check before recitation can be proposed. The structural check requires every in-scope axis to have:
     - at least one entry in **Known** or **Decision**
     - explicit **Viability conditions**
     - **Evidence / basis** for material claims (decisions, viability conditions)
     - **Unknown** state matches **Status**:
       - if `status: viable`, **Unknown** must be empty (no open questions remain)
       - if `status: not-yet-viable`, **Unknown** must be non-empty (the open questions are why it's not yet viable)
       - if `status: blocked`, **Unknown** may be empty or non-empty, but the blocker must be named in **Viability conditions**
       - if `status: deferred`, **Unknown** may be in any state; the revisit trigger is in the top-level Deferred list

     If the document fails the structural check, the agent continues interviewing on the failing axes — no recitation proposal. If it passes, the agent *proposes* entering recitation. User can veto ("more to discuss") to keep interviewing. Exhaustion + structural-check is the agent's internal trigger to *propose* recitation, not to declare the session over.
   - (b) User has no more answers, requirements, or ideas to share.
   - (c) Agent recites the plan back **axis-by-axis**; user confirms each axis individually. Whole-document recitation is rejected as the easy-ratification trap this skill is designed to avoid.

7. **Tree-aware ordering.** Decisions that constrain other decisions get resolved first. Within a decision, depth-first: resolve fully — including per-axis viability where the decision affects an axis — before sliding sideways to the next branch.

8. **Adversarial lean — graduated and user-dialable.** Default trajectory follows saturation:
   - **Gather** (early) — open questions, no challenges. *"Tell me about X."*
   - **Probe** (mid) — drill into vagueness, ask for specifics. *"What does that mean concretely?"*
   - **Stress-test** (late) — challenge claims, ask for evidence. *"How do you know that's true?"*
   - **Adversarial** (deep) — actively look for holes. *"What would have to be different for this not to work?" / "What's the strongest objection?"*

   User can dial level at any moment in either direction: *"go harder now"* / *"ease off, still ideating"* / *"stay at probe for this axis."*

**Pause/resume.** Sessions can run long. The document is persistent state — leaving and returning resumes from the document, not from conversation memory. The agent's session state lives in the document frontmatter (see "Session state" under Document structure) so resume is deterministic, not reconstructed from chat history. On resume, the agent restates the level and target, then **re-asks the last unanswered question verbatim** from the `last-question` frontmatter field — e.g. *"Resuming at stress-test on Security. Last question: [verbatim from frontmatter]."* — and stops. The user can ask for refinement if needed; the agent does not offer a meta-choice (offering "repeat or refine?" is a multiple-choice ratification trap that violates the one-question-per-turn rule). The unanswered question is the active edge; resume re-presents it, nothing more.

## Document structure

The output is a markdown file at `docs/interrogations/YYYY-MM-DD-<topic>.md`. It grows incrementally during the interview — agent updates it after each meaningful axis exchange, never reconstructs it wholesale at the end. User can read it at any point.

### Outline

```
[frontmatter]
## Scope
  ### In scope
  ### Out of scope
## Deferred
## [Per-axis sections, one per in-scope item]
```

### Frontmatter fields

- `created` — ISO timestamp of session start
- `last-updated` — ISO timestamp of most recent update
- `signed-at` — ISO timestamp of mutual sign-off (set at sign-off, absent before)
- `signers` — named map (populated at sign-off):
  ```yaml
  signers:
    user: Anthony Maley
    agent: claude-opus-4-7
  ```
  Named fields rather than a positional list — clearer to read and parse. Future versions may add a `sign-off-history` list of past sign-offs (when documents are revisited and re-signed); v1 carries only the current sign-off.
- `status` — `draft` (interview in progress or paused) | `signed` (mutual sign-off complete)
- `topic` — short human-readable topic name

### Session state (frontmatter, for deterministic resume)

These fields exist while `status: draft` and are removed (or frozen) at sign-off:

- `current-axis` — the in-scope axis under interview right now
- `current-thread` — the question thread within that axis (e.g. a sub-decision being resolved)
- `last-question` — the last question the agent asked, verbatim
- `adversarial-level` — current level: `gather` | `probe` | `stress-test` | `adversarial`
- `recitation-status` — per-axis map. Initialized to `pending` for every in-scope axis as soon as the axis is added; transitions to `recited` after the agent recites that axis, then `confirmed` (user accepted) or `pushed-back` (user pushed back; that axis re-enters interview). At document birth before any axes exist, the map is empty (`{}`). Once axes are added, every in-scope axis must have an entry — no missing keys.

Without these, resume relies on chat memory and becomes brittle — the same calibration problem at a different layer. With them, resume is a state-machine transition, not a reconstruction.

### Scope (defines project boundaries)

Scope is a boundary concept, not a tracking concept. What's in *and* what's out together define the project. Both are scope.

- **In scope** — list of axes or items the plan covers. This list is also the index — each entry has a per-axis section below.
- **Out of scope** — list of axes or items the plan deliberately excludes. Each: item + one-line reason. These items do not have per-axis sections; they live only in this list.

### Deferred (separate from scope — tracks timing, not boundaries)

Items in scope but pushed to a later round. Each: item + reason + revisit trigger (timeline, dependency, or condition that would reactivate it). If an item was deferred mid-interview after content was gathered, it retains its per-axis section with `status: deferred` AND appears in this list.

### Per-axis sections

One section per in-scope item, in the order they appear in the In Scope list. Each has six fields:

- **Known** — what we have established about this axis (general context and facts)
- **Unknown** — open questions still on the table
- **Evidence / basis** — for each item in Known and each Decision, the source: a fetched doc, a user statement, a tested observation, an explicit "from training data; may be outdated." This complements global Claim Discipline: viability conditions built on unsupported assumptions are surfaced as such, not laundered into "known."
- **Decision / current position** — crisp resolved decisions for this axis (e.g. *"Storage: local markdown files under `docs/interrogations/`"*). Distinct from Known, which holds general context. A decision is something the plan has *committed to*, not just something the plan *knows*.
- **Viability conditions** — what would have to be true for this axis to be considered viable
- **Status** — `viable` | `not-yet-viable` | `blocked` | `deferred`

  Status semantics:
  - `viable` — known enough, with stated viability conditions and evidence supporting them. The plan can proceed on this axis.
  - `not-yet-viable` — open unknowns remain, but no known blocker. More interview is needed; the gap is information, not impediment.
  - `blocked` — a known condition currently prevents viability (e.g. missing approval, unmet dependency, regulatory barrier). The blocker is named in Viability conditions; status is `blocked` until it's resolved.
  - `deferred` — intentionally postponed with a revisit trigger. Item appears in the top-level Deferred list with its trigger.

`out-of-scope` is not a valid status value because out-of-scope items don't have per-axis sections; they live in the Scope section above.

### Canonical template

A new interrogation document begins as:

```markdown
---
created: 2026-05-02T18:30:00Z
last-updated: 2026-05-02T18:30:00Z
status: draft
topic: <short human-readable name>
current-axis: <axis-name>
current-thread: <sub-decision being resolved, or empty>
last-question: <verbatim text of agent's last question>
adversarial-level: gather
recitation-status:
  <axis-name-1>: pending
  <axis-name-2>: pending
---

# Interrogation: <topic>

## Scope

### In scope
- <axis-name>
- <axis-name>

### Out of scope
- <item> — <one-line reason>

## Deferred
- <item> — <reason> — revisit when <trigger>

## <Axis name>

### Known
- <fact / context>

### Unknown
- <open question>

### Evidence / basis
- <fact> — <source: fetched doc URL, user statement, tested observation, "from training data; may be outdated">

### Decision / current position
- <crisp resolved decision, distinct from general Known context>

### Viability conditions
- <what must be true for this axis to be viable>

### Status
not-yet-viable
```

At sign-off, frontmatter gains `signed-at`, `signers`, and `status: signed` per the Sign-off ritual; session-state fields (`current-axis`, `current-thread`, `last-question`, `adversarial-level`, `recitation-status`) are frozen as a final snapshot or removed (implementation decision during writing-plans).

The template is the structural floor — agents working in interrogation must produce documents that match this shape exactly. Drift here means the resume / structural-check / recitation logic loses purchase.

**Zero-path initialization.** The template above shows a document with axes already established. In zero-path entry, the initial document begins before any axes exist: `current-axis` is empty, the In Scope list is empty, and `recitation-status` is `{}`. As the interview proceeds and axes get added (via the user surfacing them or the agent proposing domain-specific ones), they get added to the In Scope list and `recitation-status` simultaneously. `current-axis` becomes populated as soon as the first axis is established and the interview moves into it.

## Recitation gate

Before sign-off can occur, the agent does a final recitation pass. It reads each axis back in summary form and asks the user to confirm. If the user pushes back on any axis, the interview re-enters for that axis (graduated lean continues from where it was) until the user vetoes the re-entry. Only after every in-scope axis passes recitation does sign-off become possible.

This is gate (c) of the three "done" gates — the demonstration of understanding, not just its declaration.

## Sign-off ritual

Once recitation passes for all axes:

1. Agent presents the document with the timestamp and signer placeholders ready.
2. User explicitly signs by typing `signed` in chat. (Commit-message signing was considered and rejected — it introduces git-state ambiguity and forces the skill to reason about commits, authors, and repository workflow. v1 keeps sign-off in-conversation.)
3. Frontmatter updates: `status: signed`, `signed-at: <ISO timestamp>`, and `signers` populated as the named map (`user: <name>`, `agent: <model-id>`) per the Frontmatter fields section.
4. Session-state fields are moved into a `final-session-state:` block in frontmatter — preserved as an audit snapshot, not removed. Active resume fields (`current-axis`, `current-thread`, `last-question`, `adversarial-level`, `recitation-status` at the top level) are removed. Example post-sign-off frontmatter shape:

   ```yaml
   final-session-state:
     current-axis: <last axis under interview>
     current-thread: <last sub-decision>
     last-question: <verbatim>
     adversarial-level: <last level>
     recitation-status:
       <axis-1>: confirmed
       <axis-2>: confirmed
   ```

   This preserves auditability (what state did the interview end in?) without leaving active resume hooks on a signed document.

The document reads "complete as of [signed-at]" — not eternally. Future revisits create new sign-off entries with new timestamps; the original signature is preserved as a point-in-time record.

## Composition with Kerd

`/kerd:interrogate` is callable from anywhere — inside a dian session, inside a mode, or standalone.

- **Invoked mid-dian:** returns to dian after sign-off. The signed interrogation document is referenced from dian's plan phase.
- **Invoked mid-mode:** returns to the mode after sign-off.
- **Invoked standalone:** exits cleanly after sign-off. No further workflow assumed.

If the user says "stop" without sign-off, the document saves as `status: draft` and the skill exits. Re-invoking with the same plan-ref or topic resumes from the draft.

## Default axis list (universal core + domain layers)

A small **universal core** applies to every interrogation regardless of domain:

- **Scope viability** (the *axis* is whether the boundaries already declared in the top-level Scope section are coherent and complete — distinct from the Scope section itself, which captures the boundaries. Naming it "Scope viability" prevents confusion between the structural section and the per-axis interview.)
- **Users / stakeholders** (who is this for; who has a say)
- **Value** (why this is worth doing; what changes if it works)
- **Constraints** (what must hold; what cannot change)
- **Risks** (what could fail; what consequences if it does)
- **Dependencies** (what this requires from outside the plan)
- **Overall viability** (the cross-axis "what must be true" set — distinct from the per-axis Viability conditions field. This axis aggregates conditions that span multiple axes or that are foundational to the plan as a whole. Renamed from "Viability conditions" to avoid collision with the per-axis field of the same name.)

**Domain-specific starter sets** layer on top, proposed by the agent based on what the plan-ref or zero-mode discussion reveals:

- *Software engineering plans:* technical design, data model, security, performance, testing, deployment.
- *Business / product plans:* business case, ROI, marketing, sales, pricing, competitive landscape.
- *Investment / financial plans:* due diligence, ROI, audit, compliance, term sheet, exit conditions.
- *Legal / contract plans:* compliance, privacy, data protection, jurisdiction, liability.

The user prunes any of these via out-of-scope/defer. Full-list-by-default was rejected as noise-generating; minimal universal core + inferred domain set is the default.

## What is deliberately out of this design

- **No mandatory exhaustive axis checklist.** The agent infers relevant axes from plan content (plan-ref path) or from what surfaces in the interview (zero path), proposes them, and lets the user prune. The universal core above always applies; everything else is proposed and pruned.
- **No automatic sign-off detection.** The agent may *propose* entering recitation when its known unknowns are exhausted, but it never declares the session over. User-veto on stop is absolute through to the final ritual.
- **No verbosity in the interview itself.** Insight blocks, structured framing, and explanation belong outside interrogate sessions. During interrogation, the agent is question-shaped only.
- **No multi-user sign-off in v1.** The signers list supports one user + one agent. Future work could extend this for multi-stakeholder plan-readiness, but v1 is single-user.
- **Interrogate does not produce the implementation plan itself.** It produces *readiness*. The boundary prevents the agent from sneaking into design synthesis too early. After sign-off, transition to `superpowers:writing-plans` (or another planning skill) is the next step — explicitly outside the interrogate session.

## Resolved during review (no longer open)

The first design draft listed three open questions; the review pass resolved all three.

- **Default axis list:** universal core + domain-specific starter sets, layered. See "Default axis list" above. Full-list-by-default rejected as noise.
- **Recitation format:** axis-by-axis. Whole-document recitation rejected as the easy-ratification trap this skill is designed to avoid.
- **Resumed-session continuity:** resume at the last dialed adversarial level. Agent briefly restates the level and target before the next question (e.g. *"Resuming at stress-test on Security."*) — preserves continuity without forcing the user to re-establish context.
