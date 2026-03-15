# Tend — Structural Health Check & Convergence

**Date:** 2026-03-15
**Replaces:** startup (skills/startup/SKILL.md)

## What It Is

`/kerd:tend` audits a repo's infrastructure against current Kerd conventions, shows a visual report of current vs expected state, and fixes with approval. Run it on day one or day 100 — same command, same result.

Use cases:
- New repo: sets up everything from scratch
- Existing repo after a Kerd version bump: picks up new conventions
- Anytime: checks for drift, stray files, deprecated patterns

Non-interactive by default. Infers project name from README.md heading, directory name, or `kivna/vault.json`. Only asks questions for brand new repos with no README (project name + one-line description).

## Boundary with SOTU

- **tend** — structure and plumbing (dirs, vault, config, naming, stray files, deprecated patterns)
- **sotu** — content (doc accuracy, staleness, consistency, CLAUDE.md sections)

## What It Checks

Seven categories, in order:

### 1. Directory structure
Required dirs exist: `kivna/`, `kivna/sessions/`, `docs/`

### 2. Required files
`README.md`, `CLAUDE.md`, `TODO.md`, `docs/playbook.md`, `.sotu`, `kivna/vault.json`

### 3. Vault integration
- `vault.json` exists and points to a real folder
- Vault folder at `~/ObsidianLLM/[folder]/` exists
- Vault-native files exist: MOC, Context.md, Log.md, Decisions.md
- Symlinks are current (no new `.md` files in repo missing from vault)

### 4. Deprecated patterns
Old-era files that should be removed:
- `kivna/context.md`
- `kivna/checkpoints/`
- `kivna/memories/`
- `commands/`

### 5. Naming consistency
- Mixed case in filenames (e.g., `Setup.md` vs `setup.md`)
- Inconsistent separators (kebab-case vs snake_case vs spaces)
- Files that don't follow the project's dominant naming pattern

### 6. Stray & stale files
- Screenshots, temp files, `.DS_Store`, `*.log`, `*.tmp` in the repo root or committed dirs
- Files not referenced anywhere (orphaned docs, unused configs)
- Files with no commits in 60+ days that aren't docs (potential dead code/cruft)

### 7. .gitignore hygiene
- `kivna/input/`, `kivna/output/` should be ignored
- Common patterns missing (`.DS_Store`, `*.log`, OS files)
- Untracked files that suggest a missing ignore rule

## Report Format

Visual report grouped by status. Tables only appear for categories with issues. Passing categories stay as one-liners.

```
┌─────────────────────────────────────────────────┐
│  /kerd:tend — krutho-founders                   │
└─────────────────────────────────────────────────┘

✓ Directory structure
  kivna/  kivna/sessions/  docs/

✓ Required files
  README.md  CLAUDE.md  TODO.md  docs/playbook.md  .sotu

✗ Vault integration
  ┌──────────────────┬───────────────┬─────────────────────────────┐
  │ Item             │ Current       │ Proposed                    │
  ├──────────────────┼───────────────┼─────────────────────────────┤
  │ vault.json       │ missing       │ create with folder:         │
  │                  │               │ krutho-founders             │
  │ vault symlinks   │ 4 of 7 .md   │ add 3 missing symlinks      │
  │                  │ files linked  │                             │
  └──────────────────┴───────────────┴─────────────────────────────┘
  Why: vault.json connects this repo to its Obsidian vault.
       Symlinks keep vault graph in sync with repo docs.

⚠ Deprecated patterns
  ┌──────────────────┬───────────────┬─────────────────────────────┐
  │ Item             │ Current       │ Proposed                    │
  ├──────────────────┼───────────────┼─────────────────────────────┤
  │ kivna/context.md │ exists        │ remove (replaced by vault   │
  │                  │               │ Context.md)                 │
  │ kivna/checkpoints│ 3 files       │ remove (vault is append-    │
  │                  │               │ only, replaces checkpoints) │
  └──────────────────┴───────────────┴─────────────────────────────┘

⚠ Stray & stale files
  ┌──────────────────┬───────────────┬─────────────────────────────┐
  │ Item             │ Current       │ Proposed                    │
  ├──────────────────┼───────────────┼─────────────────────────────┤
  │ Screenshot*.png  │ 2 files in    │ delete or move to           │
  │                  │ repo root     │ kivna/input/                │
  │ .DS_Store        │ 3 locations   │ add to .gitignore, remove   │
  └──────────────────┴───────────────┴─────────────────────────────┘

✓ Naming consistency
✓ .gitignore hygiene

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 3 passing  ·  2 warnings  ·  1 failing
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Fix all? [yes / pick individually / skip]
```

Symbols:
- `✓` — passing, no action needed
- `✗` — failing, needs creation or fix
- `⚠` — warning, needs cleanup

## Fix Flow

**"yes"** — Fix everything. Create missing files/dirs, run kivna scaffold if vault needs setup, remove deprecated files, clean up strays, update `.gitignore`. Stage all changes, show summary.

**"pick"** — Re-display each `✗`/`⚠` item individually. Ask yes/no for each. Apply only approved fixes.

**"skip"** — Do nothing. Report is the value.

## New Repo Behavior

If tend detects very little exists (no README, no CLAUDE.md, no docs/), it asks:
- **Project name**
- **One-line description**

Then creates everything using the same templates startup currently has. Same report format — more items showing `missing → create`.

## No Commit

Tend does NOT commit or push. It makes structural changes and stops. Switch owns all git boundary operations (established Kerd convention). For a new repo: `/kerd:tend` then `/kerd:switch out`.

## Migration from Startup

- Delete `skills/startup/SKILL.md`
- Create `skills/tend/SKILL.md`
- Update README.md: replace startup section with tend
- Update CLAUDE.md: remove startup references
- Update cross-skill references in other skills (switch, dian) if any reference startup
- Update `.claude-plugin/plugin.json` and `marketplace.json`
- Version bump (minor — new skill, changed behavior)
