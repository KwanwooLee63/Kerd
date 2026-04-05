# TODO

## Current Session
(completed 2026-04-04, session 3)

### Done this session
- [x] Switch in — picked up from session 2
- [x] Full lorg scan: built project profile, searched all 3 tiers, scored and ranked 24 results
- [x] Saved lorg report to docs/lorg-report.md and vault (Kerd Lorg Report.md)
- [x] Installed kepano/obsidian-skills (marketplace + plugin: 5 Obsidian skills for kivna vault writes)
- [x] Loaded plugin-dev:hook-development reference — compared Kerd hooks against official patterns
- [x] Fixed hooks auto-loading bug: renamed hooks/hooks.json to hooks.template.json (v0.23.1)
- [x] Updated tend and playbook to reference hooks.template.json
- [x] Version bumped to 0.23.1 in all 3 locations

### Context
- Version is 0.23.1
- Untracked files still pending decision: AGENTS.md, docs/demo-mode.cast, docs/demo-mode.gif, docs/demo-mode.mp4
- obsidian-skills plugin installed (obsidian@obsidian-skills) — requires Claude Code restart to activate
- Lorg report identified structured JSON output for hooks and PreCompact hook as deferred improvements
- User explicitly rejected making Stop hook blocking (Kerd hooks are reminders, non-blocking by design)

## Backlog
- Merge Kwanwoo's trim PR (#1) — waiting on his approval
- Run /kerd:tend on krutho-founders, krutho-strategy, obair to migrate vaults
- Embed demo gif in README
- Commit or decide on AGENTS.md and docs/demo-mode.* files
- Clean .DS_Store files from repo
- Solicit community mode contributions
- Consider structured JSON systemMessage output for hooks (deferred from this session)
- Consider PreCompact hook for preserving mode state during long sessions (deferred)
