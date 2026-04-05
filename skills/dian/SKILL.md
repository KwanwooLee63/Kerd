---
name: dian
description: "Use when starting a work session, when you need structured session discipline, or when the user says 'dian', 'session', 'let's get structured', or wants to plan and track a focused work block. Provides orient-plan-execute-close protocol."
---

# Dian (Session Discipline)

From Irish/Scottish Gaelic "dian," intense, rigorous. Pronounced "DEE-an".

A protocol for staying focused within a session. Dian does not touch git boundaries (pull/push). That's switch's job. Dian keeps you on track once you're working.

## Mode Markers

Dian is a modal skill. It runs across multiple responses. Announce the current phase so the user always knows what's active.

**On every phase transition**, output a marker on its own line at the top of your response:

- `[dian: orient]` reading context, summarizing state
- `[dian: plan]` proposing session plan
- `[dian: execute]` working through tasks
- `[dian: close-out]` updating docs, running checks
- `[dian: closed]` session complete (final marker, then done)

**State file:** When entering a phase, write the current phase to `kivna/.active-modes`. When closing out, remove the dian line from the file (or delete the file if it's the only entry). This lets `/kerd:switch in` report active modes and hooks surface reminders.

Format of `kivna/.active-modes` — dian owns one line only:
```
dian: <phase>
```

Example: `dian: execute`. Remove the line entirely when closing out (don't write `dian: closed`). Never touch other skills' lines in this file.

## The Protocol

### 1. Orient

Output `[dian: orient]` at the top of your response.

Read these files if they exist (skip any that don't):

1. `TODO.md`: current session plan, roadmap, task queue
2. `CLAUDE.md`: project conventions and structure
3. Vault: discover the vault path using `kivna/vault.json` or convention (see `/kerd:kivna` vault discovery). Read `[Name] Status.md` for where the project stands. Read the MOC (`[Name].md`) to discover what other vault files exist (Architecture Decisions, Playbook, etc.) and read any that are relevant to the planned work.
4. Progress tracking: check `docs/project/progress.md`, `progress.md`, or `CHANGELOG.md`
5. `docs/playbook.md`: project playbook (how to rebuild this project from scratch)

**Mode awareness:** Read `kivna/.active-modes`. If a mode is active, report it: what mode, which step, and the session instruction if one was set. Dian should operate within the mode's scope. If the mode says "focus on pricing strategy only," dian's plan should respect that constraint. If no mode is active, proceed normally.

**Consistency sniff test:** After reading, do a quick cross-check. Does CLAUDE.md reference files or conventions that don't match the codebase? Does the playbook's tech stack or architecture still match reality? Does the vault Status mention things that have since changed? Flag any contradictions to the user before planning. Don't build on stale assumptions.

Summarize the current state for the user, including any inconsistencies found and active mode context.

### 2. Plan

Output `[dian: plan]` at the top of your response.

#### Critical review

Before writing the plan, surface doubts and unresolved risks. If something about the task feels underspecified, contradictory, or risky, say so now. Do not hide concerns to appear confident. Do not guess or infer context. It's cheaper to spend two minutes clarifying than to build the wrong thing.

**Challenge yourself on:**
- Do I actually understand what the user wants, or am I filling in gaps with assumptions?
- Are there dependencies between tasks that affect the order?
- Is anything in the plan vague enough that I might interpret it differently than the user intended?
- What could go wrong, and how will I catch it?

Ask clarifying questions about anything ambiguous. Push back on things that don't make sense.

#### Write the plan

Propose a session plan to the user. Each step must be concrete and testable:

- **What:** specific action with file paths
- **Verify:** how to confirm it worked (command to run, output to check, behavior to observe)

Ban vague plan items. "Implement feature X" is not a plan step. "Write the handler in `src/api/handler.ts` that accepts POST requests and returns 201" is. Every step should be small enough that you can verify it independently before moving on.

If a mode is active, scope the plan to the mode's current step and instruction. Don't plan beyond the mode's scope.

Write this as a `## Current Session` block in TODO.md with today's date. Wait for user approval before executing. Do not proceed until the user confirms the plan. A good plan prevents rework.

### 3. Execute

Output `[dian: execute]` at the top of your response when entering this phase.

Do the work. Stay focused on the plan.

#### Verification gate

After each task, verify it with evidence before claiming it's done. No exceptions.

1. **Identify** the check: what command, file read, or test confirms this task worked?
2. **Run** it. Actually run it. Don't assume.
3. **Read** the output. Look at what came back.
4. **Confirm** the claim: does the evidence support "this task is done"?

Only then mark the task complete. If you catch yourself thinking "should work", "probably fine", or "seems good" without evidence, stop. Run the check.

#### 3-fix limit

If a task isn't working after 3 attempts, stop. Do not attempt fix #4. Instead:
- Summarize what was tried and why each attempt failed
- Surface the problem to the user
- Ask whether to continue with a different approach, skip the task, or rethink the plan

Three failed fixes usually means the approach is wrong, not the execution.

#### Scope creep

If something comes up that isn't in the plan, stop working on it immediately. Add it to TODO.md backlog. Do not continue on the tangent. Do not "just quickly" do it. Return to the current plan step. The user can reopen the plan if the new work is more important.

#### Decision recording

When a significant decision is made during execution (architecture choice, rejected approach, key trade-off), record it in TODO.md's `### Context` section immediately. Don't defer to close-out. Decisions lose their reasoning if you wait.

Do not write to `kivna/sessions/` during execution. Switch owns session log creation at the git boundary. Dian's decisions accumulate in TODO.md and flow into the session log when switch runs.

#### Docs travel with code

If a task changes behavior, update the affected docs (README, playbook, CLAUDE.md) in the same commit. Don't defer doc updates to close-out. No commit should leave docs inconsistent with code.

#### No mid-session vault writes

Work accumulates in repo-side files (TODO.md) during execution. The vault gets one clean update at close-out. This keeps the vault lean and searchable: one session, one update.

### 4. Close Out

Output `[dian: close-out]` at the top of your response.

Before ending the session:

1. **Update TODO.md**: check off completed tasks, add new ones discovered during work, update roadmap statuses, clear the `## Current Session` block.
2. **Doc impact assessment**: if the project has a Doc Impact Table in CLAUDE.md, check it. Update ALL affected docs.
3. **Update the vault**: call `/kerd:kivna save` once. This updates vault `[Name] Status.md` (with approval) and proposes updates to any other vault files where new knowledge belongs. This is the single vault write for the session.
4. **Update playbook**: if `docs/playbook.md` exists, update it with anything learned this session: new setup steps, new integrations, gotchas discovered, tech stack changes, updated Current Status section. If it doesn't exist, create it from the skeleton:

```markdown
# Playbook: [Project Name]

How to rebuild this project from scratch.

## Tech Stack
[What tools/frameworks and why they were chosen]

## Setup
[Steps to get the project running locally]

## Architecture
[Key structural decisions and why]

## Integrations
[External services, APIs, config needed]

## Deployment
[How to deploy, environment variables needed]

## Gotchas
[Things that broke, non-obvious behavior, workarounds]

## Current Status
[What's working, what's in progress, what's next]
```

5. **Diff review**: run `git diff` (or `git diff --cached` if staged) to review everything changed this session. Look for accidental changes, forgotten files, inconsistencies between code and docs, anything that doesn't match the plan. Fix issues before proceeding.
6. **Staleness sweep**: search for any renamed or changed concepts across `docs/`, `README.md`, and other documentation.
7. **Run checks**: run the project's build/test command if one exists. Do not close out with failing tests.
8. **Mode-aware completion**: if a mode is active, do NOT suggest the session is done unless the mode flow is also complete. Dian may be one step in a larger mode flow. After dian's close-out, control returns to the mode for the next step. If no mode is active, this is the natural end point.
9. **Clear mode marker**: remove the dian line from `kivna/.active-modes`. Output `[dian: closed]` as the final marker. Never touch the mode line — mode owns its own state.

## Principles

- **No git boundary ops.** No `git pull`, no `git push`. Use `/kerd:switch` for that.
- **Evidence before claims.** Every "done" must have a check that was run, output that was read, and a conclusion that follows.
- **Hard stop on scope creep.** Out-of-plan work goes to backlog. No exceptions without reopening the plan.
- **Three fixes, then escalate.** Don't thrash. Surface the problem.
- **Docs travel with code.** If you change behavior, update the docs in the same commit.
- **Dian doesn't own session logs.** Decisions go to TODO.md. Switch writes the session log at the boundary.
