---
description: Auto-review a story in "In Review" — detect project type, run relevant review agents in a fix/re-review cycle (max 3 iterations), move to Done
---

Run automated code review on the current story's changes. Detects what changed and which review agents are relevant, runs them in parallel, fixes blocking issues, and re-reviews — up to `max_cycles` iterations.

## Arguments

- `--max-cycles N` (default: 3) — Maximum review/fix iterations before stopping and reporting remaining issues to user
- `--skip-fix` — Run review only, report findings, do not attempt fixes (useful for dry-run review)

## Step 1: Context Discovery

1. Find the vault path from `CLAUDE.md` under `## Obsidian Project`
2. Determine the current story from the branch name (`feature/STORY-<name>` or `hotfix/STORY-<name>`)
3. Read the story file to get acceptance criteria and PR link
4. Verify the story is in "In Review" on `Sprint/Board.md` — if not, warn the user but continue (useful for pre-review checks)

Initialize cycle state:
```
cycle = 1
max_cycles = N (from args, default 3)
findings_ledger = []   # tracks all findings across cycles
```

## Step 2: Detect What Changed

Run `git diff develop...HEAD --name-only` to get the list of changed files.

Classify changes into categories:
- **contract**: Files importing from `@btc-vision/btc-runtime`, files in directories with `asconfig.json`, `.ts` files in contract-like directories
- **frontend**: `.tsx` files, `.ts` files importing from `opnet` or using React/wallet patterns
- **backend**: `.ts` files importing from `opnet`, `@btc-vision/transaction`, or using `hyper-express`/Express
- **go**: `.go` files
- **python**: `.py` files
- **general**: All other code files (`.ts`, `.js`, `.tsx`, `.jsx`, `.css`, etc.)

## Step 3: Detect Project Type

Check if this is an OPNet project by looking for ANY of:
- `package.json` contains `@btc-vision/` dependencies
- Source files import from `@btc-vision/btc-runtime`, `opnet`, or `@btc-vision/transaction`
- `asconfig.json` exists (AssemblyScript compiler config)

## Step 4: Select Review Agents

Build the agent list based on what changed. Launch ALL applicable agents **in parallel**.

### Always run (for any code changes):
| Agent | Type | Purpose |
|-------|------|---------|
| `code-reviewer` | Agent | General code quality, patterns, maintainability |
| `security-reviewer` | Agent | Security vulnerabilities, secrets, OWASP top 10 |

### Language-specific (if those file types changed):
| Condition | Agent | Purpose |
|-----------|-------|---------|
| Go files changed | `go-reviewer` | Idiomatic Go, concurrency, error handling |
| Python files changed | `python-reviewer` | PEP 8, type hints, Pythonic patterns |

### OPNet-specific (if OPNet project detected):
| Condition | Agent | Purpose |
|-----------|-------|---------|
| Contract files changed | `opnet-auditor` | 27-pattern security checklist |
| Contract files changed | `contract-optimizer` | Gas efficiency, storage layout |
| Frontend files changed | `frontend-analyzer` | 40+ OPNet frontend anti-pattern checks |
| Backend files changed | `backend-analyzer` | Reliability, caching, RPC patterns |
| Multiple layers changed | `cross-layer-validator` | ABI/address/network consistency |
| Any OPNet files changed | `dependency-auditor` | Package versions, conflicts, missing overrides |

### OPNet MCP enrichment (if `opnet-bob` MCP is available):
- After local agents complete, run `opnet_audit` MCP tool for a second opinion on contract code
- Cross-reference MCP findings with local agent findings — flag agreements as high-confidence

---

## Step 5: Review/Fix Cycle

```
WHILE cycle <= max_cycles:
    run_review()
    IF verdict == PASS → break, go to Step 6
    IF verdict == FAIL → fix findings, increment cycle
    IF cycle > max_cycles → stop, report to user
```

### 5a: Run Review (dispatch agents)

**Cycle 1 (full review):**
Launch all selected agents in parallel using the Agent tool. For each agent:
- Provide the list of changed files relevant to that agent
- Provide the story's acceptance criteria for context
- Ask it to produce structured findings with severity levels

