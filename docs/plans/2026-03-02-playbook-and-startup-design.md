# Design: Playbook Integration + Startup Skill

**Date:** 2026-03-02

Three changes to the Kerd skill suite: integrate a living playbook into dian's session workflow, add a playbook audit area to sotu, and create a new startup skill for scaffolding projects.

## 1. Evolving `kerd:dian` — Playbook in Close-Out

The playbook (`docs/playbook.md`) becomes a first-class artifact that dian maintains. A general rebuild guide — not domain-specific, but adapted to whatever the project is. Captures tech stack choices, setup steps, integrations, gotchas, and current status.

### Changes to dian

**Orient step** — add playbook to the read list:
- Read `docs/playbook.md` if it exists (after TODO.md, CLAUDE.md, progress tracking)

**Close Out step** — add playbook update after doc impact assessment:
1. Update TODO.md (existing)
2. Doc impact assessment (existing)
3. **Update playbook** — if `docs/playbook.md` exists, update it with anything learned this session: new setup steps, new integrations, gotchas discovered, tech stack changes, updated Current Status. If it doesn't exist, create it from the skeleton below.
4. Staleness sweep (existing)
5. Run checks (existing)

### Playbook skeleton

Created automatically on first close-out if `docs/playbook.md` doesn't exist:

```markdown
# Playbook — [Project Name]

How to rebuild this project from scratch.

## Tech Stack
[What tools/frameworks and why they were chosen]

## Setup
[Steps to get the project running locally]

## Architecture
[Key structural decisions and why]

## Integrations
[External services, APIs, config needed]

## Deployment
[How to deploy, environment variables needed]

## Gotchas
[Things that broke, non-obvious behavior, workarounds]

## Current Status
[What's working, what's in progress, what's next]
```

## 2. Evolving `kerd:sotu` — Playbook Audit Area

A new `playbook` area in the `.sotu` config with a dedicated `/sotu playbook` command.

### Config addition

```
## playbook
- docs/playbook.md
```

### What `/sotu playbook` checks

1. **Existence** — does `docs/playbook.md` exist? If not, high severity ("No playbook found — run a dian session to create one")
2. **Current Status accuracy** — compare the "Current Status" section against actual project state (working build, test results, deployed state if detectable)
3. **Tech stack drift** — are the tools/frameworks listed in the playbook still in `package.json` / `pyproject.toml` / equivalent? Flag removed or added deps not reflected in playbook
4. **Setup steps validity** — do the setup commands reference files and scripts that still exist?
5. **Freshness** — when was playbook last modified relative to recent commits? If 10+ commits have landed since the last playbook update, flag as medium
6. **Section completeness** — are any major sections empty or still showing skeleton placeholder text?

### Severity guide

| Severity | Issue |
|----------|-------|
| high | Playbook doesn't exist, setup steps reference deleted scripts, tech stack lists removed dependency |
| medium | Current Status is stale (10+ commits behind), empty sections remain |
| low | Minor naming inconsistency, formatting drift |

## 3. New `kerd:startup` Skill

A one-time skill that scaffolds a new project with Kerd conventions. Assumes the git repo already exists (cloned or initialized with remote set).

### Trigger

`/kerd:startup` or user says "set up this project", "initialize kerd", etc.

### The process

1. **Verify git** — confirm `.git` exists. If not, stop and tell the user to init/clone first.
2. **Gather context** — ask the user:
   - Project name (for README and playbook headers)
   - One-line description (what this project does)
3. **Create directory structure:**
   - `kivna/`
   - `kivna/sessions/`
   - `docs/`
4. **Create files:**
   - `README.md` — project name, description, basic structure
   - `TODO.md` — empty template with `## Current Session` block ready to go
   - `CLAUDE.md` — Kerd conventions: doc impact table, session workflow rules (update TODO.md and playbook on close-out), pointer to Kerd skills
   - `docs/playbook.md` — skeleton from the dian template (all sections with placeholder text)
   - `.sotu` — default config registering README.md, docs/, and the playbook
5. **Commit** — single commit: "feat: initialize project with Kerd scaffold"
6. **Push** — push to remote, verify success
7. **Confirm** — print what was created and suggest: "Run `/kerd:dian` to start your first session."

### What startup does NOT do

- No git init, no remote setup
- No tech stack decisions — those happen in the first dian session
- No skill file copying — Kerd skills live in the Kerd repo, not in each project
