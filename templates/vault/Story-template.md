# Story: {{Story Name}}

**Epic**: [[EPIC-name]]
**Branch**: `feature/STORY-{{story-name}}`
**Points**: 1 | 2 | 3 | 5 | 8 | 13
**Priority**: ⏫ High | 🔼 Medium | 🔽 Low
**Status**: Icebox | Needs Refinement | Refined | Ready | In Progress | In Review | Done
**PR**: (link when created)

## User Story
As a **[role]**,
I want **[capability]**,
so that **[benefit]**.

## Specs
- [[Specs/Features/SPEC-feature-name]] — Feature spec
- [[Specs/Technical/SPEC-tech-name]] — Technical spec (if applicable)

## Specialist Context

**Project type**: [e.g. OPNet contract, OPNet frontend, Go backend, Python API, React frontend]
**Specialists consulted**: [list of specialist agents consulted during story creation]
**Key recommendations**:
- [recommendation from specialist consultation]

**Specialist agents for development**: [agents available during pickup/implementation]
- [agent 1] — [purpose]
- [agent 2] — [purpose]

**Known pitfalls**:
- [pitfall from specialist or incident query]

## Acceptance Criteria
- [ ] Given [context], when [action], then [outcome]
- [ ] Given [context], when [action], then [outcome]

## Testing Strategy

**Test framework**: [detected or recommended: jest/vitest/pytest/go test/as-pect]
**Coverage target**: 80%+
**TDD required**: Yes — write tests FIRST, then implement

### Unit Tests
- [ ] Test [function/component] — [scenario]
- [ ] Test [function/component] — [edge case]

### Integration Tests
- [ ] Test [API/module interaction] — [scenario]

### Contract Tests (if OPNet)
- [ ] Test [contract method] — [valid inputs]
- [ ] Test [contract method] — [revert on invalid inputs]

### E2E Tests (if user-facing flow)
- [ ] Test [user flow] — [end-to-end scenario]

## Tasks
- [ ] Set up test infrastructure (if needed)
- [ ] Write unit tests (RED phase)
- [ ] Implement [component 1]
- [ ] Write integration tests
- [ ] Implement [component 2]
- [ ] Write E2E tests (if applicable)
- [ ] Verify all tests pass (GREEN phase)
- [ ] Refactor (IMPROVE phase)
- [ ] Verify coverage >= 80%

## Notes

---
*Created: {{date}}*