**Cycle 2+ (incremental review):**
Only re-run agents that had findings in the previous cycle. Provide them with:
- The diff since last review: `git diff HEAD~1` (the fix commit)
- Previous findings from the ledger (so they can check for regressions)
- Instruction: "Focus on the diff + blast radius. Verify previous findings are resolved. Check for regressions."

### 5b: Collect and Categorize Findings

Merge all agent results. Assign each finding a unique ID (`F-001`, `F-002`, etc., incrementing across cycles).

Update the findings ledger:

| ID | Cycle Found | Cycle Resolved | Status | Severity | Finding | File | Agent |
|----|-------------|----------------|--------|----------|---------|------|-------|
| F-001 | 1 | - | OPEN | CRITICAL | [description] | [file:line] | [responsible agent] |
| F-002 | 1 | 2 | RESOLVED | HIGH | [description] | [file:line] | [responsible agent] |
| F-003 | 2 | - | REGRESSION | HIGH | [description] | [file:line] | [responsible agent] |

Status values:
- `OPEN` — new finding, not yet fixed
- `RESOLVED` — fixed in a later cycle
- `REGRESSION` — was resolved but reappeared (treat as CRITICAL)

### 5c: Determine Verdict

```
blocking = findings where severity in [CRITICAL, HIGH] AND status == OPEN
regressions = findings where status == REGRESSION

IF len(blocking) == 0 AND len(regressions) == 0:
    verdict = PASS
ELSE:
    verdict = FAIL
```

### 5d: Handle FAIL Verdict

If `--skip-fix` was passed: report all findings and stop (no fix attempt).

If `cycle < max_cycles`:
1. Display findings summary: "{N} blocking issues found (cycle {cycle}/{max_cycles})"
2. For each blocking finding, identify the fix:
   - Route to the appropriate scope based on the finding's file and agent
   - Apply the fix in the worktree
3. Stage and commit fixes:
   ```
   fix(<scope>): address review findings (cycle <cycle>)

   Story: STORY-<name>
   ```
4. Push to the feature branch: `git push`
5. Update ledger: mark fixed findings as `RESOLVED` with current cycle number
6. Increment cycle: `cycle = cycle + 1`
7. Loop back to **5a** (incremental review)

If `cycle >= max_cycles` (max iterations reached):
1. Display all remaining OPEN findings with full details
2. Report: "Review cycle limit reached ({max_cycles} cycles). {N} issues remain unresolved."
3. List each unresolved finding with file, line, severity, and description
4. Leave story in "In Review" — do NOT move to Done
5. Ask user:
   - "Fix remaining issues manually and re-run `/agile-flow:review`"
   - "Accept as-is and move to Done anyway"
   - "Leave in review for now"

### 5e: Handle PASS Verdict

1. Report: "All reviews passed (cycle {cycle}/{max_cycles}). No blocking issues."
2. If MEDIUM/LOW findings exist, list them as advisory
3. Proceed to Step 6

---

## Step 6: Complete Review (Move to Done)

1. Move item from "In Review" to "Done" on `Sprint/Board.md`
2. Update the story's **Status** to `Done`
3. Add completion date: `✅ YYYY-MM-DD` (use today's date)
4. Check off any remaining acceptance criteria that are verified
5. Print review summary:
   ```
   Review complete (cycle {final_cycle}/{max_cycles})
   - Total findings: {total}
   - Resolved: {resolved}
   - Advisory (MEDIUM/LOW): {advisory}
   ```
6. Ask: "Story is done. Exit worktree? (keep branch until PR merges)"

---

## Notes

- This skill can be triggered manually via `/agile-flow:review` at any time
- It is also triggered automatically by `/agile-flow:done` after creating the PR
- Re-running on an already-reviewed story is safe — it just re-checks the current state
- Regressions (fixed then reappeared) are automatically elevated to CRITICAL severity
- The `--max-cycles` flag can be overridden per invocation for particularly complex stories
- The skill respects the agent routing rules in `opnet-agent-routing.md` for OPNet projects
- Each cycle only re-runs agents that had findings — clean agents are not re-dispatched
