# Obsidian Vault Workflow — Agile

## Vault Location
- Path: `C:\Obsidian_Vaults`
- Each project has its own folder: `C:\Obsidian_Vaults\<ProjectName>\`
- The vault directory is in `additionalDirectories` — use Read/Edit/Write tools directly
- The current project's vault folder is specified in the repo's CLAUDE.md under `## Obsidian Project`

## Project Structure
```
<ProjectName>/
├── Roadmap.md                    # Phase-level milestones and epics
├── Sprint/
│   └── Board.md                  # Kanban board for current sprint work
├── Backlog/
│   ├── Product-Backlog.md        # Kanban board: Icebox → Needs Refinement → Refined
│   ├── Epics/
│   │   └── EPIC-<name>.md        # Epic definitions
│   └── Stories/
│       └── STORY-<name>.md       # User stories with acceptance criteria
├── Specs/
│   ├── Features/
│   │   └── SPEC-<feature>.md     # Detailed feature specifications
│   ├── Technical/
│   │   └── SPEC-<component>.md   # Technical design documents
│   └── API/
│       └── SPEC-<endpoint>.md    # API contracts
├── Research/
│   ├── SPIKE-<topic>.md          # Time-boxed investigations
│   ├── POC-<topic>.md            # Proof of concepts
│   └── RESEARCH-<topic>.md       # General research
├── Notes/
│   ├── Decisions/                # Architecture decision records
│   ├── Daily/                    # Daily logs
│   └── Retros/                   # Sprint retrospectives
└── Archive/                      # Completed sprints and old boards
```

## Agile Hierarchy

```
Roadmap (phases)
  └── Epic (large body of work)
        └── Story (user-facing value, has acceptance criteria)
              ├── Tasks (checklist items within the story)
              ├── Specs (linked detailed documents in Specs/)
              └── Branch: feature/STORY-<name>
```

## Board Formats

### Product Backlog (`Backlog/Product-Backlog.md`)
```
---
kanban-plugin: basic
---

## Icebox
%% Ideas and low-priority items — not yet evaluated %%

## Needs Refinement
%% Accepted ideas that need research, story writing, or breakdown %%

## Refined
%% Fully defined stories with acceptance criteria — ready to pull into a sprint %%
```

### Sprint Board (`Sprint/Board.md`)
```
---
kanban-plugin: basic
---

## Ready
%% Refined stories/tasks pulled from Backlog into this sprint %%

## In Progress
%% Actively being worked on — limit WIP to 2-3 items %%

## In Review
%% Code complete, awaiting review or verification %%

## Done
%% Accepted and complete %%
```

## Story Format
Stories in `Backlog/Stories/STORY-<name>.md` follow this structure:
```markdown
# Story: <Name>

**Epic**: [[EPIC-name]]
**Branch**: `feature/STORY-<name>`
**Points**: 1 | 2 | 3 | 5 | 8 | 13
**Priority**: ⏫ | 🔼 | 🔽
**Status**: Icebox | Needs Refinement | Refined | Ready | In Progress | In Review | Done
**PR**: (link when created)

## User Story
As a **[role]**, I want **[capability]**, so that **[benefit]**.

## Specs
- [[Specs/Features/SPEC-feature-name]]
- [[Specs/Technical/SPEC-tech-name]]

## Acceptance Criteria
- [ ] Given [context], when [action], then [outcome]

## Tasks
- [ ] Task 1
- [ ] Task 2
```

## Task Format (on boards)
```
- [ ] [[STORY-name]]: Task description ⏫ 📅 YYYY-MM-DD
```
- ⏫ = high priority, 🔼 = medium, 🔽 = low
- Completed: `- [x] [[STORY-name]]: Task description ✅ YYYY-MM-DD`

## Spec Linking
Stories should NOT contain full specifications. Instead:
- Write detailed specs in `Specs/Features/` or `Specs/Technical/`
- Link from the story using `[[Specs/Features/SPEC-name]]`
- API contracts go in `Specs/API/`
- The story contains only: user story, acceptance criteria, task checklist, and spec links

