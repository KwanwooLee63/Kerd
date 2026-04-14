# TODO

## Current Session
(completed 2026-04-14)

### Done this session
- [x] Fixed stale hook paths in krutho-founders (0.29.0→0.31.0), krutho-strategy (0.29.0→0.31.0), leru (0.30.0→0.31.0)
- [x] Fixed settings.json `pps-local` marketplace entry — `"source": "local"` is invalid, changed to `"source": "github"`. This was causing entire settings.json to be skipped, breaking all plugins across all repos.
- [x] Fixed PPS marketplace.json — same `"source": "local"` → `"source": "url"` fix so `claude plugins add-marketplace` works
- [x] Decided to keep TPS/PPS as a separate plugin (different domain, independent versioning, user choice)
- [x] Switch auto-commit (v0.32.0): session files commit without confirmation, only unexpected files trigger INPUT REQUIRED banner

### Context
- Version is 0.32.0
- Cached plugin still at 0.31.0 — needs `claude plugins install kerd` to pick up v0.32.0
- PPS marketplace not yet added — needs commit+push of PPS marketplace.json fix, then `claude plugins add-marketplace anthonymaley/PPS`

## Backlog
- Run /kerd:tend on krutho-founders, krutho-strategy, obair to migrate vaults
- Solicit community mode contributions
