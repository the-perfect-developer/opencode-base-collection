# Agent Selection Guide

Comprehensive rules for selecting the right specialized agent for each task type during implementation.

## Available Specialized Agents

### @junior-engineer
**Specialization**: Fast, focused implementation of small features, bug fixes, and straightforward tasks

**Strengths**:
- Quick implementation of well-defined tasks
- Simple CRUD operations
- Utility functions
- Basic file modifications
- Straightforward bug fixes

**Limitations**:
- Not suitable for complex architectural decisions
- Limited to tasks under ~100 lines of code
- Should not handle security-critical code
- Not for performance optimization

### @frontend-engineer
**Specialization**: Frontend Engineer & UI/UX Specialist

**Strengths**:
- User interface implementation
- React/Vue/Angular components
- CSS and responsive design
- Accessibility (WCAG compliance)
- Client-side state management
- Frontend routing
- User experience optimization

**Limitations**:
- Not for backend API implementation
- Limited database knowledge
- Not for server-side logic

### @backend-engineer
**Specialization**: Backend Engineer - APIs, database operations, services

**Strengths**:
- RESTful/GraphQL API implementation
- Service layer logic
- Database operations and queries
- Server-side validation
- Background jobs and workers
- Third-party API integrations
- Business logic implementation

**Limitations**:
- Not for architectural decisions (consult @architect first)
- Not for security design (consult @security-expert)
- Not for performance optimization strategy (consult @performance-engineer)

### @architect
**Specialization**: Software Architect - System design, architectural patterns, design decisions

**Strengths**:
- System architecture design
- Design pattern selection
- Cross-cutting concerns
- Module/service boundaries
- Technology stack decisions
- Refactoring strategies
- Scalability design

**When to consult**:
- Before major structural changes
- When choosing architectural patterns
- For complex refactoring plans
- When designing cross-cutting concerns
- Before making technology choices

### @security-expert
**Specialization**: Security & Cryptography Specialist

**Strengths**:
- Security audits and threat modeling
- Authentication and authorization design
- Cryptography implementation
- Input validation strategies
- Secure coding practices
- Compliance requirements (OWASP, SOC2, HIPAA)
- Secrets management

**When to consult** (ALWAYS):
- Authentication/authorization implementation
- Input validation logic
- Data encryption/decryption
- API security
- Secrets management
- Any security-sensitive code paths
- Before implementing security features
- After implementing security features (review)

### @performance-engineer
**Specialization**: Performance Optimization & Efficiency Specialist

**Strengths**:
- Performance profiling and benchmarking
- Algorithm optimization
- Database query optimization
- Caching strategies
- Resource usage optimization
- Scalability analysis
- Performance testing

**When to consult** (ALWAYS):
- Database query optimization
- Caching implementation
- Resource-intensive operations
- High-traffic endpoints
- Scalability concerns
- Performance-critical code paths
- Before implementing performance-sensitive features
- After implementing (review)

## Agent Selection Decision Tree

### Step 1: Identify Task Category

**Is it an architectural decision?**
- YES → Consult **@architect** first
- NO → Continue to Step 2

**Is it security-related?**
- YES → Consult **@security-expert** (always)
- NO → Continue to Step 3

**Is it performance-critical?**
- YES → Consult **@performance-engineer** (always)
- NO → Continue to Step 4

### Step 2: Determine Complexity

**Simple task** (< 50 lines, single file, well-defined)?
- YES → **@junior-engineer**
- NO → Continue to Step 3

**Medium complexity** (< 200 lines, few files, clear requirements)?
- YES → Continue to Step 3
- NO → Consult **@architect** first

### Step 3: Determine Domain

**Frontend/UI task?**
- YES → **@frontend-engineer**
- NO → Continue

**Backend/API task?**
- YES → **@backend-engineer**
- NO → Consult **@architect**

## Task Type Matrix

