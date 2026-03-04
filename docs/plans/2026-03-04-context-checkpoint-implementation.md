# Context Checkpoint Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add context checkpointing to Kerd — a living `kivna/context.md` file that captures working context (decisions, reasoning, rejected approaches, assumptions) and is auto-updated at task boundaries to prevent context rot.

**Architecture:** New `/kivna checkpoint` command writes a cumulative context snapshot to `kivna/context.md`, archiving the previous version to `kivna/checkpoints/YYYY-MM-DD.md`. Dian auto-triggers checkpoints at task boundaries and close-out. Switch reads context on arrival and ensures it's current on departure. Startup scaffolds the new structure.

**Tech Stack:** Markdown files, Claude Code plugin system (SKILL.md definitions)

---

### Task 1: Update kivna skill — add checkpoint command and folder convention

**Files:**
- Modify: `skills/kivna/SKILL.md:13-17` (folder convention)
- Modify: `skills/kivna/SKILL.md:90-106` (after memory command, add checkpoint command)
- Modify: `skills/kivna/SKILL.md:108-114` (notes section)

**Step 1: Update folder convention (lines 13-17)**

Add `context.md` and `checkpoints/` to the folder convention list. Replace the existing four-line list with:

```markdown
- `kivna/context.md` — living working context, overwritten each checkpoint (committed to git)
- `kivna/checkpoints/` — daily archives of previous context versions (committed to git)
- `kivna/sessions/` — full session logs written by switch (committed to git)
- `kivna/memories/` — quick notes captured mid-session (committed to git)
- `kivna/input/` — drop files here for import (should be gitignored, transit folder)
- `kivna/output/` — exports land here (should be gitignored, transit folder)
```

**Step 2: Add checkpoint command after the memory command (after line 106)**

Insert the following section after the memory command's closing code block:

```markdown
### `/kivna checkpoint` — Context Snapshot

Capture the current working context to `kivna/context.md`. This is the anti-context-rot mechanism — write frequently at natural breakpoints so compaction or session boundaries don't lose the thinking.

1. **Archive the current context.** If `kivna/context.md` exists and has content beyond the skeleton, append its content to `kivna/checkpoints/YYYY-MM-DD.md` with a `## HH:MM` timestamp header and a `---` separator. Create the file and directory if they don't exist.

2. **Write the new context.** Overwrite `kivna/context.md` with the current working state:

```markdown
# Context — [Project Name]

## Current Focus
[What we're actively working on. The task, the approach, where we are in it.]

## Mental Model
[The high-level understanding of how things fit together right now. Not architecture docs — the working theory that guides decisions.]

## Decisions
[Each decision with full reasoning. What was considered, what was rejected, why the chosen approach won.]

## Rejected Approaches
[Things we tried or considered and ruled out. With reasons. Prevents re-exploring dead ends.]

## Working Assumptions
[Things established as true that aren't written anywhere else. Constraints discovered, behaviors observed, limits hit.]

## Active Threads
[Partial work, what's in progress, what's blocking, what's queued next.]

## Open Questions
[Unresolved things that need input or investigation.]
```

3. **Quick confirmation.** No approval flow — same as `/kivna memory`. Just confirm what was written.

