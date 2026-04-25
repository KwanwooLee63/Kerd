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
hooks/            # opt-in hooks (hooks.template.json + shell scripts, registered via tend)
docs/plans/       # historical design docs
docs/playbook.md  # this file
docs/state-contract.md # shared state ownership and format rules
kivna/vault.json  # Obsidian vault config
kivna/sessions/   # session logs written by switch
kivna/.active-modes # ephemeral mode/skill state (gitignored)
.claude-plugin/   # plugin.json + marketplace.json
```

The project's knowledge layer lives in the Obsidian vault at `~/eolas/vault/kerd/`. The vault is a human knowledge base, living files updated in place, not append-only dumps. Kivna reads and writes vault files (`Kerd Status.md`, plus optional domain files like Architecture Decisions). The vault spec at `docs/vault-spec.md` defines what belongs. The vault config is at `kivna/vault.json`. See `/kerd:kivna` for details.

**Nine skills, each with a single responsibility, plus three opt-in hooks:**
- **dian**: session discipline (orient/plan/execute/close-out protocol)
- **lorg**: skill gap analysis (tiered subcommands: installed, available, explore, all, report)
- **switch**: git boundary operations (pull on arrive, commit+push on leave)
- **kivna**: knowledge management (Obsidian vault: living Status.md, domain knowledge files, import/export)
- **slainte**: project health audits (docs, code, site, deps, playbook)
- **skriv**: human writing voice enforcement (audit, fix, session mode, self-audit pass)
- **tend**: structural health check and convergence
- **trim**: token optimization (archive shipped docs, prune stale context, safety-gated cleanup)
- **mode**: workflow routing (orchestrates Kerd, GSD, Superpowers, and other plugins into guided flows)

**Three opt-in hooks** (registered via `/kerd:tend`, stored in `.claude/settings.local.json`):
- **Stop**: reminds about uncommitted changes and active modes on session end
- **SessionStart**: surfaces stale state (remote drift, last session date, interrupted mode) on same-machine resume
- **PostToolUse (Skill)**: shows mode progress when the current step's skill completes (read-only)

## Mode-to-Skill Composition

Rules for how modes and skills interact:

- **Modes guide, skills execute.** A mode presents a flow and tracks progress. It never calls a skill directly — the user invokes each skill when they reach that step. Mode is a session configuration, not an orchestrator.
- **Skills are self-contained.** A skill must work standalone, not just as a mode step. If a skill only makes sense inside a mode, it's coupled too tightly.
- **Dian runs inside modes, not above them.** A mode can include dian as a step. Dian reads the active mode context and respects its scope. Mode and dian both write to `.active-modes` (their own lines only).
- **Switch bookends every mode.** Every mode starts with switch-in and ends with switch-out. These are the git boundaries. No other skill pulls or pushes.
- **Mode steps reference concrete invocations.** Each step in a mode file has the form `/plugin:skill [args]`. No vague steps like "review the code." The step must be invocable.
- **External skills are optional.** Modes can reference skills from GSD, Superpowers, or other plugins in `core_skills`. Missing skills are a warning, not a blocker. The mode still runs with available skills.
- **4 steps per phase max.** The UI batches up to 4 questions per prompt. If a phase has more than 4 steps, split it into sub-phases.

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
- **Cached plugin version lags**: after pushing changes, the installed plugin still uses its cached version until `claude plugins install kerd` runs again. Skill templates loaded from cache will be old. This is why the switch template in this session loaded v0.21.0 even though the repo was at v0.23.0.
- **Legacy user commands shadow plugin skills**: pre-plugin command files in `~/.claude/commands/` show as duplicate entries in the command picker. Delete them after migrating to the plugin. Common leftovers: `switch.md`, `kivna.md`, `sotu.md` (old slainte name), `human-draft.md` (old skriv), `rigour.md` (old dian).
- **Hook paths break on plugin version updates**: hooks wired in `settings.local.json` point to absolute cache paths (e.g., `/cache/kerd/0.30.0/hooks/`). When the plugin updates to a new version, the path changes and hooks break. Run `/kerd:tend` in each repo after updating to re-wire.
- **settings.json validation is all-or-nothing**: a single invalid field anywhere in `~/.claude/settings.json` causes the entire file to be skipped. All plugins, hooks, permissions, and config go with it. The error message ("Files with errors are skipped entirely") is easy to miss. If plugins suddenly stop loading across all repos, check settings.json first. The `"source": "local"` type for `extraKnownMarketplaces` is not valid — use `"github"` (with `repo`) or `"git"` (with `url`).
- **PostToolUse payload is a full envelope**: the stdin payload includes `session_id`, `tool_name`, `tool_input`, `tool_response`, `tool_use_id`, not just `tool_input`. Sed parsers must handle the nesting. Documented in `docs/state-contract.md`.


## Current Status

**Version:** 0.35.0

**Working:**
- All nine skills functional: dian, lorg, switch, kivna, slainte, skriv, tend, trim, mode
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
- Switch-out reflection with explicit gotcha capture. Captures learnings to CLAUDE.md and memory files, gotchas to playbook
- Switch session logs use bare-headers template with three rules above the fence (anti-hallucination, okay-not-to-know, match-vocabulary-to-work). Optional sections omitted entirely when empty
- Switch-in progressive loading: newest session log in full, older logs skimmed for key decisions and gotchas
- Switch `light` modifier for lower-token handoffs
- Lorg tiered subcommands: installed (default), available, explore, all, report. Per-tier freshness. Incremental saves.
- Mode skill for workflow routing with 10 community-contributed starter modes (added `spike` for high-uncertainty exploration)

**Recent changes (as of 2026-04-25):**
- v0.35.0: Spike v1.1 — six structural additions after first real-world dogfood (3of3 tvOS deep-link spike). Setup adds pre-flight inventory and empirical-primitive-first. Try adds per-variant verify, provisional-decline zone (closure claims survive a config change or push-back round before promotion to canonical loss; each entry must enumerate "what would change my mind" and "what I haven't yet tried"), WebFetch-fail-3-alternates with "verified by [URL]" tags on external claims, and matrix trimming. All changes are structural (required artifacts/gates), not prose reminders — addressing the wallpaper-effect of high-frequency identical reminders losing their grip.
- v0.34.0: New `spike` mode for high-uncertainty exploration. Directional but exploratory — no plan, no decomposition. Captures both wins AND losses with evidence in a per-topic spec file. Batch-hard for hardware/long-loop tests (default N+1 variants). Commit graduation at close-out classifies each output as keep-as-is, extract-and-promote, or discard. Includes Removed-from-backlog log for disproven hypotheses.
- v0.33.0: Switch + kivna template refactor. Dropped bracketed fill-in prompts in favor of bare headers in template fences. Added three rules above the fence: anti-hallucination (omit empty optional sections; don't write "None" or "N/A"), okay-not-to-know ("I don't know" is a valid log entry, don't construct plausible explanations), match-vocabulary-to-work (covers code, writing, strategy, sales, research). Same vocabulary fix to kivna Weekly Achievements.
- v0.32.0: Switch auto-commit. Session files (TODO.md, session log, playbook) commit and push without confirmation. Only unexpected/unknown files trigger an INPUT REQUIRED banner. Steps 6-9 collapsed into 6-7.
- v0.31.0: Dian task framing in plan phase. Decompose request into scoped tasks with acceptance criteria and verification before writing implementation plan. Default one task per session. Fresh-session retry when framing was wrong. Inspired by Backlog.md's spec-driven AI development pattern — borrowed the framing, not the tool.
- v0.30.0: Switch `low` modifier for minimum viable handoffs. Brief TODO (3-5 lines), skeleton session log (What Was Done + What's Next), skip vault/reflection/triage/trim, compressed narration. Switch-in low: pull, TODO current session, latest What's Next, active modes, no dian offer.
- v0.29.1: Tend hook path resolution fix. ${CLAUDE_PLUGIN_ROOT} doesn't expand in settings.local.json.
- v0.29.0: Lorg dedupe across tiers and explanation quality rules. Mode resume/recovery protocol for stale or compacted context. Kivna do-not-save markers for private session content. State-contract workflow ownership table and conflict resolution rules.
- v0.28.0: Slainte cross-doc claim verification (README vs SKILL.md, playbook vs actual skills, state-contract ownership table, hook template currency). Trim added to maintain mode. CONTRIBUTING.md contributor quality gate. Mode-to-skill composition conventions in playbook.
- v0.27.0: Switch pre-commit summary (shows staged files before committing), untracked file triage (surfaces forgotten files), handoff contract verification on switch-in (flags partial handoffs), evidence-cited final confirmation (commit hash, push target, clean tree), conditional trim suggestion for completed plan docs.
- v0.26.0: Dian execution discipline: hard verification gate (identify-run-read-confirm), bite-sized plan steps with concrete file paths and verification criteria, 3-fix escalation limit, hard stop on scope creep, critical review before plan approval. Kerd integration: mode-awareness in orient (reads .active-modes, surfaces mode instruction), mode-aware close-out (doesn't claim "done" mid-flow), fixed session-log ownership (dian writes to TODO.md only, switch owns session logs).
- v0.25.0: Lorg tiered subcommands. Default runs Tier 1 only (installed but unused). Subcommands: installed, available, explore, all, report. Per-tier freshness dates. Incremental report saves.
- v0.24.0: Trim skill (community contribution from Kwanwoo Lee). Post-feature token cleanup: archives completed docs with forward-looking content rescue, prunes CLAUDE.md, cleans memory, trims TODO.md, safety-gated by haiku subagent.
- v0.23.1: Fixed hooks auto-loading bug (renamed hooks.json to hooks.template.json). Full lorg scan.
- v0.23.0: Switch: branch metadata in session logs, first-class Gotchas section, progressive session log loading on switch-in, stronger gotcha capture in reflection step.
- v0.22.0: Skriv: self-audit pass, synonym cycling rule, copula avoidance, chatbot residue cleanup.
- v0.21.0: Lorg ranking (scored results, recency-aware filtering, weak match cutoff). Shared state contract doc at docs/state-contract.md.
- v0.20.0: Kerd Interchange Format (KIF). `/kerd:kivna out` produces `.kif.toon` + `.kif.json`. Repo-grounded exports (TODO, session logs, playbook, vault first, conversation fills gaps). `/kerd:kivna in` parses `.kif.json` with per-section approval. Supports `--full` flag for all sections.
- v0.19.0: Hooks infrastructure (Stop, SessionStart, PostToolUse). Unified `.active-modes` schema. Structured mode steps format. Switch mode snapshot for cross-machine handoff. Tend category 9 (hook hygiene). Slainte release audit category.
- v0.17.1: Mode interactive phase selection (AskUserQuestion), session instructions.
- v0.17.0: Mode skill for workflow routing. 9 starter modes. Community-contributed via PR.
- v0.16.0: Switch `light` modifier for lower-token handoffs.
- v0.15.0: Lorg `report` subcommand.

**Next:**
- Add trim to maintain mode flow after audit phase
- Run `/kerd:tend` on other projects to migrate vaults
