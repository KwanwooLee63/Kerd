# Skill Rename Implementation Plan

> **For Claude:** Execute tasks with parallel agents where possible.

**Goal:** Rename three skills to Gaelic names to avoid collisions with superpowers plugin: sotu→slainte, switch→seach, discover→lorg.

**Architecture:** Mechanical rename across directories, frontmatter, cross-references, docs, and manifests. Historical files (session logs, design docs) are NOT updated. The `.sotu` config file becomes `.slainte`. Old names added to tend's deprecated patterns.

**Version:** 0.11.0 (MINOR, renamed skill interfaces)

---

## Living files to update (in scope)

These files contain references that must be renamed:

- `skills/sotu/SKILL.md` → move to `skills/slainte/SKILL.md`, update frontmatter + internal refs
- `skills/switch/SKILL.md` → move to `skills/seach/SKILL.md`, update frontmatter + internal refs
- `skills/discover/SKILL.md` → move to `skills/lorg/SKILL.md`, update frontmatter + internal refs
- `skills/dian/SKILL.md` (refs to switch, sotu)
- `skills/kivna/SKILL.md` (refs to switch)
- `skills/tend/SKILL.md` (refs to sotu, switch, discover, `.sotu` config)
- `skills/skriv/SKILL.md` (no refs expected, verify)
- `README.md`
- `CLAUDE.md`
- `docs/playbook.md`
- `CHANGELOG.md` (add 0.11.0 entry, don't rewrite history)
- `TODO.md`
- `.claude-plugin/plugin.json` (version + description)
- `.claude-plugin/marketplace.json` (version + description)
- `docs/vault-spec.md` (no refs expected, verify)

## Historical files (out of scope)

Do NOT touch: `kivna/sessions/*`, `docs/plans/*` (except this plan). These are frozen records.

## Vault files to update

- `~/Obsidian/kerd/Kerd Status.md` (refs to skills)
- `~/Obsidian/kerd/Kerd.md` (MOC, if it references skill names)

---

### Task 1: Rename skill directories

Move the three skill directories:

```bash
git mv skills/sotu skills/slainte
git mv skills/switch skills/seach
git mv skills/discover skills/lorg
```

### Task 2: Update renamed skill SKILL.md files (3 files, parallel)

**Task 2a: skills/slainte/SKILL.md**
- Frontmatter `name: sotu` → `name: slainte`
- Frontmatter `description:` update trigger words to include "slainte" alongside "sotu", "audit", etc.
- Title: `# SOTU (State of the Union)` → `# Slainte (Project Health)`
- Add etymology line: From Irish "slàinte" (health). Pronounced "SLAHN-chuh".
- Replace all `/kerd:sotu` → `/kerd:slainte`
- Replace `.sotu` config file references → `.slainte`
- Replace `## sotu` section header in config example → `## slainte`... wait, actually `.slainte` is the file name but the section headers inside are area names (docs, code, site, deps, playbook). Those don't change.
- Actually: the `.sotu` filename in the config format section and Category 2 required files needs to become `.slainte`

**Task 2b: skills/seach/SKILL.md**
- Frontmatter `name: switch` → `name: seach`
- Frontmatter `description:` update trigger words to include "seach" alongside "switch", "switching machines", etc.
- Title: `# Switch (Machine Handoff)` → `# Seach (Machine Handoff)`
- Add etymology line: From Gaelic "seachad" (to pass, hand over). Pronounced "SHAKH".
- Replace all `/kerd:switch` → `/kerd:seach`
- Replace internal prose refs: "switch owns" → "seach owns", "switch's job" → "seach's job", etc.

**Task 2c: skills/lorg/SKILL.md**
- Frontmatter `name: discover` → `name: lorg`
- Frontmatter `description:` update trigger words to include "lorg" alongside "discover", "find skills", etc.
- Title: `# Discover (Skill Gap Analysis)` → `# Lorg (Skill Gap Analysis)`
- Add etymology line: From Gaelic "lorg" (to seek, track down). Pronounced "LORG".
- Replace all `/kerd:discover` → `/kerd:lorg`

### Task 3: Update cross-references in other skill files (4 files, parallel)

**Task 3a: skills/dian/SKILL.md**
- `/kerd:switch` → `/kerd:seach`
- "switch's job" → "seach's job"
- Any other switch/sotu/discover refs

**Task 3b: skills/kivna/SKILL.md**
- `/kerd:switch` → `/kerd:seach`
- Any other switch/sotu/discover refs

**Task 3c: skills/tend/SKILL.md**
- `/kerd:sotu` → `/kerd:slainte`
- `/kerd:switch` → `/kerd:seach`
- `/kerd:discover` → `/kerd:lorg`
- "sotu" in boundary description → "slainte"
- `.sotu` config file references → `.slainte`
- Add `.sotu` to Category 4 deprecated patterns list (with note: "renamed to `.slainte` in v0.11.0")
- Update Category 2 required files: `.sotu` → `.slainte`
- Update Category 2 template for `.slainte` config file (was `.sotu`)

**Task 3d: skills/skriv/SKILL.md**
- Verify no refs to switch/sotu/discover. If none, skip.

### Task 4: Update project docs (5 files, parallel)

**Task 4a: README.md**
- Section headers: `### sotu (...)` → `### slainte (...)`, `### switch (...)` → `### seach (...)`, `### discover (...)` → `### lorg (...)`
- All `/sotu` → `/slainte`, `/switch` → `/seach`, `/discover` → `/lorg`
- Naming table: update names and meanings
- All prose references to skill names
- "How They Fit Together" section: update all skill name references
- `.sotu` → `.slainte` where referenced

**Task 4b: CLAUDE.md**
- Update plugin description line if it mentions skill names
- Any refs to sotu/switch/discover as skill names

**Task 4c: docs/playbook.md**
- Skill list: update names
- All `/kerd:sotu` → `/kerd:slainte`, `/kerd:switch` → `/kerd:seach`, etc.
- `.sotu` → `.slainte`
- Recent changes list: don't rewrite, but update "Current Status" and skill list

**Task 4d: CHANGELOG.md**
- Add new 0.11.0 entry at top (do NOT rewrite historical entries)
- Entry content: renamed sotu→slainte, switch→seach, discover→lorg, .sotu→.slainte

**Task 4e: TODO.md**
- Update any refs to old skill names

### Task 5: Update manifests

**Files:** `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`

- Bump version to 0.11.0 (all three locations)
- Update description if it mentions skill names by name (currently it says "session discipline, machine handoff, knowledge management, project audits, human writing voice, structural health, and skill discovery" which doesn't name skills, so likely no change needed)

### Task 6: Update vault files

**Files:** `~/Obsidian/kerd/Kerd Status.md`, `~/Obsidian/kerd/Kerd.md`

- Update any references to old skill names
- Show user proposed changes, get approval before writing

### Task 7: Update docs/vault-spec.md

- Verify no refs to sotu/switch/discover. If none, skip.

### Task 8: Final verification

Run grep across all living files for old names:
- `grep -r "sotu" --include="*.md" --include="*.json"` (excluding sessions/, plans/)
- `grep -r "/kerd:switch" --include="*.md"`
- `grep -r "/kerd:discover" --include="*.md"`
- Verify new directories exist and old ones are gone
- Verify version is 0.11.0 in all three locations

### Task 9: Commit and push

```bash
git add -A
git commit -m "feat: rename sotu→slainte, switch→seach, discover→lorg (v0.11.0)"
git push
```

---

## Execution approach

Tasks 1 must go first (directory renames). Then Tasks 2-5 can run in parallel (7-8 agents). Task 6 needs user approval. Tasks 7-9 are sequential at the end.
