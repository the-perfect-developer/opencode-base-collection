# Parallel Execution Strategies

Strategies for coordinating multiple specialized agents in parallel to maximize implementation efficiency.

## Overview

Parallel execution allows multiple agents to work on independent tasks simultaneously, dramatically reducing implementation time. This reference explains when and how to run agents in parallel safely.

## Benefits of Parallel Execution

**Time Savings**:
- 3-5x faster implementation for complex features
- Reduced idle time waiting for sequential tasks
- Better resource utilization

**Example**:
```
Sequential: 5 agents × 10 minutes = 50 minutes
Parallel: 5 agents running simultaneously = 10 minutes
Savings: 80% time reduction
```

## When to Use Parallel Execution

### ✅ Safe for Parallel Execution

**Independent Files**:
- Different components with no shared dependencies
- Separate modules or services
- Unrelated utility functions

**Independent Layers**:
- Frontend and backend (when API contract is defined)
- Tests and implementation (when interfaces are clear)
- Documentation and code (when spec is finalized)

**Independent Features**:
- Multiple bug fixes
- Multiple small features
- Different sections of a large feature

### ❌ NOT Safe for Parallel Execution

**Shared Dependencies**:
- Tasks modifying the same file
- Tasks depending on the same module
- Tasks with tight coupling

**Sequential Dependencies**:
- Database schema before queries
- API definition before implementation
- Core services before dependent features

**Conflicting Changes**:
- Multiple tasks modifying the same component
- Tasks that might conflict in git
- Tasks requiring coordination

## Parallel Execution Patterns

### Pattern 1: Frontend + Backend Parallel

**Use when**: API contract is defined upfront

**Structure**:
```typescript
// After defining API contract with @architect

Promise.all([
  Task({
    subagent_type: 'frontend-engineer',
    prompt: `Implement login UI:
    - Form with email/password fields
    - Call POST /api/auth/login
    - Handle response/errors
    - Expected API: ${apiContract}`
  }),
  Task({
    subagent_type: 'backend-engineer',
    prompt: `Implement login API:
    - POST /api/auth/login endpoint
    - Validate credentials
    - Return JWT token
    - API contract: ${apiContract}`
  })
])
```

**Benefits**: Frontend and backend developed simultaneously
**Timeline**: ~10 minutes (vs 20 minutes sequential)

### Pattern 2: Multiple Independent Components

**Use when**: Components have no shared dependencies

**Structure**:
```typescript
Promise.all([
  Task({
    subagent_type: 'frontend-engineer',
    prompt: 'Create UserProfile component in src/components/UserProfile.tsx'
  }),
  Task({
    subagent_type: 'frontend-engineer',
    prompt: 'Create SettingsPanel component in src/components/SettingsPanel.tsx'
  }),
  Task({
    subagent_type: 'frontend-engineer',
    prompt: 'Create NotificationBell component in src/components/NotificationBell.tsx'
  })
])
```

**Benefits**: Multiple components built simultaneously
**Timeline**: ~8 minutes (vs 24 minutes sequential)

### Pattern 3: Implementation + Tests Parallel

**Use when**: Interfaces/contracts are defined

**Structure**:
```typescript
// After defining function signatures

Promise.all([
  Task({
    subagent_type: 'backend-engineer',
    prompt: `Implement UserService.createUser() method:
    Signature: createUser(data: CreateUserDTO): Promise<User>
    Location: src/services/user.service.ts`
  }),
  Task({
    subagent_type: 'backend-engineer',
    prompt: `Write tests for UserService.createUser():
    Test file: src/services/user.service.test.ts
    Test cases:
    - Should create user with valid data
    - Should throw error for invalid email
    - Should throw error for duplicate email`
  })
])
```

**Benefits**: Implementation and tests ready simultaneously
**Timeline**: ~12 minutes (vs 20 minutes sequential)

### Pattern 4: Multiple Services Parallel

**Use when**: Services are independent or have defined contracts

