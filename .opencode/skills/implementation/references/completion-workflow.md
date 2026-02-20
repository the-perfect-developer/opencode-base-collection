# Completion Workflow

Detailed workflow for finalizing implementation, updating status, and generating completion summary.

## Overview

The completion workflow ensures proper documentation, status updates, and handoff after implementation is finished. This is the final phase before marking a plan as complete.

## Completion Steps

```
1. Final Documentation Updates
   ↓
2. Git Status Check
   ↓
3. Mark Plan as Completed
   ↓
4. Generate Implementation Summary
   ↓
5. Display to User
```

## Step 1: Final Documentation Updates

### Code Documentation

**JSDoc/Docstrings for Public APIs**:

```typescript
/**
 * Authenticates a user with email and password.
 * 
 * @param email - User's email address
 * @param password - User's password (will be hashed)
 * @returns JWT token and user information
 * @throws {UnauthorizedError} If credentials are invalid
 * @throws {RateLimitError} If too many failed attempts
 * 
 * @example
 * const result = await authService.login('user@example.com', 'password123');
 * // Returns: { token: 'jwt...', user: { id: 1, email: '...', name: '...' } }
 */
async login(email: string, password: string): Promise<LoginResult> {
  // Implementation
}
```

**Inline Comments for Complex Logic**:

```typescript
// Hash password with bcrypt (cost factor: 10)
// Higher cost factor = more secure but slower
const hashedPassword = await bcrypt.hash(password, 10);

// Generate JWT with 24-hour expiration
// Token includes user ID and email for authorization
const token = jwt.sign(
  { userId: user.id, email: user.email },
  process.env.JWT_SECRET,
  { expiresIn: '24h' }
);
```

### README Updates

**If feature requires setup or configuration**:

```markdown
## Authentication

This application uses OAuth 2.0 authentication with Google and GitHub providers.

### Setup

1. Create OAuth apps:
   - Google: https://console.developers.google.com/
   - GitHub: https://github.com/settings/developers

2. Add credentials to `.env`:
   ```
   GOOGLE_CLIENT_ID=your_client_id
   GOOGLE_CLIENT_SECRET=your_client_secret
   GITHUB_CLIENT_ID=your_client_id
   GITHUB_CLIENT_SECRET=your_client_secret
   ```

3. Run database migrations:
   ```bash
   npm run migrate
   ```

### Usage

Users can sign in using:
- Email/password (existing method)
- Google OAuth
- GitHub OAuth

To link an OAuth account to an existing user, sign in with email/password first, then navigate to Settings > Connected Accounts.
```

**Update `.env.example`**:

```bash
# Add new environment variables
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
GITHUB_CLIENT_ID=your_github_client_id
GITHUB_CLIENT_SECRET=your_github_client_secret
```

### API Documentation

**If API endpoints were added/modified**:

Update OpenAPI/Swagger documentation:

```yaml
paths:
  /auth/oauth/{provider}:
    get:
      summary: Initiate OAuth authentication
      description: Redirects user to OAuth provider for authentication
      parameters:
        - name: provider
          in: path
          required: true
          schema:
            type: string
            enum: [google, github]
      responses:
        '302':
          description: Redirect to OAuth provider
        '400':
          description: Invalid provider

  /auth/oauth/{provider}/callback:
    get:
      summary: OAuth callback endpoint
      description: Handles OAuth provider redirect after authentication
      parameters:
        - name: provider
          in: path
          required: true
          schema:
            type: string
        - name: code
          in: query
          required: true
          schema:
            type: string
        - name: state
          in: query
          required: true
          schema:
            type: string
      responses:
        '302':
          description: Redirect to application with session
        '401':
          description: Authentication failed
```

### User Documentation

**If feature is user-facing**:

Create or update user guides:

```markdown
# Signing In with Google or GitHub

You can now sign in using your existing Google or GitHub account.

## First Time Sign In

1. Click "Sign in with Google" or "Sign in with GitHub" on the login page
2. Authorize the application to access your profile information
3. You'll be redirected back and automatically signed in

## Linking OAuth Accounts

If you already have an account with email/password:

1. Sign in with your email/password
2. Go to Settings > Connected Accounts
3. Click "Connect Google" or "Connect GitHub"
4. Authorize the connection
5. Your accounts are now linked

## Security

- Your password is never shared with Google or GitHub
- You can disconnect OAuth accounts at any time in Settings
- OAuth tokens are securely encrypted
```

