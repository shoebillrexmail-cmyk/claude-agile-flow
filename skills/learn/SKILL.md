---
description: Extract learnings from a completed story — generate educational writeups, patterns, and integration guides in the Obsidian vault
---

After a story is completed, extract what was learned and write it up in the vault's `Learning/` folder. This builds a growing knowledge base the user can study to deepen their understanding of the project, its integrations, and common pitfalls.

This skill is triggered automatically by `/agile-flow:done` after a story moves to Done, or manually via `/agile-flow:learn`.

## Arguments

- `$ARGUMENTS` — Story name (e.g. `STORY-auth-login`). If empty, detect from branch name.
- `--skip` — Skip learning extraction (for trivial changes)

## Step 1: Gather Context

1. Find the vault path from `CLAUDE.md` under `## Obsidian Project`
2. Determine the story from branch name or argument
3. Read the story file — extract specialist context, testing strategy, acceptance criteria
4. Read linked specs
5. Gather the change context:
   - `git diff develop...HEAD --stat` — scope of changes
   - `git log develop..HEAD --oneline` — commit history (tells the story of development)
   - Review findings (if `/agile-flow:review` ran) — what was caught and fixed
   - Specialist feedback captured in the story
6. Read existing `Learning/Index.md` to check for related prior learnings

## Step 2: Assess What Was Learned

Analyze the gathered context and classify learnings into categories:

### Category Detection

| Signal | Category | Output |
|--------|----------|--------|
| Story involved a technology/service not previously used in the project | **Integration Guide** | `Learning/Integrations/GUIDE-<name>.md` |
| Review found bugs that reveal a reusable anti-pattern | **Pattern** | `Learning/Patterns/PATTERN-<name>.md` |
| Story solved a complex problem with a non-obvious approach | **Writeup** | `Learning/Writeups/WRITEUP-<name>.md` |
| Specialist agent provided guidance that was key to success | **Writeup** or **Pattern** | Depends on depth |
| Story was routine with no novel learnings | **Skip** | No output (note in story: "No new learnings") |

### Novelty Check

Before creating a learning, check `Learning/Index.md` and existing files:
- If a similar integration guide already exists → **update** it instead of creating a duplicate
- If a similar pattern already exists → **increment its occurrence count** and add the new example
- If this is genuinely new → create a new learning

A story can produce multiple learnings (e.g., one integration guide + two patterns).

## Step 3: Generate Learnings

### Integration Guide (`Learning/Integrations/GUIDE-<name>.md`)

**When**: The story involved connecting to a new API, using a new library, integrating a new service, or implementing a new protocol for the first time.

```markdown
# Integration Guide: <Technology/Service Name>

**First used in**: [[STORY-<name>]]
**Last updated**: YYYY-MM-DD
**Confidence**: Low | Medium | High (based on how battle-tested)

## What Is It?
Brief explanation of the technology/service and why we use it.

## How It Works
Step-by-step guide to the integration:
1. Setup / Installation
2. Configuration
3. Basic usage pattern
4. Our specific implementation

## Code Examples

### Basic Pattern
```<language>
// Annotated code showing the standard usage pattern
```

### Our Implementation
```<language>
// How we actually use it in this project, with file references
```

## Gotchas and Pitfalls
- [gotcha 1 — how we discovered it, how to avoid]
- [gotcha 2]

## Testing This Integration
- How to write tests for this integration
- Mocking strategies
- Integration test setup

## Related
- [[STORY-<name>]] — story where this was first implemented
- [[SPEC-<name>]] — relevant spec
- [external docs link] — official documentation

---
*Contributors: STORY-<name>*
```

### Pattern (`Learning/Patterns/PATTERN-<name>.md`)

**When**: A review finding, a bug, or a specialist warning revealed something the developer should know to avoid in the future.

```markdown
# Pattern: <Short Descriptive Name>

**Type**: Anti-pattern | Best Practice | Gotcha
**Severity**: Critical | High | Medium | Low
**Domain**: [project domain — e.g. Go | Python | Frontend | Backend | Security | General, or domain plugin name]
**Occurrences**: 1
**First seen**: [[STORY-<name>]] (YYYY-MM-DD)

## The Problem
What goes wrong if you don't know this? Concrete description.

## The Wrong Way
```<language>
// Code that demonstrates the mistake
```

## The Right Way
```<language>
// Code that demonstrates the correct approach
```

## Why It Matters
Explanation of the consequences — what breaks, what's the impact?

## How We Found It
- Found by: [review agent / manual testing / production bug / specialist consultation]
- Story: [[STORY-<name>]]
- Finding: [description of the review finding or bug]

## Related Patterns
- [[PATTERN-<related>]] (if any)

---
*Occurrences: STORY-<name>*
```

