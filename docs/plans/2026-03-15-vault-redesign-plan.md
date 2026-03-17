# Vault Redesign Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Align all Kerd skills with the new vault philosophy — human knowledge base, not machine sync layer. Remove symlinks, append-only files, and per-task vault writes. Add approval-gated Status.md overwrites.

**Architecture:** The vault spec (`docs/vault-spec.md`) is the canonical reference. Skills reference it for philosophy. Skills implement mechanics: kivna owns vault reads/writes, dian and switch call `/kerd:kivna save` at session boundaries, tend audits vault structure against the spec.

**Tech Stack:** Pure markdown (SKILL.md files, docs, README, CHANGELOG)

---

### Task 1: Rewrite kivna SKILL.md

**Files:**
- Modify: `skills/kivna/SKILL.md` (full rewrite of scaffold, save, and notes sections)

**Step 1: Rewrite the file**

Replace the entire SKILL.md with the updated version. Key changes:

**Frontmatter** — update trigger description to remove "saving working context" and "snapshot" language, add "status update":
```yaml
---
name: kivna
description: "Use when the user says 'kivna', 'vault', 'save context', 'save', 'scaffold', 'import', 'export context', or needs to manage project knowledge in the Obsidian vault — updating project status, importing external files, exporting session context, or setting up the vault."
---
```

**Opening paragraph** — change from "All durable context, decisions, and activity logs live in the Obsidian vault" to "The vault is a human knowledge base. Every file answers a question someone would actually ask. Files are living — updated in place, not appended to."

**Vault Discovery** — unchanged.

**Folder Convention** — remove "symlinked to vault" note from `kivna/sessions/`:
```
- `kivna/vault.json` — vault config (committed to git)
- `kivna/sessions/` — session logs written by switch (committed)
- `kivna/.active-modes` — ephemeral mode state (not committed)
- `kivna/input/` — drop files here for import (gitignored, transit folder)
- `kivna/output/` — exports land here (gitignored, transit folder)
```

**`/kivna save` section** — complete rewrite:

1. Discover vault (unchanged).
2. Read current `[Name] Status.md`. Draft an updated version reflecting the current session state. Show the user a diff or summary of what changed. Ask for approval before overwriting. If the file doesn't exist, create it (still ask approval for the content). Status.md format:
   ```markdown
   # [Name] Status

   ## Where We Are
   [Current state — what's working, what was just completed]

   ## What's Open
   [Open questions, blockers, unresolved items]

   ## What's Next
   [Prioritized next steps]
   ```
3. Review the session for new knowledge that belongs in other vault files. For each piece of knowledge, identify the target file (Architecture Decisions, Playbook, Positioning Contract, etc.), show the proposed addition, and ask for approval. Create the file if it doesn't exist (with user approval). Skip if no new knowledge surfaced.
4. Update MOC if new vault files were created this session — add links. Don't scan repo files or manage symlinks.
5. Confirm: "Saved to vault: Status updated, N files updated, MOC refreshed."

**`/kivna scaffold` section** — complete rewrite:

1. Create the vault folder at `~/Obsidian/[folder]/`.
2. Create `[Name].md` (MOC) — links to Status.md only (nothing else exists yet). Under 40 lines.
3. Create `[Name] Status.md` — seed from repo state (read git log, TODO.md, CLAUDE.md, README.md). Write in human form — a summary someone could read cold. Ask for approval of the draft before writing.
4. Write `kivna/vault.json` (unchanged).
5. Suggest optional files based on what the project looks like. Examples:
   - "This looks like a code plugin — consider `[Name] Architecture Decisions.md` and `[Name] Usage Guide.md`"
   - "This has a company/product — consider `[Company] Playbook.md` and `[Company] Company.md`"
   Do NOT create these files. Just suggest. They get added as knowledge accumulates.
6. Confirm: report vault path, files created, suggestions made.

**`/kivna in` and `/kivna out`** — unchanged. Remove the line in `/kivna in` step 6 that says "Flag decisions for `Decisions.md` approval using the same mechanic as `/kivna save` step 4." Replace with: "If import surfaces knowledge that belongs in a vault file, note it for the user — they can update the vault with `/kerd:kivna save` later."

