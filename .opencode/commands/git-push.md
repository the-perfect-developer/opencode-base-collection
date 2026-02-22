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

## Step 3: Pre-Push Safety Checklist

Before pushing, run the following checks against the commits about to be pushed and present the results using ✅ (pass) or ❌ (FAIL) for each item. If ANY item fails, warn the user prominently and ask whether to continue.

Run these commands to gather data:
!`git log @{u}..HEAD --name-only --pretty=format:"" | sort -u | grep -v "^$"`
!`git diff @{u}..HEAD | grep -n "PRIVATE KEY\|-----BEGIN\|password\s*=\|secret\s*=\|api_key\s*=\|apikey\s*=\|token\s*=\|AWS_SECRET\|AWS_ACCESS" | head -20`
!`git log @{u}..HEAD --name-only --pretty=format:"" | sort -u | grep -v "^$" | xargs -I{} find {} -maxdepth 0 -size +1M 2>/dev/null`
!`git log @{u}..HEAD --name-only --pretty=format:"" | sort -u | grep -v "^$" | grep -E "\.env$|\.env\.|credentials|secrets|\.pem$|\.key$|\.p12$|\.pfx$|id_rsa|id_dsa|id_ecdsa"`
!`git diff @{u}..HEAD | grep -n "<<<<<<\|=======\|>>>>>>>" | head -20`
!`git branch --show-current`
!`git log @{u}..HEAD --oneline | wc -l`
!`git log --oneline @{u}..HEAD | head -20`

Present the checklist in this exact format:

```
## Pre-Push Safety Checklist

| # | Check | Status | Detail |
|---|-------|--------|--------|
| 1 | No secrets or credentials in commits to push | ✅ / ❌ | [matches or "None found"] |
| 2 | No files larger than 1 MB in commits | ✅ / ❌ | [files or "None found"] |
| 3 | No .env or sensitive config files in commits | ✅ / ❌ | [files or "None found"] |
| 4 | No merge conflict markers in committed files | ✅ / ❌ | [files or "None found"] |
| 5 | No private key files in commits (.pem, .key, id_rsa, etc.) | ✅ / ❌ | [files or "None found"] |
| 6 | Not pushing directly to main/master branch | ✅ / ❌ | [branch name] |
| 7 | Not a force push (no history rewrite risk) | ✅ / ❌ | ["Safe" or "Force push detected"] |
| 8 | Commit count is reasonable (not hundreds of commits) | ✅ / ❌ | [count] |
| 9 | Commit messages follow project conventions | ✅ / ❌ | [review messages] |
| 10 | Remote is the intended target (not wrong remote/branch) | ✅ / ❌ | [remote and branch] |
```

After the table, **always** display a full result summary in this exact format:

```
## Safety Check Results

✅ Passed ([n]/10):
- No secrets or credentials in commits to push
- No files larger than 1 MB in commits
- [every passing check listed by name]

❌ Failed ([n]/10):
- Not pushing directly to main/master branch → Currently on: main
- [every failing check listed by name with what was found]
```

**If ALL checks passed** (0 failures), follow the result summary with:

```
All 10 safety checks passed. Safe to proceed with pushing.
```

**If any checks failed**, follow the result summary with:

```
⚠️  WARNING: [n] of 10 safety check(s) failed before pushing.
Pushing sensitive data to a remote repository is difficult or impossible to undo.

Do you want to continue anyway?
```

## Step 4: Present Summary to User

If all checks pass (or user confirms to proceed), present a summary to the user in this exact format:

```
## Summary
[1-2 sentence overall description of commits to push]

## Commits to Push

1. [commit message]
2. [commit message]
3. [commit message]

## Target
Branch: [branch name]
Remote: [remote name]
Status: [commits ahead/details]

## Attention Required
[List any issues like force push needed, conflicts, or None if nothing to note]

---

Is it okay to proceed with pushing these commits?
```

Then:
1. **Analyze commits to be pushed**
2. **Provide the formatted summary** to the user
3. **Ask for confirmation** before proceeding with the push

## Step 5: Push to Remote

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

1. Run pre-push safety checklist ✓
2. Show commits to be pushed ✓
3. Show target branch and remote ✓
4. Ask: "Is it okay to proceed with pushing?" ✓
5. Wait for user confirmation ✓
6. Push: `git push`
7. Verify: `git status`
8. Confirm: "✓ Commits pushed successfully to origin/main"
