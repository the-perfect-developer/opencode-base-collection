# Agent Coordination Strategies

Strategies for using specialized agents in parallel to maximize efficiency during the planning process.

## Overview

Specialized agents can analyze different aspects of a feature simultaneously. This reference explains when and how to coordinate multiple agents for efficient planning.

## Available Specialized Agents

### 1. Architecture Agent (`architect`)
**Focus**: System design, architectural patterns, design decisions, complex backend logic

**Use when**:
- Feature requires significant architectural decisions
- Need to design new components or modules
- Need to evaluate different design patterns
- System integration complexity is high

**Example tasks**:
- Design microservice boundaries
- Choose database schema design
- Design API contract between services
- Evaluate monolith vs microservices

### 2. Security Agent (`security-expert`)
**Focus**: Security audits, threat modeling, cryptography, authentication, authorization

**Use when**:
- Feature handles sensitive data (PII, credentials, payment info)
- Authentication or authorization logic changes
- Compliance requirements exist (GDPR, HIPAA, SOC2)
- Need to evaluate security implications

**Example tasks**:
- Identify security vulnerabilities in design
- Recommend encryption strategies
- Design secure authentication flows
- Evaluate OWASP Top 10 considerations

### 3. Performance Agent (`performance-engineer`)
**Focus**: Profiling, benchmarking, algorithm optimization, performance analysis

**Use when**:
- Performance is a critical requirement
- Feature processes large data volumes
- High concurrency expected
- Need to optimize existing slow operations

**Example tasks**:
- Identify performance bottlenecks
- Recommend caching strategies
- Optimize database queries
- Design for horizontal scalability

### 4. Frontend Agent (`frontend-engineer`)
**Focus**: UI/UX, React/Vue/Angular, accessibility, responsive design, user experience

**Use when**:
- Feature has user-facing components
- Need to design UI flows
- Accessibility requirements exist
- Need to evaluate different UI frameworks

**Example tasks**:
- Design component hierarchy
- Plan state management approach
- Evaluate accessibility compliance
- Design responsive layouts

### 5. Backend Agent (`backend-engineer`)
**Focus**: Backend features, APIs, database operations, services

**Use when**:
- Feature is primarily backend logic
- Need to design API endpoints
- Database operations are complex
- Need to integrate with external services

**Example tasks**:
- Design RESTful API endpoints
- Plan database migrations
- Design background job processing
- Plan third-party API integrations

### 6. Explore Agent (`explore`)
**Focus**: Fast codebase exploration, finding patterns, searching code

**Use when**:
- Need to understand existing codebase structure
- Looking for similar implementations
- Need to identify integration points
- Want to find existing patterns to follow

**Example tasks**:
- Find all authentication-related files
- Identify existing API patterns
- Locate database schema definitions
- Find similar features for reference

## Coordination Patterns

### Pattern 1: Parallel Independent Analysis

**When to use**: Different agents analyze independent aspects simultaneously

**Structure**:
```
Launch in parallel:
- Frontend Agent: Analyze UI requirements
- Backend Agent: Analyze API requirements  
- Security Agent: Analyze security implications
```

**Example scenario**: OAuth authentication feature
```
Parallel tasks:
1. Frontend Agent: Design OAuth login button placement and flow
2. Backend Agent: Design OAuth callback endpoint and token exchange
3. Security Agent: Evaluate OAuth security best practices and CSRF protection
```

**Benefits**:
- Fastest approach (3x speedup in this example)
- Agents work independently with no conflicts
- Results can be combined into comprehensive plan

### Pattern 2: Sequential Dependent Analysis

**When to use**: Later agents need results from earlier agents

**Structure**:
```
1. Architecture Agent: Design high-level architecture
   ↓
2. Launch in parallel:
   - Frontend Agent: Implement UI based on architecture
   - Backend Agent: Implement API based on architecture
```

**Example scenario**: New data export feature
```
Sequential tasks:
1. Architecture Agent: Decide on export architecture (sync vs async, file format)
   ↓
2. Parallel tasks:
   - Frontend Agent: Design export UI based on chosen approach
   - Backend Agent: Design export API based on chosen approach
   - Performance Agent: Optimize for chosen data volume strategy
```

