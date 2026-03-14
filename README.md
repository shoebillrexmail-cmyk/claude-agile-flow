# Agile Flow for Claude Code

An agile project management plugin for Claude Code that integrates Obsidian vaults, Kanban boards, user stories, and git worktrees for parallel development.

## What It Does

- **Kanban boards** in Obsidian for sprint and backlog management
- **User stories** with acceptance criteria, linked specs, and story points
- **Git worktrees** for isolated parallel sessions — each story gets its own workspace
- **Slash commands** for the full agile lifecycle: create stories, manage sprints, pick up work, ship PRs

## Quick Start

```bash
# Clone
git clone https://github.com/<your-user>/claude-agile-flow.git

# Install rules + templates
cd claude-agile-flow
bash install.sh

# Test the plugin locally
claude --plugin-dir .

# Initialize a project
/agile-flow:init my-project
```

## Commands

| Command | What it does |
|---------|-------------|
| `/agile-flow:init <name>` | Create vault structure for a new project |
| `/agile-flow:board` | Show sprint board and backlog status |
| `/agile-flow:story <desc>` | Create a new user story |
| `/agile-flow:sprint [start\|pull\|retro]` | Manage sprints |
| `/agile-flow:pickup [story]` | Pick up a story, enter worktree, start coding |
| `/agile-flow:done` | Complete story, push, create PR, update board |
| `/agile-flow:spike <question>` | Time-boxed research investigation |

## Workflow

```
Idea → /story → Icebox → Refine → /sprint pull → Ready
                                                    ↓
                                              /pickup STORY-x
                                                    ↓
                                          EnterWorktree (isolated)
                                                    ↓
                                              Code the feature
                                                    ↓
                                              /done → PR → Review → Done
```

## Architecture

```
claude-agile-flow/
├── .claude-plugin/
│   ├── plugin.json          # Plugin manifest
│   └── marketplace.json     # Marketplace definition
├── skills/                  # Slash commands
│   ├── board/SKILL.md       # /agile-flow:board
│   ├── story/SKILL.md       # /agile-flow:story
│   ├── sprint/SKILL.md      # /agile-flow:sprint
│   ├── pickup/SKILL.md      # /agile-flow:pickup
│   ├── done/SKILL.md        # /agile-flow:done
│   ├── spike/SKILL.md       # /agile-flow:spike
│   └── init/SKILL.md        # /agile-flow:init
├── agents/
│   └── agile-pm.md          # PM agent for board management
├── hooks/
│   └── hooks.json           # Session end: check for in-progress stories
├── rules/                   # Workflow rules (copied by installer)
│   ├── obsidian-workflow.md
│   └── git-workflow.md
├── templates/vault/         # Obsidian vault templates
│   ├── Board-template.md
│   ├── Backlog-template.md
│   ├── Epic-template.md
│   ├── Story-template.md
│   ├── Feature-Spec-template.md
│   ├── Technical-Spec-template.md
│   └── Spike-template.md
├── install.sh               # Installer script
└── README.md
```

## Vault Structure (per project)

```
<ProjectName>/
├── Roadmap.md
├── Sprint/Board.md              # Kanban: Ready → In Progress → In Review → Done
├── Backlog/
│   ├── Product-Backlog.md       # Kanban: Icebox → Needs Refinement → Refined
│   ├── Epics/EPIC-*.md
│   └── Stories/STORY-*.md
├── Specs/
│   ├── Features/SPEC-*.md
│   ├── Technical/SPEC-*.md
│   └── API/SPEC-*.md
├── Research/SPIKE-*.md
├── Notes/{Decisions,Daily,Retros}/
└── Archive/
```

## Requirements

- [Claude Code](https://claude.ai/claude-code) CLI
- [Obsidian](https://obsidian.md) with **Kanban** and **Tasks** community plugins
- Git

## Configuration

The installer adds to `~/.claude/rules/common/`:
- `obsidian-workflow.md` — Agile workflow rules
- `git-workflow.md` — Branching strategy with worktree support

And to `~/.claude/settings.json`:
- `permissions.additionalDirectories` — vault path
- `worktree.symlinkDirectories` — shared heavy directories

## License

MIT
