# Playbook: Kerd

How to rebuild this project from scratch.

## Tech Stack

Pure markdown and JSON. No runtime dependencies, no build step, no package manager.

- **Claude Code plugin system**: skills (SKILL.md), plugin manifest (plugin.json/marketplace.json)
- **Markdown**: all skill definitions, docs, session logs, and the playbook itself
- **JSON**: plugin.json and marketplace.json in `.claude-plugin/`
- **Git**: version control and the distribution mechanism (plugins install from the git repo)

There is no package.json, no node_modules, no compiled output. The plugin is consumed directly by Claude Code from the repo.

## Setup

1. Clone the repo:
   ```
   git clone git@github.com:anthonymaley/Kerd.git
   cd Kerd
   ```

2. That's it. There's no install step. The project is markdown and JSON files consumed by Claude Code's plugin system.

3. To test locally, install the plugin in Claude Code:
   ```
   claude plugins install /path/to/Kerd
   ```

4. To install from the marketplace (published version):
   ```
   claude plugins add-marketplace anthonymaley/Kerd
   claude plugins install kerd
   ```

## Architecture

**Skills define behavior.** The plugin system loads them directly via the `kerd:` prefix (e.g., `/kerd:dian`).

Each skill lives in `skills/<name>/SKILL.md` with YAML frontmatter (`name`, `description`) and the full protocol in markdown. The `description` field controls when Claude auto-invokes the skill.

The plugin manifest (`.claude-plugin/plugin.json`) declares the plugin name, version, and description. The marketplace manifest (`.claude-plugin/marketplace.json`) wraps that for the Claude Code marketplace.

**Directory layout:**
```
skills/           # SKILL.md per skill (dian, lorg, kivna, mode, skriv, slainte, tend, switch)
modes/            # workflow mode definitions (one .md per mode, community-contributed)
hooks/            # opt-in hooks (hooks.json + shell scripts, registered via tend)
docs/plans/       # historical design docs
docs/playbook.md  # this file
docs/state-contract.md # shared state ownership and format rules
kivna/vault.json  # Obsidian vault config
kivna/sessions/   # session logs written by switch
kivna/.active-modes # ephemeral mode/skill state (gitignored)
.claude-plugin/   # plugin.json + marketplace.json
```

The project's knowledge layer lives in the Obsidian vault at `~/eolas/vault/kerd/`. The vault is a human knowledge base, living files updated in place, not append-only dumps. Kivna reads and writes vault files (`Kerd Status.md`, plus optional domain files like Architecture Decisions). The vault spec at `docs/vault-spec.md` defines what belongs. The vault config is at `kivna/vault.json`. See `/kerd:kivna` for details.

**Eight skills, each with a single responsibility, plus three opt-in hooks:**
- **dian**: session discipline (orient/plan/execute/close-out protocol)
- **lorg**: skill gap analysis (scan project signals, recommend skills/plugins across tiers)
- **switch**: git boundary operations (pull on arrive, commit+push on leave)
- **kivna**: knowledge management (Obsidian vault: living Status.md, domain knowledge files, import/export)
- **slainte**: project health audits (docs, code, site, deps, playbook)
- **skriv**: human writing voice enforcement (audit, fix, session mode)
- **tend**: structural health check and convergence
- **mode**: workflow routing (orchestrates Kerd, GSD, Superpowers, and other plugins into guided flows)

**Three opt-in hooks** (registered via `/kerd:tend`, stored in `.claude/settings.local.json`):
- **Stop**: reminds about uncommitted changes and active modes on session end
- **SessionStart**: surfaces stale state (remote drift, last session date, interrupted mode) on same-machine resume
- **PostToolUse (Skill)**: shows mode progress when the current step's skill completes (read-only)

## Integrations

No external services or APIs. Kerd operates entirely within the local filesystem and git.

The only integration point is the **Claude Code plugin system**. Kerd registers as a plugin and its skills become available as slash commands (`/kerd:dian`, `/kerd:switch`, etc.).

Session logs written by switch go to `kivna/sessions/` and are committed to git, making them available across machines.

## Deployment

Kerd is distributed as a Claude Code marketplace plugin.

**To publish an update:**
1. Make changes to skills and docs
2. Bump the version in all three locations per the release checklist in CLAUDE.md:
   - `.claude-plugin/plugin.json` → `version`
   - `.claude-plugin/marketplace.json` → `metadata.version`
   - `.claude-plugin/marketplace.json` → `plugins[0].version`
3. Commit and push to `main`
4. Users get the update on next `claude plugins install kerd`