**Benefits**:
- Ensures architectural decisions guide implementation
- Still parallelizes where possible
- Reduces rework from conflicting approaches

### Pattern 3: Explore-Then-Specialize

**When to use**: Need to understand codebase before specialized analysis

**Structure**:
```
1. Explore Agent: Find existing patterns and integration points
   ↓
2. Launch specialized agents with context from exploration
```

**Example scenario**: Adding new payment provider
```
Sequential tasks:
1. Explore Agent: Find existing payment provider implementations
   ↓
2. Parallel tasks:
   - Backend Agent: Design new provider adapter following existing pattern
   - Security Agent: Analyze payment security requirements
   - Performance Agent: Evaluate transaction volume impact
```

**Benefits**:
- Leverages existing code patterns
- Reduces need to reinvent solutions
- Ensures consistency with existing code

### Pattern 4: Architect-First Approach

**When to use**: Complex features requiring strong architectural foundation

**Structure**:
```
1. Architecture Agent: Design overall architecture
   ↓
2. Review architecture, ask clarifying questions
   ↓
3. Launch specialized agents based on architectural decisions
```

**Example scenario**: Migrating from monolith to microservices
```
Sequential tasks:
1. Architecture Agent: Design service boundaries and communication patterns
   ↓
2. Review and validate architectural decisions
   ↓
3. Parallel tasks:
   - Backend Agent: Design individual service implementations
   - Performance Agent: Design inter-service communication optimization
   - Security Agent: Design service-to-service authentication
```

**Benefits**:
- Ensures architectural coherence
- Prevents agents from making conflicting design decisions
- Allows validation before detailed planning

### Pattern 5: Security-First Approach

**When to use**: Security-critical features (auth, payments, PII handling)

**Structure**:
```
1. Security Agent: Identify security requirements and constraints
   ↓
2. Architecture Agent: Design architecture within security constraints
   ↓
3. Launch implementation agents
```

**Example scenario**: Implementing user data export (GDPR compliance)
```
Sequential tasks:
1. Security Agent: Identify GDPR requirements, data protection needs
   ↓
2. Architecture Agent: Design export system meeting security requirements
   ↓
3. Parallel tasks:
   - Backend Agent: Implement export logic with security controls
   - Frontend Agent: Design UI with security considerations (user verification)
```

**Benefits**:
- Security is not an afterthought
- Reduces need for security-related rework
- Ensures compliance requirements are met

## Practical Coordination Examples

### Example 1: OAuth Authentication Feature

**Requirements**: Add Google/GitHub OAuth login alongside existing email/password auth

**Coordination Strategy**: Pattern 1 (Parallel Independent Analysis)

**Agent Tasks**:
```typescript
// Launch in parallel
Promise.all([
  Task({
    subagent_type: 'explore',
    prompt: 'Find existing authentication implementations and identify integration points for OAuth'
  }),
  Task({
    subagent_type: 'security-expert',
    prompt: 'Analyze OAuth 2.0 security requirements: CSRF protection, token storage, provider validation'
  }),
  Task({
    subagent_type: 'backend-engineer', 
    prompt: 'Design OAuth callback endpoint, token exchange flow, and user account linking logic'
  }),
  Task({
    subagent_type: 'frontend-engineer',
    prompt: 'Design OAuth login button placement, redirect flow, and account linking UI'
  })
])
```

**Timeline**: ~5 minutes (parallel execution)
**vs Sequential**: ~20 minutes (4 agents × 5 minutes each)

### Example 2: Real-Time Analytics Dashboard

**Requirements**: Build real-time dashboard showing user activity metrics

**Coordination Strategy**: Pattern 2 (Sequential Dependent Analysis)

**Phase 1**: Architecture decisions
```typescript
// Step 1: Architecture decision
const architectureResult = await Task({
  subagent_type: 'architect',
  prompt: `Design architecture for real-time analytics dashboard:
  - Should we use WebSockets or Server-Sent Events?
  - Should we pre-aggregate data or compute on-demand?
  - What data store should we use for time-series data?`
})
```

