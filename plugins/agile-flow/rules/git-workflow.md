# Git Workflow

## Branch Strategy (Gitflow-lite)

```
master (production releases)
  ↑ merge via PR (release)
develop (integration branch)
  ↑ merge via PR (story complete)
feature/STORY-<name> (one branch per story)
  ↑ merge via PR (if subtask branches needed)
  feature/STORY-<name>/<subtask>
```

### Branch Types

| Branch | Purpose | Branches from | Merges into | Naming |
|--------|---------|---------------|-------------|--------|
| `master` | Production-ready code | — | — | `master` |
| `develop` | Integration, latest accepted work | — | `master` | `develop` |
| `feature/*` | Story implementation | `develop` | `develop` | `feature/STORY-<name>` |
| `hotfix/*` | Urgent production fix | `master` | `master` + `develop` | `hotfix/<description>` |
| `release/*` | Release stabilization (optional) | `develop` | `master` + `develop` | `release/vX.Y.Z` |

### Rules
- NEVER commit directly to `master` or `develop`
- Every story gets its own feature branch
- Feature branches are short-lived — merge and delete after PR accepted
- Keep feature branches up to date: `git rebase develop` before PR
- Branch names match story names: `feature/STORY-auth-login` maps to `Backlog/Stories/STORY-auth-login.md`

## Git Worktrees (Parallel Sessions)

Git worktrees allow multiple Claude Code sessions to work on different stories simultaneously, each in its own directory with its own branch.

### How It Works
```
C:\Github\my-project\                  ← main repo (develop branch)
C:\Github\my-project-worktrees\
  ├── STORY-auth-login\                ← worktree on feature/STORY-auth-login
  ├── STORY-payment-flow\              ← worktree on feature/STORY-payment-flow
  └── STORY-user-settings\             ← worktree on feature/STORY-user-settings
```

Each worktree is a full working directory tied to its own branch. Sessions don't interfere with each other.

### Creating a Worktree

**Option 1 — From within a Claude session (preferred):**
Just tell Claude to work on a story. Claude uses the built-in `EnterWorktree` tool:
```
You: "Work on STORY-auth-login"
Claude: → EnterWorktree(name: "STORY-auth-login")
       → renames branch to feature/STORY-auth-login
       → reads story + specs from vault
       → starts coding
```

**Option 2 — Launch with worktree flag:**
```bash
claude --worktree
```

**Option 3 — Manual (rare):**
```bash
git worktree add -b feature/STORY-<name> ../my-project-worktrees/STORY-<name> develop
cd ../my-project-worktrees/STORY-<name>
claude
```

### Exiting / Cleaning Up a Worktree

**From within Claude:**
```
You: "Exit the worktree" or "I'm done with this story"
Claude: → ExitWorktree(action: "keep")    # preserves branch until PR merges
       — or —
Claude: → ExitWorktree(action: "remove")  # deletes worktree + branch (after merge)
```

**Manual cleanup:**
```bash
git worktree remove ../my-project-worktrees/STORY-<name>
git branch -d feature/STORY-<name>
```

### Worktree Config
Heavy directories are symlinked (not copied) to save disk space. Configured in `~/.claude/settings.json`:
```json
"worktree": {
  "symlinkDirectories": ["node_modules", ".venv", ".cache"]
}
```

### Session ↔ Story Mapping
When starting a Claude Code session in a worktree:
1. The session reads the repo's CLAUDE.md to find the Obsidian project
2. The branch name `feature/STORY-<name>` maps to `Backlog/Stories/STORY-<name>.md`
3. The session reads the story and linked specs before starting work
4. Board updates happen on `Sprint/Board.md` in the shared vault (not branch-specific)

## Commit Message Format
```
<type>(<scope>): <description>

<optional body>

Story: STORY-<name>
```

Types: feat, fix, refactor, docs, test, chore, perf, ci

Scope is optional but encouraged — use the module/component name.

Examples:
```
feat(auth): add JWT middleware for protected routes

Implements token validation and refresh logic.
Adds middleware to all /api routes.

Story: STORY-auth-login
```

```
fix(payments): handle Stripe webhook signature timeout

Story: STORY-payment-flow
```

Note: Attribution disabled globally via ~/.claude/settings.json.

## Pull Request Workflow

### Feature → Develop
1. Ensure branch is up to date: `git fetch origin && git rebase origin/develop`
2. Analyze full commit history: `git log develop..HEAD` and `git diff develop...HEAD`
3. Create PR targeting `develop`:
   ```
   gh pr create --base develop --title "STORY-<name>: <summary>" --body "..."
   ```
4. PR body must include:
   - Story link (Obsidian reference)
   - Summary of changes
   - Test plan
   - Acceptance criteria status (from the story)
5. After merge, delete the feature branch and clean up the worktree

### Develop → Master (Release)
1. Create a release branch if stabilization needed: `release/vX.Y.Z`
2. Or merge develop directly to master for simple releases
3. Tag the release: `git tag vX.Y.Z`
4. Merge back to develop if release branch had hotfixes

### Hotfix
1. Branch from master: `git checkout -b hotfix/<desc> master`
2. Fix, commit, PR to master
3. After merge, also merge/cherry-pick to develop

## Multi-Session Safety
- Each session works in its own worktree on its own branch — no conflicts
- The Obsidian vault is shared (file-level, not branch-level) — board updates are immediate
- If two sessions need to touch the same file, coordinate via the Sprint Board (one at a time)
- Always `git fetch` before creating a new worktree to have latest develop
