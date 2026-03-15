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

## Branch → Environment Mapping

Branches map to deployment environments. CI/CD pipelines should deploy automatically based on which branch receives a push:

```
feature/STORY-*  ──PR──▶  develop  ──PR──▶  release/vX.Y.Z  ──PR──▶  master
     │                       │                    │                       │
  Preview only         Staging / Testnet     Release Candidate       Production / Mainnet
  (frontend)          (full deploy pipeline)  (stabilization)        (full deploy pipeline)
```

| Branch | Environment | Deploys |
|--------|-------------|---------|
| `feature/*`, `hotfix/*` | Preview | Frontend only (temporary preview URL) |
| `develop` | Staging / Testnet | Contracts (if changed) → Indexer → Frontend |
| `release/*` | Release Candidate | Same as staging — final verification before production |
| `master` | Production / Mainnet | Contracts (if changed) → Indexer → Frontend |

### Deployment Config Pattern

Use a `deployments/` directory to track what's deployed per environment:

```
deployments/
├── testnet.json    # addresses, hashes, timestamps for staging
├── mainnet.json    # addresses, hashes, timestamps for production
```

These files are committed to the repo and updated by CI after successful deployments. They serve as the single source of truth for "what's deployed where" — downstream jobs (indexer, frontend) read addresses from these files.

When CI commits deployment config back to a branch, use `[skip ci]` in the commit message to prevent infinite loops.

### Sync Before Work (MANDATORY)

Before starting any work or entering a worktree, always sync with the remote to pick up CI-generated commits (e.g., deployment config updates):

```bash
git fetch origin
# Fast-forward develop if behind (CI may have committed deployment configs)
git merge --ff-only origin/develop 2>/dev/null || true
```

This ensures you always have the latest deployed addresses and configuration. Without this, local builds may use stale contract addresses.

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

### Gitignored Files (IMPORTANT)
Git worktrees only contain tracked files. Gitignored files like `.env` are NOT included. After entering a worktree, you MUST symlink them from the main repo:
```bash
MAIN_REPO=$(git -C "$(git rev-parse --git-common-dir)" rev-parse --show-toplevel 2>/dev/null || echo "")
for f in .env .env.local .env.development .env.test; do
  [ -f "$MAIN_REPO/$f" ] && [ ! -f "$f" ] && ln -s "$MAIN_REPO/$f" "$f"
done
```
Without this, builds and tests fail due to missing environment variables and secrets.

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

Releases follow a structured flow to ensure production stability.

#### Versioning (Semantic Versioning)
- **MAJOR** (`vX.0.0`) — breaking changes, incompatible API modifications
- **MINOR** (`v0.X.0`) — new features, backward-compatible additions
- **PATCH** (`v0.0.X`) — bug fixes, patches, no new features

#### Release Flow

**Step 1 — Cut the release branch:**
```bash
git fetch origin
git checkout develop
git pull origin develop
git checkout -b release/vX.Y.Z
git push -u origin release/vX.Y.Z
```

**Step 2 — Stabilize on the release branch:**
- Only bug fixes, documentation, and release-prep commits allowed (no new features)
- Update version numbers in `package.json`, `version.ts`, or equivalent
- Update `CHANGELOG.md` — move `[Unreleased]` entries under `[vX.Y.Z] - YYYY-MM-DD`
- Run full test suite and verification
- Commit type: `chore(release): prepare vX.Y.Z`

**Step 3 — Merge to master and tag:**
```bash
git checkout master
git merge --no-ff release/vX.Y.Z -m "release: vX.Y.Z"
git tag -a vX.Y.Z -m "Release vX.Y.Z"
git push origin master --tags
```

**Step 4 — Merge back to develop:**
```bash
git checkout develop
git merge --no-ff release/vX.Y.Z -m "chore: merge release/vX.Y.Z back to develop"
git push origin develop
```

**Step 5 — Clean up:**
```bash
git branch -d release/vX.Y.Z
git push origin --delete release/vX.Y.Z
```

**Step 6 — Create GitHub Release:**
```bash
gh release create vX.Y.Z --title "vX.Y.Z" --notes-file RELEASE_NOTES.md
```

#### Quick Release (no stabilization needed)
When `develop` is already stable and no release branch is needed:
```bash
git checkout master && git merge --no-ff develop -m "release: vX.Y.Z"
git tag -a vX.Y.Z -m "Release vX.Y.Z"
git push origin master --tags
gh release create vX.Y.Z --title "vX.Y.Z" --generate-notes
```
Then update CHANGELOG and merge the tag back to develop.

#### Release Fixes
If bugs are found during release stabilization:
1. Fix directly on the `release/vX.Y.Z` branch
2. Commit: `fix(scope): description` (no story reference needed for release fixes)
3. These fixes flow to both `master` (via merge) and `develop` (via back-merge)

### Hotfix
1. Branch from master: `git checkout -b hotfix/<desc> master`
2. Fix, commit, PR to master
3. After merge, also merge/cherry-pick to develop

## Multi-Session Safety
- Each session works in its own worktree on its own branch — no conflicts
- The Obsidian vault is shared (file-level, not branch-level) — board updates are immediate
- If two sessions need to touch the same file, coordinate via the Sprint Board (one at a time)
- Always `git fetch` before creating a new worktree to have latest develop
