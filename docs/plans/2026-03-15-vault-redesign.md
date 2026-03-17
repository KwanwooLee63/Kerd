# Vault Redesign — Human Knowledge, Not Machine Plumbing

**Date:** 2026-03-15

## What Changed

The Obsidian vault shifts from a machine sync layer (symlinks, append-only context dumps, one-liner logs) to a human knowledge base. Every file answers a question someone would actually ask. Files are living — updated in place, not appended to. The vault stays lean and searchable.

Reference implementation: `~/Obsidian/krutho-strategy/`

## Governing Principles

- No symlinks to repo files
- No append-only files or dated snapshots
- No session exports or LLM artifacts
- No generic filenames — every name self-identifies in Obsidian's quick switcher across vaults
- No files for things that haven't happened yet — the vault reflects what is known
- If a file only makes sense with context from another system, it doesn't belong here

**Repo owns:** session logs, TODO.md, context dumps, operational plumbing, LLM handoff artifacts. These accumulate freely during work.

**Vault owns:** project knowledge written in human form. Updated once per session at close-out. Never automatically — always with approval before overwriting.

## Vault File Types

### Always (every project)

**MOC:** `[Project].md`
Entry point. Links to every other vault file with one-line descriptions. Under 40 lines.

**Status:** `[Project] Status.md`
Living summary: where we are, what's working, what's open, what's next. Two screens max. Overwritten each session (with approval), not appended to.

### Optional (based on project type)

| File | When |
|------|------|
| `[Project] Architecture Decisions.md` | Code/plugin projects. Design choices with rationale. |
| `[Company] Playbook.md` | Company/product projects. The bible: descriptions, messaging, voice, proof points. |
| `[Company] Company.md` | What this thing is, who built it, history. |
| `[Project] Positioning Contract.md` | Language rules, framing decisions. |
| `[Project] Solution Overview.md` | Technical proposals, human-readable. |
| `[Project] Usage Guide.md` | Tools/products with users. |
| `[Project] Install Guide.md` | Tools/products with users. |
| Client subfolders (`client-name/`) | Engagement, Opportunity, Workshop, Research files. |
| Research files (named by topic) | In `research/` or alongside what they support. |

## Vault Spec

The full vault specification (principles, file types, quality test, growth rules) lives at `docs/vault-spec.md` in the Kerd repo. Kivna scaffold references it. Skills don't duplicate it — they reference it and implement the mechanics.

## Skill Changes

### kivna

**scaffold:**
- Creates `[Project].md` (MOC) and `[Project] Status.md` only
- No symlinks. No Context.md, Log.md, or Decisions.md
- Seeds Status.md from repo state (git log, TODO.md, CLAUDE.md) in human form
- Seeds MOC with link to Status.md
- After creation, suggests optional files based on project type
- Still creates `kivna/vault.json` in the repo

**save:**
- Reads current vault Status.md, drafts an updated version, shows diff, asks for approval before overwriting
- Reviews the session for new knowledge that belongs in other vault files — suggests updates to specific files, each with approval
- Updates MOC if new vault files were created (add links)
- No symlink scanning, no Log.md entries, no append-only writes
- Called by dian close-out and switch-out, or manually

**in / out:**
- Unchanged. Repo-side import/export.

### dian

**Orient (cold start):**
- Read vault Status.md — where are we
- Read vault MOC — discover what other vault files exist
- Read any relevant domain files
- Read repo-side: TODO.md, latest `kivna/sessions/` log
- No more Context.md or Log.md reads

**Execute:**
- No vault writes during execute
- Decisions recorded to repo-side session log, not vault
- Docs-with-code enforcement unchanged

**Close-out:**
- Calls `/kerd:kivna save` once — the single vault write moment
- Updates playbook.md (repo-side) as before
- Session log to `kivna/sessions/` as before
- No per-task vault writes

### switch

**Switch in:**
- Pull, smoke test, read TODO.md (unchanged)
- Read vault: Status.md first, then MOC to discover other relevant files
- Read latest `kivna/sessions/` log
- Check `.active-modes`, summarize, offer dian
- No more Context.md, Log.md, or Decisions.md reads

**Switch out:**
- Write TODO.md, write session log (unchanged)
- Call `/kerd:kivna save` — replaces "verify Context.md was saved"
- Reflect and capture learnings (unchanged)
- Stage, commit, push, verify (unchanged)

### tend

**Vault audit (Category 3) flips:**

Old: check for missing symlinks, create them.

New:
- Flag symlinks as violations — report for removal
- Flag banned files — CLAUDE.md, README.md, TODO.md, Context.md, Log.md, session exports
- Check filenames are self-identifying — flag generic names that collide across vaults
- Check MOC links resolve — every wikilink points to a real file
- Flag append-only patterns — files with multiple dated `## YYYY-MM-DD` sections

Tend still doesn't commit. Still reports visually with fix flow.

### sotu

No changes. Sotu audits content quality, not vault structure.

## Migration Path

No migration skill. Tend converges existing vaults to the new conventions:

1. Run `/kerd:tend` — flags symlinks, banned files, append-only patterns
2. Approve fixes (remove symlinks, delete old files)
3. Run `/kerd:kivna scaffold` — creates new MOC + Status.md
4. Add domain files over time as knowledge accumulates

## What This Removes

- `[Name] Context.md` (append-only snapshots) → replaced by `[Project] Status.md` (overwritten)
- `[Name] Log.md` (one-liner changelog) → removed, no replacement in vault (git log is authoritative)
- `Decisions.md` (generic name) → replaced by project-specific files (`Architecture Decisions.md`, `Positioning Contract.md`, etc.)
- All symlinks to repo files → removed entirely
- MOC auto-refresh from repo scans → MOC updated only when vault files change
- Per-task vault writes during dian execute → vault writes only at session close-out
