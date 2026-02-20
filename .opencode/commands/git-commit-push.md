---
description: Commit staged files with conventional commit message and push to remote
agent: build
model: github-copilot/claude-haiku-4.5
---

You are about to commit staged changes with a conventional commit message and push to the git repository. Follow these steps carefully:

## Step 1: Analyze Current State

Check the current git state:
!`git status`

View staged changes:
!`git diff --staged`

View recent commit history for style reference:
!`git log -5 --oneline`

## Step 2: Check for Staged Changes

Before proceeding, check if there are any staged changes:

!`git diff --staged --quiet`

If there are NO staged changes, inform the user:
```
No staged changes found. There is nothing to commit and push.

Please stage your changes first using:
- git add <file> (to stage specific files)
- git add . (to stage all changes)
```

Then stop the process.

## Step 3: Present Summary to User

If there ARE staged changes, you MUST:

1. **Analyze staged changes**
2. **Provide a clear, concise summary** to the user including:
    - What files are staged for commit
    - The nature of the changes (new feature, bug fix, refactor, etc.)
    - The proposed conventional commit message you plan to use (following Conventional Commits specification)
3. **Ask for confirmation** before proceeding with the commit and push

Example summary format:
```
I found the following staged changes:
- Modified: src/utils/helper.ts (refactored validation logic)
- Added: tests/helper.test.ts (added unit tests)

Proposed commit message:
refactor(utils): improve validation logic with better error handling

This will create a commit from your staged changes and push it to the remote repository.

Is it okay to proceed?
```

## Step 4: Commit with Conventional Commits

**CRITICAL**: You MUST use the Conventional Commits 1.0.0 specification for this command.

Load and reference the conventional commit skill:
@.opencode/skills/conventional-git-commit/SKILL.md

The commit message MUST follow this format:
- **Type**: feat, fix, docs, style, refactor, perf, test, build, ci, chore
- **Scope** (optional): e.g., `feat(auth):`, `fix(parser):`
- **Description**: Clear, imperative-mood description of what was changed
- **Body** (optional): Detailed explanation if needed
- **Footer** (optional): Use `BREAKING CHANGE:` or `!` for breaking changes

Example commit messages:
- `feat(auth): add login validation`
- `fix(parser): handle null values correctly`
- `docs(readme): update installation instructions`
- `refactor!: restructure authentication module`

## Step 5: Commit and Push

Only after receiving user confirmation:

1. Create the commit with the conventional message (using already staged files)
2. If commit validation fails (from hooks):
    - Show the validation error logs to the user
    - Ask the user if they want to take over and fix the issues, or attempt to rerun the commit
    - Do not proceed with the push until validation passes
3. Push to the remote repository: `git push`
4. If push fails:
    - Show the error message to the user
    - Explain what went wrong (e.g., conflicts, rejected push)
    - Suggest solutions if applicable
5. Verify the push was successful with `git status`

## Important Notes

- **DO NOT** push without user confirmation
- **DO** provide clear feedback on what was committed and pushed
- **DO** handle any errors gracefully and report them to the user
- **NOTE**: This command commits ONLY already staged files (no new staging occurs)

## Example Workflow

1. Show staged changes summary ✓
2. Show proposed commit message ✓
3. Ask: "Is it okay to proceed?" ✓
4. Wait for user confirmation ✓
5. Commit: `git commit -m "refactor(utils): improve validation logic with better error handling"`
6. Push: `git push`
7. Confirm: "✓ Changes committed and pushed successfully"
