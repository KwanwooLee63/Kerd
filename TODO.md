# TODO

## Current Session
(no active session, last completed 2026-03-17)

### Done this session
- [x] Cleaned vault: removed symlinks, old dirs, old-format files (Context.md, Log.md, Decisions.md)
- [x] Created Kerd Architecture Decisions.md (migrated + updated stale references)
- [x] Created Kerd Usage Guide.md (workflows, skill boundaries, common recipes)
- [x] Created Kerd Install Guide.md (prerequisites, install, update, verify)
- [x] Updated MOC, Status.md, repo playbook

## Backlog
- Run /kerd:tend on krutho-founders, krutho-strategy, obair to migrate vaults
- Re-open Obsidian vault pointing to ~/Obsidian/ (manual step)
- Test slainte playbook audit on a project with a playbook
- Adopt third-person description format for skill triggers (low priority)
- Description optimization for skill triggers (low priority, eval harness limitations)

### Context
- Version is 0.11.0
- Vault cleaned and built out: Architecture Decisions, Usage Guide, Install Guide added
- Old vault artifacts (symlinks, Context.md, Log.md, generic Decisions.md) removed
- Plugin update command is `claude plugin update kerd@kerd-marketplace`
- marketplace.json URL uses ssh format (git@github.com:), intentional
- discover-sources.json in vault with 9 repos and 6 URLs
