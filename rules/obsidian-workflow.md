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
├── Learning/
│   ├── Index.md                  # Catalog of all learnings
│   ├── Integrations/
│   │   └── GUIDE-<tech>.md       # How-to guides for integrations
│   ├── Patterns/
│   │   └── PATTERN-<name>.md     # Anti-patterns, gotchas, best practices
│   └── Writeups/
│       └── WRITEUP-<topic>.md    # Educational deep-dives on complex problems
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

## Worktree Rule (NON-NEGOTIABLE — ZERO EXCEPTIONS)

**Every piece of code work MUST happen in a worktree.** Before writing ANY code — even a single line — you MUST call `EnterWorktree` first.

### The Rule
1. Call `EnterWorktree` with the story name
2. Rename the branch to `feature/STORY-<name>` or `hotfix/STORY-<name>`
3. Only then start coding

### This applies regardless of:
- **Story state** — whether the story is new, in progress, in review, or done. State does not matter.
- **Prior sessions** — if a previous session worked on this story without a worktree, YOU still use one.
- **Branch existence** — if the feature branch doesn't exist yet, `EnterWorktree` creates one. That's what it does.
- **Urgency** — urgent bugs, critical hotfixes, "just a quick fix" — ALL get a worktree. No urgency bypass.
- **Where the changes are** — if changes are on develop, on master, or uncommitted. Enter a worktree first, then work.
- **How small the change is** — one line or one thousand lines, worktree first.

### The ONLY exceptions (must be explicitly true):
- You are already inside a worktree (check with: is the cwd inside `.claude/worktrees/`?)
- The user explicitly says "don't use a worktree" or "work on this branch directly"
- The work is documentation-only (zero code file changes)

### After entering a worktree — symlink gitignored files
Git worktrees only include tracked files. Gitignored files like `.env` are NOT copied. After `EnterWorktree`, immediately symlink these from the main repo:

```bash
# Get the main repo root (parent of .claude/worktrees/)
MAIN_REPO=$(git -C "$(git rev-parse --git-common-dir)" rev-parse --show-toplevel 2>/dev/null || echo "")

# Symlink .env and other gitignored config files if they exist in the main repo
for f in .env .env.local .env.development .env.test; do
  [ -f "$MAIN_REPO/$f" ] && [ ! -f "$f" ] && ln -s "$MAIN_REPO/$f" "$f"
done
```

This is MANDATORY after every `EnterWorktree`. Without it, builds and tests fail due to missing environment variables.

### Why this matters
Without worktrees, parallel sessions conflict, develop gets polluted with half-finished work, and there's no clean branch-per-story history. The worktree IS the isolation boundary.

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
4. **Load specialist context** from the story's `## Specialist Context` section:
   - Identify project type and recommended specialist agents
   - Load domain-specific knowledge (OPNet slices, Go patterns, Python standards, etc.)
   - Note known pitfalls to avoid during implementation
   - If specialist context is missing (legacy story), auto-detect project type
5. **Consult prior learnings**: Read `Learning/Index.md` and search for relevant entries:
   - Check `Learning/Patterns/` for anti-patterns related to this story's domain
   - Check `Learning/Integrations/` for guides on technologies this story will use
   - Check `Learning/Writeups/` for relevant prior deep-dives
   - Include relevant learnings in the development brief — these are lessons from past experience
6. **Verify testing infrastructure**: Check test framework, coverage tools, test scripts exist
6. Respect WIP limit: max 2-3 items in "In Progress" at once
7. **MANDATORY — Enter a worktree before writing any code**:
   a. If already in a worktree, skip to step 8
   b. Use `EnterWorktree` with name `STORY-<name>`
   c. Rename the branch: `git branch -m feature/STORY-<name>`
   d. The session is now isolated — other sessions won't conflict
   e. Only skip worktree if the user explicitly says "don't use a worktree"
8. Present development brief: acceptance criteria, testing strategy, specialist context, tasks