## Step 2: Git Status Check

### Check Changed Files

```bash
git status
```

**Example output**:
```
On branch feature/oauth-authentication
Changes not staged for commit:
  modified:   src/routes/auth.routes.ts
  modified:   package.json
  modified:   .env.example
  
Untracked files:
  src/controllers/auth/oauth.controller.ts
  src/services/auth/oauth.service.ts
  src/services/auth/providers/google-provider.ts
  src/services/auth/providers/github-provider.ts
  tests/integration/oauth.test.ts
```

### Review Changed Files

```bash
git diff --stat
```

**Example output**:
```
.env.example                                        |   4 +
package.json                                        |   3 +
src/controllers/auth/oauth.controller.ts            | 156 ++++++++++++++++++
src/routes/auth.routes.ts                           |  12 +-
src/services/auth/oauth.service.ts                  | 203 ++++++++++++++++++++++
src/services/auth/providers/base-provider.ts        |  18 ++
src/services/auth/providers/google-provider.ts      |  87 ++++++++++
src/services/auth/providers/github-provider.ts      |  91 ++++++++++
tests/integration/oauth.test.ts                     | 142 +++++++++++++++
9 files changed, 712 insertions(+), 4 deletions(-)
```

### Verify No Unintended Changes

- No debug code left in
- No console.log statements
- No commented-out code
- No temporary files
- No secrets in code

## Step 3: Mark Plan as Completed

### Update .opencode/.plan-status.json

**Read existing status**:
```typescript
import fs from 'fs';

const statusFilePath = '.opencode/.plan-status.json';
const status = JSON.parse(fs.readFileSync(statusFilePath, 'utf-8'));
```

**Update plan status**:
```typescript
const featureName = 'oauth-authentication'; // From plan file

status.plans[featureName].status = 'completed';
status.plans[featureName].completed = new Date().toISOString();
status.plans[featureName].implemented = new Date().toISOString();

// Optional: Add implementation metadata
status.plans[featureName].filesChanged = 9;
status.plans[featureName].linesAdded = 712;
status.plans[featureName].linesRemoved = 4;
```

**Write updated status**:
```typescript
fs.writeFileSync(
  statusFilePath,
  JSON.stringify(status, null, 2)
);
```

**Complete example**:
```json
{
  "plans": {
    "oauth-authentication": {
      "filename": "plan-oauth-authentication.md",
      "status": "completed",
      "created": "2026-02-19T10:30:00Z",
      "description": "Add OAuth login with Google and GitHub providers",
      "implemented": "2026-02-19T15:45:00Z",
      "implementedBy": "build-orchestrator",
      "startedAt": "2026-02-19T11:00:00Z",
      "completedAt": "2026-02-19T15:45:00Z",
      "filesChanged": 9,
      "linesAdded": 712,
      "linesRemoved": 4
    }
  }
}
```

### Update Plan File Frontmatter

**Read plan file**:
```typescript
const planFilePath = `plan-${featureName}.md`;
let planContent = fs.readFileSync(planFilePath, 'utf-8');
```

**Update frontmatter**:
```typescript
// Update status
planContent = planContent.replace(
  /^status: .*$/m,
  'status: completed'
);

// Add completed timestamp
const frontmatterEndIndex = planContent.indexOf('---', 4);
const frontmatter = planContent.substring(0, frontmatterEndIndex);

if (!frontmatter.includes('completed:')) {
  planContent = planContent.replace(
    /^---$/m,
    `completed: ${new Date().toISOString()}\n---`
  );
} else {
  planContent = planContent.replace(
    /^completed: .*$/m,
    `completed: ${new Date().toISOString()}`
  );
}
```

**Write updated plan file**:
```typescript
fs.writeFileSync(planFilePath, planContent);
```

**Example plan frontmatter after update**:
```markdown
---
feature: oauth-authentication
status: completed
created: 2026-02-19T10:30:00Z
completed: 2026-02-19T15:45:00Z
description: Add OAuth login with Google and GitHub providers
---
```

