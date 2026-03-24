# Modes Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a `/kerd:mode` skill that loads workflow modes from `modes/` directory, checks skill availability, auto-discovers extras, presents an editable flow, and tracks progress.

**Architecture:** One new skill (`skills/mode/SKILL.md`) reads mode definitions from `modes/*.md`. Each mode file has YAML frontmatter (name, description, category, core_skills, discover_keywords) and a markdown body (the flow checklist). The skill parses these, checks installed plugins, presents the flow, and tracks progress via `kivna/.active-modes`.

**Tech Stack:** Pure markdown. No runtime dependencies.

---

### Task 1: Create the mode skill

**Files:**
- Create: `skills/mode/SKILL.md`

**Step 1: Write the skill file**

Create `skills/mode/SKILL.md` with the full skill definition. The skill handles:
- No args: list all modes from `modes/` directory, grouped by category
- With arg: load the named mode, run the mechanic (check skills, discover extras, present flow, customize, track)

The SKILL.md frontmatter:
```yaml
---
name: mode
description: "Use when the user says 'mode', 'greenfield', 'quickfix', 'maintain', 'strategy', 'writing', 'research', 'legal', 'sales', or wants to start a guided workflow for a specific type of work. Orchestrates skills from Kerd, GSD, Superpowers, and other plugins into customizable session flows."
---
```

The body defines the full mechanic from the design doc:
1. Load mode file from `modes/<name>.md`
2. Parse YAML frontmatter for core_skills and discover_keywords
3. Check core skills against `~/.claude/plugins/cache/`
4. Auto-discover extras by scanning installed skill descriptions for keyword matches
5. Present numbered checklist from mode body, all enabled by default
6. Let user customize (skip, reorder, add steps) before "go"
7. On "go", write active mode to `kivna/.active-modes` and begin tracking
8. After each step, check it off and remind what's next
9. On completion or "done", clear mode from `.active-modes`

**Step 2: Commit**

```bash
git add skills/mode/SKILL.md
git commit -m "feat: add mode skill for workflow orchestration"
```

---

### Task 2: Create the modes directory with 4 development modes

**Files:**
- Create: `modes/greenfield.md`
- Create: `modes/quickfix.md`
- Create: `modes/deepwork.md`
- Create: `modes/maintain.md`

**Step 1: Write greenfield.md**

Full spec-driven build flow. Core skills: GSD (new-project, discuss-phase, plan-phase, execute-phase, verify-work), Superpowers (brainstorming, TDD, verification, code review), Kerd (switch, slainte). Keywords: feature, implementation, testing, code review, deployment.

**Step 2: Write quickfix.md**

Bug fix or small change. Core skills: Superpowers (systematic-debugging, TDD, verification), Kerd (switch). Keywords: bug, fix, patch, debug. Flow uses switch light.

**Step 3: Write deepwork.md**

Existing feature, dian-driven, no GSD. Core skills: Kerd (dian, switch, slainte), Superpowers (brainstorming, writing-plans, dispatching-parallel-agents, verification, code review, finishing-a-development-branch). Keywords: refactor, feature, enhancement.

**Step 4: Write maintain.md**

Health loop. Core skills: Kerd (tend, slainte, lorg, skriv). Keywords: health, audit, drift, staleness. No GSD or Superpowers needed.

**Step 5: Commit**

```bash
git add modes/
git commit -m "feat: add 4 development modes (greenfield, quickfix, deepwork, maintain)"
```

---

### Task 3: Create 3 business modes

**Files:**
- Create: `modes/strategy.md`
- Create: `modes/writing.md`
- Create: `modes/research.md`

**Step 1: Write strategy.md**

Positioning, go-to-market, competitive analysis. Core skills: Kerd (skriv, switch), Superpowers (brainstorming). Keywords: strategy, positioning, market, competitive, pricing, go-to-market. Discover will pick up sales plugin skills if installed.

**Step 2: Write writing.md**

Prose creation. Core skills: Kerd (skriv, switch), Superpowers (brainstorming). Keywords: writing, prose, blog, documentation, copy, content. Light flow: skriv on, brainstorm topic, write, skriv audit, switch out.

**Step 3: Write research.md**

Investigation and due diligence. Core skills: Superpowers (brainstorming), Kerd (switch, kivna). Keywords: research, investigation, analysis, due diligence, market. Discover will pick up firecrawl if installed.

**Step 4: Commit**

```bash
git add modes/
git commit -m "feat: add 3 business modes (strategy, writing, research)"
```

---

### Task 4: Create 2 operations modes

**Files:**
- Create: `modes/legal.md`
- Create: `modes/sales.md`

**Step 1: Write legal.md**

Contract review, compliance, policy. Core skills: Kerd (skriv, switch), Superpowers (brainstorming). Keywords: legal, compliance, contract, policy, regulation, terms. Discover-heavy since legal skills vary by install.

**Step 2: Write sales.md**

Pipeline review, call prep, outreach. Core skills: Kerd (skriv, switch), Superpowers (brainstorming). Keywords: sales, pipeline, outreach, prospect, deal, forecast, call prep. Discover will pick up sales plugin skills (pipeline-review, call-prep, draft-outreach, etc.) if installed.

**Step 3: Commit**

```bash
git add modes/
git commit -m "feat: add 2 operations modes (legal, sales)"
```

---

### Task 5: Release checklist

**Files:**
- Modify: `.claude-plugin/plugin.json` — version to 0.17.0
- Modify: `.claude-plugin/marketplace.json` — version to 0.17.0 (both locations)
- Modify: `README.md` — add mode section
- Modify: `CLAUDE.md` — add modes/ to project structure
- Modify: `docs/playbook.md` — update version and recent changes

**Step 1: Bump version to 0.17.0 in all three locations**

- `.claude-plugin/plugin.json` → `version: "0.17.0"`
- `.claude-plugin/marketplace.json` → `metadata.version: "0.17.0"`
- `.claude-plugin/marketplace.json` → `plugins[0].version: "0.17.0"`

**Step 2: Update plugin description**

Add "workflow modes" to the description in plugin.json and marketplace.json since this is a new high-level capability.

**Step 3: Update README.md**

Add a new section for mode after the lorg section. Cover: what modes are, how to invoke, starter modes list, community contribution.

**Step 4: Update CLAUDE.md**

Add `modes/` to the project structure section.

**Step 5: Update docs/playbook.md**

- Version to 0.17.0
- Add mode to "Working" list
- Add v0.17.0 to recent changes

**Step 6: Commit**

```bash
git add .claude-plugin/ README.md CLAUDE.md docs/playbook.md
git commit -m "feat: workflow modes with 9 starter flows (v0.17.0)"
```

**Step 7: Push**

```bash
git push
```
