# Common Command Patterns

A collection of proven patterns and examples for creating effective OpenCode commands.

## Testing Commands

### Basic Test Runner

Run tests with default configuration:

```markdown
---
description: Run tests
agent: build
---

Run the test suite:
!`npm test`

Report any failures and suggest fixes.
```

### Test with Coverage

Run tests with coverage reporting:

```markdown
---
description: Run tests with coverage
agent: build
---

Run tests with coverage:
!`npm test -- --coverage`

Coverage report:
!`cat coverage/coverage-summary.json 2>/dev/null || echo "No coverage report found"`

Analyze coverage and suggest improvements.
```

### Test Specific File

Run tests for a specific file:

```markdown
---
description: Test specific file
agent: build
---

Run tests for $ARGUMENTS:
!`npm test -- $ARGUMENTS`

Analyze results and suggest fixes if any tests fail.
```

Usage: `/test-file src/utils/parser.test.ts`

### Watch Mode Tests

Run tests in watch mode:

```markdown
---
description: Run tests in watch mode
agent: build
---

Starting test watch mode for $ARGUMENTS

Run: npm test -- --watch $ARGUMENTS

Monitor test results and report failures.
```

## Code Review Commands

### Review Recent Changes

Review recent git commits:

```markdown
---
description: Review recent changes
---

Recent commits:
!`git log --oneline -10`

Changed files:
!`git diff --name-only HEAD~5`

Review for:
- Code quality
- Potential bugs
- Performance issues
```

### Review Pull Request

Review changes in a PR:

```markdown
---
description: Review PR changes
---

PR diff:
!`git diff main..HEAD`

Modified files:
!`git diff --name-only main..HEAD`

Review changes for:
- Breaking changes
- Test coverage
- Documentation updates
- Security concerns
```

### Review Specific File

Review a single file in depth:

```markdown
---
description: Review file
---

File to review:
@$1

Similar files for context:
!`find $(dirname $1) -name "*.$(basename $1 | cut -d. -f2)" -not -path $1 | head -3`

Review for:
- Code quality and patterns
- Performance optimizations
- Security vulnerabilities
- Test coverage
```

Usage: `/review-file src/components/Button.tsx`

### Compare Files

Compare two files:

```markdown
---
description: Compare files
---

First file:
@$1

Second file:
@$2

Compare these files and identify:
- Similarities
- Differences
- Which approach is better
- Migration path from $1 to $2
```

Usage: `/compare src/old-api.ts src/new-api.ts`

## Deployment Commands

### Deploy to Environment

Deploy to specific environment:

```markdown
---
description: Deploy to environment
agent: build
subtask: true
---

Deploy to $1 environment:

Pre-deployment checks:
!`git status`

Package version:
@package.json

Steps:
1. Verify build passes: npm run build
2. Run tests: npm test
3. Deploy: npm run deploy:$1
4. Verify deployment
```

Usage: `/deploy staging`

### Production Deployment Checklist

Comprehensive production deployment:

```markdown
---
description: Deploy to production
agent: build
model: anthropic/claude-3-opus-20240229
subtask: true
---

⚠️ PRODUCTION DEPLOYMENT ⚠️

Current state:
!`git status`

Branch:
!`git branch --show-current`

Last 5 commits:
!`git log --oneline -5`

Package version:
@package.json

Changelog:
@CHANGELOG.md

Pre-deployment checklist:
- [ ] On main branch
- [ ] No uncommitted changes
- [ ] All tests pass
- [ ] Changelog updated
- [ ] Version bumped
- [ ] No security vulnerabilities

Run: npm run deploy:production
```

### Rollback Deployment

Roll back to previous version:

```markdown
---
description: Rollback deployment
agent: build
subtask: true
---

Rollback $1 environment to previous version:

Current version:
!`npm run version:current --env=$1`

Previous versions:
!`npm run version:history --env=$1 | head -5`

Steps:
1. Confirm rollback target
2. Run: npm run rollback:$1
3. Verify rollback successful
4. Alert team
```

Usage: `/rollback production`

## Component Generation Commands

### Create Component

Generate new React component:

```markdown
---
description: Create React component
---

Create component: $1

Template to follow:
@templates/Component.tsx

Requirements:
- TypeScript types
- Props interface
- Basic styling
- Tests file

Location: src/components/$1/
```

Usage: `/component UserProfile`

### Create Page Component

Generate page with routing:

