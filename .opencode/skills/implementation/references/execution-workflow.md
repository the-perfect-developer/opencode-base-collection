# Execution Workflow

Detailed step-by-step workflow for executing implementation tasks with specialized agents.

## Overview

This reference provides the complete workflow for executing each task in an implementation plan, from pre-implementation consultation through verification.

## Complete Task Execution Flow

```
1. Pre-Implementation Consultation
   ↓
2. Task Assignment
   ↓
3. Skill Loading
   ↓
4. Documentation & Research
   ↓
5. Implementation
   ↓
6. Verification
   ↓
7. Mark Todo Complete
```

## Step 1: Pre-Implementation Consultation

### For Simple Tasks

Skip consultation, proceed directly to assignment.

**Examples**:
- Add utility function
- Fix typo
- Update config file
- Simple bug fix

### For Complex Tasks

Consult appropriate experts:

**Architecture Consultation**:
```typescript
const architectureDecision = await Task({
  subagent_type: 'architect',
  description: 'Get architectural guidance',
  prompt: `Architectural Decision Needed:

Feature: [Feature name]
Question: [Specific architectural question]
Context: [Relevant context from plan]

Options Considered:
1. [Option 1] - [Pros/Cons]
2. [Option 2] - [Pros/Cons]

Constraints:
- [Constraint 1]
- [Constraint 2]

Please provide architectural recommendation.`
});
```

**Security Consultation** (for security-sensitive tasks):
```typescript
const securityGuidance = await Task({
  subagent_type: 'security-expert',
  description: 'Get security guidance',
  prompt: `Security Review Needed:

Feature: [Feature name]
Task: [Specific task]

Security Concerns:
- [Concern 1: e.g., user authentication]
- [Concern 2: e.g., password storage]

Data Handled: [PII, credentials, payment info, etc.]
Compliance Requirements: [GDPR, HIPAA, etc.]

Please provide security requirements and best practices.`
});
```

**Performance Consultation** (for performance-critical tasks):
```typescript
const performanceGuidance = await Task({
  subagent_type: 'performance-engineer',
  description: 'Get performance guidance',
  prompt: `Performance Review Needed:

Feature: [Feature name]
Task: [Specific task]

Expected Load:
- Concurrent users: [number]
- Requests per second: [number]
- Data volume: [size]

Performance Targets:
- Latency: [target, e.g., <100ms p95]
- Throughput: [target, e.g., 1000 req/s]

Concerns:
- [Concern 1: e.g., database query performance]
- [Concern 2: e.g., memory usage]

Please provide optimization strategy.`
});
```

### When to Consult Multiple Experts

For complex features, consult multiple experts in sequence:

```typescript
// Example: OAuth authentication
const architectureDecision = await Task({
  subagent_type: 'architect',
  prompt: 'Design OAuth authentication architecture'
});

const securityRequirements = await Task({
  subagent_type: 'security-expert',
  prompt: `Review OAuth architecture for security:
  Architecture: ${architectureDecision}
  Provide security requirements and potential vulnerabilities.`
});

// Now ready for implementation with both architecture and security guidance
```

## Step 2: Task Assignment

### Create Task Prompt

**Template**:
```
Task: [Specific task from plan]

Context: [Relevant context from plan and consultations]

Requirements:
  - [Requirement 1]
  - [Requirement 2]
  - [Requirement 3]

Files to modify:
  - [File path 1]
  - [File path 2]

Files to create:
  - [New file path 1]
  - [New file path 2]

Architectural Guidance: [From @architect if consulted]
Security Requirements: [From @security-expert if consulted]
Performance Targets: [From @performance-engineer if consulted]

Success Criteria:
  - [How to verify completion]
  - [Expected behavior]
  - [Tests that should pass]
```

### Example Task Prompts

**Example 1: Simple Task**
```typescript
await Task({
  subagent_type: 'junior-engineer',
  description: 'Add date utility function',
  prompt: `Task: Create a date formatting utility function

Context: Need to format dates consistently across the application

Requirements:
  - Function name: formatDate
  - Input: Date object
  - Output: String in format "YYYY-MM-DD HH:mm:ss"
  - Handle null/undefined gracefully

Files to create:
  - src/utils/date.ts

Success Criteria:
  - Function exports formatDate
  - Returns correctly formatted string
  - Handles edge cases (null, undefined, invalid dates)`
});
```

