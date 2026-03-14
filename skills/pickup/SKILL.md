---
description: Pick up a story from the sprint board and start working on it in a worktree
---

Pick up a story and start working. Argument: "$ARGUMENTS" (story name or empty to show options).

1. Find the project's vault path from the repo's CLAUDE.md under `## Obsidian Project`
2. Read `Sprint/Board.md`

**If no argument given:**
- List all items in "Ready" column
- Ask the user which story to pick up

**When a story is selected (e.g. STORY-auth-login):**
1. Read the story file at `Backlog/Stories/STORY-<name>.md`
2. Read any linked specs in `Specs/`
3. Move the item from "Ready" to "In Progress" on `Sprint/Board.md`
4. Update the story's **Status** to `In Progress`
5. Use `EnterWorktree` with name `STORY-<name>` to create an isolated workspace
6. Inside the worktree, rename the branch: `git branch -m feature/STORY-<name>`
7. Report: "Working on STORY-<name> in isolated worktree. Here's what the story requires:" followed by the acceptance criteria and tasks
8. Begin implementation

**WIP limit:** If there are already 3 items in "In Progress", warn the user before proceeding.
