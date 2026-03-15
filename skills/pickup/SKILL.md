---
description: Pick up a story from the sprint board — load specialist context, enforce TDD, start working in a worktree
---

Pick up a story and start working. Argument: "$ARGUMENTS" (story name or empty to show options).

## Step 1: Find and Select Story

1. Find the project's vault path from the repo's CLAUDE.md under `## Obsidian Project`
2. Read `Sprint/Board.md`

**If no argument given:**
- List all items in "Ready" column with their points and priority
- Ask the user which story to pick up

**WIP limit:** If there are already 3 items in "In Progress", warn the user before proceeding.

## Step 2: Read Story and Specs

When a story is selected (e.g. STORY-auth-login):

1. Read the story file at `Backlog/Stories/STORY-<name>.md`
2. Read any linked specs in `Specs/Features/` and `Specs/Technical/`
3. Extract from the story:
   - Acceptance criteria
   - Testing strategy (test types, framework, coverage target)
   - Specialist context (project type, recommended agents, known pitfalls)
   - Task list

## Step 3: Load Specialist Context

Based on the story's `## Specialist Context` section (or detect if missing):

### If specialist context exists in story:
Load the recommended specialist knowledge for the detected project type:

| Project Type | Knowledge to Load | Agents Available |
|-------------|-------------------|-----------------|
| OPNet contract | Read `knowledge/slices/contract-dev.md`, OPNet bible sections [CONTRACT] | `opnet-contract-dev`, `contract-optimizer`, `opnet-auditor` |
| OPNet frontend | Read `knowledge/slices/frontend-dev.md` | `opnet-frontend-dev`, `frontend-analyzer` |
| OPNet backend | Read `knowledge/slices/backend-dev.md` | `opnet-backend-dev`, `backend-analyzer` |
| Go | Go patterns and idioms | `go-reviewer`, `tdd-guide` |
| Python | Python patterns and PEP standards | `python-reviewer`, `tdd-guide` |
| General frontend | React/Next.js patterns | `code-reviewer`, `tdd-guide` |
| General backend | API/DB patterns | `code-reviewer`, `security-reviewer`, `tdd-guide` |

### If specialist context is missing (legacy stories):
Run detection from Step 2 of the story skill:
- Check `package.json`, `go.mod`, `pyproject.toml`, etc.
- Determine project type and applicable specialists
- Note: "This story was created without specialist context — auto-detected as [type]"

### OPNet-specific loading:
If OPNet project detected:
- Check `opnet_incident_query` MCP for recent known pitfalls (if MCP available)
- Load OPNet rules: no Buffer, SafeMath required, no constructor logic, ECDSA deprecated, `signer: null` on frontend, `networks.opnetTestnet` for testnet
- Note any OPNet-specific constraints from the story's pitfalls section

## Step 4: Consult Prior Learnings

Check the vault's `Learning/` folder for relevant knowledge from past stories:

1. Read `Learning/Index.md` to scan the catalog
2. **Search Patterns**: Check `Learning/Patterns/` for anti-patterns matching this story's domain:
   - If OPNet contract story → look for contract-related patterns (storage, SafeMath, gas)
   - If frontend story → look for UI/wallet/React patterns
   - If API story → look for security/validation patterns
   - Match by domain tag in pattern files
3. **Search Integration Guides**: Check `Learning/Integrations/` for guides on technologies this story will use:
   - If the story's spec references a technology that has a guide → load it
   - Flag guides with "Confidence: Low" — these may need updating
4. **Search Writeups**: Check `Learning/Writeups/` for relevant prior deep-dives:
   - Look for writeups in the same domain as this story
   - Especially useful if the story is related to a previous complex story

Include relevant learnings in the development brief (Step 6):
```
### Prior Learnings (from past stories)
- PATTERN-<name>: [summary] — avoid this
- GUIDE-<name>: [summary] — reference for [technology]
- WRITEUP-<name>: [summary] — relevant context
```

If no relevant learnings found, note: "No prior learnings for this domain yet."

## Step 5: Verify Testing Infrastructure

