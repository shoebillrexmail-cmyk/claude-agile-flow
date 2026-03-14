---
description: Create a new user story with acceptance criteria and linked specs
---

Create a new agile user story. The argument "$ARGUMENTS" describes what the story is about.

1. Generate a kebab-case story name from the description (e.g. "auth-login", "payment-checkout")
2. Find the project's vault path from the repo's CLAUDE.md under `## Obsidian Project`
3. Create `Backlog/Stories/STORY-<name>.md` using this format:

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
(create linked spec files if the story needs detailed documentation)

## Acceptance Criteria
- [ ] Given [context], when [action], then [outcome]
(generate 3-5 meaningful acceptance criteria)

## Tasks
- [ ] (break into implementable tasks)

## Notes
```

4. Add the story to `Backlog/Product-Backlog.md` under "Needs Refinement"
5. If the story is complex, create a feature spec at `Specs/Features/SPEC-<name>.md`
6. Ask the user if they want to refine it further or pull it into the sprint
