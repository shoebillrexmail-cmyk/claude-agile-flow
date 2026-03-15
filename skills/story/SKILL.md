---
description: Create a new user story with structured spec, testing strategy, and specialist consultation
---

Create a new agile user story. The argument "$ARGUMENTS" describes what the story is about.

## Step 1: Initial Setup

1. Generate a kebab-case story name from the description (e.g. "auth-login", "payment-checkout")
2. Find the project's vault path from the repo's CLAUDE.md under `## Obsidian Project`

## Step 2: Detect Project Type and Discover Specialists

Before writing anything, detect what kind of project this is.

**General detection (built-in):**
- Check for `.go` files or `go.mod` → Go project
- Check for `.py` files or `pyproject.toml`/`requirements.txt` → Python project
- Check for `.tsx`/`.jsx` files or React deps → Frontend project
- Check for Express/Fastify/NestJS → Backend project
- Check for `prisma/`, `drizzle/`, or migration dirs → Database project
- Check for existing test framework (`jest.config`, `vitest.config`, `pytest.ini`, `*_test.go`) → Note test tooling

**Domain specialist discovery:**
Search for specialist configurations provided by installed domain plugins. Check:
1. Installed plugin directories for `specialists.md` files
2. Loaded rules in `~/.claude/rules/` that contain specialist routing (e.g., agent routing rules)
3. CLAUDE.md for a `## Specialists` section

For each discovered specialist config, check its **Detection** rules against the current project. If detection matches, load that domain's agents, rules, and test types.

**Build a specialist roster** from all matches. Always include these general-purpose agents:

| Always Available | Purpose |
|-----------------|---------|
| `code-reviewer` | General code quality, patterns, maintainability |
| `security-reviewer` | Security vulnerabilities, secrets, OWASP top 10 |
| `tdd-guide` | Test-driven development enforcement |
| `architect` | System design and architectural decisions |

Plus language-specific reviewers (built into Claude Code):
| Detected | Agent |
|----------|-------|
| Go | `go-reviewer` |
| Python | `python-reviewer` |

Plus any domain-specific agents from discovered specialist configs.

## Step 3: Specialist Consultation on Approach

Launch specialist agents (based on detected project type and discovered domain configs) to provide feedback on the described feature.

**Prompt each specialist with:**
- The feature description from the user
- The detected project type and tech stack
- Ask: "What are the key technical considerations, risks, and recommended approach for implementing this? What testing strategy would you recommend? Are there common pitfalls to avoid?"

