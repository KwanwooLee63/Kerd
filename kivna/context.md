# Context — Kerd

## Current Focus
Implementing context checkpoint feature (design doc: docs/plans/2026-03-04-context-checkpoint-design.md, implementation plan: docs/plans/2026-03-04-context-checkpoint-implementation.md). Eight tasks: four skill modifications (kivna, dian, switch, startup), README update, CLAUDE.md + playbook update, version bump to 0.3.0, push. Using subagent-driven development — dispatching one subagent per task with spec + quality review after each.

## Mental Model
Kerd is a Claude Code plugin with six skills defined in markdown (SKILL.md). Each skill has a thin command wrapper in commands/. The plugin is pure markdown + JSON — no build step, no dependencies. Context checkpointing adds a living `kivna/context.md` file that captures the working context (decisions, reasoning, rejected approaches, assumptions) and is auto-updated at task boundaries by dian. The archive goes to `kivna/checkpoints/YYYY-MM-DD.md`. The goal is to make context compaction and session boundaries irrelevant — the thinking survives in a file.

## Decisions
- **context.md is cumulative, not incremental** — each checkpoint captures the full working state, not deltas. This means one file read restores everything on cold start.
- **Rolling file + daily archive** — context.md is overwritten each checkpoint (latest state), previous version appended to checkpoints/YYYY-MM-DD.md (history). Cold start reads only context.md. Archive is for tracing decisions back.
- **Checkpoint triggers: auto at dian task boundaries + manual /kivna checkpoint** — we can't detect context window limits from inside the conversation, so we checkpoint frequently at natural breakpoints to make compaction irrelevant.
- **Switch in offers dian (ask first, don't auto-start)** — user might want a quick check without full session discipline.
- **No sidebar skill for now** — context checkpointing makes sidebar less urgent. Subagent approach could work for single Q→A but multi-turn isn't possible. Revisit if needed.
- **Version 0.3.0 (MINOR)** — new feature, new command, modified behavior in three skills.

## Rejected Approaches
- **Detecting context limits automatically** — not possible from inside the conversation. Compaction happens server-side with no warning signal.
- **Sidebar skill** — investigated using subagents for isolated Q&A mid-session. Single-turn works but multi-turn can't be isolated from main context. Deferred — context checkpointing reduces the need.
- **Per-session checkpoint files** — considered but per-day matches existing kivna convention (sessions, memories are per-day). Simpler, fewer files.
- **Single rolling archive (one big file)** — rejected in favor of per-day files for searchability and matching existing patterns.
- **dian/ directory for TODO and playbook** — discussed whether dian should own its files like kivna owns its. Decided no: TODO.md and playbook are project files that dian manages, not dian-internal artifacts. They live in their natural locations (root and docs/).

## Working Assumptions
- Claude Code plugin system loads skills from SKILL.md files with YAML frontmatter (name, description). The description field controls auto-invocation.
- Commands in commands/ are thin markdown wrappers that invoke skills. One-to-one mapping.
- Version must be synced in three places: plugin.json, marketplace.json metadata.version, marketplace.json plugins[0].version.
- CLAUDE.md convention: all cross-skill references use /kerd:<skill> prefix. README examples may omit prefix for readability.
- The plugin has no test suite — it's pure markdown. Verification is reading files and checking consistency.

## Active Threads
- Task 1 of 8: About to dispatch subagent for kivna skill update (add checkpoint command, folder convention, trigger description)
- Tasks 2-4: Other skill modifications (dian, switch, startup) — sequential, each depends on consistent patterns from Task 1
- Tasks 5-6: Doc updates (README, CLAUDE.md, playbook) — depend on final skill content
- Task 7: Version bump — last before push
- Task 8: Push and verify

## Open Questions
- None currently — design is finalized and approved.
