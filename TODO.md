# TODO

## Current Session
(completed 2026-04-05)

### Done this session
- [x] Switch in — repo up to date, no new remote commits
- [x] Vault update: Status.md (v0.23.1), MOC version bump, Weekly additions, Architecture Decisions (hooks.json → hooks.template.json)
- [x] Loaded obsidian-skills reference (obsidian-markdown, obsidian-bases, obsidian-cli) — assessed vault files against Obsidian best practices, concluded no frontmatter needed (consistent convention across all vaults)
- [x] Cleaned .DS_Store files (local only, gitignore already covers them)
- [x] Closed two deferred hook items as rejected: structured JSON output (plain text fits reminder hooks), PreCompact hook (no event exists, state persists on disk). Recorded in Architecture Decisions.
- [x] Cherry-picked trim skill from Kwanwoo's PR #1 onto main (v0.24.0). PR branch too stale to merge (0.17.1 → 0.23.1 drift). Closed PR with comment crediting contribution.
- [x] Lorg tiered subcommands (v0.25.0): default to Tier 1 only, subcommands for installed/available/explore/all/report, per-tier freshness dates, incremental report saves
- [x] Added What's New section to README covering v0.19.0–v0.25.0
- [x] Gitignored AGENTS.md
- [x] Updated playbook, vault (Status, MOC, Weekly, Architecture Decisions, Usage Guide) across all changes

### Context
- Version is 0.25.0
- Untracked files still pending decision: docs/demo-mode.cast, docs/demo-mode.gif, docs/demo-mode.mp4 (AGENTS.md now gitignored)
- obsidian-skills plugin installed but no vault frontmatter convention adopted yet — deferred to future vault-spec update if wanted

## Backlog
- Run /kerd:tend on krutho-founders, krutho-strategy, obair to migrate vaults
- Embed demo gif in README
- Decide on docs/demo-mode.* files (cast, gif, mp4)
- Solicit community mode contributions
- Add trim to maintain mode flow after audit phase
- If long-session mode drift appears, fix in mode skill (re-read .active-modes before each step)