## Step 4: Generate Implementation Summary

### Collect Metrics

```typescript
const summary = {
  feature: featureName,
  status: 'completed',
  duration: calculateDuration(
    status.plans[featureName].startedAt,
    status.plans[featureName].completedAt
  ),
  tasks: {
    total: getAllTasks().length,
    completed: getCompletedTasks().length
  },
  files: {
    changed: status.plans[featureName].filesChanged,
    added: getAddedFiles().length,
    modified: getModifiedFiles().length
  },
  lines: {
    added: status.plans[featureName].linesAdded,
    removed: status.plans[featureName].linesRemoved
  },
  tests: {
    total: getTestCount(),
    passing: getPassingTestCount(),
    coverage: getCodeCoverage()
  }
};
```

### Format Summary

```typescript
function formatSummary(summary) {
  return `
✅ Implementation completed: plan-${summary.feature}.md
📊 Status: ${summary.status}
🕐 Duration: ${summary.duration}

📋 Tasks:
  - Total: ${summary.tasks.total}
  - Completed: ${summary.tasks.completed}

📁 Files:
  - Changed: ${summary.files.changed}
  - Added: ${summary.files.added}
  - Modified: ${summary.files.modified}

📝 Code:
  - Lines added: ${summary.lines.added}
  - Lines removed: ${summary.lines.removed}

🧪 Tests:
  - Total: ${summary.tests.total}
  - Passing: ${summary.tests.passing}
  - Coverage: ${summary.tests.coverage}%

✅ All quality gates passed
✅ Security review completed (if applicable)
✅ Performance review completed (if applicable)
✅ Documentation updated

The plan has been marked as completed and will no longer appear in /implement.
`;
}
```

## Step 5: Display to User

### Success Message

```
✅ Implementation completed: plan-oauth-authentication.md
📊 Status: completed
🕐 Duration: 4 hours 45 minutes

📋 Tasks:
  - Total: 12
  - Completed: 12

📁 Files:
  - Changed: 9
  - Added: 6
  - Modified: 3

📝 Code:
  - Lines added: 712
  - Lines removed: 4

🧪 Tests:
  - Total: 45
  - Passing: 45
  - Coverage: 94%

✅ All quality gates passed
✅ Security review completed
✅ Performance review completed
✅ Documentation updated

The plan has been marked as completed and will no longer appear in /implement.

Next steps:
  - Review changes: git diff
  - Commit changes: git add . && git commit -m "Implement OAuth authentication"
  - Create pull request or deploy
```

### Warnings or Considerations (if any)

```
⚠️ Warnings:
  - OAuth requires environment variables to be set in production
  - Database migration must be run before deploying
  - Users who signed up with OAuth cannot use password reset (they don't have passwords)

📚 Documentation:
  - README.md updated with OAuth setup instructions
  - API documentation updated with new endpoints
  - User guide created: docs/oauth-signin.md

🔄 Next Steps:
  - Set up OAuth apps in Google and GitHub consoles
  - Add credentials to production environment variables
  - Run database migration in production
  - Deploy to staging for testing
  - Deploy to production
```

## Complete Completion Example