**Example 2: Frontend Task**
```typescript
await Task({
  subagent_type: 'frontend-engineer',
  description: 'Create login form component',
  prompt: `Task: Create login form component

Context: Users need to log in with email/password

Requirements:
  - Form fields: email (input type="email"), password (input type="password")
  - Submit button: "Sign In"
  - Client-side validation: email format, password min 8 characters
  - Show validation errors
  - Call POST /api/auth/login on submit
  - Handle success (redirect to /dashboard) and error (show message)

Files to create:
  - src/components/LoginForm.tsx
  - src/components/LoginForm.test.tsx

Security Requirements:
  - Do not log password in console/errors
  - Use HTTPS for form submission
  - Validate email format before submission

Success Criteria:
  - Form renders with all fields
  - Validation works client-side
  - API called correctly on submit
  - Tests pass`
});
```

**Example 3: Backend Task with Security**
```typescript
await Task({
  subagent_type: 'backend-engineer',
  description: 'Implement login API endpoint',
  prompt: `Task: Implement POST /api/auth/login endpoint

Context: Authenticate users with email/password

Requirements:
  - Endpoint: POST /api/auth/login
  - Input: { email: string, password: string }
  - Output: { token: string, user: { id, email, name } }
  - Validate credentials against database
  - Generate JWT token on success
  - Return 401 for invalid credentials
  - Rate limit: 5 attempts per minute per IP

Files to modify:
  - src/routes/auth.routes.ts (add route)

Files to create:
  - src/controllers/auth.controller.ts (login method)
  - src/controllers/auth.controller.test.ts (tests)

Security Requirements (from @security-expert):
  - Hash passwords with bcrypt (already done in DB)
  - Use bcrypt.compare() for password verification
  - Do not reveal whether email or password is incorrect (generic "Invalid credentials")
  - Implement rate limiting with express-rate-limit
  - Set secure HTTP-only cookie for JWT
  - Token expiration: 24 hours
  - Log failed login attempts

Performance Targets:
  - Latency: <200ms p95
  - Support 100 concurrent logins

Success Criteria:
  - Endpoint returns 200 with token for valid credentials
  - Endpoint returns 401 for invalid credentials
  - Rate limiting works (6th attempt in 1 minute returns 429)
  - JWT token is valid and contains user info
  - Tests pass`
});
```

## Step 3: Skill Loading

Load appropriate skills before implementation.

### Technology Detection

Detect technology from file paths:

```typescript
const files = [
  'src/components/LoginForm.tsx',
  'src/utils/date.ts'
];

const skills = [];

// TypeScript files
if (files.some(f => f.endsWith('.ts') || f.endsWith('.tsx'))) {
  skills.push('typescript-style');
}

// React files  
if (files.some(f => f.endsWith('.tsx'))) {
  skills.push('react'); // if available
}

// CSS files
if (files.some(f => f.endsWith('.css'))) {
  skills.push('css');
}

// Load skills
for (const skill of skills) {
  await Skill({ name: skill });
}
```

### Common Skill Mappings

| File Extension | Skill to Load |
|----------------|---------------|
| `.ts`, `.tsx` | `typescript-style` |
| `.js`, `.jsx` | `javascript` |
| `.py` | `python` |
| `.go` | `go` |
| `.css` | `css` |
| `.html` | `html` |
| Tailwind classes | `tailwind-css` |
| Alpine.js directives | `alpinejs` |

## Step 4: Documentation & Research

### When to Web Search

**Always search for**:
- Third-party library documentation
- Framework-specific patterns
- Current best practices
- Known issues or gotchas

**Example searches**:
```typescript
// OAuth implementation
const oauthDocs = await WebFetch({
  url: 'https://oauth.net/2/',
  format: 'markdown'
});

// Passport.js documentation
const passportDocs = await WebFetch({
  url: 'https://www.passportjs.org/docs/',
  format: 'markdown'
});

// JWT best practices
const jwtBestPractices = await WebFetch({
  url: 'https://jwt.io/introduction',
  format: 'markdown'
});
```

### Search Strategy

1. **Check official docs first**
   - Framework documentation
   - Library API references

2. **Verify version compatibility**
   - Check package version in package.json
   - Search for that specific version's docs

3. **Look for current best practices**
   - Avoid outdated blog posts
   - Prefer official sources