**If domain plugins provide MCP tools** (from the specialist config's MCP Tools section), use them for additional guidance and known pitfall queries.

Capture all specialist feedback — it feeds into the spec and testing strategy.

## Step 4: Generate Testing Strategy

Based on the project type, feature description, and specialist feedback, determine which test types are needed:

### Built-in Test Types (always considered)

| Test Type | When Required | Framework Detection |
|-----------|--------------|-------------------|
| **Unit Tests** | ALWAYS — every story must have unit tests | jest/vitest/pytest/go test/mocha |
| **Integration Tests** | When feature touches APIs, databases, external services, or cross-module boundaries | Same frameworks + test DBs, supertest, httptest |
| **E2E Tests** | When feature has user-facing flows, critical paths, or multi-step interactions | Playwright, Cypress |
| **Security Tests** | When feature handles auth, user input, payments, secrets, or permissions | Custom assertions, OWASP checks |
| **Performance Tests** | When feature has explicit performance requirements or handles high throughput | k6, artillery, benchmark tests |

### Domain-specific Test Types
If domain specialist configs define additional test types (in their Test Types section), include them when their conditions are met.

Generate concrete test requirements for each applicable type.

## Step 5: Create the Story File

Create `Backlog/Stories/STORY-<name>.md` using this format:

```markdown
# Story: <Descriptive Name>

**Epic**: (ask user or leave as TBD)
**Branch**: `feature/STORY-<name>`
**Points**: (estimate based on complexity: 1, 2, 3, 5, 8, 13)
**Priority**: (ask user or infer: ⏫ High | 🔼 Medium | 🔽 Low)
**Status**: Needs Refinement
**PR**: —

## User Story
As a **[role]**,
I want **[capability]**,
so that **[benefit]**.

## Specs
- [[Specs/Features/SPEC-<name>]]
- [[Specs/Technical/SPEC-<name>]] (if applicable)

## Specialist Context

**Project type**: [detected type(s)]
**Domain(s)**: [matched domain plugin names, if any]
**Specialists consulted**: [list of specialist agents]
**Key recommendations**:
- [recommendation 1 from specialist]
- [recommendation 2 from specialist]

**Specialist agents for development**: [agents available during pickup — from domain config's Development section]

**Domain rules**: [key rules from domain config — constraints to follow]

**Known pitfalls**:
- [pitfall 1]
- [pitfall 2]

## Acceptance Criteria
- [ ] Given [context], when [action], then [outcome]
(generate 3-5 meaningful acceptance criteria from the feature description and specialist feedback)

## Testing Strategy

**Test framework**: [detected or recommended]
**Coverage target**: 80%+
**TDD required**: Yes — write tests FIRST, then implement

### Required Test Types
(include only applicable types — built-in + domain-specific)

#### Unit Tests
- [ ] [concrete test requirement]

#### Integration Tests
- [ ] [concrete test requirement]

#### [Domain-specific test type name] (if applicable)
- [ ] [concrete test requirement]

#### E2E Tests (if applicable)
- [ ] [concrete test requirement]

## Tasks
- [ ] Set up test infrastructure (if not already present)
- [ ] Write unit tests (RED phase — tests should fail)
- [ ] Implement [component/feature 1]
- [ ] Write integration tests
- [ ] Implement [component/feature 2]
- [ ] Write E2E tests (if applicable)
- [ ] Verify all tests pass (GREEN phase)
- [ ] Refactor (IMPROVE phase)
- [ ] Verify coverage >= 80%

## Notes
[Specialist feedback summary, architectural decisions, constraints]
```

## Step 6: Create the Spec

**Always** create a feature spec at `Specs/Features/SPEC-<name>.md`:

Use the feature spec template but ensure these sections are filled:
- **Testing Strategy** — populated from Step 4 with concrete requirements per test type
- **Specialist Considerations** — captured from Step 3 consultation (domain rules, recommendations)
- **Edge Cases** — informed by specialist feedback and known pitfalls
- **Security Considerations** — from security-reviewer perspective

**If the story involves technical architecture** (new services, data models, APIs), also create `Specs/Technical/SPEC-<name>.md` with the technical spec template.

## Step 7: Quality Gate

Before finalizing, validate the story against these checks:

**Completeness:**
- [ ] User story has clear role, capability, and benefit
- [ ] At least 3 acceptance criteria with Given/When/Then format
- [ ] Testing strategy has at least unit tests defined
- [ ] Each acceptance criterion has a corresponding test requirement
- [ ] Specialist context is documented (project type, agents, pitfalls)
- [ ] Tasks include TDD workflow steps (write tests → implement → verify)

**Testability:**
- [ ] Every acceptance criterion is automatable (not subjective)
- [ ] Test framework is identified
- [ ] Test types are appropriate for the feature scope

**Specialist review:**
- [ ] At least one specialist was consulted (general or domain-specific)
- [ ] Known pitfalls are documented
- [ ] Specialist recommendations are reflected in the approach

If any check fails, fix it before proceeding.

## Step 8: Add to Backlog and Next Steps

1. Add the story to `Backlog/Product-Backlog.md` under "Needs Refinement"
2. Report to user:
   - Story summary
   - Specialist findings (general + domain-specific)
   - Testing strategy overview
   - Story point estimate with rationale
3. Ask: "Want to refine further, pull into the sprint, or create more stories?"
