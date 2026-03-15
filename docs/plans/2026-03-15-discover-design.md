# Discover — Skill Gap Analysis

**Date:** 2026-03-15
**Status:** Design complete — ready for implementation

## What It Is

`/kerd:discover` scans the current project and Claude Code environment, then recommends skills/plugins to add or explore. Prevents the "island problem" — getting stuck with what you know while the ecosystem moves on.

Three tiers of "what should we be using here that we're not?" Each tier searches a wider radius, all informed by the same project signals.

## Three Tiers

### Tier 1: Installed but not activated here
"You have `frontend-design` installed but haven't used it in this project. This is a Next.js app — it would help."

- Scan installed plugins/skills (`~/.claude/plugins/`)
- Match against project signals
- Surface installed skills that are **relevant to this project** but aren't being leveraged
- **Action:** "Try using this here" — show how to invoke it

### Tier 2: Available but not installed
"The marketplace has `vercel:deploy` — matches your Next.js + Vercel setup."

- Read project signals
- Search Claude Code marketplace
- Search curated repos from `~/ObsidianLLM/kerd/discover-sources.json`
- Filter out what's already installed
- **Action:** Install prompt — `claude plugin add ...`

### Tier 3: Explore the unknown
"Trending: `plugin-testing-framework` — automated test harness for Claude Code plugins. 85 stars."

- GitHub search for Claude Code plugin/skill repos
- Web search for trending plugins, community discussions, announcements
- Filter out anything found in Tiers 1 & 2
- **Action:** "Check this out" — link + summary, you decide after looking

## Project Signals

Two layers of signal detection, computed fresh each run (not stored):

### Layer 1: Tech signals — file-based, mechanical
- Package manifests: `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`
- Deploy configs: `Dockerfile`, `vercel.json`, `netlify.toml`
- CI: `.github/workflows/`, `.gitlab-ci.yml`
- Environment: `.env.example`
- Dominant file extensions

### Layer 2: Work signals — theme extraction from prose
- `README.md` — project description, what it's for
- `docs/playbook.md` — integrations, architecture intent
- `TODO.md` — active work and backlog themes
- Vault `Decisions.md` — what kinds of decisions keep coming up
- Vault `[Name] Context.md` — latest section, recent work focus
- `kivna/sessions/` — last 3-5 session logs, recurring task patterns

From Layer 2, discover extracts **keywords and themes** — not categories. A project might surface: "fundraising, pitch deck, investor, compliance, content writing, SEO." These become search terms alongside the tech signals.

## Sources

**Tier 1:** `~/.claude/plugins/` — what's installed locally

**Tier 2 (two sources):**
- Claude Code marketplace
- Curated repo list at `~/ObsidianLLM/kerd/discover-sources.json`

**Tier 3 (two sources):**
- GitHub search — repos tagged or describing Claude Code plugins/skills
- Web search — blog posts, community discussions, trending mentions

### Curated list format

Lives in the vault, syncs between machines automatically. Simple lists, easy to edit:

```json
{
  "repos": [
    "anthonymaley/Kerd",
    "anthropics/claude-code-plugins",
    "obra/the-elements-of-style"
  ],
  "urls": [
    "https://github.com/topics/claude-code-plugin",
    "https://docs.anthropic.com/en/docs/claude-code"
  ]
}
```

Discover reads repos via GitHub API and fetches URLs at scan time. No metadata needed — discover figures out relevance from content.

## Report Format

Rich cards with enough info to decide without leaving the report. Each item shows: name, source link, description, why it's relevant here, and an actionable prompt.

```
┌─────────────────────────────────────────────────┐
│  /kerd:discover — Kerd                          │
└─────────────────────────────────────────────────┘

Project profile:
  Tech: markdown, JSON, Claude Code plugin
  Themes: workflow, session management, writing, auditing

━━━ Tier 1: Installed but not activated here ━━━━

┌─────────────────────────────────────────────────┐
│ elements-of-style: writing-clearly-and-concisely│
│                                                 │
│ Apply Strunk's timeless writing rules to ANY    │
│ prose humans will read — documentation, commit  │
│ messages, error messages, explanations. Makes   │
│ your writing clearer, stronger, and more        │
│ professional.                                   │
│                                                 │
│ Why here: Kerd has skriv for voice/tone — this  │
│ complements it with structural prose rules.     │
│ Your session logs show frequent doc writing.    │
│                                                 │
│ Already installed — try: /elements-of-style     │
└─────────────────────────────────────────────────┘

━━━ Tier 2: Available but not installed ━━━━━━━━━

┌─────────────────────────────────────────────────┐
│ The Elements of Style                           │
│ github.com/obra/the-elements-of-style           │
│                                                 │
│ A Claude Code plugin providing William Strunk   │
│ Jr.'s The Elements of Style (1918) as a         │
│ reference skill for clear, precise writing.     │
│ Gives Claude access to Strunk's foundational    │
│ writing guidance when working on documentation, │
│ user-facing text, or any prose that needs       │
│ clarity and proper style.                       │
│                                                 │
│ Why here: You build writing skills — having     │
│ Strunk as a reference would strengthen skriv    │
│ and any doc work across projects.               │
│                                                 │
│ Install: claude plugin add obra/the-elements-   │
│ of-style                                        │
└─────────────────────────────────────────────────┘

━━━ Tier 3: Worth exploring ━━━━━━━━━━━━━━━━━━━━

┌─────────────────────────────────────────────────┐
│ plugin-testing-framework                        │
│ github.com/user/plugin-testing ⭐ 85 · active   │
│                                                 │
│ Automated test harness for Claude Code plugins. │
│ Runs skill triggering evals, validates hook     │
│ behavior, and checks plugin.json consistency.   │
│ Generates coverage reports per skill.           │
│                                                 │
│ Why here: Your session logs mention eval issues │
│ with skill-creator — this addresses the same    │
│ gap from a different angle.                     │
│                                                 │
│ Explore: github.com/user/plugin-testing         │
└─────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 1 installed match · 1 available · 1 to explore
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

After the report, discover walks through each item individually:
- Tier 1: "Want me to show how to use X in this project?"
- Tier 2: "Install X?" (runs the install command on approval)
- Tier 3: "Want me to fetch the README so you can see more?"

No batch actions across tiers — different trust levels, different actions.

## What Discover Does NOT Do

- **No auto-install.** Every install is prompted and approved.
- **No removal suggestions.** A skill unused here may be critical elsewhere. Discover finds gaps, not waste.
- **No health checks.** That's tend's job (structure) or sotu's job (content).
- **No caching of results.** Fresh scan every run.
- **No rating or ranking.** Presents what it finds with context. You decide what's valuable.

## Boundary with Other Skills

- **tend** — structural health (dirs, vault, config, naming)
- **sotu** — content health (doc accuracy, staleness)
- **discover** — skill/plugin opportunities (what tools would help this project)

## Migration from Startup

Discover is a new skill (7th skill). It does not replace anything. Version bump: MINOR (new skill).

Update needed:
- Create `skills/discover/SKILL.md`
- Create `~/ObsidianLLM/kerd/discover-sources.json` (seeded with initial repos)
- Update README: add discover section, change "Six" to "Seven"
- Update CLAUDE.md description
- Update plugin.json and marketplace.json descriptions
- Bump version
- Update playbook and changelog