### 3. While Working — TDD and Specialist Enforcement
- **TDD is mandatory**: Write tests FIRST (RED), implement (GREEN), refactor (IMPROVE)
- Follow the story's `## Testing Strategy` — write each required test type
- Check off completed tasks (`- [x]`) in the story file as you go
- **Invoke specialist agents at trigger points**:
  - OPNet contract code → follow `opnet-contract-dev` rules
  - OPNet frontend code → follow `opnet-frontend-dev` rules (signer: null, simulate before send)
  - API endpoints → invoke `security-reviewer` for auth/input validation
  - Database queries → invoke `database-reviewer` for SQL safety
  - Go code → invoke `go-reviewer` for idiomatic patterns
  - Python code → invoke `python-reviewer` for PEP 8 compliance
  - Architectural decisions → invoke `architect` agent
- If you discover new work, add it to `Backlog/Product-Backlog.md` under "Icebox"
- If you need to investigate something, create a `Research/SPIKE-<topic>.md`
- Write architecture decisions to `Notes/Decisions/`
- **Commits** reference the story: `feat(scope): description\n\nStory: STORY-<name>`
- **Test commits** come first: `test(scope): add tests for [component]\n\nStory: STORY-<name>`

### 4. Completing Work
1. **Documentation gate** (before PR):
   a. Check `git diff develop...HEAD --name-only` for what changed
   b. Update repo docs affected by changes: README, CHANGELOG (`[Unreleased]`), API docs, config/env docs, stale inline comments
   c. Commit: `docs(scope): update documentation for STORY-<name>`
   d. If story adds/changes user-visible behavior (new features, UI changes, CLI commands, API contracts):
      - Create `Backlog/Stories/STORY-docs-<name>.md` — "Update user documentation for [feature]"
      - Add to `Backlog/Product-Backlog.md` under "Needs Refinement"
   e. Skip user-facing docs task for purely internal changes (refactoring, tests, infrastructure)
2. Move item from "In Progress" to "In Review" on `Sprint/Board.md`
3. Update the story's **Status** to `In Review`
4. **Git**: Push the feature branch and create a PR → `develop`:
   ```
   git push -u origin feature/STORY-<name>
   gh pr create --base develop --title "STORY-<name>: <summary>"
   ```
   Include user-facing docs task reference in PR body if created.
5. Update the story's **PR** field with the PR link
6. **Automated Review Cycle** (triggered automatically by `/agile-flow:done`, max 3 cycles):
   a. Detect changed files: `git diff develop...HEAD --name-only`
   b. Detect project type (OPNet, Go, Python, general)
   c. Launch relevant review agents **in parallel**:
      - **Always**: `code-reviewer`, `security-reviewer`
      - **If Go**: `go-reviewer`
      - **If Python**: `python-reviewer`
      - **If OPNet contract**: `opnet-auditor`, `contract-optimizer`
      - **If OPNet frontend**: `frontend-analyzer`
      - **If OPNet backend**: `backend-analyzer`
      - **If OPNet multi-layer**: `cross-layer-validator`, `dependency-auditor`
   d. Collect findings, assign IDs, track in findings ledger (OPEN/RESOLVED/REGRESSION)
   e. **If CRITICAL/HIGH findings (FAIL verdict)**:
      - Apply **Structured Repair (R1/R2/R3)**: LOCALIZE (read-only) → PATCH (generate fix) → VALIDATE (run tests)
      - Commit fixes: `fix(<scope>): address review findings (cycle N)`
      - Push, increment cycle
      - **Re-review incrementally** — only re-run agents that had findings, with diff context
      - Regressions (fixed then reappeared) → auto-elevated to CRITICAL
      - Repeat until PASS or max cycles reached
   f. **If max cycles reached**: report remaining OPEN findings, ask user to fix manually, accept as-is, or leave in review
   g. **Hard Gates** (before completing):
      - Tests must pass (BLOCKS if failing)
      - No CRITICAL security findings may remain (BLOCKS)
      - Coverage check — warn if < 80% (does not block)
      - OPNet contract tests must exist for changed methods (WARNS)
   h. **If PASS**: MEDIUM/LOW reported as advisory, move to "Done", update status with `✅ YYYY-MM-DD`
7. **Learning extraction** — run `/agile-flow:learn` to generate educational content:
   - Analyze what was built, what was caught in review, what specialist feedback was key
   - Generate **Integration Guides** (new tech), **Patterns** (anti-patterns/gotchas), **Writeups** (complex solutions)
   - Save to `Learning/` in the vault, update `Learning/Index.md`
   - Link learnings back to the story file
   - Skip for routine changes with no novel learnings
