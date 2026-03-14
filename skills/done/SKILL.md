---
description: Complete the current story — push, create PR, update board
---

Complete the current story and create a pull request.

1. Find the project's vault path from the repo's CLAUDE.md under `## Obsidian Project`
2. Determine the current story from the branch name (`feature/STORY-<name>`)
3. Read the story file to get acceptance criteria

**Verification:**
- Check off all completed tasks in the story file
- Verify acceptance criteria are met (review the code changes against each criterion)
- If criteria are NOT met, warn the user and list what's missing

**If ready:**
1. Stage and commit any remaining changes (with `Story: STORY-<name>` in the message)
2. Push the feature branch: `git push -u origin feature/STORY-<name>`
3. Create a PR targeting `develop`:
   ```
   gh pr create --base develop --title "STORY-<name>: <summary>" --body "..."
   ```
   Include in PR body: story link, acceptance criteria checklist, test plan
4. Move item from "In Progress" to "In Review" on `Sprint/Board.md`
5. Update the story's **Status** to `In Review`
6. Update the story's **PR** field with the PR URL
7. Ask: "Story is in review. Exit worktree, or continue with another story?"
