# TODO

## Current Session
(no active session, last completed 2026-03-18)

### Done this session
- [x] Moved vault path from ~/Obsidian/ to ~/eolas/vault/ across all active files (v0.12.1)
- [x] Audited vault content for stale references, fixed 5 vault files
- [x] Renamed seach → shakh for voice tool compatibility (v0.13.0)
- [x] Updated all cross-skill references, docs, README, vault files

## Backlog
- Run /kerd:tend on krutho-founders, krutho-strategy, obair to migrate vaults
- Update vault.json in other repos to point to ~/eolas/vault/
- Re-open Obsidian vault in app pointing to ~/eolas/vault/ (manual step)
- Test slainte playbook audit on a project with a playbook
- Adopt third-person description format for skill triggers (low priority)
- Description optimization for skill triggers (low priority, eval harness limitations)

### Context
- Version is 0.13.0
- Vault path is now ~/eolas/vault/ (changed from ~/Obsidian/)
- Skill "seach" renamed to "shakh" — voice tools couldn't parse the old name
- Plugin update command is `claude plugin update kerd@kerd-marketplace`
- marketplace.json URL uses ssh format (git@github.com:), intentional
