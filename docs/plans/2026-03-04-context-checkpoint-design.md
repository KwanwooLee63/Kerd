# Context Checkpoint Design

**Date:** 2026-03-04
**Problem:** Session context rots when Claude Code compacts the context window mid-session, and when sessions end. Key decisions, reasoning, rejected approaches, and working assumptions are lost. Cold starts from TODO.md and session logs are shallow — they capture what happened, not the thinking.

## Design

### New file: `kivna/context.md`

A living document that always reflects the current working context. Overwritten on every checkpoint — not appended to. One read and you're caught up.

```markdown
# Context — [Project Name]

## Current Focus
What we're actively working on. The task, the approach,
where we are in it.

## Mental Model
The high-level understanding of how things fit together
right now. Not architecture docs — the working theory
that guides decisions this session.

## Decisions
Each decision with full reasoning. What was considered,
what was rejected, why the chosen approach won.

## Rejected Approaches
Things we tried or considered and ruled out. With reasons.
Prevents the next session from re-exploring dead ends.

## Working Assumptions
Things established as true that aren't written anywhere
else. Constraints discovered, behaviors observed, limits hit.

## Active Threads
Partial work, what's in progress, what's blocking,
what's queued next.

## Open Questions
Unresolved things that need input or investigation.
```

### New folder: `kivna/checkpoints/`

Daily archive of previous context.md versions. Every time context.md is overwritten, the previous content is appended here with a timestamp:

```markdown
## HH:MM

[previous context.md content]

---

## HH:MM

[next archived version]
```

One file per day: `kivna/checkpoints/YYYY-MM-DD.md`. Committed to git.

### Updated folder structure

```
kivna/
  context.md       # living working context (overwritten each checkpoint)
  checkpoints/     # daily archives of previous context versions
  sessions/        # session logs from switch (unchanged)
  memories/        # quick notes (unchanged)
  input/           # import inbox (unchanged)
  output/          # export transit (unchanged)
```

`context.md` and `checkpoints/` are committed to git.

## Checkpoint triggers

1. **Dian task boundaries** — auto-update after each task completes during execute phase
2. **Dian close-out** — finalize context.md with end-of-session state
3. **Switch out** — ensure context.md is current (no-op if dian close-out already ran)
4. **Manual `/kivna checkpoint`** — user-triggered snapshot anytime

Philosophy: don't try to predict context compaction, just make it irrelevant by writing frequently at natural breakpoints.

## Skill changes

### kivna

New command: `/kivna checkpoint`

- Read the current conversation state
- Archive current `kivna/context.md` to `kivna/checkpoints/YYYY-MM-DD.md` (append with `## HH:MM` header)
- Overwrite `kivna/context.md` with current working context
- Quick confirmation — no approval flow (same as `/kivna memory`)

Update folder convention to include `context.md` and `checkpoints/`.

### dian

Three new touchpoints:

1. **Orient (step 1)** — add `kivna/context.md` to the read list, after TODO.md and CLAUDE.md. This is the cold-start restore.

2. **Execute (step 3)** — after each task completes, auto-update `kivna/context.md`. Archive previous version first. Same mechanic as `/kivna checkpoint` but triggered automatically.

3. **Close-out (step 4)** — finalize `kivna/context.md` with end-of-session state. Update "Current Focus" and "Active Threads" to reflect paused/completed state. This becomes the cold-start document for the next session.

### switch

**Switch in** — after the summary (step 5), ask: "Start a dian session?" If yes, flow into dian orient. If no, stop.

**Switch out** — after writing TODO.md and session log (step 2), ensure `kivna/context.md` is current. If dian close-out already ran, this is a no-op. If not (quick switch without formal close-out), write a checkpoint.

### startup

Add to the scaffold:
- Create `kivna/context.md` (empty skeleton with section headers and placeholder text)
- Create `kivna/checkpoints/` directory

## Restore scenarios

1. **Cold start (new session)** — dian orient reads `kivna/context.md`. Full context restored in one file read.

2. **Mid-session after compaction** — user says "re-read context" or notices drift. Claude reads `kivna/context.md` and recovers.

3. **Moving to another LLM** — hand them three files: `CLAUDE.md`, `docs/playbook.md`, `kivna/context.md`. Full cold-start kit.

4. **Tracing a decision** — read `kivna/checkpoints/YYYY-MM-DD.md` to see how the mental model evolved.

## What doesn't change

- TODO.md stays at project root — dian manages it, but it's a project file
- docs/playbook.md stays in docs — it's documentation, not a session artifact
- Session logs in kivna/sessions/ — unchanged, still written by switch
- Memories in kivna/memories/ — unchanged, still quick notes

## Version impact

This is a MINOR version bump (new feature: context checkpoints, new command: `/kivna checkpoint`, modified behavior in dian/switch/startup).