**Structure**:
```typescript
// After architect defines service boundaries

Promise.all([
  Task({
    subagent_type: 'backend-engineer',
    prompt: 'Implement EmailService in src/services/email.service.ts'
  }),
  Task({
    subagent_type: 'backend-engineer',
    prompt: 'Implement NotificationService in src/services/notification.service.ts'
  }),
  Task({
    subagent_type: 'backend-engineer',
    prompt: 'Implement AuditService in src/services/audit.service.ts'
  })
])
```

**Benefits**: Multiple services ready simultaneously
**Timeline**: ~15 minutes (vs 45 minutes sequential)

### Pattern 5: Bug Fixes Parallel

**Use when**: Bugs are independent

**Structure**:
```typescript
Promise.all([
  Task({
    subagent_type: 'junior-engineer',
    prompt: 'Fix bug #123: Date formatting error in UserProfile component'
  }),
  Task({
    subagent_type: 'junior-engineer',
    prompt: 'Fix bug #124: Validation error message typo in login form'
  }),
  Task({
    subagent_type: 'junior-engineer',
    prompt: 'Fix bug #125: Missing null check in getUserById function'
  })
])
```

**Benefits**: Multiple bugs fixed simultaneously
**Timeline**: ~5 minutes (vs 15 minutes sequential)

## Dependency Management

### Identifying Dependencies

**Before running parallel tasks, ask**:
1. Do tasks modify the same file?
2. Does one task depend on another's output?
3. Do tasks share a common dependency that might change?
4. Could tasks conflict in git?

If YES to any question → Run **sequentially**

### Dependency Graph Example

**Feature**: OAuth Authentication

**Tasks**:
1. Define API contract (architect)
2. Create database schema (backend)
3. Implement OAuth service (backend)
4. Implement OAuth endpoints (backend)
5. Create login UI (frontend)
6. Write tests (backend)

**Dependencies**:
```
1 (API contract)
├─→ 3 (OAuth service needs contract)
├─→ 4 (Endpoints need contract)
└─→ 5 (UI needs contract)

2 (Database schema)
└─→ 3 (OAuth service needs schema)

3 (OAuth service)
└─→ 4 (Endpoints use service)

1, 2 complete
└─→ 3, 5, 6 can run in parallel

3 complete
└─→ 4 can run
```

**Execution Plan**:
```typescript
// Phase 1: Sequential (dependencies)
await Task({ subagent_type: 'architect', prompt: 'Define API contract' });
await Task({ subagent_type: 'backend-engineer', prompt: 'Create database schema' });

// Phase 2: Parallel (independent after Phase 1)
await Promise.all([
  Task({ subagent_type: 'backend-engineer', prompt: 'Implement OAuth service' }),
  Task({ subagent_type: 'frontend-engineer', prompt: 'Create login UI' }),
  Task({ subagent_type: 'backend-engineer', prompt: 'Write OAuth service tests' })
]);

// Phase 3: Sequential (depends on Phase 2)
await Task({ subagent_type: 'backend-engineer', prompt: 'Implement OAuth endpoints' });
```

## Coordination Techniques

### Technique 1: Define Contracts First

Before parallel execution, define interfaces/contracts:

```typescript
// Step 1: Define contract
const apiContract = await Task({
  subagent_type: 'architect',
  prompt: 'Define API contract for user authentication'
});

// Step 2: Parallel implementation using contract
await Promise.all([
  Task({
    subagent_type: 'frontend-engineer',
    prompt: `Implement UI using contract: ${apiContract}`
  }),
  Task({
    subagent_type: 'backend-engineer',
    prompt: `Implement API using contract: ${apiContract}`
  })
]);
```

### Technique 2: Separate by File/Directory

Assign different files or directories to different agents:

```typescript
await Promise.all([
  Task({
    subagent_type: 'frontend-engineer',
    prompt: 'Implement components in src/components/auth/'
  }),
  Task({
    subagent_type: 'backend-engineer',
    prompt: 'Implement services in src/services/auth/'
  })
]);
```

### Technique 3: Layer Separation

Separate by architectural layer:

```typescript
await Promise.all([
  Task({
    subagent_type: 'backend-engineer',
    prompt: 'Implement controller layer in src/controllers/user.controller.ts'
  }),
  Task({
    subagent_type: 'backend-engineer',
    prompt: 'Implement service layer in src/services/user.service.ts'
  }),
  Task({
    subagent_type: 'backend-engineer',
    prompt: 'Implement repository layer in src/repositories/user.repository.ts'
  })
]);
```

