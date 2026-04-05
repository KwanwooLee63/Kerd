# TODO

## Current Session
(completed 2026-04-05, session 3)

### Done this session
- [x] Fixed broken hook paths in krutho-founders and krutho-strategy (${CLAUDE_PLUGIN_ROOT} doesn't expand in settings.local.json)
- [x] Updated tend SKILL.md to require absolute path resolution at wiring time (v0.29.1)
- [x] Documented that plugin version updates change the cache path, breaking wired hooks — tend should detect and re-wire

### Context
- Version is 0.29.1
- Hook paths in krutho-founders and krutho-strategy now point to /Users/anthonymaley/.claude/plugins/cache/kerd-marketplace/kerd/0.29.0/hooks/
- When Kerd updates to a new version, those paths will break again. Tend category 9 should detect this.
- obair has no hooks wired yet

## Backlog
- Run /kerd:tend on krutho-founders, krutho-strategy, obair to migrate vaults
- Solicit community mode contributions
