# TODO

## Current Session
(no active session, last completed 2026-03-23)

### Done this session
- [x] Ran `/kerd:kivna save` — updated vault Status.md, created first `Kerd Weekly.md`, added Weekly link to MOC
- [x] Added `/kerd:lorg report` subcommand to view last scan without rescanning (v0.15.0)
- [x] Added `light` modifier to switch for lower-token handoffs (v0.16.0)
- [x] Updated README, playbook, and vault Usage Guide with v0.15.0 and v0.16.0 features

## Backlog
- Run /kerd:tend on krutho-founders, krutho-strategy, obair to migrate vaults
- Update vault.json in other repos to point to ~/eolas/vault/
- Re-open Obsidian vault in app pointing to ~/eolas/vault/ (manual step)
- Test slainte playbook audit on a project with a playbook
- Adopt third-person description format for skill triggers (low priority)
- Description optimization for skill triggers (low priority, eval harness limitations)

### Context
- Version is 0.16.0
- Vault path is now ~/eolas/vault/ (changed from ~/Obsidian/)
- Switch skill has `light` modifier: `/switch out light` and `/switch in light` skip vault, reflection, smoke test
- Lorg has `report` subcommand: `/lorg report` shows last saved report
- Plugin update command is `claude plugin update kerd@kerd-marketplace`
- marketplace.json URL uses ssh format (git@github.com:), intentional
- Tend now has Category 8 (Skill hygiene) to catch missing kerd: prefixes and stale skill names
- Weekly tracker exercised: first `Kerd Weekly.md` created in vault