**Notes section** — rewrite completely:
- Remove all references to Context.md, Log.md, Decisions.md, symlinks, append-only, checkpoint mechanic
- Add: "The vault spec at `docs/vault-spec.md` defines what belongs in the vault and what doesn't. Kivna implements the mechanics; the spec defines the philosophy."
- Add: "Status.md is overwritten, not appended to. Always show the user what's changing and get approval before overwriting."
- Add: "Vault files use self-identifying names — `[Project] Status.md`, not `Status.md`. This prevents collisions in Obsidian's quick switcher across vaults."
- Add: "No symlinks to repo files. The vault contains knowledge written in human form, not mirrors of machine-readable repo files."
- Keep: notes about kivna/input and kivna/output being gitignored, exports in plain markdown, import filtering guidance, wikilink conventions.
- Update cold-start note: "On cold start, read vault `[Name] Status.md` and scan the MOC to discover other relevant vault files."

**Step 2: Verify**

Read the modified file. Check:
- No references to Context.md, Log.md, Decisions.md (as generic names)
- No references to symlinks or symlink scanning
- No references to append-only behavior
- Save mechanic shows diff and asks approval before overwriting
- Scaffold creates only MOC + Status.md
- All cross-skill references use `/kerd:` prefix

**Step 3: Commit**

```bash
git add skills/kivna/SKILL.md
git commit -m "feat: rewrite kivna for vault redesign — living files, no symlinks, approval-gated overwrites"
```

---

### Task 2: Update dian SKILL.md

**Files:**
- Modify: `skills/dian/SKILL.md:38-43` (orient — vault reads)
- Modify: `skills/dian/SKILL.md:76-81` (execute — remove per-task vault writes)
- Modify: `skills/dian/SKILL.md:89-93` (close-out — single vault write)

**Step 1: Update orient section (lines 38-43)**

Replace the vault reading instructions. Old:
```
3. Vault `[Name] Context.md` — working context from the last session. Discover the vault path using `kivna/vault.json` or convention (see `/kerd:kivna` vault discovery). Read the latest section (the first `## YYYY-MM-DD` block). Also read vault `Decisions.md` for project rules and conventions.
```

New:
```
3. Vault — discover the vault path using `kivna/vault.json` or convention (see `/kerd:kivna` vault discovery). Read `[Name] Status.md` for where the project stands. Read the MOC (`[Name].md`) to discover what other vault files exist (Architecture Decisions, Playbook, etc.) and read any that are relevant to the planned work.
```

**Step 2: Update execute section (lines 76-81)**

Remove auto-save. Old:
```
**Record decisions immediately.** When a significant decision is made during execution (architecture choice, rejected approach, key trade-off), decisions go into the vault Context.md section (via the `/kerd:kivna save` mechanic) AND get flagged for vault Decisions.md approval. Don't defer decision recording to close-out — decisions lose their reasoning if you wait.
```

New:
```
**Record decisions immediately.** When a significant decision is made during execution (architecture choice, rejected approach, key trade-off), record it in the session log (`kivna/sessions/`) and in TODO.md context. Don't defer decision recording to close-out — decisions lose their reasoning if you wait. The vault gets updated once at close-out via `/kerd:kivna save`.
```

Remove auto-save line. Old:
```
**Auto-save:** After completing each task in the plan, save to the Obsidian vault using the `/kerd:kivna save` mechanic (prepend to vault Context.md, update Log.md, flag decisions). This ensures context survives compaction mid-session.
```

New:
```
**No mid-session vault writes.** Work accumulates in repo-side files (session log, TODO.md) during execution. The vault gets one clean update at close-out. This keeps the vault lean and searchable — one session, one update.
```

**Step 3: Update close-out section (lines 89-93)**

Replace step 3. Old:
```
3. **Finalize context** — write a close-out section to the vault `[Name] Context.md` via `/kerd:kivna save`. Mark "Where We Are" as session complete. Prepend session summary to vault `[Name] Log.md`. This becomes the cold-start context for the next session.
```

New:
```
3. **Update the vault** — call `/kerd:kivna save` once. This updates vault `[Name] Status.md` (with approval) and proposes updates to any other vault files where new knowledge belongs. This is the single vault write for the session.
```

**Step 4: Verify**

Read the modified file. Check:
- Orient reads Status.md + MOC, not Context.md + Decisions.md
- Execute has no vault writes, records decisions to repo-side files
- Close-out calls `/kerd:kivna save` once
- No references to Context.md, Log.md, or append-only

**Step 5: Commit**

```bash
git add skills/dian/SKILL.md
git commit -m "feat: update dian for vault redesign — read Status.md, no mid-session vault writes"
```

---

### Task 3: Update switch SKILL.md

**Files:**
- Modify: `skills/switch/SKILL.md:56-58` (switch-out step 3)
- Modify: `skills/switch/SKILL.md:73-76` (switch-out step 5 — reflection)
- Modify: `skills/switch/SKILL.md:112-117` (switch-in steps 4-5)
- Modify: `skills/switch/SKILL.md:144-152` (fallback behavior)

**Step 1: Update switch-out step 3 (line 56-58)**

Old:
```
### 3. Ensure context is current

