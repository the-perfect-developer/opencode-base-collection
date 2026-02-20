# Quality Assurance Guidelines

Comprehensive guidelines for ensuring security, performance, and code quality throughout implementation.

## Overview

Quality assurance is continuous throughout implementation, not just at the end. This reference provides guidelines for security reviews, performance reviews, and code quality checks.

## Security Review Process

### When to Conduct Security Reviews

**ALWAYS review before deploying**:
- Authentication/authorization code
- Input validation logic
- Data encryption/decryption
- API endpoints handling sensitive data
- Password handling
- Session management
- File uploads
- Payment processing
- Any code handling PII (Personally Identifiable Information)

### Security Review Checklist

**Input Validation**:
- [ ] All user inputs are validated
- [ ] Validation happens on both client and server
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (input sanitization)
- [ ] Command injection prevention
- [ ] Path traversal prevention

**Authentication & Authorization**:
- [ ] Passwords are hashed (never stored plain text)
- [ ] Secure password hashing algorithm (bcrypt, argon2)
- [ ] Session tokens are secure and HTTP-only
- [ ] JWT tokens have expiration
- [ ] Authorization checks on all protected endpoints
- [ ] Role-based access control (RBAC) properly implemented

**Data Protection**:
- [ ] Sensitive data encrypted at rest
- [ ] Sensitive data encrypted in transit (HTTPS)
- [ ] Secrets stored in environment variables
- [ ] No secrets in code or version control
- [ ] PII handled according to compliance (GDPR, HIPAA)

**API Security**:
- [ ] Rate limiting implemented
- [ ] CORS configured correctly
- [ ] CSRF protection for state-changing operations
- [ ] API authentication required
- [ ] API authorization checks

**Error Handling**:
- [ ] No sensitive information in error messages
- [ ] Generic error messages for authentication failures
- [ ] Errors logged securely (no sensitive data in logs)

### Security Review with @security-expert

**Before Implementation**:
```typescript
const securityRequirements = await Task({
  subagent_type: 'security-expert',
  description: 'Get security requirements',
  prompt: `Security Review Needed:

Feature: [Feature name]
Description: [What the feature does]

Security Concerns:
- [Concern 1: e.g., handles user passwords]
- [Concern 2: e.g., stores PII]

Data Handled: [Type of data]
Compliance: [GDPR, HIPAA, etc.]

Please provide:
1. Security requirements
2. Potential vulnerabilities
3. Best practices to follow`
});
```

**After Implementation**:
```typescript
const securityReview = await Task({
  subagent_type: 'security-expert',
  description: 'Review implemented security feature',
  prompt: `Security Review:

Feature: [Feature name]
Files changed:
  - [File 1]
  - [File 2]

Implementation summary:
[Brief summary of what was implemented]

Please review for:
1. OWASP Top 10 vulnerabilities
2. Input validation correctness
3. Authentication/authorization correctness
4. Data protection
5. Secure coding practices

Provide feedback and required changes.`
});
```

### Common Security Vulnerabilities to Check

**OWASP Top 10**:
1. **Broken Access Control**: Check authorization on all protected resources
2. **Cryptographic Failures**: Verify proper encryption usage
3. **Injection**: Check for SQL injection, command injection, XSS
4. **Insecure Design**: Review architectural security
5. **Security Misconfiguration**: Check default configs, error messages
6. **Vulnerable Components**: Check for outdated dependencies
7. **Authentication Failures**: Review auth implementation
8. **Data Integrity Failures**: Check data validation and integrity
9. **Logging & Monitoring Failures**: Verify security event logging
10. **Server-Side Request Forgery**: Check SSRF prevention

### Example Security Review

**Feature**: User login API

**Security Checklist**:
```
✅ Password stored as bcrypt hash in database
✅ Password never logged or exposed in errors
✅ Generic error message for invalid credentials
✅ Rate limiting: 5 attempts per minute per IP
✅ HTTPS required for login endpoint
✅ JWT token with 24-hour expiration
✅ HTTP-only, Secure, SameSite cookies
✅ Failed login attempts logged
✅ Input validation: email format, password length
✅ SQL injection prevented (parameterized queries)
```

## Performance Review Process

### When to Conduct Performance Reviews

**ALWAYS review before deploying**:
- Database queries (especially complex joins)
- Caching implementations
- Resource-intensive operations (image processing, file uploads)
- High-traffic endpoints
- Background jobs processing large data
- Real-time features (WebSocket, SSE)

### Performance Review Checklist

**Database Optimization**:
- [ ] Queries use indexes
- [ ] No N+1 query problems
- [ ] Appropriate use of joins vs separate queries
- [ ] Pagination for large result sets
- [ ] Connection pooling configured