Before entering the worktree, check that the testing infrastructure is ready:

1. **Detect test framework**: Look for `jest.config.*`, `vitest.config.*`, `pytest.ini`, `go.mod` (for `go test`), `as-pect.config.*`
2. **Check test scripts**: Look in `package.json` scripts for `test`, `test:unit`, `test:integration`, `test:e2e`
3. **Check coverage tooling**: Look for `c8`, `istanbul`, `coverage` in config or deps

Report test infrastructure status:
- "Test framework: [name] (ready)" or "Test framework: not found — will need setup"
- "Coverage tool: [name] (ready)" or "Coverage tool: not configured"

## Step 6: Enter Worktree and Start Work

1. Move the item from "Ready" to "In Progress" on `Sprint/Board.md`
2. Update the story's **Status** to `In Progress`
3. Use `EnterWorktree` with name `STORY-<name>` to create an isolated workspace
4. Inside the worktree, rename the branch: `git branch -m feature/STORY-<name>`
5. Symlink gitignored files from main repo (`.env`, `.env.local`, etc.)

## Step 7: Present Development Brief

Report to the user with a structured development brief:

```
## STORY-<name>: <Title>

### Acceptance Criteria
- [ ] [criterion 1]
- [ ] [criterion 2]
...

### Testing Strategy (TDD ENFORCED)
Coverage target: 80%+
Workflow: Write tests FIRST → Run (should FAIL) → Implement → Run (should PASS) → Refactor

Test types required:
- Unit tests: [list from story]
- Integration tests: [list from story]
- [other test types from story]

### Specialist Context
Project type: [type]
Available specialists: [list]
Known pitfalls:
- [pitfall 1]
- [pitfall 2]

### Tasks
- [ ] [task 1]
- [ ] [task 2]
...
```

## Step 8: Begin Implementation (TDD Workflow)

Start implementation following TDD discipline:

### Phase 1: RED — Write Tests First
1. For each task in the story, write the corresponding tests BEFORE implementation:
   - Unit tests for functions/components
   - Integration tests for API/DB/cross-module interactions
   - Contract tests for OPNet methods (if applicable)
2. Run tests — they should all FAIL (this confirms they're testing the right thing)
3. Commit test files: `test(scope): add tests for STORY-<name> (RED phase)`

### Phase 2: GREEN — Implement to Pass
1. Implement the minimum code to make tests pass
2. Follow specialist recommendations from the story's context
3. After each component, run tests to verify progress
4. Consult specialist agents when encountering domain-specific decisions:
   - **OPNet**: Use `opnet-contract-dev` agent for contract patterns, `opnet-frontend-dev` for wallet integration
   - **Security-sensitive**: Use `security-reviewer` agent for auth/input handling
   - **Performance-critical**: Use `architect` agent for design decisions
5. Commit working code: `feat(scope): implement [component] for STORY-<name>`

### Phase 3: IMPROVE — Refactor
1. Refactor for clarity, DRY, and maintainability
2. Ensure tests still pass after refactoring
3. Run coverage check — must be >= 80%
4. If coverage is below 80%, add missing tests

### During Development — Specialist Agent Usage
Proactively invoke specialist agents at these trigger points:

| Trigger | Agent to Invoke | Purpose |
|---------|----------------|---------|
| Writing OPNet contract code | `opnet-contract-dev` rules | Validate patterns, storage layout, SafeMath usage |
| Writing OPNet frontend code | `opnet-frontend-dev` rules | Validate signer: null, simulation before send |
| Writing API endpoints | `security-reviewer` | Check auth, input validation, rate limiting |
| Writing database queries | `database-reviewer` | Check SQL injection, query optimization |
| Making architectural decisions | `architect` | Validate design trade-offs |
| Writing Go code | `go-reviewer` | Check idiomatic patterns, error handling |
| Writing Python code | `python-reviewer` | Check PEP 8, type hints, Pythonic patterns |
| Stuck on implementation | `planner` | Re-plan approach with specialist input |

These are not optional — if the trigger condition is met, invoke the specialist.
