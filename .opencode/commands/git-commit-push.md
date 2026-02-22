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

## Step 2: Pre-Commit Safety Checklist

Before creating the commit, run the following checks against staged content and present the results using ✅ (pass) or ❌ (FAIL) for each item. If ANY item fails, warn the user prominently and ask whether to continue.

Run these commands to gather data:
!`git diff --staged --name-only`
!`git diff --staged --name-only | xargs -I{} find {} -maxdepth 0 -size +1M 2>/dev/null`
!`git diff --staged | grep -n "PRIVATE KEY\|-----BEGIN\|password\s*=\|secret\s*=\|api_key\s*=\|apikey\s*=\|token\s*=\|AWS_SECRET\|AWS_ACCESS" | head -20`
!`git diff --staged | grep -n "<<<<<<\|=======\|>>>>>>>" | head -20`
!`git diff --staged --name-only | grep -E "\.env$|\.env\.|credentials|secrets|\.pem$|\.key$|\.p12$|\.pfx$|id_rsa|id_dsa|id_ecdsa" | head -20`
!`git diff --staged | grep -n "console\.log\|debugger;\|binding\.pry\|byebug\|pdb\.set_trace\|dd(" | head -20`
!`git branch --show-current`
!`git diff --staged --name-only | xargs grep -l "TODO\|FIXME\|HACK\|XXX" 2>/dev/null | head -10`

Present the checklist in this exact format:

```
## Pre-Commit Safety Checklist

| # | Check | Status | Detail |
|---|-------|--------|--------|
| 1 | No secrets or credentials in staged changes | ✅ / ❌ | [matches or "None found"] |
| 2 | No staged files larger than 1 MB | ✅ / ❌ | [files or "None found"] |
| 3 | No .env or sensitive config files staged | ✅ / ❌ | [files or "None found"] |
| 4 | No merge conflict markers (<<<<<<, =======, >>>>>>>) | ✅ / ❌ | [files or "None found"] |
| 5 | No private key files staged (.pem, .key, id_rsa, etc.) | ✅ / ❌ | [files or "None found"] |
| 6 | No debug statements left in (console.log, debugger, etc.) | ✅ / ❌ | [files or "None found"] |
| 7 | No blocking TODO/FIXME comments in staged files | ✅ / ❌ | [files or "None found"] |
| 8 | Not committing directly to main/master branch | ✅ / ❌ | [branch name] |
| 9 | No binary or generated files that shouldn't be committed | ✅ / ❌ | [files or "None found"] |
| 10 | All staged files are intentional (not accidental adds) | ✅ / ❌ | [review staged list] |
```

After the table, **always** display a full result summary in this exact format:

```
## Safety Check Results

✅ Passed ([n]/10):
- No secrets or credentials in staged changes
- No staged files larger than 1 MB
- [every passing check listed by name]

❌ Failed ([n]/10):
- No .env or sensitive config files staged → Found: .env.production
- [every failing check listed by name with what was found]
```

**If ALL checks passed** (0 failures), follow the result summary with:

```
All 10 safety checks passed. Safe to proceed with committing.
```

**If any checks failed**, follow the result summary with:

```
⚠️  WARNING: [n] of 10 safety check(s) failed before committing.
Proceeding may expose sensitive data or introduce broken code into the repository history.

Do you want to continue anyway?
```

## Step 3: Present Summary to User

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

## Step 4: Commit with Conventional Commits

**IMPORTANT**: You MUST follow the Conventional Commits 1.0.0 specification.

Reference the conventional commit skill:
@.opencode/skills/conventional-git-commit/SKILL.md

Create a commit message that:
- Uses the correct type (feat, fix, docs, style, refactor, perf, test, build, ci, chore)
- Includes scope if appropriate (e.g., `feat(auth):`, `fix(parser):`)
- Has a clear, imperative-mood description
- Includes a body if the changes need explanation
- Uses `BREAKING CHANGE:` footer or `!` if there are breaking changes

## Step 5: Stage, Commit, and Push

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

1. Run pre-commit safety checklist ✓
2. Show changes summary ✓
3. Show proposed commit message ✓
4. Ask: "Is it okay to proceed with this commit?" ✓
5. Wait for user confirmation ✓
6. Stage files: `git add .opencode/commands/new-command.md`
7. Commit: `git commit -m "feat(commands): add new-command for automated deployment"`
8. Push: `git push`
9. Confirm: "✓ Changes committed and pushed successfully"