---

## Mandatory Agent Workflow

### 1. Before Starting Any Work
1. Read `Sprint/Board.md` — check what's in "Ready" and "In Progress"
2. Read `Backlog/Product-Backlog.md` — understand the pipeline
3. Report current state to the user
4. Only pick up work from the Sprint Board's "Ready" column

### 2. Picking Up a Story
1. Move the item from "Ready" to "In Progress" on `Sprint/Board.md`
2. Update the linked story's **Status** to `In Progress`
3. Read the story file and any linked specs before coding
4. Respect WIP limit: max 2-3 items in "In Progress" at once
5. **Git — use worktree for isolation**:
   - If user says to work on a story (e.g. "work on STORY-auth-login"):
     a. Use `EnterWorktree` with name `STORY-<name>` to create an isolated worktree
     b. Inside the worktree, rename the branch to follow convention:
        `git branch -m feature/STORY-<name>`
     c. The session is now isolated — other sessions won't conflict
   - If already in a worktree (e.g. launched with `claude --worktree`), skip creation
   - If user explicitly doesn't want a worktree, fall back to branch checkout:
     `git checkout develop && git pull && git checkout -b feature/STORY-<name>`

### 3. While Working
- Check off completed tasks (`- [x]`) in the story file as you go
- If you discover new work, add it to `Backlog/Product-Backlog.md` under "Icebox"
- If you need to investigate something, create a `Research/SPIKE-<topic>.md`
- Write architecture decisions to `Notes/Decisions/`
- **Commits** reference the story: `feat(scope): description\n\nStory: STORY-<name>`

### 4. Completing Work
1. Move item from "In Progress" to "In Review" on `Sprint/Board.md`
2. Update the story's **Status** to `In Review`
3. **Git**: Push the feature branch and create a PR → `develop`:
   ```
   git push -u origin feature/STORY-<name>
   gh pr create --base develop --title "STORY-<name>: <summary>"
   ```
4. Update the story's **PR** field with the PR link
5. Ask the user: "Story is ready for review. Want me to exit the worktree?"
   - If yes: use `ExitWorktree` with action `keep` (preserves branch until PR merges)
   - If user wants to continue with another story: exit worktree, then `EnterWorktree` for the next story
6. After review/verification passes, move to "Done"
7. Update story **Status** to `Done`, add `✅ YYYY-MM-DD`
8. **Git cleanup** (after PR merged): use `ExitWorktree` with action `remove`, or:
   ```
   git branch -d feature/STORY-<name>
   ```

### 5. When User Reports a Bug or Issue

**Trigger**: User says "there's a bug", "this is broken", "fix this", reports an error, pastes a stack trace, or describes unexpected behavior.

**Immediate (critical/blocking bug):**
1. Create a story: `Backlog/Stories/STORY-fix-<description>.md` with:
   - Bug description, steps to reproduce, expected vs actual behavior
   - Priority: ⏫ (bugs are high priority by default)
   - Status: `Ready`
2. Add directly to `Sprint/Board.md` under "Ready" (bypass backlog refinement)
3. Pick it up immediately — move to "In Progress"
4. Create worktree: `EnterWorktree(name: "STORY-fix-<description>")`
5. Create branch: `git branch -m hotfix/STORY-fix-<description>`
6. Fix the bug, run tests
7. Follow the normal completion flow (PR → develop, update board)

**Non-critical bug:**
1. Create a story in `Backlog/Stories/STORY-fix-<description>.md`
2. Add to `Backlog/Product-Backlog.md` under "Needs Refinement"
3. Ask user: "Want me to fix this now or add it to the backlog?"
4. If now: promote to Sprint Board and pick up
5. If later: leave in backlog for next sprint planning

**Hotfix (production/master):**
1. Create story as above but with branch from `master`:
   `git checkout -b hotfix/STORY-fix-<description> master`