```markdown
---
description: Create page component
---

Create page: $1

Template:
@templates/Page.tsx

Route config:
@src/router/routes.ts

Requirements:
1. Create component: src/pages/$1/$1.tsx
2. Add route to routes.ts
3. Create page tests
4. Update navigation
```

Usage: `/page Dashboard`

### Create Hook

Generate custom React hook:

```markdown
---
description: Create custom hook
---

Create hook: $1

Example hooks:
@src/hooks/useExample.ts

Requirements:
- TypeScript types
- JSDoc comments
- Unit tests
- Usage example

Location: src/hooks/$1.ts
```

Usage: `/hook useLocalStorage`

## Documentation Commands

### Document File

Generate documentation for a file:

```markdown
---
description: Generate documentation
---

Generate documentation for:
@$ARGUMENTS

Include:
- Overview and purpose
- API reference
- Parameters and return types
- Usage examples
- Edge cases and limitations
```

Usage: `/doc src/utils/parser.ts`

### Generate README

Create README for a directory:

```markdown
---
description: Generate README
---

Generate README for: $1

Directory contents:
!`ls -la $1`

Code files:
!`find $1 -name "*.ts" -o -name "*.tsx" | head -10`

Include:
- Directory overview
- File structure
- Main exports
- Usage examples
```

Usage: `/readme src/utils`

### API Documentation

Generate API docs:

```markdown
---
description: Generate API docs
---

API endpoints:
@src/api/routes.ts

Generate documentation including:
- Endpoint list
- Request/response formats
- Authentication requirements
- Error codes
- Examples

Output format: Markdown
```

## Analysis Commands

### Analyze Bundle Size

Analyze build bundle size:

