# TODO

## Current Session
(completed 2026-04-04, session 2)

### Done this session
- [x] Switch in — picked up from earlier session today
- [x] Live smoke test of all three hooks (SessionStart, Stop, PostToolUse)
- [x] Confirmed PostToolUse payload shape — full envelope with session_id, tool_input, tool_response, etc.
- [x] Hardened skill-complete.sh to guard on tool_response.success
- [x] Documented payload shape in state-contract.md and design doc
- [x] Reviewed blader/humanizer — added 4 rules to skriv: self-audit pass, synonym cycling, copula avoidance, chatbot residue (v0.22.0)
- [x] Reviewed thedotmack/claude-mem — added 3 features to switch: branch metadata, gotcha capture, progressive loading (v0.23.0)
- [x] Updated vault (Status, MOC, Weekly, Architecture Decisions, Usage Guide)
- [x] Updated README and playbook for v0.22.0 and v0.23.0

### Context
- Version is 0.23.0 (bumped in all 3 locations)
- Untracked files still pending decision: AGENTS.md, docs/demo-mode.cast, docs/demo-mode.gif, docs/demo-mode.mp4
- Cached plugin version is still 0.21.0 — switch template loaded from cache doesn't have branch/gotcha fields yet. Users need to reinstall to pick up v0.23.0.

## Backlog
- Merge Kwanwoo's trim PR (#1) — waiting on his approval
- Run /kerd:tend on krutho-founders, krutho-strategy, obair to migrate vaults
- Embed demo gif in README
- Commit or decide on AGENTS.md and docs/demo-mode.* files
- Clean .DS_Store files from repo
- Solicit community mode contributions