**Caching**:
- [ ] Frequently accessed data is cached
- [ ] Cache invalidation strategy defined
- [ ] Cache TTL (Time To Live) appropriate
- [ ] Cache keys are unique and descriptive

**Resource Usage**:
- [ ] Memory usage is bounded (no memory leaks)
- [ ] CPU usage is acceptable
- [ ] File handles are closed properly
- [ ] Network requests are minimized

**Scalability**:
- [ ] Horizontal scaling possible
- [ ] No hard-coded limits that prevent scaling
- [ ] Stateless design where appropriate

**API Performance**:
- [ ] Response time targets met (e.g., <200ms p95)
- [ ] Throughput targets met (e.g., 1000 req/s)
- [ ] Slow endpoints identified and optimized
- [ ] Background jobs for long-running tasks

### Performance Review with @performance-engineer

**Before Implementation**:
```typescript
const performanceGuidance = await Task({
  subagent_type: 'performance-engineer',
  description: 'Get performance guidance',
  prompt: `Performance Guidance Needed:

Feature: [Feature name]
Description: [What the feature does]

Expected Load:
- Concurrent users: [number]
- Requests per second: [number]
- Data volume: [size]

Performance Targets:
- Latency: [target, e.g., <100ms p95]
- Throughput: [target, e.g., 1000 req/s]

Concerns:
- [Concern 1: e.g., complex database query]
- [Concern 2: e.g., large file processing]

Please provide:
1. Optimization strategy
2. Caching recommendations
3. Scalability considerations`
});
```

**After Implementation**:
```typescript
const performanceReview = await Task({
  subagent_type: 'performance-engineer',
  description: 'Review performance implementation',
  prompt: `Performance Review:

Feature: [Feature name]
Files changed:
  - [File 1]
  - [File 2]

Implementation summary:
[Brief summary]

Please review for:
1. Query efficiency
2. Caching correctness
3. Resource usage
4. Scalability
5. Performance targets met

Provide feedback and optimization recommendations.`
});
```

### Example Performance Review

**Feature**: User search API

**Performance Checklist**:
```
✅ Full-text search index on users.name, users.email
✅ Pagination: max 50 results per page
✅ Query uses index for WHERE clause
✅ Results cached for 5 minutes (common searches)
✅ Response time: <150ms p95 (target: <200ms)
✅ Throughput: 500 req/s (target: 1000 req/s)
✅ Connection pooling: max 100 connections
⚠️ Optimization opportunity: Add Redis caching for popular searches
```

## Code Quality Standards

### Code Style Compliance

**Use loaded skills for style**:
- TypeScript → `typescript-style` skill
- JavaScript → `javascript` skill
- Python → `python` skill
- Go → `go` skill
- CSS → `css` skill

**Common Standards**:
- Consistent naming conventions
- Proper indentation and formatting
- No commented-out code
- No console.log or debug statements (use proper logging)
- Meaningful variable and function names

### Code Review Checklist

**Readability**:
- [ ] Code is self-documenting
- [ ] Complex logic has comments explaining "why"
- [ ] Functions are small and focused (single responsibility)
- [ ] Variable names are descriptive

**Maintainability**:
- [ ] No code duplication (DRY principle)
- [ ] Proper error handling
- [ ] Consistent with existing codebase patterns
- [ ] Dependencies are minimal

**Testing**:
- [ ] Unit tests cover critical logic
- [ ] Integration tests for API endpoints
- [ ] Edge cases are tested
- [ ] Tests are readable and maintainable

**Documentation**:
- [ ] Public APIs have JSDoc/docstrings
- [ ] Complex functions have comments
- [ ] README updated if needed
- [ ] API documentation updated

### Automated Quality Checks

**Linting**:
```bash
# TypeScript/JavaScript
npm run lint

# Python
flake8 src/
pylint src/

# Go
golint ./...
```

**Type Checking**:
```bash
# TypeScript
npx tsc --noEmit

# Python
mypy src/

# Go
go vet ./...
```

**Testing**:
```bash
# TypeScript/JavaScript
npm test
npm run test:coverage

# Python
pytest
pytest --cov=src

# Go
go test ./...
go test -cover ./...
```

**Code Formatting**:
```bash
# TypeScript/JavaScript
npm run format

# Python
black src/
isort src/

# Go
go fmt ./...
```

## Continuous Quality Assurance

### During Implementation

**After each task**:
1. Run tests
2. Check type errors
3. Run linter
4. Verify functionality manually

**Before moving to next task**:
1. All tests pass
2. No type errors
3. No lint errors
4. Code reviewed for quality

### Before Committing