Triggered automatically by dian at task boundaries and close-out. Also available manually anytime.
```

**Step 3: Update notes section (lines 108-114)**

Add a note about context.md and checkpoints. After the existing notes, add:

```markdown
- `kivna/context.md` and `kivna/checkpoints/` should be committed to git — they're the session's working memory.
- Context checkpoints are cumulative, not incremental. Each checkpoint captures the full working state, not just deltas.
- On cold start, read `kivna/context.md` alone. The archive in `kivna/checkpoints/` is for tracing decisions back, not for restore.
```

**Step 4: Update the description frontmatter (line 3)**

Update the trigger description to include checkpoint-related triggers:

```yaml
description: "Use when the user says 'kivna', 'import', 'export context', 'save memory', 'remember this', 'checkpoint', 'save context', 'snapshot', or needs to manage project knowledge — importing external files, exporting session context, saving quick notes, or checkpointing working context mid-session."
```

**Step 5: Commit**

```bash
git add skills/kivna/SKILL.md
git commit -m "feat: add /kivna checkpoint command and context.md convention"
```

---

### Task 2: Update dian skill — orient reads context, execute auto-checkpoints, close-out finalizes

**Files:**
- Modify: `skills/dian/SKILL.md:14-23` (orient phase)
- Modify: `skills/dian/SKILL.md:35-37` (execute phase)
- Modify: `skills/dian/SKILL.md:41-75` (close-out phase)

**Step 1: Update orient phase (lines 14-23)**

Add `kivna/context.md` to the orient read list as item 3 (after CLAUDE.md, before progress tracking). This is the cold-start restore point.

The read list becomes:

```markdown
1. `TODO.md` — current session plan, roadmap, task queue
2. `CLAUDE.md` — project conventions and structure
3. `kivna/context.md` — working context from the last checkpoint (decisions, reasoning, active threads, assumptions)
4. Progress tracking — check `docs/project/progress.md`, `progress.md`, or `CHANGELOG.md`
5. Decision log — check `docs/project/decisions.md` or `decisions.md` if the work involves architecture choices
6. `docs/playbook.md` — project playbook (how to rebuild this project from scratch)
```

**Step 2: Update execute phase (lines 35-37)**

Replace the current execute section with:

```markdown
### 3. Execute

Do the work. Commit incrementally if it makes sense. Stay focused on the plan — if scope creep appears, flag it and add it to TODO.md for later rather than chasing it now.

**Auto-checkpoint:** After completing each task in the plan, update `kivna/context.md` with the current working context using the `/kivna checkpoint` mechanic (archive previous version, write new one). This ensures context survives compaction mid-session.
```

**Step 3: Update close-out phase (lines 41-75)**

Add a new step 3 (renumbering existing 3-5 to 4-6) for finalizing context.md:

After the existing step 2 (Doc impact assessment), insert:

```markdown
3. **Finalize context** — update `kivna/context.md` with end-of-session state. Mark "Current Focus" as completed or paused. Update "Active Threads" to reflect what's done and what carries over. This becomes the cold-start document for the next session.
```

**Step 4: Commit**

```bash
git add skills/dian/SKILL.md
git commit -m "feat: add context checkpointing to dian orient, execute, and close-out"
```

---

### Task 3: Update switch skill — read context on arrival, ensure current on departure, offer dian

**Files:**
- Modify: `skills/switch/SKILL.md:19-27` (switch out step 1, add context.md step)
- Modify: `skills/switch/SKILL.md:73-103` (switch in, add context read and dian offer)

**Step 1: Update switch out — add context checkpoint after session log (after step 2)**

Insert a new step 3 after "Write session log" (renumber existing 3-7 to 4-8):

```markdown
### 3. Ensure context is current

If `kivna/context.md` exists and a dian session was active, close-out should have already updated it — verify it's current and move on. If no dian session was running (quick switch without formal session), write a checkpoint now using the `/kivna checkpoint` mechanic.
```

**Step 2: Update switch in — add context read and dian offer**

In the switch in section, add reading `kivna/context.md` as a new step 3 (after "Read TODO.md", before "Check session logs"):

```markdown
### 3. Read working context

If `kivna/context.md` exists, read it. This has the decisions, reasoning, active threads, and assumptions from the last session. It's the richest source for picking up where things left off.
```

Renumber existing steps 3-6 to 4-7.

Replace the current step 6/Ask (which becomes step 7) with:

```markdown
### 7. Offer dian

Ask: "Start a dian session?" If yes, flow into dian orient. If no, stop — user wants to do something quick without full session discipline.
```

**Step 3: Commit**

```bash
git add skills/switch/SKILL.md
git commit -m "feat: add context.md to switch in/out flow, offer dian on arrival"
```

---

### Task 4: Update startup skill — scaffold context.md and checkpoints directory

**Files:**
- Modify: `skills/startup/SKILL.md:28-32` (directory structure)
- Modify: `skills/startup/SKILL.md:102-114` (after .sotu file, add context.md)

**Step 1: Update directory structure (lines 28-32)**

Replace the directory creation list with:

```
kivna/
kivna/sessions/
kivna/checkpoints/
docs/
```

**Step 2: Add context.md to the files created (after .sotu, before step 5)**

Add a new file to the "Create files" section:

```markdown
**`kivna/context.md`**

