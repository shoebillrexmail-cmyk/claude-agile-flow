# Agile Flow for Claude Code

Agile project management for Claude Code using Obsidian vaults as your board. Kanban boards, user stories, specs, and git worktrees — all managed through natural conversation.

## What It Does

- **Kanban boards** in Obsidian for sprint and backlog management
- **User stories** with acceptance criteria, linked specs, and story points
- **Git worktrees** so multiple Claude sessions work on different stories in parallel
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

Claude: → Creates vault folder structure
        → Creates Sprint Board and Product Backlog
        → Creates Roadmap
        → Updates your CLAUDE.md
```

### Creating stories

```
You: I need a user login feature with email and password

Claude: → Creates Backlog/Stories/STORY-user-login.md
        → Writes user story, acceptance criteria, tasks
        → Creates Specs/Features/SPEC-user-login.md for the detailed spec
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

Claude: → Reads the story file and linked specs
        → Creates an isolated worktree (EnterWorktree)
        → Creates branch: feature/STORY-user-login
        → Moves story to "In Progress" on the Sprint Board
        → Starts implementing based on acceptance criteria
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
        → Commits remaining changes
        → Pushes branch
        → Creates PR targeting develop
        → Moves story to "In Review" on Sprint Board
        → Updates story file with PR link
        → Asks if you want to exit the worktree
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

### Creating specs

```
You: Write a detailed spec for the notification system

Claude: → Creates Specs/Features/SPEC-notifications.md
        → Writes requirements, user flows, data model, edge cases
        → Links it from the story file
```

---

## How It Works

After installation, Claude Code loads the workflow rules from `~/.claude/rules/common/` on every session. These rules teach Claude:

1. **Where your vault is** and how to read/write Obsidian Markdown files
2. **The agile workflow** — backlog grooming, sprint planning, story lifecycle, bug reports, unplanned work
3. **Board formats** — Kanban plugin-compatible Markdown that renders as drag-and-drop boards in Obsidian
4. **Git branching** — one feature branch per story, PRs to develop, hotfixes to master
5. **Mandatory worktrees** — every code change happens in an isolated git worktree (non-negotiable)
6. **When to update what** — move board items, check off tasks, write notes as work progresses

You don't need slash commands. Claude understands what you want from natural language and follows the workflow rules.

### Rules Files

The installer copies these to `~/.claude/rules/common/`:

| Rule | What it enforces |
|------|-----------------|
| `obsidian-workflow.md` | Full agile lifecycle — board management, story creation, bug handling, sprint planning. **Mandatory worktree rule**: all code work must happen in a worktree. |
| `git-workflow.md` | Branch strategy (master/develop/feature), worktree setup, commit format with story refs, PR workflow. |

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
master ────────────────────────── production
  ↑ PR (release)
develop ───────────────────────── integration
  ↑ PR         ↑ PR         ↑ PR
feature/       feature/     feature/
STORY-login    STORY-pay    STORY-ui
(worktree 1)   (worktree 2) (worktree 3)
```

- Every story gets a branch: `feature/STORY-<name>`
- Each Claude session works in its own worktree — no conflicts
- PRs target `develop`, releases merge `develop → master`
- The Obsidian vault is shared across all sessions

## Plugin Mode (Optional)

If you want the slash commands (`/agile-flow:board`, `/agile-flow:pickup`, etc.) in addition to natural language, run Claude with:

```bash
claude --plugin-dir /path/to/claude-agile-flow
```

Or add the marketplace:
```
/plugin marketplace add shoebillrexmail-cmyk/claude-agile-flow
```

## Repo Structure

```
claude-agile-flow/
├── .claude-plugin/              # Plugin manifest + marketplace
├── skills/                      # Slash commands (optional)
├── agents/                      # PM agent for board management
├── hooks/                       # Session exit: warns about in-progress stories
├── rules/                       # Workflow rules (core — copied by installer)
│   ├── obsidian-workflow.md     # Agile + Obsidian integration
│   └── git-workflow.md          # Branching + worktree strategy
├── templates/vault/             # Obsidian vault templates
├── install.sh                   # One-command setup
└── README.md
```

## License

MIT
