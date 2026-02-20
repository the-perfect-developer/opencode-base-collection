---
description: Push commits to remote repository
agent: build
model: github-copilot/claude-haiku-4.5
---

You are about to push commits to the remote git repository. Follow these steps carefully:

## Step 1: Analyze Current State

Check the current git state:
!`git status`

View commits to be pushed:
!`git log --oneline @{u}..HEAD`

View remote tracking information:
!`git branch -vv`

## Step 2: Check for Commits to Push

Before proceeding, check if there are any commits to push:

!`git log --oneline @{u}..HEAD`

If there are NO commits to push, inform the user:
```
No commits found to push. Your local branch is already up to date with the remote.

If you want to commit changes, please use:
- git-stage-commit-push (to stage, commit and push)
- git-commit-push (to commit staged changes and push)
```

Then stop the process.

## Step 3: Present Summary to User

If there ARE commits to push, you MUST:

1. **Analyze commits to be pushed**
2. **Provide a clear, concise summary** to the user including:
    - The number of commits to be pushed
    - Brief description of each commit
    - The target branch and remote
    - Any warnings about force push or conflicts
3. **Ask for confirmation** before proceeding with the push

Example summary format:
```
I found the following commits ready to push:

1. refactor(utils): improve validation logic with better error handling
2. test(utils): add unit tests for validation

Target: origin/main (2 commits ahead)

Is it okay to proceed with pushing these commits?
```

## Step 4: Push to Remote

Only after receiving user confirmation:

1. Push to the remote repository: `git push`
2. If push fails:
    - Show the error message to the user
    - Explain what went wrong (e.g., conflicts, rejected push, authentication issues)
    - Suggest solutions if applicable
    - Do not force push unless the user explicitly requests it
3. Verify the push was successful: `git status`

## Important Notes

- **DO NOT** push without user confirmation
- **NEVER** force push to main/master branch unless user explicitly requests it
- **DO** warn the user if they're about to force push
- **DO** provide clear feedback on what was pushed
- **DO** handle any errors gracefully and report them to the user
- **NOTE**: This command ONLY pushes existing commits (no staging or committing occurs)

## Example Workflow

1. Show commits to be pushed ✓
2. Show target branch and remote ✓
3. Ask: "Is it okay to proceed with pushing?" ✓
4. Wait for user confirmation ✓
5. Push: `git push`
6. Verify: `git status`
7. Confirm: "✓ Commits pushed successfully to origin/main"