**Note**: Only works if interfaces are defined first!

### Technique 4: Feature Flags

Use feature flags to allow parallel development without conflicts:

```typescript
await Promise.all([
  Task({
    subagent_type: 'backend-engineer',
    prompt: `Implement feature A behind flag 'feature-a-enabled'`
  }),
  Task({
    subagent_type: 'backend-engineer',
    prompt: `Implement feature B behind flag 'feature-b-enabled'`
  })
]);
```

## Real-World Examples

### Example 1: E-commerce Checkout Feature

**Feature**: Implement checkout flow

**Tasks**:
1. Design checkout architecture (architect)
2. Create checkout UI (frontend)
3. Implement payment API (backend)
4. Implement order processing (backend)
5. Add email notifications (backend)

**Execution**:
```typescript
// Phase 1: Architecture
const architecture = await Task({
  subagent_type: 'architect',
  prompt: 'Design checkout architecture: UI flow, payment integration, order processing'
});

// Phase 2: Parallel implementation
await Promise.all([
  Task({
    subagent_type: 'frontend-engineer',
    prompt: `Implement checkout UI: ${architecture.uiFlow}`
  }),
  Task({
    subagent_type: 'backend-engineer',
    prompt: `Implement payment API: ${architecture.paymentAPI}`
  }),
  Task({
    subagent_type: 'backend-engineer',
    prompt: `Implement email service for order confirmations`
  })
]);

// Phase 3: Integration
await Task({
  subagent_type: 'backend-engineer',
  prompt: 'Implement order processing connecting payment and email services'
});
```

**Timeline**:
- Phase 1: 5 minutes (sequential)
- Phase 2: 10 minutes (parallel, was 30 minutes sequential)
- Phase 3: 8 minutes (sequential)
- **Total: 23 minutes (vs 53 minutes sequential)**

### Example 2: User Dashboard with Multiple Widgets

**Feature**: Create user dashboard with 5 widgets

**Tasks**:
1. Create dashboard layout (frontend)
2. Create analytics widget (frontend)
3. Create activity widget (frontend)
4. Create notifications widget (frontend)
5. Create profile widget (frontend)
6. Create settings widget (frontend)

**Execution**:
```typescript
// Phase 1: Layout (foundation for widgets)
await Task({
  subagent_type: 'frontend-engineer',
  prompt: 'Create dashboard layout with 5 widget slots'
});

// Phase 2: All widgets in parallel
await Promise.all([
  Task({
    subagent_type: 'frontend-engineer',
    prompt: 'Create AnalyticsWidget component'
  }),
  Task({
    subagent_type: 'frontend-engineer',
    prompt: 'Create ActivityWidget component'
  }),
  Task({
    subagent_type: 'frontend-engineer',
    prompt: 'Create NotificationsWidget component'
  }),
  Task({
    subagent_type: 'frontend-engineer',
    prompt: 'Create ProfileWidget component'
  }),
  Task({
    subagent_type: 'frontend-engineer',
    prompt: 'Create SettingsWidget component'
  })
]);
```

**Timeline**:
- Phase 1: 5 minutes (sequential)
- Phase 2: 8 minutes (parallel, was 40 minutes sequential)
- **Total: 13 minutes (vs 45 minutes sequential)**

### Example 3: API + Database + Tests

**Feature**: User CRUD API

**Tasks**:
1. Design database schema (architect)
2. Create migration (backend)
3. Implement UserRepository (backend)
4. Implement UserService (backend)
5. Implement UserController (backend)
6. Write unit tests (backend)
7. Write integration tests (backend)

