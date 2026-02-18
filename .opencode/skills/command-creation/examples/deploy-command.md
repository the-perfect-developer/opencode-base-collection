---
description: Deploy to environment
agent: build
model: anthropic/claude-3-5-sonnet-20241022
subtask: true
---

Deploy application to $1 environment:

## Pre-Deployment Checks

Current git status:
!`git status`

Current branch:
!`git branch --show-current`

Package version:
@package.json

Recent commits:
!`git log --oneline -5`

## Deployment Steps

1. **Verify Prerequisites**
   - All tests pass
   - Build succeeds
   - No uncommitted changes
   - On correct branch

2. **Run Pre-Deployment Tasks**
   - Build: npm run build
   - Tests: npm test
   - Lint: npm run lint

3. **Deploy**
   - Run: npm run deploy:$1
   - Monitor deployment logs
   - Verify deployment health

4. **Post-Deployment Verification**
   - Check application status
   - Run smoke tests
   - Verify key functionality

5. **Rollback Plan**
   - If deployment fails, run: /rollback $1
   - Alert team of issues

## Environment: $1

Proceed with deployment checklist above.