```markdown
---
description: Analyze bundle size
agent: build
subtask: true
---

Build the project:
!`npm run build`

Bundle analysis:
!`du -sh dist/* | sort -hr`

Large files:
!`find dist -type f -size +100k -exec ls -lh {} \; | awk '{print $5, $9}'`

Identify:
- Largest bundles
- Unused dependencies
- Optimization opportunities
```

### Analyze Dependencies

Analyze project dependencies:

```markdown
---
description: Analyze dependencies
subtask: true
---

Dependencies:
@package.json

Installed versions:
!`npm list --depth=0`

Outdated packages:
!`npm outdated`

Security audit:
!`npm audit`

Report on:
- Outdated dependencies
- Security vulnerabilities
- Unused dependencies
- Update recommendations
```

### Code Metrics

Analyze code metrics:

```markdown
---
description: Analyze code metrics
subtask: true
---

Lines of code:
!`find src -name "*.ts" -o -name "*.tsx" | xargs wc -l | tail -1`

File count:
!`find src -type f | wc -l`

Largest files:
!`find src -type f -name "*.ts" -o -name "*.tsx" | xargs wc -l | sort -nr | head -10`

Test coverage:
!`cat coverage/coverage-summary.json 2>/dev/null || echo "Run tests first"`

Analyze:
- Code distribution
- Test coverage gaps
- Large files needing refactor
```

## Debugging Commands

### Debug Test Failure

Debug failing tests:

```markdown
---
description: Debug test failures
agent: build
---

Run tests in debug mode:
!`npm test -- --verbose $ARGUMENTS`

Test file content:
@$ARGUMENTS

Analyze failures and suggest fixes.
```

Usage: `/debug-test src/utils/parser.test.ts`

### Debug Build Error

Debug build errors:

```markdown
---
description: Debug build errors
agent: build
---

Run build:
!`npm run build 2>&1`

Recent changes:
!`git diff HEAD~1`

Analyze errors and suggest fixes.
```

### Debug Runtime Error

Debug runtime errors:

```markdown
---
description: Debug runtime error
---

Error description: $ARGUMENTS

Related code:
!`grep -rn "$ARGUMENTS" src/ | head -10`

Recent changes to related files:
!`git log --oneline --all --grep="$ARGUMENTS" -10`

Analyze error and suggest solutions.
```

Usage: `/debug "TypeError: Cannot read property"`

## Git Commands

### Git Status Report

Comprehensive git status:

```markdown
---
description: Git status report
---

Branch:
!`git branch --show-current`

Status:
!`git status`

Recent commits:
!`git log --oneline -5`

Staged changes:
!`git diff --staged --stat`

Unstaged changes:
!`git diff --stat`

Summarize repository state.
```

### Create Branch

Create new branch:

```markdown
---
description: Create branch
---

Create branch: $ARGUMENTS

From current branch:
!`git branch --show-current`

Run: git checkout -b $ARGUMENTS

After creation:
- Verify branch created
- Push to remote
- Set upstream
```

Usage: `/branch feature/new-feature`

### Prepare Commit

Prepare commit message:

```markdown
---
description: Prepare commit
---

Staged changes:
!`git diff --staged`

Changed files:
!`git diff --staged --name-only`

Recent commits for reference:
!`git log --oneline -5`

Generate commit message following conventional commits:
- type(scope): description
- Include breaking changes if any
- Reference related issues
```

## Refactoring Commands

### Refactor Function

Refactor specific function:

```markdown
---
description: Refactor function
---

Function to refactor in $1:
@$1

Similar patterns:
!`grep -n "function\|const.*=" $1 | head -5`

Refactor for:
- Readability
- Performance
- Type safety
- Testability
```

Usage: `/refactor src/utils/helper.ts`

### Extract Component

Extract component from file:

```markdown
---
description: Extract component
---

Source file:
@$1

Extract component: $2

Requirements:
1. Create new file: src/components/$2.tsx
2. Move component logic
3. Update imports in $1
4. Maintain functionality
```

Usage: `/extract src/pages/Dashboard.tsx UserCard`

### Rename Symbol

Rename across codebase:

```markdown
---
description: Rename symbol
---

Rename $1 to $2

Files containing $1:
!`grep -rn "$1" src/ --include="*.ts" --include="*.tsx" | cut -d: -f1 | sort -u`

Plan:
1. List all occurrences
2. Update imports
3. Update references
4. Run tests
```

Usage: `/rename oldName newName`

## Performance Commands

### Performance Audit

Audit performance:

```markdown
---
description: Performance audit
subtask: true
---

Build size:
!`npm run build && du -sh dist/`

Bundle analysis:
!`npm run analyze 2>/dev/null || echo "Install bundle analyzer"`

Lighthouse score:
!`npm run lighthouse 2>/dev/null || echo "Setup lighthouse"`

Identify:
- Performance bottlenecks
- Large dependencies
- Lazy loading opportunities
- Optimization recommendations
```

### Profile Component

Profile React component performance:

```markdown
---
description: Profile component
---

Component to profile:
@$1

Dependencies:
!`grep -n "^import" $1`

Analyze for:
- Unnecessary re-renders
- Large props
- Expensive computations
- Missing memoization
```

Usage: `/profile src/components/DataGrid.tsx`

## Maintenance Commands

### Update Dependencies

Update project dependencies:

```markdown
---
description: Update dependencies
agent: build
subtask: true
---

Current dependencies:
@package.json

Outdated packages:
!`npm outdated`

Steps:
1. Review outdated packages
2. Check for breaking changes
3. Update package.json
4. Run: npm install
5. Run tests: npm test
6. Update documentation
```

### Clean Project

Clean build artifacts:

```markdown
---
description: Clean project
agent: build
---

Remove build artifacts:
!`du -sh dist/ node_modules/ coverage/ 2>/dev/null`

Run:
- rm -rf dist/
- rm -rf coverage/
- npm ci

Verify clean state.
```

### Security Audit

Run security audit:

```markdown
---
description: Security audit
subtask: true
---

NPM audit:
!`npm audit`

Dependency tree:
!`npm list --depth=0`

Steps:
1. Review vulnerabilities
2. Update affected packages
3. Run: npm audit fix
4. Verify fixes don't break functionality
```

## Best Practices for Patterns

**DO**:
- ✅ Use descriptive command names
- ✅ Include clear success/failure criteria
- ✅ Add safety checks for destructive operations
- ✅ Provide context with shell commands
- ✅ Reference relevant files
- ✅ Use appropriate agent and model
- ✅ Set subtask for long operations

**DON'T**:
- ❌ Create overly complex commands
- ❌ Mix unrelated operations
- ❌ Use destructive commands without warnings
- ❌ Assume all environments are identical
- ❌ Include sensitive data
- ❌ Skip error handling

## Combining Patterns

Many patterns can be combined for powerful workflows:

```markdown
---
description: Pre-deploy checks
agent: build
subtask: true
---

🔍 Pre-Deployment Checks for $1

1. Code Quality:
!`npm run lint`

2. Tests:
!`npm test`

3. Build:
!`npm run build`

4. Security:
!`npm audit`

5. Git Status:
!`git status`

6. Version:
@package.json

If all checks pass, run: /deploy $1
```

This combines testing, linting, security, and deployment patterns into a single comprehensive command.