| Task Type | Primary Agent | Consult First | Consult After |
|-----------|---------------|---------------|---------------|
| **Simple Tasks** |
| Add utility function | @junior-engineer | - | - |
| Fix simple bug | @junior-engineer | - | - |
| Update config file | @junior-engineer | - | - |
| Add simple validation | @junior-engineer | - | @security-expert |
| **Frontend Tasks** |
| Create UI component | @frontend-engineer | - | - |
| Style existing component | @frontend-engineer | - | - |
| Add form validation | @frontend-engineer | - | @security-expert |
| Implement routing | @frontend-engineer | @architect (if complex) | - |
| Add accessibility | @frontend-engineer | - | - |
| State management | @frontend-engineer | @architect (if complex) | - |
| **Backend Tasks** |
| Create API endpoint | @backend-engineer | @architect (if complex) | @security-expert |
| Database query | @backend-engineer | - | @performance-engineer |
| Service layer logic | @backend-engineer | - | - |
| Background job | @backend-engineer | @architect (if complex) | @performance-engineer |
| Third-party integration | @backend-engineer | @architect | @security-expert |
| Data validation | @backend-engineer | - | @security-expert |
| **Security Tasks** |
| Authentication | @backend-engineer | @security-expert, @architect | @security-expert |
| Authorization | @backend-engineer | @security-expert, @architect | @security-expert |
| Input sanitization | @backend-engineer | @security-expert | @security-expert |
| Encryption | @backend-engineer | @security-expert | @security-expert |
| API security | @backend-engineer | @security-expert | @security-expert |
| Secrets management | @backend-engineer | @security-expert | @security-expert |
| **Performance Tasks** |
| Query optimization | @backend-engineer | @performance-engineer | @performance-engineer |
| Caching | @backend-engineer | @performance-engineer, @architect | @performance-engineer |
| Algorithm optimization | @backend-engineer | @performance-engineer | @performance-engineer |
| Load balancing | @architect | @performance-engineer | @performance-engineer |
| Resource optimization | @backend-engineer | @performance-engineer | @performance-engineer |
| **Architectural Tasks** |
| Refactoring | @architect | - | - |
| Module design | @architect | - | - |
| Pattern selection | @architect | - | - |
| Technology choice | @architect | @performance-engineer | - |
| Service boundaries | @architect | - | - |
| Database design | @architect | - | @performance-engineer |

## Detailed Task Examples

### Simple Tasks → @junior-engineer

**Example 1: Add utility function**
```
Task: Create a date formatting utility function
Complexity: Low (< 50 lines, single file)
Agent: @junior-engineer
Consult: None
```

**Example 2: Fix typo in error message**
```
Task: Fix typo in validation error message
Complexity: Trivial (single line)
Agent: @junior-engineer
Consult: None
```

**Example 3: Update configuration**
```
Task: Add new environment variable to .env.example
Complexity: Low (single file, no logic)
Agent: @junior-engineer
Consult: None
```

### Frontend Tasks → @frontend-engineer

**Example 1: Create login form component**
```
Task: Create login form with email/password fields
Complexity: Medium (UI component, validation)
Agent: @frontend-engineer
Consult: None initially, @security-expert after (for validation review)
```

**Example 2: Add responsive design**
```
Task: Make dashboard responsive for mobile devices
Complexity: Medium (CSS changes, multiple files)
Agent: @frontend-engineer
Consult: None
```

**Example 3: Implement dark mode**
```
Task: Add dark mode toggle with theme persistence
Complexity: Medium-High (state management, multiple files)
Agent: @frontend-engineer
Consult: @architect if state management is complex
```

### Backend Tasks → @backend-engineer

**Example 1: Create REST API endpoint**
```
Task: Create GET /api/users/:id endpoint
Complexity: Medium (API, validation, database query)
Agent: @backend-engineer
Consult: @architect if part of larger API design
Review: @security-expert (input validation), @performance-engineer (if query is complex)
```

**Example 2: Implement background job**
```
Task: Create daily report generation job
Complexity: Medium-High (job queue, data processing)
Agent: @backend-engineer
Consult: @architect (job queue design), @performance-engineer (data volume)
```

**Example 3: Add database migration**
```
Task: Add 'avatar_url' column to users table
Complexity: Low-Medium (schema change)
Agent: @backend-engineer
Consult: @architect if schema change is significant
```

### Security-Critical Tasks → Consult @security-expert

**Example 1: OAuth authentication**
```
Task: Implement OAuth2 authentication with Google
Complexity: High (security-critical)
Workflow:
  1. Consult @security-expert for security requirements
  2. Consult @architect for design
  3. Assign to @backend-engineer for implementation
  4. Review with @security-expert before deploying
```

**Example 2: Input validation**
```
Task: Add input validation for user profile updates
Complexity: Medium (security-sensitive)
Workflow:
  1. Consult @security-expert for validation strategy
  2. Assign to @backend-engineer for implementation
  3. Review with @security-expert
```

**Example 3: API key management**
```
Task: Implement API key rotation system
Complexity: High (security-critical)
Workflow:
  1. Consult @security-expert for security design
  2. Consult @architect for architecture
  3. Assign to @backend-engineer for implementation
  4. Review with @security-expert
```

### Performance-Critical Tasks → Consult @performance-engineer

**Example 1: Database query optimization**
```
Task: Optimize slow user search query
Complexity: Medium (performance-critical)
Workflow:
  1. Consult @performance-engineer for profiling and strategy
  2. Assign to @backend-engineer for implementation
  3. Review with @performance-engineer
```

**Example 2: Implement caching**
```
Task: Add Redis caching for frequently accessed data
Complexity: High (performance-critical, architectural)
Workflow:
  1. Consult @architect for caching strategy
  2. Consult @performance-engineer for cache configuration
  3. Assign to @backend-engineer for implementation
  4. Review with @performance-engineer
```