```markdown
# Context — [Project Name]

## Current Focus
[Not started yet — run `/kerd:dian` to begin your first session.]

## Mental Model
[Will be populated as decisions are made.]

## Decisions
[No decisions yet.]

## Rejected Approaches
[Nothing rejected yet.]

## Working Assumptions
[No assumptions recorded yet.]

## Active Threads
[No active work yet.]

## Open Questions
[No open questions yet.]
```
```

**Step 3: Commit**

```bash
git add skills/startup/SKILL.md
git commit -m "feat: add context.md and checkpoints/ to startup scaffold"
```

---

### Task 5: Update README.md — document context checkpointing

**Files:**
- Modify: `README.md:17-26` (dian section)
- Modify: `README.md:39-57` (kivna section)
- Modify: `README.md:95-99` (How They Fit Together)

**Step 1: Update dian section (lines 17-26)**

Add mention of context checkpointing to the dian description. After the paragraph about close-out and playbook, add:

```markdown
During execution, dian auto-checkpoints your working context to `kivna/context.md` after each task completes — decisions made, approaches rejected, assumptions discovered, what's in progress. On close-out it finalizes the context for the next session. If context compacts mid-session, re-read context.md and you're caught up.
```

**Step 2: Update kivna section (lines 39-57)**

Update to mention four modes instead of three. Add checkpoint to the description and folder structure. Add `/kivna checkpoint` to the command examples.

Update the opening paragraph to mention four modes and add checkpoint. Update the folder structure to include `context.md` and `checkpoints/`. Add a checkpoint example to the command block:

```
/kivna checkpoint                                  # snapshot working context
```

**Step 3: Update "How They Fit Together" (lines 95-99)**

Weave context checkpointing into the narrative. Add mention of context.md being read on switch in and checkpointed during work.

**Step 4: Commit**

```bash
git add README.md
git commit -m "docs: document context checkpointing in README"
```

---

### Task 6: Update CLAUDE.md and playbook — reflect new structure

**Files:**
- Modify: `CLAUDE.md:34-43` (Project Structure)
- Modify: `docs/playbook.md:47-55` (Architecture directory layout)
- Modify: `docs/playbook.md:57-63` (skill descriptions)
- Modify: `docs/playbook.md:96-116` (Current Status)

**Step 1: Update CLAUDE.md Project Structure (lines 34-43)**

Add `kivna/context.md` and `kivna/checkpoints/` to the structure listing:

```
kivna/context.md  # living working context, overwritten each checkpoint
kivna/checkpoints/ # daily archives of previous context versions
```

**Step 2: Update playbook Architecture section**

Add `kivna/context.md` and `kivna/checkpoints/` to the directory layout. Update the kivna skill description to mention context checkpointing.

**Step 3: Update playbook Current Status**

Update version to 0.3.0. Add context checkpointing to the "Working" and "Recent changes" lists.

**Step 4: Commit**

```bash
git add CLAUDE.md docs/playbook.md
git commit -m "docs: update CLAUDE.md and playbook with context checkpoint structure"
```

---

### Task 7: Version bump to 0.3.0

**Files:**
- Modify: `.claude-plugin/plugin.json:4` (version)
- Modify: `.claude-plugin/marketplace.json:8` (metadata.version)
- Modify: `.claude-plugin/marketplace.json:18` (plugins[0].version)

**Step 1: Bump all three version locations from 0.2.4 to 0.3.0**

This is a MINOR bump — new feature (context checkpoints), new command (`/kivna checkpoint`), modified behavior in dian, switch, and startup.

**Step 2: Commit**

```bash
git add .claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "chore: bump version to 0.3.0"
```

---

### Task 8: Push and verify

**Step 1: Push to remote**

```bash
git push
```

**Step 2: Verify clean working tree**

```bash
git status
```

Expected: clean working tree, branch up to date with origin/main.