If a `/kerd:dian` session was active, close-out should have already saved to the vault — verify the latest section in vault `[Name] Context.md` reflects this session and move on. If no `/kerd:dian` session was running (quick switch without formal session), save context now using `/kerd:kivna save` (which writes to the vault). Discover the vault path using `kivna/vault.json` or convention (see `/kerd:kivna` vault discovery).
```

New:
```
### 3. Update the vault

If a `/kerd:dian` session was active, close-out should have already called `/kerd:kivna save`. Verify vault `[Name] Status.md` reflects this session and move on. If no `/kerd:dian` session was running (quick switch without formal session), call `/kerd:kivna save` now — this updates Status.md and proposes updates to other vault files, each with user approval.
```

**Step 2: Update switch-out step 5 reflection (lines 73-76)**

Old:
```
- **Conventions and patterns** → flag for vault `Decisions.md` with user approval (using the `/kerd:kivna save` decision-flagging mechanic)
```

New:
```
- **Conventions and patterns** → flag for the appropriate vault file (Architecture Decisions, Positioning Contract, etc.) — these get proposed during the `/kerd:kivna save` step
```

**Step 3: Update switch-in steps 4-5 (lines 112-117)**

Old:
```
### 4. Read working context

Read the vault `[Name] Context.md` (latest section — the first `## YYYY-MM-DD` block). This has the working state from the last session. Discover the vault path using `kivna/vault.json` or convention (see `/kerd:kivna` vault discovery). Also read vault `[Name] Log.md` for recent activity at a glance.

### 5. Read vault decisions

Read vault `Decisions.md` for project conventions and rules.
```

New:
```
### 4. Read vault

Discover the vault path using `kivna/vault.json` or convention (see `/kerd:kivna` vault discovery). Read `[Name] Status.md` for where the project stands. Read the MOC (`[Name].md`) to discover what other vault files exist and read any that are relevant (Architecture Decisions, Playbook, etc.).

### 5. (removed — merged into step 4)
```

Renumber subsequent steps (6→5, 7→6, 8→7, 9→8, 10→9).

**Step 4: Update fallback behavior (lines 144-152)**

Old:
```
If no vault is found (no `kivna/vault.json` and no vault folder at `~/Obsidian/[folder]/`), fall back to reading `kivna/context.md` if it exists. Report this gracefully — suggest running `/kerd:kivna scaffold` to set up the vault.
```

New:
```
If no vault is found (no `kivna/vault.json` and no vault folder at `~/Obsidian/[folder]/`), report this gracefully — suggest running `/kerd:kivna scaffold` to set up the vault.
```

(Remove the `kivna/context.md` fallback — that file no longer exists.)

**Step 5: Verify**

Read the modified file. Check:
- Switch-out calls `/kerd:kivna save`, no direct vault file writes
- Switch-in reads Status.md + MOC, not Context.md + Log.md + Decisions.md
- Steps are correctly renumbered
- Fallback doesn't reference kivna/context.md
- No references to Context.md, Log.md, or append-only

**Step 6: Commit**

```bash
git add skills/switch/SKILL.md
git commit -m "feat: update switch for vault redesign — read Status.md, delegate vault writes to kivna save"
```

---

### Task 4: Update tend SKILL.md

**Files:**
- Modify: `skills/tend/SKILL.md:149-175` (Category 3: Vault integration)
- Modify: `skills/tend/SKILL.md:177-183` (Category 4: Deprecated patterns)
- Modify: `skills/tend/SKILL.md:230-246` (report example)

**Step 1: Rewrite Category 3 (lines 149-175)**

Old category checks for vault-native files (Context.md, Log.md, Decisions.md) and missing symlinks.

New:
```
#### Category 3: Vault integration