**Example 3: Optimize image processing**
```
Task: Optimize image upload and thumbnail generation
Complexity: Medium-High (performance-critical)
Workflow:
  1. Consult @performance-engineer for optimization strategy
  2. Assign to @backend-engineer for implementation
  3. Review with @performance-engineer
```

### Architectural Tasks → Consult @architect

**Example 1: Refactor to microservices**
```
Task: Split monolith into user service and auth service
Complexity: Very High (architectural)
Workflow:
  1. @architect designs service boundaries and communication
  2. Review design with @security-expert (service auth)
  3. Review with @performance-engineer (inter-service communication)
  4. Assign implementation to @backend-engineer
```

**Example 2: Add event sourcing**
```
Task: Implement event sourcing for audit trail
Complexity: Very High (architectural)
Workflow:
  1. @architect designs event sourcing pattern
  2. Review with @performance-engineer (event storage)
  3. Assign implementation to @backend-engineer
```

## Agent Communication Templates

### Assigning to @junior-engineer

```
Task: [Simple, well-defined task]
Files: [Specific file paths]
Requirements:
  - [Specific requirement 1]
  - [Specific requirement 2]
Success Criteria:
  - [How to verify completion]
Estimated Complexity: Low (< 50 lines)
```

### Assigning to @frontend-engineer

```
Task: [UI/UX task description]
Component: [Component name or location]
Design: [Link to mockup or description]
Requirements:
  - [Requirement 1]
  - [Requirement 2]
Accessibility: [WCAG level if applicable]
Success Criteria:
  - [Verification steps]
```

### Assigning to @backend-engineer

```
Task: [Backend task description]
Endpoint/Service: [Specific endpoint or service]
Input: [Expected input format]
Output: [Expected output format]
Database: [Schema changes if needed]
Requirements:
  - [Requirement 1]
  - [Requirement 2]
Success Criteria:
  - [Verification steps]
  - [Test cases]
```

### Consulting @architect

```
Architectural Decision Needed:
Question: [Specific architectural question]
Context: [Relevant context]
Options Considered:
  1. [Option 1] - [Pros/Cons]
  2. [Option 2] - [Pros/Cons]
Constraints:
  - [Constraint 1]
  - [Constraint 2]
Request: Please provide architectural guidance
```

### Consulting @security-expert

```
Security Review Needed:
Feature: [Feature being implemented]
Security Concerns:
  - [Concern 1]
  - [Concern 2]
Data Handled: [Type of data: PII, credentials, etc.]
Compliance: [GDPR, HIPAA, etc. if applicable]
Request: Please review security implications and provide guidance
```

### Consulting @performance-engineer

```
Performance Review Needed:
Feature: [Feature being implemented]
Expected Load: [Users, requests/sec, data volume]
Performance Target: [Latency, throughput targets]
Concerns:
  - [Concern 1]
  - [Concern 2]
Request: Please review and provide optimization guidance
```

## Common Mistakes to Avoid

### ❌ Mistake 1: Assigning Complex Tasks to @junior-engineer

**Bad**:
```
Task: Implement OAuth2 authentication system
Agent: @junior-engineer
```

**Good**:
```
Task: Implement OAuth2 authentication system
Consult: @architect (design), @security-expert (security)
Agent: @backend-engineer
Review: @security-expert
```

### ❌ Mistake 2: Skipping Security Consultation

**Bad**:
```
Task: Add user password reset feature
Agent: @backend-engineer
```

**Good**:
```
Task: Add user password reset feature
Consult: @security-expert (security requirements)
Agent: @backend-engineer
Review: @security-expert (security review)
```

### ❌ Mistake 3: Forgetting Performance Review

**Bad**:
```
Task: Implement user search with full-text search
Agent: @backend-engineer
```

**Good**:
```
Task: Implement user search with full-text search
Consult: @performance-engineer (indexing strategy)
Agent: @backend-engineer
Review: @performance-engineer (query optimization)
```

### ❌ Mistake 4: Making Architectural Decisions Without @architect

**Bad**:
```
Task: Refactor to use event-driven architecture
Agent: @backend-engineer
```

**Good**:
```
Task: Refactor to use event-driven architecture
Consult: @architect (design event system)
Review: @performance-engineer (event throughput)
Agent: @backend-engineer (implementation)
```

## Summary

**Agent Selection Principles**:
1. **Consult experts early** - Architecture, security, performance
2. **Match complexity to agent** - Simple tasks to junior, complex to specialists
3. **Domain expertise matters** - Frontend vs backend specialists
4. **Always review security** - No exceptions for security-critical code
5. **Always review performance** - For performance-critical code
6. **Verify after implementation** - Tests, security, performance

**Quick Decision**:
- Simple & well-defined → @junior-engineer
- UI/UX → @frontend-engineer
- API/Backend → @backend-engineer
- Architecture → @architect
- Security → Consult @security-expert (always)
- Performance → Consult @performance-engineer (always)

**Golden Rule**: When in doubt, consult the expert first. It's faster to get it right the first time than to fix security or performance issues later.