**Phase 2**: Specialized implementation (parallel)
```typescript
// Step 2: Implementation based on architecture
Promise.all([
  Task({
    subagent_type: 'backend-engineer',
    prompt: `Design backend implementation using:
    - ${architectureResult.communication_method} for real-time updates
    - ${architectureResult.data_store} for time-series storage
    - ${architectureResult.aggregation_strategy} for data processing`
  }),
  Task({
    subagent_type: 'frontend-engineer',
    prompt: `Design frontend dashboard components using:
    - ${architectureResult.communication_method} for receiving updates
    - Chart library for visualizations
    - Real-time data update strategies`
  }),
  Task({
    subagent_type: 'performance-engineer',
    prompt: `Optimize for real-time performance:
    - Data aggregation strategy: ${architectureResult.aggregation_strategy}
    - Expected load: 10,000 concurrent users
    - Target latency: <100ms for updates`
  })
])
```

**Timeline**: ~8 minutes (3 min architecture + 5 min parallel implementation)

### Example 3: Database Migration from SQL to NoSQL

**Requirements**: Migrate user data from PostgreSQL to MongoDB for scalability

**Coordination Strategy**: Pattern 4 (Architect-First Approach)

**Phase 1**: Architecture
```typescript
const architectureResult = await Task({
  subagent_type: 'architect',
  prompt: `Design migration strategy from PostgreSQL to MongoDB:
  - Should we do big-bang migration or gradual dual-write?
  - How should we handle relational data in document model?
  - What is the rollback strategy?
  - How should we validate data integrity?`
})

// Review architecture, discuss with user if needed
```

**Phase 2**: Security validation
```typescript
const securityResult = await Task({
  subagent_type: 'security-expert',
  prompt: `Review migration architecture for security implications:
  Architecture: ${architectureResult}
  - Are there data exposure risks during migration?
  - How should we handle encryption key migration?
  - What are compliance implications (GDPR)?`
})
```

**Phase 3**: Implementation planning (parallel)
```typescript
Promise.all([
  Task({
    subagent_type: 'backend-engineer',
    prompt: `Plan migration implementation:
    Strategy: ${architectureResult.migration_strategy}
    Security requirements: ${securityResult.requirements}
    - Design migration scripts
    - Design dual-write implementation
    - Design validation logic`
  }),
  Task({
    subagent_type: 'performance-engineer',
    prompt: `Optimize migration performance:
    Data volume: ${architectureResult.data_volume}
    - Design batching strategy
    - Estimate migration duration
    - Design for minimal downtime`
  })
])
```

**Timeline**: ~12 minutes (4 min architecture + 3 min security + 5 min parallel implementation)

## Decision Matrix: Which Agents to Use

| Feature Type | Primary Agents | Optional Agents | Pattern |
|--------------|----------------|-----------------|---------|
| Authentication/Authorization | Security, Backend | Frontend, Architect | Security-First |
| Public API | Backend, Architect | Security, Performance | Architect-First |
| UI Feature | Frontend, Explore | Backend, Performance | Explore-Then-Specialize |
| Database Change | Backend, Architect | Security, Performance | Architect-First |
| Performance Optimization | Performance, Explore | Backend, Architect | Explore-Then-Specialize |
| Integration | Backend, Explore | Security, Architect | Explore-Then-Specialize |
| Data Export/Import | Backend, Security | Performance, Frontend | Parallel Independent |
| Real-time Feature | Architect, Backend | Frontend, Performance | Sequential Dependent |

## Agent Prompt Best Practices

### Be Specific
**Bad**: "Design the authentication system"
**Good**: "Design OAuth 2.0 authentication supporting Google and GitHub providers, with account linking for existing users"

### Provide Context
**Bad**: "Review security"
**Good**: "Review security for OAuth implementation handling user credentials. Focus on: CSRF protection, token storage, and OWASP Top 10 considerations"

### Define Scope
**Bad**: "Look at the codebase"
**Good**: "Find all existing authentication implementations in src/auth/ to identify patterns for OAuth integration"