Check:
- `kivna/vault.json` exists and is valid JSON with `vault`, `folder`, `name` fields
- The vault folder at the resolved path exists on disk
- Required vault files exist: `[Name].md` (MOC), `[Name] Status.md`
- **No symlinks** — scan the vault folder for symlinks pointing to the repo. Each symlink is a violation.
- **No banned files** — check for files that don't belong in the vault: `CLAUDE.md`, `README.md`, `TODO.md`, `Context.md`, `[Name] Context.md`, `[Name] Log.md`, `Log.md`, session export files, any file whose name doesn't start with the project/company name (generic names like `Decisions.md`, `Notes.md`)
- **Self-identifying filenames** — every file in the vault folder (except the MOC) should start with the project or company name. Flag files that would collide across vaults in Obsidian's quick switcher.
- **MOC links resolve** — every `[[wikilink]]` in the MOC should point to a file that exists in the vault folder.
- **No append-only patterns** — flag files with multiple dated `## YYYY-MM-DD` section headers (remnants of old pattern).

If `kivna/vault.json` does not exist, report with the same advisory context as before (unchanged).

If vault needs full setup, the fix is to run the `/kerd:kivna scaffold` mechanic.
```

**Step 2: Update Category 4 deprecated patterns (lines 177-183)**

Add new deprecated items:
```
#### Category 4: Deprecated patterns

Detect files/dirs from older Kerd versions:
- `kivna/context.md` — replaced by vault Status.md in v0.10.0 (was vault Context.md in v0.7.0)
- `kivna/checkpoints/` — replaced by vault Status.md in v0.10.0 (was vault Context.md in v0.7.0)
- `kivna/memories/` — replaced by vault in v0.7.0
- `commands/` — removed in v0.7.0, plugin system loads skills directly
```

**Step 3: Update report example (lines 230-246)**

Replace the vault integration example in the report:
```
✗ Vault integration
  ┌──────────────────┬───────────────┬─────────────────────────────┐
  │ Item             │ Current       │ Proposed                    │
  ├──────────────────┼───────────────┼─────────────────────────────┤
  │ symlinks         │ 8 found       │ remove all (vault spec      │
  │                  │               │ prohibits repo symlinks)    │
  │ Context.md       │ exists        │ remove (replaced by         │
  │                  │               │ Status.md)                  │
  │ Log.md           │ exists        │ remove (no replacement —    │
  │                  │               │ git log is authoritative)   │
  │ Decisions.md     │ generic name  │ rename to [Project]         │
  │                  │               │ Architecture Decisions.md   │
  └──────────────────┴───────────────┴─────────────────────────────┘
  Why: vault spec requires self-identifying filenames, no symlinks,
       no append-only files. See docs/vault-spec.md.
```

**Step 4: Update notes at bottom of file**

Add to the Notes section:
```
- The vault spec at `docs/vault-spec.md` defines what belongs in the vault. Tend checks structure against this spec.
```

**Step 5: Verify**

Read the modified file. Check:
- Category 3 flags symlinks as violations, not missing symlinks
- Category 3 flags banned/generic filenames
- Category 3 checks MOC link resolution
- Category 4 deprecated patterns are up to date
- Report example shows the new violation types

**Step 6: Commit**

```bash
git add skills/tend/SKILL.md
git commit -m "feat: update tend vault audit — flag symlinks and generic names as violations"
```

---

### Task 5: Update README.md

**Files:**
- Modify: `README.md` (kivna section, dian section, "How They Fit Together" section)

**Step 1: Update kivna section (lines 43-62)**

Replace the kivna description. New:

```markdown
### kivna — Knowledge Management

Kivna owns the project's knowledge layer, stored in an Obsidian vault at `~/Obsidian/[project]/`. The vault is a human knowledge base — every file answers a question someone would actually ask. No symlinks, no append-only logs, no session dumps. Files are living, updated in place with approval.

Save (`/kivna save`) updates the vault's Status.md and proposes updates to other vault files (Architecture Decisions, Playbook, etc.) — each change shown and approved before writing. This is the same save mechanic dian and switch use at session boundaries. Scaffold (`/kivna scaffold`) creates the vault folder with a MOC and Status.md, then suggests what other files might fit the project. Import (`/kivna in`) reads files from `kivna/input/` and integrates relevant knowledge. Export (`/kivna out`) packages your session for another LLM.

