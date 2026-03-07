# Context — Kerd

## Current Focus
v0.6.0 shipped. Two feature releases this session: mode markers (v0.5.0) and strengthened dian/switch (v0.6.0). Backlog: sotu playbook audit test, third-person descriptions, description optimization retry with API key.

## Mental Model
Kerd is a Claude Code plugin with six skills defined in markdown (SKILL.md). Each skill has a thin command wrapper in commands/. The plugin is pure markdown + JSON — no build step, no dependencies.

The information flow has three layers:
1. **Stable docs** — CLAUDE.md (conventions), playbook (architecture), README (user-facing). Updated on close-out.
2. **Living context** — `kivna/context.md`. Updated at task boundaries. Captures the thinking: decisions, reasoning, rejected approaches, assumptions.
3. **Historical record** — session logs (`kivna/sessions/`), checkpoint archives (`kivna/checkpoints/`), memories (`kivna/memories/`). Append-only.

Cold start reads: CLAUDE.md + playbook + context.md. Three files, fully caught up.

## Decisions
- **context.md is cumulative, not incremental** — each checkpoint captures the full working state.
- **Rolling file + daily archive** — context.md overwritten each checkpoint, previous version appended to checkpoints/YYYY-MM-DD.md.
- **Context save triggers: auto at dian task boundaries + manual /kivna save**
- **Switch in offers dian (ask first, don't auto-start)**
- **No sidebar skill** — deferred. Context checkpointing reduces the need.
- **Subagents must not expand command files** — commands stay thin wrappers.
- **Resume IDs not worth tracking in switch** — they're local to one machine.
- **Mode markers over kerd:status skill** — user's real problem was not knowing when skills are active. Solved with visible markers and a state file, not a new skill.
- **Only modal skills get markers** — dian (4 phases + closed) and skriv (session mode). One-shot skills don't need them.
- **Always push after commit, always run release checklist first** — codified in CLAUDE.md.
- **Decision recording in execute, not close-out** — decisions lose reasoning context if deferred.
- **Verify each task before moving on** — catch issues early, don't accumulate for close-out.
- **Docs travel with code, enforced in execute** — no commit should leave docs inconsistent with code.
- **Switch-out reflection** — capture learnings to CLAUDE.md, memory files, playbook gotchas. Sessions compound.
- **Switch-in smoke test** — run project tests if they exist before building on top.
- **Dian plan pushback** — ask questions, challenge assumptions, don't infer. Cheaper to clarify than rework.

## Rejected Approaches
- **Detecting context limits automatically** — not possible from inside the conversation.
- **Sidebar skill** — single-turn subagent works but multi-turn can't be isolated.
- **Recording --resume IDs in switch** — local to one machine, defeats cross-machine handoff.
- **kerd:status as a separate skill** — self-announcing markers solve the problem more simply.
- **Automated description optimization** — eval harness (`claude -p` with temp commands) doesn't replicate real plugin triggering. Current descriptions work in practice.

## Working Assumptions
- Plugin system loads skills from SKILL.md with YAML frontmatter (name, description).
- Commands are thin markdown wrappers. One-to-one mapping with skills.
- Version synced in three places: plugin.json, marketplace.json metadata.version, marketplace.json plugins[0].version.
- No test suite — pure markdown. Verification is reading files and checking consistency.

## Active Threads
- Sotu playbook audit still untested on a project with a real playbook (not blocking)
- Description optimization could be retried with ANTHROPIC_API_KEY if triggering issues arise

## Open Questions
- None currently blocking
