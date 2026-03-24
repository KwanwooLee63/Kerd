---
name: mode
description: "Use when the user says 'mode', 'greenfield', 'quickfix', 'maintain', 'strategy', 'writing', 'research', 'legal', 'sales', or wants to start a guided workflow for a specific type of work. Orchestrates skills from Kerd, GSD, Superpowers, and other plugins into customizable session flows."
---

# Mode (Workflow Routing)

Session configurations that prime the right tools for a type of work. Modes don't call other skills directly. They set up the session, present a customizable flow, and guide you through it.

## Usage

`/kerd:mode` list all available modes by category
`/kerd:mode <name>` load and start the named mode

## The Mechanic

### 1. Load

If no argument given, list all modes. Read every `.md` file in the `modes/` directory, parse the YAML frontmatter, and display grouped by category:

```
Available modes:

  Development
    greenfield    Build a new feature from scratch using spec-driven development
    quickfix      Bug fix or small change with minimal ceremony
    deepwork      Focused session on existing feature, dian-driven
    maintain      Health loop: structural, content, skill, and writing audits

  Business
    strategy      Positioning, go-to-market, competitive analysis
    writing       Prose creation: blog posts, docs, investor updates
    research      Investigation, due diligence, market analysis

  Operations
    legal         Contract review, compliance, policy drafting
    sales         Pipeline review, call prep, outreach drafting

Start a mode: /kerd:mode <name>
```

If an argument is given, read `modes/<name>.md`. If the file doesn't exist, say: "Mode '<name>' not found." Then list available modes.

### 2. Check core skills

Parse `core_skills` from the mode's frontmatter. For each skill, check if the plugin is installed by scanning `~/.claude/plugins/cache/` for a matching plugin and skill name. The skill reference format is `plugin:skill-name` (e.g., `gsd:new-project`, `superpowers:brainstorming`, `kerd:switch`).

For Kerd skills, they are always available (same plugin). For external skills, check the cache directory.

Report status:

```
Core skills:
  ✓ gsd:new-project
  ✓ superpowers:brainstorming
  ✓ kerd:switch
  ✗ superpowers:test-driven-development (not installed)
```

Missing core skills are a warning, not a blocker. The mode still runs.

### 3. Auto-discover extras

If the mode has `discover_keywords` in frontmatter, scan installed plugins for skills whose SKILL.md description contains any of the keywords. Exclude skills already in the core list.

Show matches:

```
Discovered extras:
  + superpowers:using-git-worktrees — isolate feature work
  + pr-review-toolkit:review-pr — comprehensive PR review
```

If no extras found, skip this section silently. These are suggestions only, displayed once.

### 4. Present and customize

Extract all checkbox lines (`- [ ]`) from the mode body. Display as a numbered checklist with all steps enabled:

```
Greenfield flow:

  [x] 1. /kerd:switch in — pull, get context
  [x] 2. Confirm: what are we building?
  [x] 3. /gsd:new-project — questions, research, requirements
  [x] 4. /gsd:discuss-phase N — capture decisions
  [x] 5. /gsd:plan-phase N — research + task plans
  [x] 6. /gsd:execute-phase N — parallel execution
  [x] 7. /gsd:verify-work N — confirm it works
  [x] 8. /kerd:slainte docs — health check
  [x] 9. /kerd:switch out — commit, push, vault

Edit the flow? (skip steps, reorder, add custom steps, or 'go' to start)
```

Wait for the user to customize or say "go":
- **Skip:** "skip 4 and 8" removes those steps
- **Add:** "add 'run migrations' after step 6" inserts a custom step
- **Reorder:** "move 8 before 7" changes step order
- **Go:** "go" locks the flow and begins

Multiple edits are fine. Re-display after each edit. Only proceed when the user says "go" (or equivalent: "start", "ready", "let's go").

### 5. Track progress

Write the active mode to `kivna/.active-modes`:

```
mode: greenfield (step 1 of 9)
```

After each step is completed (user confirms it's done, or the invoked skill completes), update the tracker:

```
mode: greenfield (step 3 of 9)
```

Remind the user what's next:

```
✓ Step 3 complete. Next: step 4 — /gsd:discuss-phase N (capture decisions)
```

If the user goes off-script (does something not in the flow), don't block them. When they come back, show where they are in the flow and what remains.

### 6. Complete

When all enabled steps are done (or the user says "done"), clear the mode from `.active-modes` and confirm:

```
Mode complete: greenfield (9/9 steps)
```

## Notes

- Modes are session configurations, not automations. They guide, they don't drive.
- The flow is a recommendation. Users can skip steps, go out of order, or bail early.
- Mode files live in `modes/` at the repo root. One file per mode.
- Community contributions: PR a single `.md` file to `modes/` to add a mode.
- Modes don't replace dian. Dian is session discipline within a mode. A mode can include dian as a step.
- The mode skill reads from the `modes/` directory relative to the plugin root, not the current working directory. This means the modes ship with the plugin.