2. Fix, PR → `master` AND cherry-pick/merge to `develop`
3. Update board to "Done" after both merges

### 6. When User Asks to Create New Work

**New idea / feature request:**
1. Add to `Backlog/Product-Backlog.md` under "Icebox"
2. Create a story file in `Backlog/Stories/STORY-<name>.md`

**Refine a backlog item:**
1. Write/update the story with user story format and acceptance criteria
2. Create linked specs in `Specs/` if the story needs detailed documentation
3. Estimate story points
4. Move from "Needs Refinement" to "Refined" on the Product Backlog board

**Pull into sprint:**
1. Move "Refined" items to `Sprint/Board.md` under "Ready"
2. Break into tasks if needed

**New epic:**
1. Create `Backlog/Epics/EPIC-<name>.md`
2. Update `Roadmap.md` with the epic
3. Create child stories

### 7. Handling Unplanned Work

**Trigger**: Any request that isn't an existing story on the board — quick fixes, small tweaks, "can you just...", refactoring requests, dependency updates, etc.

**Small (< 30 min, no design needed):**
1. Create a minimal story: `Backlog/Stories/STORY-<name>.md` (can be brief — just title + what to do)
2. Add directly to `Sprint/Board.md` → "In Progress"
3. Work on current branch if already in a worktree, or create one
4. Complete normally (PR, board update)

**Medium/Large (needs design or is risky):**
1. Create a full story with acceptance criteria
2. Add to `Backlog/Product-Backlog.md` under "Needs Refinement"
3. Ask user if it should go into the current sprint or wait
4. If it needs a spec, create one in `Specs/`

### 8. When User Asks About Status
- Read `Sprint/Board.md` — summarize items per column
- Read `Backlog/Product-Backlog.md` — summarize pipeline
- Read `Roadmap.md` — report phase-level progress
- Count completed vs remaining story points if available
- Check branch status: `git branch -a` to list active feature branches

### 9. Sprint Lifecycle
**Starting a new sprint:**
1. Archive the current board to `Archive/Sprint-YYYY-MM-DD.md`
2. Create a fresh `Sprint/Board.md`
3. Pull "Refined" items from Backlog into "Ready"

**Sprint retro:**
1. Create `Notes/Retros/YYYY-MM-DD.md` with what went well, what didn't, actions

---

## Git Integration Summary

| Agile Event | Git Action |
|-------------|-----------|
| Story pulled into sprint | Branch `feature/STORY-<name>` created from `develop` |
| Story picked up (In Progress) | Checkout / worktree on that branch |
| Story completed (In Review) | Push branch, create PR → `develop` |
| Story accepted (Done) | PR merged, branch deleted, worktree removed |
| Release | `develop` merged → `master`, tagged `vX.Y.Z` |
| Hotfix | Branch from `master`, PR → `master` + `develop` |

See [git-workflow.md](./git-workflow.md) for full branching strategy and worktree usage.

---

## Adding a New Project
1. Create folder: `C:\Obsidian_Vaults\<ProjectName>\`
2. Create subfolders: `Sprint/`, `Backlog/Epics/`, `Backlog/Stories/`, `Specs/Features/`, `Specs/Technical/`, `Specs/API/`, `Research/`, `Notes/Decisions/`, `Notes/Daily/`, `Notes/Retros/`, `Archive/`
3. Copy templates for `Sprint/Board.md` and `Backlog/Product-Backlog.md`
4. Create `Roadmap.md`
5. Add `## Obsidian Project` section to the code repo's CLAUDE.md
6. Update `C:\Obsidian_Vaults\_Dashboard.md`

## Multi-Project Rules
- NEVER modify another project's vault files unless explicitly asked
- Each Claude Code session operates within its own project folder
- Cross-project references use `[[ProjectName/file]]` wiki-link syntax
- The Obsidian vault is shared across all sessions — board updates are immediate and visible to all