The folder structure:

\```
kivna/
  vault.json   # vault config (points to ~/Obsidian/[project]/)
  sessions/    # session logs from switch (committed)
  input/       # drop files here for import (gitignored)
  output/      # exports land here (gitignored)
\```

\```
/kivna in                                          # import from inbox
/kivna out                                         # export session context
/kivna save                                        # update vault
/kivna scaffold                                    # set up Obsidian vault
\```
```

**Step 2: Update dian section (lines 16-31)**

Replace the paragraph about auto-checkpointing. Old:
```
During execution, dian auto-checkpoints your working context to the Obsidian vault after each task completes — decisions made, approaches rejected, assumptions discovered, what's in progress. On close-out it saves the final context to the vault for the next session. If context compacts mid-session, re-read vault Context.md and you're caught up.
```

New:
```
During execution, decisions and progress accumulate in repo-side files (session logs, TODO.md). On close-out, dian calls `/kivna save` once — updating the vault's Status.md and proposing updates to any other vault files where new knowledge belongs. One clean vault update per session, not ten incremental dumps.
```

**Step 3: Update switch section (lines 33-41)**

Update the reference to vault Context.md. Old:
```
It also reads vault Context.md — the decisions, reasoning, and working assumptions from last time — and reports any active modes left from a previous session.
```

New:
```
It also reads vault Status.md — where the project stands and what's next — and reports any active modes left from a previous session.
```

**Step 4: Update "How They Fit Together" section (lines 114-116)**

Old:
```
Day to day: you sit down at your laptop and run `/switch in`. It pulls, reads the session logs, tells you what happened last time. It also reads vault Context.md — the decisions, reasoning, and working assumptions from last time — and reports any active modes left from a previous session. Then it offers to start a dian session. You run `/dian` to plan the session. Mid-work, you make a decision worth remembering, so you run `/kivna save`. When the work is done, dian's close-out updates the playbook and saves to the vault with the session's full context. You run `/sotu docs` to check nothing drifted. Then `/switch out` commits, pushes, and writes the session log. Tomorrow, different machine, same state. The playbook grows with every session — if someone else picks up the project, they can rebuild it from that doc alone. Periodically run `/discover` to check if new skills have emerged that would help with the project.
```

New:
```
Day to day: you sit down at your laptop and run `/switch in`. It pulls, reads the session logs, tells you what happened last time. It reads vault Status.md — where the project stands and what's next — plus any other vault files relevant to the work. Then it offers to start a dian session. You run `/dian` to plan the session. Work happens, decisions get recorded in session logs and TODO.md. When the work is done, dian's close-out updates the playbook and calls `/kivna save` to update the vault — one clean write with approval. You run `/sotu docs` to check nothing drifted. Then `/switch out` commits, pushes, and writes the session log. Tomorrow, different machine, same state. Periodically run `/discover` to check if new skills have emerged that would help with the project.
```

**Step 5: Verify**

Read the modified file. Check:
- No references to Context.md, Log.md, symlinks, append-only, auto-checkpoint
- kivna description matches new behavior
- "How They Fit Together" narrative is accurate

**Step 6: Commit**

```bash
git add README.md
git commit -m "docs: update README for vault redesign — living files, no symlinks"
```

---

### Task 6: Update playbook, CLAUDE.md, and CHANGELOG

**Files:**
- Modify: `docs/playbook.md:56` (vault file references in Architecture section)
- Modify: `docs/playbook.md:98-124` (Current Status section)
- Modify: `CHANGELOG.md` (add 0.10.0 entry at top)

**Step 1: Update playbook Architecture section (line 56)**

Old:
```
The project's durable knowledge layer lives in the Obsidian vault at `~/Obsidian/kerd/`. Kivna reads and writes vault files (`Kerd Context.md`, `Kerd Log.md`, `Decisions.md`). The vault config is at `kivna/vault.json`. See `/kerd:kivna` for details.
```

New:
```
The project's knowledge layer lives in the Obsidian vault at `~/Obsidian/kerd/`. The vault is a human knowledge base — living files updated in place, not append-only dumps. Kivna reads and writes vault files (`Kerd Status.md`, plus optional domain files like Architecture Decisions). The vault spec at `docs/vault-spec.md` defines what belongs. The vault config is at `kivna/vault.json`. See `/kerd:kivna` for details.
```

