# Agile Flow for Claude Code

Agile project management for Claude Code using Obsidian vaults as your board. Kanban boards, user stories, specs, specialist agents, automated review cycles, and a learning knowledge base — all managed through natural conversation.

## What It Does

- **Kanban boards** in Obsidian for sprint and backlog management
- **User stories** with acceptance criteria, testing strategy, and specialist context
- **Git worktrees** so multiple Claude sessions work on different stories in parallel
- **Specialist consultation** — auto-detects project type and consults domain experts during story creation
- **TDD enforcement** — tests-first workflow with coverage targets
- **Automated review cycles** — parallel review agents with fix/re-review loop (max 3 cycles)
- **Hard quality gates** — tests must pass, no CRITICAL findings, coverage checks
- **Learning system** — builds educational knowledge base from completed stories, with a shared `_Knowledge/` vault for cross-project findings
- **No special commands needed** — just talk to Claude naturally

## Install

```bash
git clone https://github.com/shoebillrexmail-cmyk/claude-agile-flow.git
cd claude-agile-flow
bash install.sh
```

The installer will:
1. Ask for your Obsidian vault path
2. Copy workflow rules to `~/.claude/rules/common/`
3. Copy vault templates to your vault's `_Templates/` folder
4. Tell you what to add to `~/.claude/settings.json`

### Prerequisites