### Writeup (`Learning/Writeups/WRITEUP-<name>.md`)

**When**: The story involved a complex problem, a non-obvious solution, or a significant architectural decision that others (or future-you) would benefit from understanding deeply.

```markdown
# Writeup: <Descriptive Title>

**Story**: [[STORY-<name>]]
**Date**: YYYY-MM-DD
**Domain**: [e.g. Frontend Architecture, API Design, DevOps, or domain plugin name]
**Difficulty**: Beginner | Intermediate | Advanced

## Context
What were we trying to build? What was the business need?

## The Challenge
What made this hard? What wasn't obvious?

## Approach
How did we think about the problem? What options did we consider?

### Option A: [approach name]
- Pros: ...
- Cons: ...

### Option B: [approach name] (chosen)
- Pros: ...
- Cons: ...
- Why we chose this: ...

## Implementation
Walk through the key parts of the implementation:

### Step 1: [phase name]
```<language>
// Key code with annotations explaining WHY, not just WHAT
```

### Step 2: [phase name]
...

## What We Learned
Key takeaways — the "aha moments":
1. [learning 1]
2. [learning 2]
3. [learning 3]

## Mistakes We Made
What went wrong during development and how we fixed it:
- [mistake 1] → [fix and lesson]
- [mistake 2] → [fix and lesson]

## If We Did It Again
What would we do differently with hindsight?

## Related
- [[STORY-<name>]] — the story
- [[GUIDE-<name>]] — integration guide (if applicable)
- [[PATTERN-<name>]] — patterns discovered (if applicable)
- [[SPEC-<name>]] — the spec

---
*Author: Claude + [user], from STORY-<name>*
```

## Step 4: Update Index

Update `Learning/Index.md` with the new entries:

```markdown
# Learning Index

Knowledge base built from project experience. Each entry links to a detailed document.

## Integration Guides
| Guide | Technology | Confidence | Stories |
|-------|-----------|------------|---------|
| [[GUIDE-<name>]] | [tech] | [Low/Med/High] | [[STORY-<name>]] |

## Patterns
| Pattern | Type | Severity | Domain | Occurrences |
|---------|------|----------|--------|-------------|
| [[PATTERN-<name>]] | [Anti-pattern/Best Practice/Gotcha] | [sev] | [domain] | [N] |

## Writeups
| Writeup | Domain | Difficulty | Date |
|---------|--------|------------|------|
| [[WRITEUP-<name>]] | [domain] | [level] | YYYY-MM-DD |
```

## Step 5: Link Back to Story

Add a `## Learnings` section to the completed story file:

```markdown
## Learnings
- [[Learning/Integrations/GUIDE-<name>]] — [brief description]
- [[Learning/Patterns/PATTERN-<name>]] — [brief description]
- [[Learning/Writeups/WRITEUP-<name>]] — [brief description]
```

## Step 6: Report to User

Present the generated learnings:

```
## Learnings from STORY-<name>

Generated {N} learning documents:

### Integration Guides
- GUIDE-<name>: [title] — [one-line summary]

### Patterns
- PATTERN-<name>: [title] — [one-line summary]

### Writeups
- WRITEUP-<name>: [title] — [one-line summary]

These are in your Obsidian vault under Learning/.
Open in Obsidian to read and annotate.
```

If no learnings were generated (routine story), report: "No new learnings from this story — all patterns were already documented."

## Updating Existing Learnings

When a learning already exists for a topic:

**Integration Guides**: Add the new story's experience:
- Update "Last updated" date
- Add new gotchas/pitfalls if discovered
- Increase "Confidence" level if appropriate (more usage = more confidence)
- Add story to "Contributors" list

**Patterns**: Increment occurrence count:
- Add new story to "Occurrences" list
- If the pattern was seen 3+ times, flag it: "This is a recurring pattern — consider adding a linter rule or pre-commit check"
- Update code examples if the new occurrence has a better illustration

## Notes

- Learning extraction is non-blocking — if it fails, the story still completes
- Users can run `/agile-flow:learn` manually on any completed story
- Writeups should be educational in tone — written for someone encountering this for the first time
- Code examples should be annotated with WHY comments, not just WHAT
- When updating existing learnings, never remove content — only add
- The Learning folder is project-specific (not global) — different projects learn different things