**Step 2: Update playbook skill description for kivna (line 62)**

Old:
```
- **kivna** — knowledge management (Obsidian vault integration: context, decisions, activity log, import/export)
```

New:
```
- **kivna** — knowledge management (Obsidian vault: living Status.md, domain knowledge files, import/export)
```

**Step 3: Update playbook Gotchas — vault path convention (line 95)**

Old:
```
- **Vault path convention** — default vault path is `~/Obsidian/`. Kivna scaffold asks for the location if it doesn't exist. All vault.json files point here. If you rename or move the vault folder, update vault.json in every repo.
```

New:
```
- **Vault path convention** — default vault path is `~/Obsidian/`. Kivna scaffold asks for the location if it doesn't exist. All vault.json files point here. If you rename or move the vault folder, update vault.json in every repo.
- **Vault spec** — the vault spec at `docs/vault-spec.md` defines what belongs in the vault. No symlinks, no append-only files, no generic filenames. When in doubt, check the spec.
```

**Step 4: Update playbook Current Status section**

Update version to 0.10.0. Update "Working" to reflect new vault behavior. Add v0.10.0 to recent changes.

**Step 5: Add CHANGELOG entry**

Prepend to CHANGELOG.md:
```markdown
## 0.10.0

**Vault redesign** — human knowledge base, not machine sync layer.

- Rewrote kivna: scaffold creates MOC + Status.md only (no symlinks, no Context.md/Log.md/Decisions.md), save overwrites Status.md with approval and proposes updates to domain files
- Updated dian: orient reads Status.md + MOC, execute has no vault writes, close-out calls `/kerd:kivna save` once
- Updated switch: in reads Status.md + MOC, out delegates vault writes to `/kerd:kivna save`
- Updated tend: vault audit flags symlinks and generic filenames as violations, checks MOC link resolution, detects append-only remnants
- Added vault spec at `docs/vault-spec.md` — canonical reference for vault philosophy and file types
- Added vault redesign design doc at `docs/plans/2026-03-15-vault-redesign.md`
```

**Step 6: Verify**

Read playbook and CHANGELOG. Check:
- No references to Context.md, Log.md, or generic Decisions.md
- Version is 0.10.0 throughout playbook Current Status
- CHANGELOG entry is accurate

**Step 7: Commit**

```bash
git add docs/playbook.md CHANGELOG.md
git commit -m "docs: update playbook and changelog for vault redesign (v0.10.0)"
```

---

### Task 7: Version bump and description update

**Files:**
- Modify: `.claude-plugin/plugin.json:4` (version)
- Modify: `.claude-plugin/marketplace.json:7` (metadata.version)
- Modify: `.claude-plugin/marketplace.json:14` (plugins[0].version)

**Step 1: Bump version to 0.10.0 in all three locations**

plugin.json:
```json
"version": "0.10.0",
```

marketplace.json metadata:
```json
"version": "0.10.0"
```

marketplace.json plugins[0]:
```json
"version": "0.10.0",
```

**Step 2: Verify**

Run: `grep -r "0.10.0" .claude-plugin/` — should show exactly 3 matches.
Run: `grep -r "0.9.2" .claude-plugin/` — should show 0 matches.

**Step 3: Commit**

```bash
git add .claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "chore: bump version to 0.10.0 for vault redesign"
```

---

### Task 8: Commit design doc and vault spec

**Files:**
- Stage: `docs/plans/2026-03-15-vault-redesign.md` (already created)
- Stage: `docs/plans/2026-03-15-vault-redesign-plan.md` (this plan)
- Stage: `docs/vault-spec.md` (already created)

**Step 1: Commit**

```bash
git add docs/plans/2026-03-15-vault-redesign.md docs/plans/2026-03-15-vault-redesign-plan.md docs/vault-spec.md
git commit -m "docs: add vault redesign design doc, implementation plan, and vault spec"
```

---

### Build Sequence

Tasks 1-4 (skill files) are independent — can be done in parallel.
Task 5 (README) depends on tasks 1-4 being finalized (to match descriptions).
Task 6 (playbook/changelog) depends on tasks 1-4.
Task 7 (version bump) depends on all other tasks.
Task 8 (design docs) is independent — can be done first or last.

Recommended order for serial execution: 8 → 1 → 2 → 3 → 4 → 5 → 6 → 7