4. **Find relevant code examples**
   - GitHub repositories
   - Official examples

## Step 5: Implementation

### Launch Agent with Full Context

```typescript
const result = await Task({
  subagent_type: '[selected-agent]',
  description: '[brief description]',
  prompt: `[Complete task prompt from Step 2]

Loaded Skills: [List of skills loaded]
Documentation: [Summary of key points from research]

Implement this task following the requirements and best practices above.`
});
```

### Monitor Progress

If using TodoWrite for tracking:

```typescript
// Before implementation
TodoWrite([
  { content: 'Implement login endpoint', status: 'in_progress', priority: 'high' }
]);

// After implementation
TodoWrite([
  { content: 'Implement login endpoint', status: 'completed', priority: 'high' }
]);
```

## Step 6: Verification

### Run Tests

```bash
# TypeScript/JavaScript
npm test

# Python
pytest

# Go
go test ./...
```

### Check Type Errors

```bash
# TypeScript
npx tsc --noEmit

# Python
mypy src/
```

### Run Linter

```bash
# TypeScript/JavaScript
npm run lint

# Python
flake8 src/

# Go
golint ./...
```

### Verify Functionality

**Manual verification**:
1. Run application locally
2. Test the implemented feature
3. Verify expected behavior
4. Check error handling

### Security Verification (for security-sensitive tasks)

After implementation, consult security expert:

```typescript
const securityReview = await Task({
  subagent_type: 'security-expert',
  description: 'Review implemented security feature',
  prompt: `Security Review:

Feature: [Feature name]
Implementation: [Summary of what was implemented]

Files changed:
  - [File 1]
  - [File 2]

Please review the implementation for:
  - Security vulnerabilities
  - OWASP Top 10 compliance
  - Input validation
  - Authentication/authorization correctness
  - Data protection

Provide feedback and required changes.`
});
```

### Performance Verification (for performance-critical tasks)

After implementation, consult performance engineer:

```typescript
const performanceReview = await Task({
  subagent_type: 'performance-engineer',
  description: 'Review implemented performance optimization',
  prompt: `Performance Review:

Feature: [Feature name]
Implementation: [Summary of what was implemented]

Files changed:
  - [File 1]
  - [File 2]

Please review the implementation for:
  - Query efficiency
  - Caching correctness
  - Resource usage
  - Scalability
  - Performance targets met

Provide feedback and optimization recommendations.`
});
```

## Step 7: Mark Todo Complete

Update todo status immediately after verification:

```typescript
TodoWrite([
  { content: '[Task description]', status: 'completed', priority: 'high' }
]);
```

## Complete Workflow Examples

### Example 1: Simple Task - Add Utility Function

```typescript
// Step 1: Pre-Implementation (skip for simple task)
// Step 2: Task Assignment
// Step 3: Skill Loading
await Skill({ name: 'typescript-style' });

// Step 4: Documentation (skip for simple task)

// Step 5: Implementation
const result = await Task({
  subagent_type: 'junior-engineer',
  description: 'Add date utility function',
  prompt: `Task: Create formatDate utility function
  
Requirements:
  - Function: formatDate(date: Date): string
  - Format: "YYYY-MM-DD HH:mm:ss"
  - Handle null/undefined gracefully
  
Files to create:
  - src/utils/date.ts
  - src/utils/date.test.ts

Success Criteria:
  - Function works correctly
  - Tests pass`
});

// Step 6: Verification
await bash({ command: 'npm test src/utils/date.test.ts' });
await bash({ command: 'npx tsc --noEmit' });

// Step 7: Mark Complete
TodoWrite([
  { content: 'Add date utility function', status: 'completed', priority: 'medium' }
]);
```

**Timeline**: ~5 minutes

### Example 2: Complex Task - OAuth Authentication

```typescript
// Step 1: Pre-Implementation Consultation
const architecture = await Task({
  subagent_type: 'architect',
  description: 'Design OAuth architecture',
  prompt: 'Design OAuth 2.0 authentication architecture for Google/GitHub providers'
});

const securityRequirements = await Task({
  subagent_type: 'security-expert',
  description: 'OAuth security requirements',
  prompt: `Review OAuth architecture for security requirements:
  Architecture: ${architecture}`
});

// Step 2: Task Assignment (prompt created with guidance)
const taskPrompt = `Task: Implement OAuth authentication

Architecture: ${architecture}
Security Requirements: ${securityRequirements}