**Execution**:
```typescript
// Phase 1: Schema design
const schema = await Task({
  subagent_type: 'architect',
  prompt: 'Design user database schema'
});

// Phase 2: Migration (must complete before anything uses DB)
await Task({
  subagent_type: 'backend-engineer',
  prompt: `Create migration for schema: ${schema}`
});

// Phase 3: Parallel layer implementation
await Promise.all([
  Task({
    subagent_type: 'backend-engineer',
    prompt: 'Implement UserRepository (data access layer)'
  }),
  Task({
    subagent_type: 'backend-engineer',
    prompt: 'Write unit tests for UserRepository'
  })
]);

// Phase 4: Service layer (depends on repository)
await Promise.all([
  Task({
    subagent_type: 'backend-engineer',
    prompt: 'Implement UserService using UserRepository'
  }),
  Task({
    subagent_type: 'backend-engineer',
    prompt: 'Write unit tests for UserService'
  })
]);

// Phase 5: Controller layer (depends on service)
await Promise.all([
  Task({
    subagent_type: 'backend-engineer',
    prompt: 'Implement UserController using UserService'
  }),
  Task({
    subagent_type: 'backend-engineer',
    prompt: 'Write integration tests for User API endpoints'
  })
]);
```

**Timeline**:
- Phase 1: 4 minutes (sequential)
- Phase 2: 5 minutes (sequential)
- Phase 3: 8 minutes (parallel, was 16 minutes)
- Phase 4: 10 minutes (parallel, was 20 minutes)
- Phase 5: 12 minutes (parallel, was 24 minutes)
- **Total: 39 minutes (vs 64 minutes sequential)**

## Conflict Resolution

### Handling Git Conflicts

If agents modify the same files:

**Prevention**:
1. Assign different files to different agents
2. Use feature branches per agent
3. Define clear boundaries

**If conflicts occur**:
1. Stop parallel execution
2. Merge changes manually
3. Continue with sequential execution

### Handling Integration Issues

If parallel implementations don't integrate:

**Prevention**:
1. Define interfaces/contracts first
2. Use mocks for dependencies
3. Integration tests after parallel work

**If issues occur**:
1. Identify integration points
2. Assign integration task to appropriate agent
3. Fix and re-test

## Monitoring Parallel Execution

### Track Progress

Use TodoWrite to track parallel tasks:

```typescript
// Create todos for parallel tasks
TodoWrite([
  { content: 'Frontend: Implement login UI', status: 'in_progress' },
  { content: 'Backend: Implement login API', status: 'in_progress' },
  { content: 'Tests: Write login tests', status: 'in_progress' }
]);

// Launch parallel tasks
await Promise.all([...]);

// Mark all complete
TodoWrite([
  { content: 'Frontend: Implement login UI', status: 'completed' },
  { content: 'Backend: Implement login API', status: 'completed' },
  { content: 'Tests: Write login tests', status: 'completed' }
]);
```

### Verify All Tasks Complete

After parallel execution:

```typescript
// Verify each task
const results = await Promise.all([...]);

results.forEach((result, index) => {
  if (result.status === 'error') {
    console.log(`Task ${index} failed: ${result.error}`);
    // Handle failure
  }
});
```

## Best Practices

**DO**:
- ✅ Define contracts/interfaces before parallel execution
- ✅ Assign different files/directories to different agents
- ✅ Use TodoWrite to track parallel tasks
- ✅ Verify all tasks complete successfully
- ✅ Run integration tests after parallel work
- ✅ Keep agents working on independent layers/modules

**DON'T**:
- ❌ Run parallel tasks on the same file
- ❌ Skip dependency analysis
- ❌ Assume parallel tasks will integrate perfectly
- ❌ Forget to track which tasks are running
- ❌ Mix dependent and independent tasks in same batch

## Summary

**Parallel Execution Benefits**:
- 3-5x faster implementation
- Better resource utilization
- Reduced idle time

**Safe Patterns**:
1. Frontend + Backend (after contract)
2. Multiple independent components
3. Implementation + Tests (after interfaces)
4. Multiple independent services
5. Independent bug fixes

**Dependency Management**:
- Define contracts first
- Separate by file/directory
- Use layer separation
- Track dependencies carefully

**Common Pitfalls**:
- Same file conflicts
- Missing dependencies
- Integration issues
- Skipping coordination

**Golden Rule**: If tasks are truly independent (different files, no shared state, no dependencies), run them in parallel. If there's any doubt, run sequentially.