- [Claude Code](https://code.claude.com) CLI
- [Obsidian](https://obsidian.md) with **Kanban** and **Tasks** community plugins installed
- Git + GitHub CLI (`gh`)

### settings.json

Make sure your `~/.claude/settings.json` includes:

```json
{
  "permissions": {
    "additionalDirectories": ["C:\\Obsidian_Vaults"]
  },
  "worktree": {
    "symlinkDirectories": ["node_modules", ".venv", ".cache"]
  }
}
```

### How it activates

The installer copies workflow rules to `~/.claude/rules/common/`. These load **automatically in every Claude Code session** — no setup per session needed.

However, Claude needs to know *which vault project* belongs to *which code repo*. Without that link, Claude has the agile workflow knowledge but won't touch any vault files (safe default).

**Two ways to link a repo to a vault project:**

**Option A — Just ask Claude (easiest):**
```
You: Set up agile flow for a project called "my-app"
Claude: → Creates vault structure + adds the config to your CLAUDE.md
```

**Option B — Manual:** Add this to your repo's `CLAUDE.md`:
```markdown
## Obsidian Project
- Vault project: my-project
- Sprint Board: C:\Obsidian_Vaults\my-project\Sprint\Board.md
- Product Backlog: C:\Obsidian_Vaults\my-project\Backlog\Product-Backlog.md
- Specs: C:\Obsidian_Vaults\my-project\Specs\
- Research: C:\Obsidian_Vaults\my-project\Research\
```

| Repo has `## Obsidian Project` in CLAUDE.md? | What happens |
|----------------------------------------------|-------------|
| Yes | Claude automatically reads the board, manages stories, uses worktrees |
| No | Claude knows the workflow but won't touch any vault — safe to use anywhere |

---

## Usage

Once installed, just open Claude Code in your repo and talk normally. The workflow rules teach Claude how to manage your boards, stories, and branches automatically.

### Setting up a new project

```
You: Set up agile flow for a project called "my-app"

Claude: → Creates vault folder structure (Learning/ + shared _Knowledge/ if missing)
        → Creates Sprint Board and Product Backlog
        → Creates Roadmap, Learning Index, and Knowledge Base Index
        → Updates your CLAUDE.md
```

### Creating stories

```
You: I need a user login feature with email and password

Claude: → Detects project type (React frontend, Node backend, etc.)
        → Consults specialist agents for approach feedback
        → Creates Backlog/Stories/STORY-user-login.md with:
          - User story and acceptance criteria
          - Specialist context (recommendations, known pitfalls)
          - Testing strategy (unit, integration, E2E — TDD enforced)
        → Creates Specs/Features/SPEC-user-login.md
        → Runs quality gate (testability, specialist coverage, completeness)
        → Adds it to the Product Backlog under "Needs Refinement"
```

### Checking your board

```
You: What's on the board?

Claude: → Reads Sprint Board and Backlog
        → Reports:
          "Sprint Board:
           Ready (2): STORY-user-login, STORY-payment-setup
           In Progress (1): STORY-api-auth
           In Review (0)
           Done (3): ...

           Backlog: 4 in Icebox, 2 need refinement, 3 refined"
```

### Picking up a story

```
You: Work on STORY-user-login

Claude: → Reads the story file, linked specs, and specialist context
        → Checks _Knowledge/ for cross-project gotchas and patterns
        → Checks Learning/ for project-specific prior learnings
        → Verifies test infrastructure is ready
        → Creates an isolated worktree (EnterWorktree)
        → Creates branch: feature/STORY-user-login
        → Moves story to "In Progress" on the Sprint Board
        → Presents development brief:
          - Acceptance criteria
          - Testing strategy (TDD enforced)
          - Specialist context + known pitfalls
          - Prior learnings from past stories
        → Starts implementation: tests first (RED), then code (GREEN), then refactor (IMPROVE)
```

### Working on multiple stories in parallel

Open separate terminals, each running `claude` in the same repo:

```
Terminal 1                          Terminal 2
─────────                          ─────────
You: Work on STORY-user-login      You: Work on STORY-payment-setup

Claude: → EnterWorktree            Claude: → EnterWorktree
        → feature/STORY-user-login         → feature/STORY-payment-setup
        → coding...                        → coding...
```

Each session gets its own worktree and branch. They don't interfere with each other. Both update the same Sprint Board in your Obsidian vault.

### Finishing a story

```
You: I'm done with this story, ship it

Claude: → Checks acceptance criteria against the code
        → Documentation gate: updates README, CHANGELOG, API docs
        → Creates backlog task for user-facing docs (if new feature)
        → Commits, pushes, creates PR targeting develop
        → Moves story to "In Review" on Sprint Board
        → Runs automated review cycle:
          - Launches review agents in parallel (code-reviewer, security-reviewer,
            plus language and domain-specific agents from installed plugins)
          - If findings: structured repair (R1 Localize → R2 Patch → R3 Validate)
          - Re-reviews incrementally (only re-runs agents that had findings)
          - Up to 3 cycles, then escalates to user
        → Hard gates: tests must pass, no CRITICAL security findings
        → Learning extraction: classifies findings as cross-cutting or project-specific
          - Cross-cutting (Gotchas, Patterns, Guides) → _Knowledge/ (shared across all projects)
          - Project-specific (architecture, conventions) → Learning/
        → Moves story to "Done"
```

### Managing sprints

```
You: Start a new sprint

Claude: → Archives current board to Archive/
        → Creates fresh Sprint Board
        → Shows refined stories from Backlog
        → Asks which to pull into the sprint
```

```
You: Pull STORY-notifications and STORY-settings into the sprint

Claude: → Moves them to "Ready" on Sprint Board
        → Updates story statuses
        → Reports total story points for the sprint
```

### Research spikes

```
You: I need to investigate which payment provider to use

Claude: → Creates Research/SPIKE-payment-provider.md
        → Researches options
        → Fills in findings and recommendation
        → Links back to the relevant story
```

---

## Story Lifecycle

```
                    ┌─────────────────────────────────────────────────┐
                    │              /agile-flow:story                  │
                    │  Detect project type → Consult specialists      │
                    │  → Generate testing strategy → Quality gate     │
                    └──────────────────┬──────────────────────────────┘
                                       │
                                       ▼
┌──────────┐    ┌──────────┐    ┌─────────────┐    ┌───────────┐    ┌──────┐
│  Icebox  │ →  │  Needs   │ →  │  Refined    │ →  │  Ready    │ →  │  In  │
│          │    │Refinement│    │(sprint-ready)│    │(on board) │    │Progr.│
└──────────┘    └──────────┘    └─────────────┘    └───────────┘    └──┬───┘
                                                                       │
                 /agile-flow:pickup                                    │
                 Load specialists + prior learnings + TDD brief        │
                 Enter worktree → TDD: RED → GREEN → IMPROVE          │
                                                                       │
                    ┌──────────────────────────────────────────────────┘
                    │  /agile-flow:done
                    ▼
          ┌─────────────────┐
          │   Doc Gate      │  Update README, CHANGELOG, API docs
          │   + PR Creation │  Create user-facing docs backlog task
          └────────┬────────┘
                   │
                   ▼
          ┌─────────────────┐
          │  Review Cycle   │  Parallel agents → findings → R1/R2/R3 repair
          │  (max 3 cycles) │  Incremental re-review → regression detection
          └────────┬────────┘
                   │
                   ▼
          ┌─────────────────┐
          │  Hard Gates     │  Tests pass? No CRITICAL findings? Coverage?
          └────────┬────────┘
                   │
                   ▼
          ┌─────────────────┐
          │  Learn          │  Classify → _Knowledge/ (cross-cutting)
          │                 │          or Learning/ (project-specific)
          └────────┬────────┘
                   │
                   ▼
             ┌──────────┐
             │   Done   │
             └──────────┘
```

---

## Review Cycle

When a story moves to "In Review", the automated review system:

1. **Detects** what changed and what project type this is
2. **Selects** review agents based on context:

| Always | Language-Specific | Domain-Specific (from plugins) |
|--------|------------------|-------------------------------|
| `code-reviewer` | `go-reviewer` | Discovered from installed domain |
| `security-reviewer` | `python-reviewer` | plugins' `specialists.md` configs |

3. **Launches** all applicable agents in parallel
4. **Collects** findings into a ledger with IDs (`F-001`, `F-002`...) tracking status across cycles
5. **Fixes** blocking findings using Structured Repair:
   - **R1 LOCALIZE** — read-only: identify exact file, function, line, root cause
   - **R2 PATCH** — generate up to 3 candidate fixes from localized context
   - **R3 VALIDATE** — run tests against each candidate, apply the best
6. **Re-reviews** incrementally (cycle 2+ only re-runs agents that had findings)
7. **Detects regressions** — if a fixed finding reappears, it's elevated to CRITICAL
8. **Repeats** up to 3 cycles (configurable with `--max-cycles`)
9. **Hard gates** before completing: tests must pass, no CRITICAL security findings

---

## Learning System

After every completed story, the system extracts learnings and routes them to the right place:

### Two-tier knowledge architecture

```
C:\Obsidian_Vaults\
├── _Knowledge/                    ← Shared across ALL projects
│   ├── Index.md                   ← Domain-indexed, severity-badged catalog
│   ├── Gotchas/GOTCHA-*.md        ← "Don't do X because Y"
│   ├── Patterns/PATTERN-*.md      ← Reusable anti-patterns / best practices
│   ├── Guides/GUIDE-*.md          ← Technology integration guides
│   └── Writeups/WRITEUP-*.md      ← Deep-dive educational content
│
├── my-project/
│   └── Learning/                  ← Project-specific only
│       ├── Patterns/              ← This project's conventions
│       ├── Integrations/          ← This project's integration setup
│       └── Writeups/              ← This project's architecture decisions
```

**Cross-cutting** (`_Knowledge/`): Findings that any project using this technology would benefit from. "Never pass signer on OPNet frontend", "Always simulate before sendTransaction."

**Project-specific** (`Learning/`): Architecture decisions and conventions unique to one codebase. "Our auth middleware uses X pattern."

### Four types of learning documents

| Type | Prefix | When Created | Destination |
|------|--------|-------------|-------------|
| **Gotcha** | `GOTCHA-` | Concrete mistake with a specific fix | Almost always `_Knowledge/` |
| **Pattern** | `PATTERN-` | Review found a bug, or specialist flagged an anti-pattern | `_Knowledge/` or `Learning/` |
| **Integration Guide** | `GUIDE-` | New technology, service, or library used for the first time | `_Knowledge/` or `Learning/` |
| **Writeup** | `WRITEUP-` | Complex problem solved with a non-obvious approach | `_Knowledge/` or `Learning/` |

### How it works

- **Auto-generated** after each story completes (skipped for trivial changes)
- **Auto-classified** — each finding is routed to `_Knowledge/` (cross-cutting) or `Learning/` (project-specific)
- **Deduplicated** — checks both locations before creating; updates existing entries instead of duplicating
- **Structured frontmatter** — every entry has type, domain tags, severity, staleness tracking, and source project
- **Occurrence tracking** — patterns seen 3+ times get flagged for linter rules
- **Staleness tracking** — entries with `last_verified` > 90 days are flagged during story pickup
- **Bidirectional links** — stories link to learnings, learnings link to stories
- **Consulted at pickup** — when starting a new story, BOTH `_Knowledge/` and project `Learning/` are loaded into the development brief
- **Promotion** — if a project-specific learning is encountered in a second project, it gets promoted to `_Knowledge/`

### Growing knowledge base

```
Project A, Story 1: Implement wallet connect → _Knowledge/Guides/GUIDE-wallet-connect.md (cross-cutting)
Project A, Story 2: Fix signer bug          → _Knowledge/Gotchas/GOTCHA-null-signer-frontend.md (cross-cutting)
Project A, Story 3: Build staking contract   → Learning/Writeups/WRITEUP-staking-architecture.md (project-specific)
                                               _Knowledge/Patterns/PATTERN-storage-pointer-order.md (cross-cutting)

Project B, Story 1: New token contract       → Loads GOTCHA-null-signer-frontend.md at pickup (from _Knowledge/)
                                               Loads PATTERN-storage-pointer-order.md at pickup (from _Knowledge/)
                                               Developer starts with ALL lessons from Project A
```

The `_Knowledge/` vault becomes a shared institutional memory. Project `Learning/` folders stay focused on project-specific context.

---

## How It Works

After installation, Claude Code loads the workflow rules from `~/.claude/rules/common/` on every session. These rules teach Claude:

1. **Where your vault is** and how to read/write Obsidian Markdown files
2. **The agile workflow** — backlog grooming, sprint planning, story lifecycle, bug reports, unplanned work
3. **Board formats** — Kanban plugin-compatible Markdown that renders as drag-and-drop boards in Obsidian
4. **Git branching** — one feature branch per story, PRs to develop, hotfixes to master
5. **Mandatory worktrees** — every code change happens in an isolated git worktree (non-negotiable)
6. **Specialist agents** — auto-detects project type and invokes domain specialists during creation and development
7. **TDD enforcement** — tests first, then implementation, then refactor, 80%+ coverage
8. **Review cycles** — parallel review agents with structured repair and regression detection
9. **Hard gates** — quality checks that block completion until resolved
10. **Learning extraction** — classifies findings as cross-cutting (`_Knowledge/`) or project-specific (`Learning/`)
11. **Documentation updates** — ensures repo docs stay current and creates backlog tasks for user-facing docs

You don't need slash commands. Claude understands what you want from natural language and follows the workflow rules.

### Rules Files

The installer copies these to `~/.claude/rules/common/`:

| Rule | What it enforces |
|------|-----------------|
| `obsidian-workflow.md` | Full agile lifecycle — board management, story creation with specialist consultation, TDD enforcement, review cycles with structured repair, hard gates, learning extraction, documentation gates. **Mandatory worktree rule**: all code work must happen in a worktree. |
| `git-workflow.md` | Branch strategy (master/develop/feature), branch-to-environment mapping, worktree setup, commit format with story refs, PR workflow. |

### settings.json Configuration

The installer also guides you to add these to `~/.claude/settings.json`:

```json
{
  "permissions": {
    "additionalDirectories": ["C:\\Obsidian_Vaults"]
  },
  "worktree": {
    "symlinkDirectories": ["node_modules", ".venv", ".cache"]
  }
}
```

- `additionalDirectories` — allows Claude to read/write your Obsidian vault from any project
- `symlinkDirectories` — avoids duplicating heavy folders when creating worktrees

## Vault Structure

The Obsidian vault has a shared `_Knowledge/` directory plus per-project folders:

```
C:\Obsidian_Vaults\
├── _Knowledge/                      # Shared cross-project knowledge base
│   ├── Index.md                     # Domain-indexed catalog
│   ├── Gotchas/GOTCHA-*.md          # Concrete mistakes with fixes
│   ├── Patterns/PATTERN-*.md        # Reusable anti-patterns / best practices
│   ├── Guides/GUIDE-*.md            # Technology integration guides
│   └── Writeups/WRITEUP-*.md        # Deep-dive educational content
│
├── my-project/
├── Roadmap.md                       # Phase-level milestones
├── Sprint/
│   └── Board.md                     # Kanban: Ready → In Progress → In Review → Done
├── Backlog/
│   ├── Product-Backlog.md           # Kanban: Icebox → Needs Refinement → Refined
│   ├── Epics/EPIC-*.md              # Large bodies of work
│   └── Stories/STORY-*.md           # User stories with acceptance criteria
├── Specs/
│   ├── Features/SPEC-*.md           # Detailed feature specifications
│   ├── Technical/SPEC-*.md          # Technical design documents
│   └── API/SPEC-*.md                # API contracts
├── Learning/
│   ├── Index.md                     # Catalog of all learnings
│   ├── Integrations/GUIDE-*.md      # How-to guides for technologies
│   ├── Patterns/PATTERN-*.md        # Anti-patterns, gotchas, best practices
│   └── Writeups/WRITEUP-*.md        # Educational deep-dives
├── Research/
│   └── SPIKE-*.md                   # Time-boxed investigations
├── Notes/
│   ├── Decisions/                   # Architecture decision records
│   ├── Daily/                       # Daily logs
│   └── Retros/                      # Sprint retrospectives
└── Archive/                         # Completed sprints
```

Open this in Obsidian with the **Kanban** and **Tasks** plugins, and `Board.md` / `Product-Backlog.md` render as interactive drag-and-drop boards.

## Git Strategy

```
master ────────────────────────── production / mainnet
  ↑ PR (release)
develop ───────────────────────── staging / testnet
  ↑ PR         ↑ PR         ↑ PR
feature/       feature/     feature/
STORY-login    STORY-pay    STORY-ui
(worktree 1)   (worktree 2) (worktree 3)
```

- Every story gets a branch: `feature/STORY-<name>`
- Each Claude session works in its own worktree — no conflicts
- PRs target `develop`, releases merge `develop → master`
- The Obsidian vault is shared across all sessions
- Branch-to-environment mapping: `feature/*` → preview, `develop` → staging/testnet, `master` → production/mainnet

## Domain Plugin Integration

agile-flow is general-purpose — it works for any project without domain-specific plugins. But when a domain plugin is installed, agile-flow automatically discovers and uses its specialist agents, domain rules, and test types.

### How it works

Domain plugins provide a `specialists.md` file that follows a standard convention. agile-flow discovers these during story creation, pickup, and review.

```
┌─────────────────────────────┐     ┌──────────────────────────────┐
│       agile-flow            │     │     domain plugin            │
│                             │     │     (e.g. opnet-knowledge)   │
│  story / pickup / review    │────▶│     specialists.md           │
│                             │     │                              │
│  "Which agents should I     │     │  - Detection rules           │
│   use for this project?"    │     │  - Agent tables              │
│                             │     │  - Domain rules              │
└─────────────────────────────┘     │  - Test types                │
                                    │  - MCP tools                 │
                                    └──────────────────────────────┘
```

### The specialists.md format

Domain plugins provide this file at their plugin root:

```markdown
---
domain: <name>
description: <one-line>
---

## Detection
How to detect this domain (package.json deps, config files, imports)

## Agents
### Story Creation — agents to consult for approach feedback
### Development — agents to invoke at trigger points during coding
### Review — agents to run during /agile-flow:review

## Domain Rules
Constraints to enforce during development

## Test Types
Additional test categories beyond unit/integration/E2E

## MCP Tools
Optional MCP tools that enrich the workflow
```

See [specialist-convention.md](specialist-convention.md) for the full specification.

### Discovery order

agile-flow finds specialist configs through:

1. **Story file** — the `## Specialist Context` section (populated at creation time)
2. **Installed plugins** — `specialists.md` files in plugin directories
3. **Project CLAUDE.md** — a `## Specialists` section pointing to the domain plugin
4. **Loaded rules** — domain routing rules in `~/.claude/rules/`

### Without domain plugins

agile-flow always provides these built-in agents regardless of domain:

| Agent | Purpose |
|-------|---------|
| `code-reviewer` | General code quality, patterns, maintainability |
| `security-reviewer` | Security vulnerabilities, secrets, OWASP top 10 |
| `tdd-guide` | Test-driven development enforcement |
| `architect` | System design and architectural decisions |
| `go-reviewer` | Idiomatic Go patterns (if Go files detected) |
| `python-reviewer` | PEP 8 and Pythonic patterns (if Python files detected) |

### Creating a domain plugin

To add specialist support for a new domain (e.g. Rust, Elixir, Kubernetes):

1. Create a plugin with agents for your domain
2. Add a `specialists.md` following the convention above
3. Optionally add a rule to `~/.claude/rules/` for auto-routing
4. Projects using your domain add `## Specialists` to their CLAUDE.md

### Example: OPNet integration

The [opnet-knowledge](https://github.com/shoebillrexmail-cmyk/opnet-knowledge) plugin implements this convention for Bitcoin L1 smart contract development:

```
# In the project's CLAUDE.md:
## Specialists
Domain plugin: opnet-knowledge
Detection: @btc-vision/ in package.json, asconfig.json exists

# agile-flow then discovers:
- 3 story creation agents (contract-dev, frontend-dev, backend-dev)
- 4 development trigger agents (contract patterns, wallet integration, RPC, TLA+)
- 6 review agents (auditor, optimizer, analyzers, cross-layer, dependencies)
- Domain rules (SafeMath, no Buffer, ML-DSA signatures, signer patterns)
- 3 test types (contract tests, on-chain E2E, adversarial)
- 6 MCP tools (audit, dev guidance, incident queries, deployment)
```

## Slash Commands (Plugin Mode)

If you want explicit slash commands in addition to natural language, run Claude with:

```bash
claude --plugin-dir /path/to/claude-agile-flow
```

| Command | Purpose |
|---------|---------|
| `/agile-flow:init` | Initialize vault structure for a new project |
| `/agile-flow:board` | Show sprint board and backlog status |
| `/agile-flow:story` | Create a story with specialist consultation and testing strategy |
| `/agile-flow:pickup` | Pick up a story — load context, enter worktree, start TDD |
| `/agile-flow:done` | Complete story — docs, PR, review cycle, hard gates, learn |
| `/agile-flow:review` | Run automated review cycle with structured repair |
| `/agile-flow:learn` | Extract learnings from a completed story |
| `/agile-flow:sprint` | Manage sprint lifecycle (start, pull, retro) |
| `/agile-flow:spike` | Create a time-boxed research spike |

## Repo Structure

```
claude-agile-flow/
├── .claude-plugin/              # Plugin manifest + marketplace
├── skills/                      # Slash commands
│   ├── init/                    # Initialize project vault
│   ├── board/                   # Show board status
│   ├── story/                   # Create story (specialist + testing)
│   ├── pickup/                  # Pick up story (TDD + learnings)
│   ├── done/                    # Complete story (docs + PR + review)
│   ├── review/                  # Automated review cycle (R1/R2/R3)
│   ├── learn/                   # Learning extraction
│   ├── sprint/                  # Sprint management
│   └── spike/                   # Research spikes
├── agents/                      # PM agent for board management
├── hooks/                       # Session exit: warns about in-progress stories
├── rules/                       # Workflow rules (core — copied by installer)
│   ├── obsidian-workflow.md     # Agile + Obsidian integration
│   └── git-workflow.md          # Branching + worktree strategy
├── templates/vault/             # Obsidian vault templates
│   ├── Board-template.md
│   ├── Backlog-template.md
│   ├── Story-template.md        # Includes specialist context + testing strategy
│   ├── Epic-template.md
│   ├── Feature-Spec-template.md # Includes specialist considerations + testing tables
│   ├── Technical-Spec-template.md
│   ├── Spike-template.md
│   ├── Knowledge-Index-template.md  # _Knowledge/ catalog template
│   ├── Gotcha-template.md          # Cross-project gotcha entry
│   ├── Learning-Index-template.md
│   ├── Integration-Guide-template.md
│   ├── Pattern-template.md
│   └── Writeup-template.md
├── specialist-convention.md      # How domain plugins integrate
├── install.sh                   # One-command setup
└── README.md
```

## License

MIT
