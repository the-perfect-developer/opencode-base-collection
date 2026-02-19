---
description: Stage changes, commit with conventional commit message, and push to remote
agent: build
model: github-copilot/claude-haiku-4.5
---

You are about to commit and push changes to the git repository. Follow these steps carefully:

## Step 1: Analyze Current State

Check the current git state:
!`git status`

View the changes:
!`git diff`

View staged changes (if any):
!`git diff --staged`

View recent commit history for style reference:
!`git log -5 --oneline`

## Step 2: Present Summary to User

Before committing, you MUST:

1. **Analyze all changes** (both staged and unstaged)
2. **Provide a clear, concise summary** to the user including:
   - What files are being added/modified/deleted
   - The nature of the changes (new feature, bug fix, refactor, etc.)
   - The proposed conventional commit message you plan to use
3. **Ask for confirmation** before proceeding with the commit

Example summary format:
```
I found the following changes:
- Added: .opencode/commands/new-command.md (new custom command)
- Modified: src/utils/helper.ts (refactored validation logic)

Proposed commit message:
feat(commands): add new-command for automated deployment

This will create a new feature commit and push it to the remote repository.

Is it okay to proceed with this commit?
```

## Step 3: Commit with Conventional Commits

**IMPORTANT**: You MUST follow the Conventional Commits 1.0.0 specification.

Reference the conventional commit skill:
@.opencode/skills/conventional-git-commit/SKILL.md

Create a commit message that:
- Uses the correct type (feat, fix, docs, style, refactor, perf, test, build, ci, chore)
- Includes scope if appropriate (e.g., `feat(auth):`, `fix(parser):`)
- Has a clear, imperative-mood description
- Includes a body if the changes need explanation
- Uses `BREAKING CHANGE:` footer or `!` if there are breaking changes

## Step 4: Stage, Commit, and Push

Only after receiving user confirmation:

1. Stage all relevant changes: `git add <files>`
2. Create the commit with the conventional message
3. If commit validation fails (from hooks):
   - Show the validation error logs to the user
   - Ask the user if they want to take over and fix the issues, or attempt to rerun the commit
   - Do not proceed with the push until validation passes
4. Push to the remote repository: `git push`
5. Verify the push was successful with `git status`

## Important Notes

- **DO NOT** commit files that likely contain secrets (.env, credentials.json, etc.)
- **DO NOT** push without user confirmation
- **DO** warn the user if they're about to commit sensitive files
- **DO** provide clear feedback on what was committed and pushed
- **DO** handle any errors gracefully and report them to the user

## Example Workflow

1. Show changes summary ✓
2. Show proposed commit message ✓
3. Ask: "Is it okay to proceed with this commit?" ✓
4. Wait for user confirmation ✓
5. Stage files: `git add .opencode/commands/new-command.md`
6. Commit: `git commit -m "feat(commands): add new-command for automated deployment"`
7. Push: `git push`
8. Confirm: "✓ Changes committed and pushed successfully"