### Request Specific Outputs
**Bad**: "Analyze performance"
**Good**: "Analyze performance for 10,000 concurrent users. Provide: expected latency p95, bottlenecks, caching strategy recommendations"

## Coordination Anti-Patterns

### Anti-Pattern 1: Serial When Parallel Possible
**Problem**: Running independent agents sequentially
```typescript
// Bad: Sequential (takes 20 minutes)
await Task({ subagent_type: 'frontend-engineer', ... })
await Task({ subagent_type: 'backend-engineer', ... })
await Task({ subagent_type: 'security-expert', ... })
await Task({ subagent_type: 'performance-engineer', ... })
```

**Solution**: Run in parallel
```typescript
// Good: Parallel (takes 5 minutes)
await Promise.all([
  Task({ subagent_type: 'frontend-engineer', ... }),
  Task({ subagent_type: 'backend-engineer', ... }),
  Task({ subagent_type: 'security-expert', ... }),
  Task({ subagent_type: 'performance-engineer', ... })
])
```

### Anti-Pattern 2: Parallel When Dependent
**Problem**: Running dependent agents in parallel
```typescript
// Bad: Architecture decisions made in parallel with implementation
await Promise.all([
  Task({ subagent_type: 'architect', prompt: 'Choose database' }),
  Task({ subagent_type: 'backend-engineer', prompt: 'Design data model' }) // Needs database choice!
])
```

**Solution**: Run sequentially
```typescript
// Good: Architecture first, then implementation
const arch = await Task({ subagent_type: 'architect', prompt: 'Choose database' })
await Task({ 
  subagent_type: 'backend-engineer', 
  prompt: `Design data model for ${arch.database_choice}`
})
```

### Anti-Pattern 3: Too Many Agents
**Problem**: Launching agents for simple features
```typescript
// Bad: Overkill for simple feature
await Promise.all([
  Task({ subagent_type: 'architect', ... }),
  Task({ subagent_type: 'security-expert', ... }),
  Task({ subagent_type: 'performance-engineer', ... }),
  Task({ subagent_type: 'frontend-engineer', ... }),
  Task({ subagent_type: 'backend-engineer', ... })
])
// Just to add a "forgot password" link to login page
```

**Solution**: Use only necessary agents
```typescript
// Good: Single frontend agent for simple UI change
await Task({ 
  subagent_type: 'frontend-engineer',
  prompt: 'Add forgot password link to login page'
})
```

### Anti-Pattern 4: Vague Prompts
**Problem**: Not providing enough context
```typescript
// Bad: Vague prompt
await Task({
  subagent_type: 'backend-engineer',
  prompt: 'Design the API'
})
```

**Solution**: Provide specific context
```typescript
// Good: Detailed prompt with context
await Task({
  subagent_type: 'backend-engineer',
  prompt: `Design RESTful API for user profile management:
  - CRUD operations for user profiles
  - Support for profile picture uploads
  - Privacy settings (public/private profiles)
  - Integration with existing auth system
  - Expected load: 1000 requests/minute`
})
```

## Summary

**Key Principles**:
1. **Parallelize independent work** - Run agents concurrently when tasks don't depend on each other
2. **Sequential for dependencies** - Run sequentially when later agents need earlier results
3. **Architecture first for complex features** - Establish architectural foundation before detailed planning
4. **Security first for sensitive features** - Address security requirements upfront
5. **Explore first when uncertain** - Understand existing codebase before planning new code

**Agent Selection**:
- Choose agents based on feature requirements
- Don't over-engineer simple features with too many agents
- Use decision matrix to guide agent selection

**Coordination Patterns**:
- Pattern 1: Parallel Independent (fastest, use when possible)
- Pattern 2: Sequential Dependent (use when results needed for next step)
- Pattern 3: Explore-Then-Specialize (use for existing codebases)
- Pattern 4: Architect-First (use for complex features)
- Pattern 5: Security-First (use for security-critical features)

**Prompt Best Practices**:
- Be specific about requirements
- Provide relevant context
- Define clear scope
- Request specific outputs

Effective agent coordination can reduce planning time by 3-5x while improving plan quality through specialized expertise.