**Pre-commit checklist**:
- [ ] All tests pass
- [ ] No type errors
- [ ] No lint errors
- [ ] Code formatted
- [ ] No debug statements
- [ ] Documentation updated
- [ ] Security review (if applicable)
- [ ] Performance review (if applicable)

### Before Deploying

**Pre-deployment checklist**:
- [ ] All tests pass (unit, integration, E2E)
- [ ] Security review completed for security-sensitive code
- [ ] Performance review completed for performance-critical code
- [ ] Code quality standards met
- [ ] Documentation updated
- [ ] Breaking changes documented
- [ ] Migration plan ready (if applicable)
- [ ] Rollback plan ready

## Quality Gates

### Mandatory Quality Gates

**All implementations must pass**:
1. **Tests**: All tests must pass (no skipped tests)
2. **Type Safety**: No type errors
3. **Linting**: No lint errors
4. **Security**: Security review passed (for security-sensitive code)
5. **Performance**: Performance review passed (for performance-critical code)

**Do not proceed if any gate fails**.

### Handling Quality Gate Failures

**If tests fail**:
1. Analyze failure
2. Fix issue
3. Re-run tests
4. Repeat until all pass

**If security review fails**:
1. Address security issues
2. Request re-review from @security-expert
3. Do not deploy until approved

**If performance review fails**:
1. Implement optimizations
2. Request re-review from @performance-engineer
3. Measure performance metrics
4. Do not deploy until targets met

## Example Quality Assurance Workflow

### Feature: OAuth Authentication

**Phase 1: Pre-Implementation**
```typescript
// Security requirements
const securityRequirements = await Task({
  subagent_type: 'security-expert',
  prompt: 'Provide OAuth security requirements'
});

// Architecture design
const architecture = await Task({
  subagent_type: 'architect',
  prompt: 'Design OAuth architecture'
});
```

**Phase 2: Implementation**
```typescript
// Implement feature
const result = await Task({
  subagent_type: 'backend-engineer',
  prompt: `Implement OAuth authentication
  Security: ${securityRequirements}
  Architecture: ${architecture}`
});

// Run tests
await bash({ command: 'npm test' });

// Type check
await bash({ command: 'npx tsc --noEmit' });

// Lint
await bash({ command: 'npm run lint' });
```

**Phase 3: Security Review**
```typescript
const securityReview = await Task({
  subagent_type: 'security-expert',
  prompt: 'Review implemented OAuth code for security'
});

// If issues found, fix and re-review
if (securityReview.issuesFound) {
  // Fix issues
  await Task({
    subagent_type: 'backend-engineer',
    prompt: `Fix security issues: ${securityReview.issues}`
  });
  
  // Re-review
  await Task({
    subagent_type: 'security-expert',
    prompt: 'Re-review OAuth security after fixes'
  });
}
```

**Phase 4: Performance Review**
```typescript
const performanceReview = await Task({
  subagent_type: 'performance-engineer',
  prompt: 'Review OAuth performance'
});

// If optimizations needed
if (performanceReview.optimizationsNeeded) {
  await Task({
    subagent_type: 'backend-engineer',
    prompt: `Optimize: ${performanceReview.recommendations}`
  });
}
```

**Phase 5: Final Quality Check**
```bash
# All tests
npm test

# Coverage check
npm run test:coverage

# Type check
npx tsc --noEmit

# Lint
npm run lint

# Format check
npm run format:check
```

**Quality Gates Passed**: ✅ Ready for deployment

## Best Practices

**DO**:
- ✅ Review security BEFORE and AFTER implementation
- ✅ Review performance for critical code
- ✅ Run automated checks after each task
- ✅ Fix issues immediately (don't accumulate technical debt)
- ✅ Use quality gates as hard requirements
- ✅ Document security and performance decisions

**DON'T**:
- ❌ Skip security reviews for auth/sensitive code
- ❌ Skip performance reviews for high-traffic code
- ❌ Ignore test failures
- ❌ Deploy with type errors or lint errors
- ❌ Skip code quality checks
- ❌ Accumulate technical debt

## Summary

**Quality Assurance is Continuous**:
- Before: Get requirements from experts
- During: Check quality after each task
- After: Comprehensive review before deployment

**Three Pillars**:
1. **Security**: Protect users and data
2. **Performance**: Meet latency and throughput targets
3. **Code Quality**: Maintain readable, maintainable code

**Quality Gates** (must pass):
- All tests pass
- No type errors
- No lint errors
- Security review passed (if applicable)
- Performance review passed (if applicable)

**Expert Consultation**:
- @security-expert: Before and after security-sensitive implementations
- @performance-engineer: Before and after performance-critical implementations
- @architect: Before complex architectural changes

Following these guidelines ensures high-quality, secure, performant implementations that are maintainable long-term.