8. Ask the user: "Story is done. Exit worktree?"
   - If yes: use `ExitWorktree` with action `keep` (preserves branch until PR merges)
   - If user wants to continue with another story: exit worktree, then `EnterWorktree` for the next story
9. **Git cleanup** (after PR merged): use `ExitWorktree` with action `remove`, or:
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
4. **MANDATORY — Enter worktree**: `EnterWorktree(name: "STORY-fix-<description>")`
5. Rename branch: `git branch -m hotfix/STORY-fix-<description>`
6. Fix the bug, run tests
7. Follow the normal completion flow (PR → develop, update board, exit worktree)

**Non-critical bug:**
1. Create a story in `Backlog/Stories/STORY-fix-<description>.md`
2. Add to `Backlog/Product-Backlog.md` under "Needs Refinement"
3. Ask user: "Want me to fix this now or add it to the backlog?"
4. If now: promote to Sprint Board → **enter worktree** → pick up (same as immediate)
5. If later: leave in backlog for next sprint planning

**Hotfix (production/master):**
1. Create story as above
2. **MANDATORY — Enter worktree**: `EnterWorktree(name: "STORY-fix-<description>")`
3. Switch to master base: `git fetch origin && git reset --hard origin/master`
4. Rename branch: `git branch -m hotfix/STORY-fix-<description>`
5. Fix, PR → `master` AND cherry-pick/merge to `develop`
6. Update board to "Done" after both merges, exit worktree

### 6. When User Asks to Create New Work

**New idea / feature request:**
1. **Detect project type**: Check `package.json`, `go.mod`, `asconfig.json`, etc.
2. **Consult specialist**: Launch a specialist agent for the detected project type to get approach feedback, risks, and testing recommendations
3. Create a story file in `Backlog/Stories/STORY-<name>.md` with:
   - User story, acceptance criteria
   - `## Specialist Context` — project type, consulted specialists, recommendations, pitfalls
   - `## Testing Strategy` — required test types (unit, integration, contract, E2E) with concrete test requirements per type. TDD is always enforced.
   - Tasks that follow TDD workflow: write tests → implement → verify coverage
4. Create linked spec in `Specs/Features/SPEC-<name>.md` with specialist considerations and testing strategy tables
5. Add to `Backlog/Product-Backlog.md` under "Needs Refinement" (or "Icebox" for vague ideas)

**Refine a backlog item:**
1. Write/update the story with user story format and acceptance criteria
2. **Consult specialists** if not already done — fill in Specialist Context section
3. **Define testing strategy** — ensure all required test types are listed with concrete requirements
4. Create linked specs in `Specs/` if the story needs detailed documentation
5. Run quality gate: every acceptance criterion must be automatable, test types must be defined, specialist context must be present
6. Estimate story points
7. Move from "Needs Refinement" to "Refined" on the Product Backlog board

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
3. **MANDATORY — Enter worktree** if not already in one: `EnterWorktree(name: "STORY-<name>")`
4. Rename branch: `git branch -m feature/STORY-<name>`
5. Complete normally (PR, board update, exit worktree)

**Medium/Large (needs design or is risky):**
1. Create a full story with acceptance criteria
2. Add to `Backlog/Product-Backlog.md` under "Needs Refinement"
3. Ask user if it should go into the current sprint or wait
4. If it needs a spec, create one in `Specs/`
5. When picked up: follows the standard "Picking Up a Story" flow (mandatory worktree)

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
2. Create subfolders: `Sprint/`, `Backlog/Epics/`, `Backlog/Stories/`, `Specs/Features/`, `Specs/Technical/`, `Specs/API/`, `Learning/Integrations/`, `Learning/Patterns/`, `Learning/Writeups/`, `Research/`, `Notes/Decisions/`, `Notes/Daily/`, `Notes/Retros/`, `Archive/`
3. Copy templates for `Sprint/Board.md` and `Backlog/Product-Backlog.md`
4. Create `Roadmap.md`
5. Add `## Obsidian Project` section to the code repo's CLAUDE.md
6. Update `C:\Obsidian_Vaults\_Dashboard.md`

## Multi-Project Rules
- NEVER modify another project's vault files unless explicitly asked
- Each Claude Code session operates within its own project folder
- Cross-project references use `[[ProjectName/file]]` wiki-link syntax
- The Obsidian vault is shared across all sessions — board updates are immediate and visible to all