[... rest of detailed prompt ...]`;

// Step 3: Skill Loading
await Skill({ name: 'typescript-style' });

// Step 4: Documentation & Research
const passportDocs = await WebFetch({
  url: 'https://www.passportjs.org/packages/passport-google-oauth20/',
  format: 'markdown'
});

// Step 5: Implementation
const result = await Task({
  subagent_type: 'backend-engineer',
  description: 'Implement OAuth authentication',
  prompt: `${taskPrompt}

Documentation: ${passportDocs}

Implement according to architecture and security requirements.`
});

// Step 6: Verification
await bash({ command: 'npm test' });
await bash({ command: 'npx tsc --noEmit' });

// Security review after implementation
const securityReview = await Task({
  subagent_type: 'security-expert',
  description: 'Review OAuth implementation',
  prompt: 'Review implemented OAuth code for security issues'
});

// Step 7: Mark Complete
TodoWrite([
  { content: 'Implement OAuth authentication', status: 'completed', priority: 'high' }
]);
```

**Timeline**: ~25 minutes

### Example 3: Frontend + Backend Parallel

```typescript
// Step 1: Pre-Implementation
const apiContract = await Task({
  subagent_type: 'architect',
  description: 'Define API contract',
  prompt: 'Define API contract for user login'
});

// Step 2: Task Assignment (two tasks)
const frontendPrompt = `Task: Implement login UI
API Contract: ${apiContract}
[... requirements ...]`;

const backendPrompt = `Task: Implement login API
API Contract: ${apiContract}
[... requirements ...]`;

// Step 3: Skill Loading
await Promise.all([
  Skill({ name: 'typescript-style' }),
  Skill({ name: 'react' })
]);

// Step 4: Documentation (parallel)
const [reactDocs, expressDocs] = await Promise.all([
  WebFetch({ url: 'https://react.dev/learn', format: 'markdown' }),
  WebFetch({ url: 'https://expressjs.com/en/api.html', format: 'markdown' })
]);

// Step 5: Implementation (parallel)
const [frontendResult, backendResult] = await Promise.all([
  Task({
    subagent_type: 'frontend-engineer',
    description: 'Implement login UI',
    prompt: frontendPrompt
  }),
  Task({
    subagent_type: 'backend-engineer',
    description: 'Implement login API',
    prompt: backendPrompt
  })
]);

// Step 6: Verification
await bash({ command: 'npm test' });
await bash({ command: 'npx tsc --noEmit' });

// Security review for API
await Task({
  subagent_type: 'security-expert',
  description: 'Review login API security',
  prompt: 'Review login API implementation for security issues'
});

// Step 7: Mark Complete
TodoWrite([
  { content: 'Implement login UI', status: 'completed', priority: 'high' },
  { content: 'Implement login API', status: 'completed', priority: 'high' }
]);
```

**Timeline**: ~15 minutes (vs 25 minutes sequential)

## Best Practices

**DO**:
- ✅ Consult experts before complex implementations
- ✅ Load appropriate skills based on technology
- ✅ Web search for official documentation
- ✅ Provide complete context to agents
- ✅ Verify implementation thoroughly
- ✅ Get security/performance reviews for critical code
- ✅ Mark todos complete immediately

**DON'T**:
- ❌ Skip expert consultation for complex/sensitive tasks
- ❌ Forget to load skills
- ❌ Implement without researching best practices
- ❌ Assign tasks with incomplete requirements
- ❌ Skip verification steps
- ❌ Deploy security-critical code without review
- ❌ Leave todos in "in_progress" state

## Summary

**Workflow Steps**:
1. Pre-Implementation Consultation (complex tasks only)
2. Task Assignment (clear, detailed prompts)
3. Skill Loading (based on technology)
4. Documentation & Research (web search)
5. Implementation (assign to agent)
6. Verification (tests, security, performance)
7. Mark Todo Complete (immediately)

**Key Principles**:
- Consult experts early for complex/sensitive tasks
- Provide complete context to agents
- Load skills before implementation
- Research best practices
- Verify thoroughly
- Track progress with todos

**Timeline Examples**:
- Simple task: ~5 minutes
- Complex task: ~25 minutes
- Parallel tasks: ~15 minutes (vs 25+ sequential)

Following this workflow ensures high-quality implementations that are secure, performant, and maintainable.