```typescript
// Step 1: Final Documentation
await Task({
  subagent_type: 'general',
  description: 'Update documentation',
  prompt: `Update documentation for OAuth authentication:
  - Add JSDoc to all public methods
  - Update README with setup instructions
  - Update .env.example with new variables
  - Create user guide for OAuth sign-in`
});

// Step 2: Git Status Check
const gitStatus = await bash({ command: 'git status' });
const gitDiffStat = await bash({ command: 'git diff --stat' });

console.log('Changed files:', gitDiffStat);

// Step 3: Mark Plan as Completed
const statusFilePath = '.opencode/.plan-status.json';
const status = JSON.parse(fs.readFileSync(statusFilePath, 'utf-8'));

const featureName = 'oauth-authentication';
status.plans[featureName].status = 'completed';
status.plans[featureName].completed = new Date().toISOString();
status.plans[featureName].filesChanged = 9;
status.plans[featureName].linesAdded = 712;
status.plans[featureName].linesRemoved = 4;

fs.writeFileSync(statusFilePath, JSON.stringify(status, null, 2));

// Update plan file frontmatter
const planFilePath = `plan-${featureName}.md`;
let planContent = fs.readFileSync(planFilePath, 'utf-8');
planContent = planContent.replace(/^status: .*$/m, 'status: completed');
planContent = planContent.replace(
  /^---$/m,
  `completed: ${new Date().toISOString()}\n---`
);
fs.writeFileSync(planFilePath, planContent);

// Step 4: Generate Summary
const summary = {
  feature: featureName,
  status: 'completed',
  duration: '4 hours 45 minutes',
  tasks: { total: 12, completed: 12 },
  files: { changed: 9, added: 6, modified: 3 },
  lines: { added: 712, removed: 4 },
  tests: { total: 45, passing: 45, coverage: 94 }
};

// Step 5: Display to User
console.log(`
✅ Implementation completed: plan-${summary.feature}.md
📊 Status: ${summary.status}
🕐 Duration: ${summary.duration}

📋 Tasks:
  - Total: ${summary.tasks.total}
  - Completed: ${summary.tasks.completed}

📁 Files:
  - Changed: ${summary.files.changed}
  - Added: ${summary.files.added}
  - Modified: ${summary.files.modified}

📝 Code:
  - Lines added: ${summary.lines.added}
  - Lines removed: ${summary.lines.removed}

🧪 Tests:
  - Total: ${summary.tests.total}
  - Passing: ${summary.tests.passing}
  - Coverage: ${summary.tests.coverage}%

✅ All quality gates passed
✅ Security review completed
✅ Documentation updated

The plan has been marked as completed and will no longer appear in /implement.

Next steps:
  - Review changes: git diff
  - Commit changes: git add . && git commit -m "Implement OAuth authentication"
  - Create pull request or deploy
`);
```

## Best Practices

**DO**:
- ✅ Update all relevant documentation (code, README, API docs, user guides)
- ✅ Verify no unintended changes in git status
- ✅ Mark plan as completed in both status file and plan file
- ✅ Generate comprehensive summary with metrics
- ✅ Provide clear next steps to user
- ✅ Highlight warnings or considerations

**DON'T**:
- ❌ Skip documentation updates
- ❌ Leave debug code or console.log statements
- ❌ Forget to update .env.example
- ❌ Mark plan complete before all tasks done
- ❌ Skip generating summary
- ❌ Leave todos in "in_progress" state

## Checklist

**Before marking complete**:
- [ ] All tasks completed
- [ ] All tests passing
- [ ] Code documentation added (JSDoc/docstrings)
- [ ] README updated (if needed)
- [ ] .env.example updated (if new env vars)
- [ ] API documentation updated (if API changed)
- [ ] User documentation created (if user-facing)
- [ ] No debug code left in
- [ ] Git status reviewed
- [ ] Security review completed (if applicable)
- [ ] Performance review completed (if applicable)

**Status update**:
- [ ] .opencode/.plan-status.json updated
- [ ] plan-*.md frontmatter updated
- [ ] Status set to "completed"
- [ ] Completed timestamp added

**Summary generated**:
- [ ] Tasks count
- [ ] Files changed count
- [ ] Lines added/removed
- [ ] Tests passing count
- [ ] Duration calculated
- [ ] Warnings highlighted (if any)
- [ ] Next steps provided

## Summary

**Completion Workflow Steps**:
1. Final Documentation Updates (code, README, API, user guides)
2. Git Status Check (verify changes, no debug code)
3. Mark Plan as Completed (update status file and plan file)
4. Generate Implementation Summary (tasks, files, lines, tests, duration)
5. Display to User (comprehensive summary with next steps)

**Key Outputs**:
- Updated documentation (multiple types)
- Updated status files (JSON and plan frontmatter)
- Comprehensive summary with metrics
- Clear next steps for deployment

**Quality Checks**:
- All tasks completed
- All tests passing
- All documentation updated
- No debug code
- Security/performance reviews done

Proper completion workflow ensures implementations are fully documented, properly tracked, and ready for deployment.