No CI/CD pipeline, no build artifacts, no environment variables.

## Gotchas

- **Version sync**: the version must be identical in three places (plugin.json version, marketplace.json metadata.version, marketplace.json plugins[0].version). Easy to update one and forget the others. The release checklist in CLAUDE.md exists because this happened.
- **Cache busting**: after publishing, Claude Code may cache the old plugin version. Bumping a patch version forces a re-fetch. This is why you see "cache bust" commits in the history.
- **Namespace prefix**: skill SKILL.md frontmatter uses bare names (`name: dian`), but all references in docs and skills must use `kerd:` prefix (`/kerd:dian`). The plugin system adds the prefix automatically. README examples are exempt for readability.
- **Vault path convention**: default vault path is `~/eolas/vault/`. Kivna scaffold asks for the location if it doesn't exist. All vault.json files point here. If you rename or move the vault folder, update vault.json in every repo.
- **Vault spec**: the vault spec at `docs/vault-spec.md` defines what belongs in the vault. No symlinks, no append-only files, no generic filenames. When in doubt, check the spec.
- **Cross-cutting changes**: when modifying a pattern used across multiple skills (like vault file references), grep all skill files for the old pattern after implementation. The plan will miss files. The v0.10.0 vault redesign missed `lorg/SKILL.md` entirely, caught only by final code review searching for stale references.
- **Agent verification**: when using parallel agents for cross-file changes, always run a grep verification sweep afterward. Agents can make incorrect inferences (e.g., renaming `discover-sources.json` to `lorg-sources.json` when only the skill name changed, not the vault filename).
- **Verify collision claims**: before renaming a skill to avoid a collision, check the other plugin's actual skill list. The shakh rename was based on an assumed superpowers collision that never existed. A 2-minute scan of `~/.claude/plugins/cache/` would have prevented two unnecessary renames.
- **Vault files need the same rename sweep as repo files**: when renaming a skill, the vault has its own references (MOC, Status, Usage Guide, Architecture Decisions, Install Guide, Lorg Report). Easy to update the repo and forget the vault.


## Current Status

**Version:** 0.21.0

**Working:**
- All eight skills functional: dian, lorg, switch, kivna, slainte, skriv, tend, mode
- Three opt-in hooks: Stop (uncommitted changes reminder), SessionStart (stale state surfacing), PostToolUse (mode progress)
- Plugin installs from marketplace
- Session logs, playbook creation, and health audits all operational
- Obsidian vault integration. Kivna reads/writes living vault files (Status.md, Weekly.md, domain knowledge) with approval-gated overwrites
- Tend audit verified (9 categories including hook hygiene). Reports structural drift and fixes with approval
- Slainte release audit catches version sync, description sync, skill/mode count drift, namespace issues
- Unified `.active-modes` schema shared by dian, skriv, mode, and switch
- Mode tracks progress with structured steps format (stable IDs, concrete args, status markers)
- Switch snapshots active mode state to TODO.md for cross-machine handoff
- Mode markers on dian and skriv. Visible phase/state announcements with `.active-modes` state file
- Dian rigorous planning and execute verification
- Switch-out reflection. Captures learnings to CLAUDE.md and memory files
- Switch `light` modifier for lower-token handoffs
- Lorg `report` subcommand to view last scan without rescanning
- Mode skill for workflow routing with 9 community-contributed starter modes

**Recent changes (as of 2026-04-04):**
- v0.21.0: Lorg ranking (scored results, recency-aware filtering, weak match cutoff). Shared state contract doc at docs/state-contract.md.
- v0.20.0: Kerd Interchange Format (KIF). `/kerd:kivna out` produces `.kif.toon` + `.kif.json`. Repo-grounded exports (TODO, session logs, playbook, vault first, conversation fills gaps). `/kerd:kivna in` parses `.kif.json` with per-section approval. Supports `--full` flag for all sections.
- v0.19.0: Hooks infrastructure (Stop, SessionStart, PostToolUse). Unified `.active-modes` schema. Structured mode steps format. Switch mode snapshot for cross-machine handoff. Tend category 9 (hook hygiene). Slainte release audit category.
- v0.17.1: Mode interactive phase selection (AskUserQuestion), session instructions.
- v0.17.0: Mode skill for workflow routing. 9 starter modes. Community-contributed via PR.
- v0.16.0: Switch `light` modifier for lower-token handoffs.
- v0.15.0: Lorg `report` subcommand.

**Next:**
- Merge Kwanwoo's trim PR (#1) — adds ninth skill for post-feature token cleanup
- Run `/kerd:tend` on other projects to migrate vaults
