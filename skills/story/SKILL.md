---
description: Create a new user story with structured spec, testing strategy, and specialist consultation
---

Create a new agile user story. The argument "$ARGUMENTS" describes what the story is about.

## Step 1: Initial Setup

1. Generate a kebab-case story name from the description (e.g. "auth-login", "payment-checkout")
2. Find the project's vault path from the repo's CLAUDE.md under `## Obsidian Project`

## Step 2: Detect Project Type and Specialists

Before writing anything, detect what kind of project this is to determine which specialists to consult.

**Detection checks (run in parallel):**
- Check `package.json` for `@btc-vision/` deps → OPNet project
- Check for `asconfig.json` → OPNet contract
- Check for `.go` files or `go.mod` → Go project
- Check for `.py` files or `pyproject.toml`/`requirements.txt` → Python project
- Check for `.tsx`/`.jsx` files or React deps → Frontend project
- Check for Express/Fastify/hyper-express → Backend project
- Check for `prisma/`, `drizzle/`, or migration dirs → Database project
- Check for existing test framework (`jest.config`, `vitest.config`, `pytest.ini`, `*_test.go`) → Note test tooling

Build a specialist roster based on detection:

| Detected | Specialists to consult | During development |
|----------|----------------------|-------------------|
| OPNet contract | `opnet-contract-dev` knowledge, `opnet-auditor` for security considerations | `opnet-contract-dev`, `contract-optimizer`, `opnet-auditor` |
| OPNet frontend | `opnet-frontend-dev` knowledge, OPNet wallet/signer patterns | `frontend-analyzer`, `opnet-frontend-dev` |
| OPNet backend | `opnet-backend-dev` knowledge, RPC/indexer patterns | `backend-analyzer`, `opnet-backend-dev` |
| Go | `go-reviewer` for idiomatic patterns | `go-reviewer`, `tdd-guide` |
| Python | `python-reviewer` for Pythonic patterns | `python-reviewer`, `tdd-guide` |
| Frontend (general) | Frontend architecture patterns | `code-reviewer`, `tdd-guide` |
| Backend (general) | API design patterns | `code-reviewer`, `security-reviewer`, `tdd-guide` |
| Database | Schema design, migration safety | `database-reviewer`, `security-reviewer` |
| Any project | `security-reviewer` for security considerations | `security-reviewer`, `code-reviewer` |

## Step 3: Specialist Consultation on Approach

Launch a specialist agent (based on detected project type) to provide feedback on the described feature. Use the Agent tool with the appropriate specialist:

**Prompt the specialist with:**
- The feature description from the user
- The detected project type and tech stack
- Ask: "What are the key technical considerations, risks, and recommended approach for implementing this? What testing strategy would you recommend? Are there common pitfalls to avoid?"

**For OPNet projects specifically:**
- Also query `opnet_dev` MCP tool (if available) for OPNet-specific guidance
- Check `opnet_incident_query` for known pitfalls related to this type of feature
- Include OPNet rules: no Buffer, SafeMath required, no constructor logic, ECDSA deprecated, etc.

Capture the specialist's feedback — it feeds into the spec and testing strategy.

## Step 4: Generate Testing Strategy

Based on the project type, feature description, and specialist feedback, determine which test types are needed:

### Test Type Selection Matrix

| Test Type | When Required | Framework Detection |
|-----------|--------------|-------------------|
| **Unit Tests** | ALWAYS — every story must have unit tests | jest/vitest/pytest/go test/mocha |
| **Integration Tests** | When feature touches APIs, databases, external services, or cross-module boundaries | Same frameworks + test DBs, supertest, httptest |
| **Contract Tests** | When OPNet contract code is involved — tests against the contract ABI | OPNet test framework, AS-pect |
| **E2E Tests** | When feature has user-facing flows, critical paths, or multi-step interactions | Playwright, Cypress, or on-chain E2E for OPNet |
| **Security Tests** | When feature handles auth, user input, payments, secrets, or permissions | Custom assertions, OWASP checks |
| **Performance Tests** | When feature has explicit performance requirements or handles high throughput | k6, artillery, benchmark tests |

Generate concrete test requirements for each applicable type:
```
Unit Tests:
- [ ] Test [specific function/component] with [happy path scenario]
- [ ] Test [specific function/component] with [edge case]
- [ ] Test [specific function/component] with [error case]

Integration Tests:
- [ ] Test [API endpoint / module interaction] end-to-end
- [ ] Test [database operation] with real connection

Contract Tests (OPNet):
- [ ] Test [contract method] with valid inputs
- [ ] Test [contract method] reverts on invalid inputs
- [ ] Test [contract method] state changes are correct

E2E Tests:
- [ ] Test [user flow] from start to finish
```

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

**Project type**: [detected type]
**Specialists consulted**: [list of specialists]
**Key recommendations**:
- [recommendation 1 from specialist]
- [recommendation 2 from specialist]

**Specialist agents for development**: [list agents available during pickup]

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
(include only applicable types from Step 4)

#### Unit Tests
- [ ] [concrete test requirement]
- [ ] [concrete test requirement]

#### Integration Tests
- [ ] [concrete test requirement]

#### Contract Tests (if OPNet)
- [ ] [concrete test requirement]

#### E2E Tests
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
- **Specialist Considerations** — captured from Step 3 consultation
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
- [ ] Specialist context is documented
- [ ] Tasks include TDD workflow steps (write tests → implement → verify)

**Testability:**
- [ ] Every acceptance criterion is automatable (not subjective)
- [ ] Test framework is identified
- [ ] Test types are appropriate for the feature scope

**Specialist review:**
- [ ] At least one specialist was consulted
- [ ] Known pitfalls are documented
- [ ] Specialist recommendations are reflected in the approach

If any check fails, fix it before proceeding.

## Step 8: Add to Backlog and Next Steps

1. Add the story to `Backlog/Product-Backlog.md` under "Needs Refinement"
2. Report to user:
   - Story summary
   - Specialist findings
   - Testing strategy overview
   - Story point estimate with rationale
3. Ask: "Want to refine further, pull into the sprint, or create more stories?"
