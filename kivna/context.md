# Context — Kerd

## Current Focus
Context checkpoint feature is shipped (v0.3.0, pushed). Now exploring Anthropic's plugin-dev skills (skill-creator, skill-development) to see if there are patterns worth adopting. Also considering adding an "Insights" section to switch's session log template.

## Mental Model
Kerd is a Claude Code plugin with six skills defined in markdown (SKILL.md). Each skill has a thin command wrapper in commands/. The plugin is pure markdown + JSON — no build step, no dependencies.

The information flow now has three layers:
1. **Stable docs** — CLAUDE.md (conventions), playbook (architecture), README (user-facing). Updated on close-out.
2. **Living context** — `kivna/context.md`. Updated at task boundaries. Captures the thinking: decisions, reasoning, rejected approaches, assumptions.
3. **Historical record** — session logs (`kivna/sessions/`), checkpoint archives (`kivna/checkpoints/`), memories (`kivna/memories/`). Append-only.

Cold start reads: CLAUDE.md + playbook + context.md. Three files, fully caught up.

## Decisions
- **context.md is cumulative, not incremental** — each checkpoint captures the full working state. One file read restores everything on cold start.
- **Rolling file + daily archive** — context.md overwritten each checkpoint, previous version appended to checkpoints/YYYY-MM-DD.md.
- **Checkpoint triggers: auto at dian task boundaries + manual /kivna checkpoint** — can't detect context limits, so checkpoint frequently to make compaction irrelevant.
- **Switch in offers dian (ask first, don't auto-start)** — user might want a quick task without full session discipline.
- **No sidebar skill** — deferred. Context checkpointing reduces the need. Subagent approach works for single Q→A but multi-turn can't be isolated.
- **CHANGELOG.md added** — standard convention for version history, keeps README clean.
- **Subagents must not expand command files** — caught during implementation. Subagents tried to inline skill content into thin command wrappers. Commands must stay thin.

## Rejected Approaches
- **Detecting context limits automatically** — not possible from inside the conversation. Compaction happens server-side with no warning.
- **Sidebar skill** — single-turn subagent works but multi-turn can't be isolated from main context.
- **Per-session checkpoint files** — per-day matches existing kivna convention.
- **Single rolling archive** — per-day files for searchability.
- **dian/ directory for TODO and playbook** — these are project files that dian manages, not dian-internal artifacts.

## Working Assumptions
- Plugin system loads skills from SKILL.md with YAML frontmatter (name, description). Description controls auto-invocation.
- Commands are thin markdown wrappers. One-to-one mapping with skills.
- Version synced in three places: plugin.json, marketplace.json metadata.version, marketplace.json plugins[0].version.
- Cross-skill references use /kerd:<skill> prefix in skills and CLAUDE.md. README uses bare names.
- No test suite — pure markdown. Verification is reading files and checking consistency.
- Spec reviewers catch namespace prefix issues that implementers miss — worth keeping the two-stage review.

## Active Threads
- Exploring Anthropic's plugin-dev skills (skill-creator, skill-development) for patterns to adopt
- Feature idea: add "Insights" section to switch's session log template to capture educational observations from sessions
- Pending from TODO.md: test startup on a fresh repo, test dian playbook creation in a real project

## Open Questions
- Should session logs capture "insights" (observations about the codebase/patterns discovered)? User wants this. Need to decide format and where it fits in the session log template.
- Are there patterns in Anthropic's plugin-dev skills we should adopt for Kerd's skill structure?
