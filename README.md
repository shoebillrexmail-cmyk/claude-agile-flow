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
- **Learning system** — builds educational knowledge base from completed stories
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

Claude: → Creates vault folder structure (including Learning/)
        → Creates Sprint Board and Product Backlog
        → Creates Roadmap and Learning Index
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
        → Checks Learning/ for relevant prior patterns, guides, writeups
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
            plus specialists: opnet-auditor, go-reviewer, python-reviewer, etc.)
          - If findings: structured repair (R1 Localize → R2 Patch → R3 Validate)
          - Re-reviews incrementally (only re-runs agents that had findings)
          - Up to 3 cycles, then escalates to user
        → Hard gates: tests must pass, no CRITICAL security findings
        → Learning extraction: generates Integration Guides, Patterns, Writeups
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
          │  Learn          │  Extract Integration Guides, Patterns, Writeups
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

| Always | Language-Specific | OPNet-Specific |
|--------|------------------|----------------|
| `code-reviewer` | `go-reviewer` | `opnet-auditor` |
| `security-reviewer` | `python-reviewer` | `contract-optimizer` |
| | | `frontend-analyzer` |
| | | `backend-analyzer` |
| | | `cross-layer-validator` |
| | | `dependency-auditor` |

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

After every completed story, the system extracts learnings into your Obsidian vault:

### Three types of learning documents

| Type | When Created | Example |
|------|-------------|---------|
| **Integration Guide** | New technology, service, or library used for the first time | `GUIDE-wallet-connect.md` — step-by-step how-to with annotated code |
| **Pattern** | Review found a bug, or specialist flagged a gotcha | `PATTERN-no-buffer-in-contracts.md` — wrong way vs right way |
| **Writeup** | Complex problem solved with a non-obvious approach | `WRITEUP-multi-pool-staking.md` — educational deep-dive |

### How it works

- **Auto-generated** after each story completes (skipped for trivial changes)
- **Deduplicated** — updates existing guides/patterns instead of creating duplicates
- **Occurrence tracking** — patterns seen 3+ times get flagged for linter rules
- **Bidirectional links** — stories link to learnings, learnings link to stories
- **Consulted at pickup** — when starting a new story, prior learnings are loaded into the development brief
- **Cataloged** in `Learning/Index.md` with searchable tables

### Growing knowledge base

```
Story 1: Implement wallet connect → GUIDE-wallet-connect.md
Story 2: Fix signer bug          → PATTERN-null-signer-frontend.md
Story 3: Build staking contract   → WRITEUP-staking-architecture.md
                                    PATTERN-storage-pointer-order.md

Story 4: New token contract       → Loads PATTERN-storage-pointer-order.md at pickup
                                    Developer starts with lessons from Story 3
```

The vault becomes an educational resource the user can browse in Obsidian to understand the project's history, patterns, and integrations.

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
10. **Learning extraction** — generates educational content from completed stories
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

Each project gets this structure in your Obsidian vault:

```
my-project/
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
│   ├── Learning-Index-template.md
│   ├── Integration-Guide-template.md
│   ├── Pattern-template.md
│   └── Writeup-template.md
├── install.sh                   # One-command setup
└── README.md
```

## License

MIT
