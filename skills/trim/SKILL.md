---
name: trim
description: "Use when the user says 'trim', '/trim', 'token trim', or 'feature complete cleanup'. Archives completed feature docs, prunes stale CLAUDE.md content, cleans and consolidates memory files, and trims completed TODO items. Run this after every feature is shipped."
---

# Trim (Token Optimization — Light Pass)

A quick cleanup to run after each feature ships. Keeps active context lean without touching anything you still need.

## Steps

Work through each step in order. Confirm with the user before removing anything.

### 1. Archive completed feature docs

Scan for spec, plan, and design docs in these locations:
- `docs/` — files with "spec", "plan", or "design" in the filename, and anything under `docs/plans/`
- Project root — same naming patterns

**Archive criteria:** A doc is archivable if its feature is merged to main AND documented as complete in `docs/playbook.md` Current Status section. Do not archive docs for work-in-progress features or features awaiting code review.

For each archivable doc, **before moving it**, run the forward-looking content rescue (see step 1a below). Then:
- Create `docs/archive/` if it doesn't exist
- Move it to `docs/archive/`
- Skip anything still referenced in active backlog items in `TODO.md`

### 1a. Rescue forward-looking content

Before archiving any doc, scan it for content that is still relevant to the project's future even though the feature is complete. This includes:

- **Deferred tasks** — items explicitly marked as deferred, out-of-scope, or "later"
- **Future phase notes** — design decisions, constraints, or options noted for an upcoming phase
- **Known limitations** — documented gaps or tradeoffs that future work will need to address
- **Pending architectural decisions** — open questions or to-be-decided items
- **Cross-cutting concerns** — notes that will affect future features (e.g. "when we add X, remember Y")

For each piece of rescued content:
1. Append it to `docs/deferred.md` under a heading matching the source doc's feature name:
   ```
   ## <Feature Name> (from <source-doc-filename>)
   <rescued content, preserved verbatim or lightly summarized>
   ```
   Create `docs/deferred.md` with this header if it doesn't exist:
   ```
   # Deferred & Future Context

   Forward-looking notes rescued during trim passes. Check this file when starting
   new features — items here may affect design or unblock work.
   ```
2. Do **not** archive the doc until the rescue is complete.
3. If `docs/deferred.md` does not already appear in `CLAUDE.md`, append this line to the bottom of `CLAUDE.md` (under a `## Living Docs` section, creating it if needed):
   ```
   See `docs/deferred.md` for deferred tasks and forward-looking context from past features.
   ```

Present rescued items to the user before writing them, so they can discard anything that is truly dead.

### 2. Update archive index

After archiving, append a line to `docs/archive/INDEX.md` for each archived doc:
```
- <feature-name>: <relative path>
```
Create the file if it doesn't exist, with this header:
```
# Archive Index
```

### 3. Prune CLAUDE.md

Scan `CLAUDE.md` for feature-specific guidance blocks — instructions that described how to handle a feature that is now permanently in the codebase and no longer needs a reminder. Present each candidate to the user and remove only with their confirmation.

Do not remove:
- Design constraints
- Code conventions
- Doc impact table
- Token efficiency rules
- Session workflow

### 4. Clean and consolidate memory files

Locate the project's memory directory at `~/.claude/projects/<project-id>/memory/`, where `<project-id>` is derived from the project's working directory path (separators replaced by dashes). This directory lives inside `~/.claude/`, not inside the project repo itself. Read `MEMORY.md` for the index, then read each memory file's frontmatter and content.

#### 4a. Staleness scan

Check every memory file for staleness. Apply type-specific criteria:

| Type | Stale when | Caution level |
|------|-----------|---------------|
| `project_*.md` | Feature shipped and no longer actionable, decision reversed or superseded, information outdated by current codebase state | Normal — flag freely |
| `reference_*.md` | Tool/service/URL no longer used by the project, resource deprecated or moved | Normal — flag freely |
| `feedback_*.md` | Guidance fully codified in a CLAUDE.md rule or global rule file AND the memory adds nothing beyond what the rule says | High — only flag exact duplicates of existing rules. When in doubt, keep. |
| `user_*.md` | Never stale | Skip — never flag for removal |

For each stale candidate, present: the file name, its description from frontmatter, why it appears stale, and for feedback files, which rule file makes it redundant.

#### 4b. Consolidation scan

Look for memory files that overlap and could be merged:

- **Same topic, different files** — e.g., two `project_` files about the same feature, or two `feedback_` files about the same behavioral pattern
- **Subset relationship** — one file's content is entirely covered by another
- **Natural grouping** — several small related memories that would read better as one file (e.g., three feedback memories about subagent model selection → one combined file)

For each consolidation candidate, present: which files to merge, what the merged file would be named, and a brief preview of the merged content.

#### 4c. Execute with approval

Remove stale files and write consolidated files only with user confirmation. After changes:
1. Delete removed/merged source files
2. Write any new consolidated files with proper frontmatter (name, description, type)
3. Rewrite `MEMORY.md` index to reflect the new state — remove deleted entries, add consolidated entries, keep surviving entries unchanged

### 5. Trim TODO.md

Review `TODO.md`. Present checked-off items under completed session headers to the user and confirm they are safe to remove. Do not touch:
- Backlog items (checked or unchecked)
- Items in the current or next session

### 6. Safety gate

Dispatch a subagent (haiku model) with the following task:

> Read the current state of CLAUDE.md, the memory MEMORY.md index, TODO.md, docs/archive/INDEX.md, docs/deferred.md (if present), and docs/. Verify that /kerd:switch in would still have all context needed: project state, active feature, session notes, key decisions, architecture constraints. Check that any deferred/future-phase content from archived docs appears in docs/deferred.md and that CLAUDE.md references it. Also scan vault session logs from the last 3 months for any inline references to docs that were just archived — flag any that now point to archived locations. Report: CONTEXT INTACT or GAPS FOUND with specifics.

If the subagent reports GAPS FOUND, surface the issues to the user before finalizing any changes. Do not commit until the user confirms.

## After trim

Report a concise summary:
- N docs archived → listed by feature name
- N forward-looking items rescued → written to `docs/deferred.md`
- N CLAUDE.md blocks removed
- N memory entries removed, N consolidated
- N TODO items removed
- Safety gate result
