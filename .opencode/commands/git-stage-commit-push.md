---
description: Stage all files, commit with conventional commit message, and push to remote
agent: build
model: github-copilot/claude-haiku-4.5
---

You are about to stage all changes, commit with a conventional commit message, and push to the git repository. Follow these steps carefully:

## Step 1: Analyze Current State

Check the current git state:
!`git status`

View the changes:
!`git diff`

View staged changes (if any):
!`git diff --staged`

View recent commit history for style reference:
!`git log -5 --oneline`

## Step 2: Pre-Stage Safety Checklist

Before staging anything, run the following checks and present the results using ✅ (pass) or ❌ (FAIL) for each item. If ANY item fails, warn the user prominently and ask whether to continue.

Run these commands to gather data:
!`git diff --name-only && git ls-files --others --exclude-standard`
!`git diff --name-only && git ls-files --others --exclude-standard | xargs -I{} find {} -maxdepth 0 -size +1M 2>/dev/null`
!`grep -rn "PRIVATE KEY\|-----BEGIN\|password\s*=\|secret\s*=\|api_key\s*=\|apikey\s*=\|token\s*=\|AWS_SECRET\|AWS_ACCESS" --include="*.env*" --include="*.json" --include="*.yaml" --include="*.yml" --include="*.toml" --include="*.ini" --include="*.conf" --include="*.config" . 2>/dev/null | grep -v ".git" | head -20`
!`git diff | grep -n "<<<<<<\|=======\|>>>>>>>" | head -20`
!`git ls-files --others --exclude-standard | grep -E "\.env$|\.env\.|credentials|secrets|\.pem$|\.key$|\.p12$|\.pfx$|id_rsa|id_dsa|id_ecdsa" | head -20`
!`git check-ignore -v $(git ls-files --others --exclude-standard) 2>/dev/null | head -20`
!`git branch --show-current`

Present the checklist in this exact format:

```
## Pre-Stage Safety Checklist

| # | Check | Status | Detail |
|---|-------|--------|--------|
| 1 | No secrets or credentials exposed | ✅ / ❌ | [files or "None found"] |
| 2 | No files larger than 1 MB | ✅ / ❌ | [files or "None found"] |
| 3 | No .env or config files with sensitive data | ✅ / ❌ | [files or "None found"] |
| 4 | No merge conflict markers (<<<<<<, =======, >>>>>>>) | ✅ / ❌ | [files or "None found"] |
| 5 | No binary or generated files that shouldn't be tracked | ✅ / ❌ | [files or "None found"] |
| 6 | No files that should be in .gitignore | ✅ / ❌ | [files or "None found"] |
| 7 | No private key files (.pem, .key, id_rsa, etc.) | ✅ / ❌ | [files or "None found"] |
| 8 | Not staging directly to main/master branch | ✅ / ❌ | [branch name] |
| 9 | No debug code left in (console.log, debugger, etc.) | ✅ / ❌ | [files or "None found"] |
| 10 | No TODO/FIXME comments that block this change | ✅ / ❌ | [files or "None found"] |
```

After the table, **always** display a full result summary in this exact format:

```
## Safety Check Results

✅ Passed ([n]/10):
- No secrets or credentials exposed
- No files larger than 1 MB
- [every passing check listed by name]

❌ Failed ([n]/10):
- No .env or config files with sensitive data → Found: .env.local, config/secrets.yml
- [every failing check listed by name with what was found]
```

**If ALL checks passed** (0 failures), follow the result summary with:

```
All 10 safety checks passed. Safe to proceed with staging.
```

**If any checks failed**, follow the result summary with:

```
⚠️  WARNING: [n] of 10 safety check(s) failed before staging.
Proceeding may expose sensitive data or corrupt the repository.

Do you want to continue anyway?
```

## Step 3: Present Summary to User

Before committing, you MUST present a summary to the user in this exact format:

```
## Summary
[1-2 sentence overall description of changes]

## Files Changed

**Added:**
- filename.ext
  Summary: [brief description]

**Modified:**
- filename.ext
  Summary: [brief description]

**Deleted:**
- filename.ext
  Summary: [brief description]

## Proposed Commit Message
[conventional commit message]

## Attention Required
[List any issues like secrets, large files, or None if nothing to note]

---

Is it okay to proceed with staging, committing, and pushing these changes?
```

Then:
1. **Analyze all changes** (both staged and unstaged)
2. **Provide the formatted summary** to the user
3. **Ask for confirmation** before proceeding with the commit

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

## Step 5: Stage All, Commit, and Push

Only after receiving user confirmation:

1. Stage all changes: `git add .`
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

1. Run pre-stage safety checklist ✓
2. Show changes summary ✓
3. Show proposed commit message ✓
4. Ask: "Is it okay to proceed with this commit?" ✓
5. Wait for user confirmation ✓
6. Stage all files: `git add .`
7. Commit: `git commit -m "feat(commands): add new-command for automated deployment"`
8. Push: `git push`
9. Confirm: "✓ Changes staged, committed and pushed successfully"
