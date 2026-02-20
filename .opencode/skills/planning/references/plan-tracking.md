# Plan Tracking and Status Management

Guide to managing plan lifecycle with `.opencode/.plan-status.json` file.

## Overview

The plan status file tracks all implementation plans in a project, providing a single source of truth for plan lifecycle management.

**Plan Directory Structure**:
```
.opencode/
├── .plan-status.json       # Status tracking file
└── plans/                  # All plan files stored here
    ├── plan-feature-1.md
    ├── plan-feature-2.md
    └── plan-feature-3.md
```

## Status File Location

`.opencode/.plan-status.json` (in project root, under `.opencode/` directory)

This file should be:
- Committed to version control
- Updated automatically by planning workflow
- Human-readable for manual inspection

## Status File Format

```json
{
  "plans": {
    "feature-name-1": {
      "filename": ".opencode/plans/plan-feature-name-1.md",
      "status": "pending",
      "created": "2026-02-19T10:30:00Z",
      "description": "Brief description of feature",
      "implemented": null,
      "implementedBy": null
    },
    "feature-name-2": {
      "filename": ".opencode/plans/plan-feature-name-2.md", 
      "status": "in-progress",
      "created": "2026-02-18T14:20:00Z",
      "description": "Another feature description",
      "implemented": null,
      "implementedBy": null,
      "startedAt": "2026-02-19T09:00:00Z"
    },
    "feature-name-3": {
      "filename": ".opencode/plans/plan-feature-name-3.md",
      "status": "completed",
      "created": "2026-02-15T11:00:00Z",
      "description": "Completed feature description",
      "implemented": "2026-02-17T16:45:00Z",
      "implementedBy": "developer-name"
    }
  }
}
```

## Plan Status Values

| Status | Meaning | Next Action |
|--------|---------|-------------|
| `pending` | Plan created, not started | Begin implementation with `/implement` |
| `in-progress` | Implementation started | Continue implementation |
| `completed` | Implementation finished | None (archived) |
| `cancelled` | Plan abandoned | None (archived) |
| `on-hold` | Implementation paused | Resume when ready |

## Plan Lifecycle

### 1. Plan Creation (Status: pending)

When a plan is created, add entry to status file:

```json
{
  "plans": {
    "oauth-authentication": {
      "filename": ".opencode/plans/plan-oauth-authentication.md",
      "status": "pending",
      "created": "2026-02-19T10:30:00Z",
      "description": "Add OAuth login with Google and GitHub providers",
      "implemented": null,
      "implementedBy": null
    }
  }
}
```

**Fields**:
- `filename`: Plan markdown file name
- `status`: Always `"pending"` initially
- `created`: ISO-8601 timestamp of plan creation
- `description`: Brief summary (1 sentence)
- `implemented`: `null` (not yet implemented)
- `implementedBy`: `null` (no implementer yet)

### 2. Implementation Start (Status: in-progress)

When implementation begins, update status:

```json
{
  "plans": {
    "oauth-authentication": {
      "filename": ".opencode/plans/plan-oauth-authentication.md",
      "status": "in-progress",
      "created": "2026-02-19T10:30:00Z",
      "description": "Add OAuth login with Google and GitHub providers",
      "implemented": null,
      "implementedBy": "john-doe",
      "startedAt": "2026-02-19T11:00:00Z"
    }
  }
}
```

**New fields**:
- `status`: Changed to `"in-progress"`
- `implementedBy`: Developer name or identifier
- `startedAt`: ISO-8601 timestamp when implementation started

### 3. Implementation Completion (Status: completed)

When implementation finishes, update status:

```json
{
  "plans": {
    "oauth-authentication": {
      "filename": ".opencode/plans/plan-oauth-authentication.md",
      "status": "completed",
      "created": "2026-02-19T10:30:00Z",
      "description": "Add OAuth login with Google and GitHub providers",
      "implemented": "2026-02-21T15:30:00Z",
      "implementedBy": "john-doe",
      "startedAt": "2026-02-19T11:00:00Z",
      "completedAt": "2026-02-21T15:30:00Z"
    }
  }
}
```

**New fields**:
- `status`: Changed to `"completed"`
- `implemented`: ISO-8601 timestamp when implementation finished
- `completedAt`: Same as `implemented` (redundant but clear)

### 4. Plan Cancellation (Status: cancelled)

If plan is abandoned:

```json
{
  "plans": {
    "oauth-authentication": {
      "filename": ".opencode/plans/plan-oauth-authentication.md",
      "status": "cancelled",
      "created": "2026-02-19T10:30:00Z",
      "description": "Add OAuth login with Google and GitHub providers",
      "implemented": null,
      "implementedBy": null,
      "cancelledAt": "2026-02-20T10:00:00Z",
      "cancelReason": "Requirements changed, no longer needed"
    }
  }
}
```

**New fields**:
- `status`: Changed to `"cancelled"`
- `cancelledAt`: ISO-8601 timestamp when plan was cancelled
- `cancelReason`: Brief explanation (optional)

### 5. Plan On Hold (Status: on-hold)

If implementation is paused:

```json
{
  "plans": {
    "oauth-authentication": {
      "filename": ".opencode/plans/plan-oauth-authentication.md",
      "status": "on-hold",
      "created": "2026-02-19T10:30:00Z",
      "description": "Add OAuth login with Google and GitHub providers",
      "implemented": null,
      "implementedBy": "john-doe",
      "startedAt": "2026-02-19T11:00:00Z",
      "onHoldAt": "2026-02-20T14:00:00Z",
      "onHoldReason": "Waiting for third-party API approval"
    }
  }
}
```

**New fields**:
- `status`: Changed to `"on-hold"`
- `onHoldAt`: ISO-8601 timestamp when plan was paused
- `onHoldReason`: Brief explanation

## Status File Operations

### Creating Status File

If `.opencode/.plan-status.json` doesn't exist, create it:

```typescript
import fs from 'fs';
import path from 'path';

const statusFilePath = '.opencode/.plan-status.json';
const plansDir = '.opencode/plans';

// Ensure .opencode directory and plans subdirectory exist
if (!fs.existsSync('.opencode')) {
  fs.mkdirSync('.opencode', { recursive: true });
}

if (!fs.existsSync(plansDir)) {
  fs.mkdirSync(plansDir, { recursive: true });
}

// Create initial status file
const initialStatus = {
  plans: {}
};

fs.writeFileSync(
  statusFilePath,
  JSON.stringify(initialStatus, null, 2)
);
```

### Adding New Plan

```typescript
import fs from 'fs';

const statusFilePath = '.opencode/.plan-status.json';

// Read existing status
const status = JSON.parse(fs.readFileSync(statusFilePath, 'utf-8'));

// Add new plan
const featureName = 'oauth-authentication';
status.plans[featureName] = {
  filename: `.opencode/plans/plan-${featureName}.md`,
  status: 'pending',
  created: new Date().toISOString(),
  description: 'Add OAuth login with Google and GitHub providers',
  implemented: null,
  implementedBy: null
};

// Write updated status
fs.writeFileSync(
  statusFilePath,
  JSON.stringify(status, null, 2)
);

console.log(`✅ Plan created: .opencode/plans/plan-${featureName}.md`);
console.log(`📝 Status: pending`);
console.log(`\nTo implement this plan, run:`);
console.log(`/implement`);
```

### Updating Plan Status

```typescript
import fs from 'fs';

const statusFilePath = '.opencode/.plan-status.json';
const featureName = 'oauth-authentication';

// Read existing status
const status = JSON.parse(fs.readFileSync(statusFilePath, 'utf-8'));

// Update to in-progress
status.plans[featureName].status = 'in-progress';
status.plans[featureName].implementedBy = 'john-doe';
status.plans[featureName].startedAt = new Date().toISOString();

// Write updated status
fs.writeFileSync(
  statusFilePath,
  JSON.stringify(status, null, 2)
);

console.log(`📝 Plan status updated: ${featureName} → in-progress`);
```

### Listing All Plans

```typescript
import fs from 'fs';

const statusFilePath = '.opencode/.plan-status.json';

// Read status
const status = JSON.parse(fs.readFileSync(statusFilePath, 'utf-8'));

// Group by status
const plansByStatus = {
  pending: [],
  'in-progress': [],
  'on-hold': [],
  completed: [],
  cancelled: []
};

Object.entries(status.plans).forEach(([name, plan]) => {
  plansByStatus[plan.status].push({ name, ...plan });
});

// Display
console.log('📋 Implementation Plans\n');

if (plansByStatus.pending.length > 0) {
  console.log('⏳ Pending:');
  plansByStatus.pending.forEach(p => {
    console.log(`  - ${p.name}: ${p.description}`);
  });
  console.log();
}

if (plansByStatus['in-progress'].length > 0) {
  console.log('🚧 In Progress:');
  plansByStatus['in-progress'].forEach(p => {
    console.log(`  - ${p.name}: ${p.description} (${p.implementedBy})`);
  });
  console.log();
}

if (plansByStatus['on-hold'].length > 0) {
  console.log('⏸️  On Hold:');
  plansByStatus['on-hold'].forEach(p => {
    console.log(`  - ${p.name}: ${p.description} (${p.onHoldReason})`);
  });
  console.log();
}

if (plansByStatus.completed.length > 0) {
  console.log('✅ Completed:');
  plansByStatus.completed.forEach(p => {
    console.log(`  - ${p.name}: ${p.description}`);
  });
  console.log();
}
```

## Integration with Plan Files

### Plan File Frontmatter

Each plan markdown file should have frontmatter matching status:

```markdown
---
feature: oauth-authentication
status: pending
created: 2026-02-19T10:30:00Z
description: Add OAuth login with Google and GitHub providers
---

# Implementation Plan: OAuth Authentication

[... rest of plan ...]
```

### Syncing Status File and Plan File

When updating plan status, update both files:

```typescript
import fs from 'fs';

const featureName = 'oauth-authentication';
const newStatus = 'in-progress';
const implementedBy = 'john-doe';

// 1. Update status file
const statusFilePath = '.opencode/.plan-status.json';
const status = JSON.parse(fs.readFileSync(statusFilePath, 'utf-8'));
status.plans[featureName].status = newStatus;
status.plans[featureName].implementedBy = implementedBy;
status.plans[featureName].startedAt = new Date().toISOString();
fs.writeFileSync(statusFilePath, JSON.stringify(status, null, 2));

// 2. Update plan file frontmatter
const planFilePath = `.opencode/plans/plan-${featureName}.md`;
let planContent = fs.readFileSync(planFilePath, 'utf-8');

// Update frontmatter (simple regex approach)
planContent = planContent.replace(
  /^status: .*$/m,
  `status: ${newStatus}`
);

fs.writeFileSync(planFilePath, planContent);

console.log(`✅ Updated ${featureName} status to ${newStatus}`);
```

## Workflow Integration

### /implement Command

The `/implement` command should:

1. List all pending plans
2. Prompt user to select a plan
3. Update status to "in-progress"
4. Begin implementation

```typescript
// List pending plans
const status = JSON.parse(fs.readFileSync('.opencode/.plan-status.json', 'utf-8'));
const pendingPlans = Object.entries(status.plans)
  .filter(([_, plan]) => plan.status === 'pending')
  .map(([name, plan]) => ({ name, ...plan }));

if (pendingPlans.length === 0) {
  console.log('No pending plans. Create a plan first with /plan');
  return;
}

// Prompt user to select
console.log('Select a plan to implement:\n');
pendingPlans.forEach((plan, idx) => {
  console.log(`${idx + 1}. ${plan.name}: ${plan.description}`);
});

// User selects plan (example: index 0)
const selectedPlan = pendingPlans[0];

// Update status to in-progress
status.plans[selectedPlan.name].status = 'in-progress';
status.plans[selectedPlan.name].implementedBy = 'current-user';
status.plans[selectedPlan.name].startedAt = new Date().toISOString();

fs.writeFileSync(
  '.opencode/.plan-status.json',
  JSON.stringify(status, null, 2)
);

// Begin implementation
console.log(`🚀 Starting implementation of: ${selectedPlan.name}`);
// ... rest of implementation logic
```

### /plan Command

The `/plan` command should:

1. Gather requirements (Phase 1-4)
2. Create plan file (Phase 5)
3. Add plan to status file (Phase 6)

```typescript
// After creating plan file
const featureName = 'oauth-authentication'; // from user input
const planDescription = 'Add OAuth login with Google and GitHub providers';

// Read or create status file
const statusFilePath = '.opencode/.plan-status.json';
let status;

if (fs.existsSync(statusFilePath)) {
  status = JSON.parse(fs.readFileSync(statusFilePath, 'utf-8'));
} else {
  status = { plans: {} };
  fs.mkdirSync('.opencode', { recursive: true });
}

// Add new plan
status.plans[featureName] = {
  filename: `.opencode/plans/plan-${featureName}.md`,
  status: 'pending',
  created: new Date().toISOString(),
  description: planDescription,
  implemented: null,
  implementedBy: null
};

// Write status file
fs.writeFileSync(
  statusFilePath,
  JSON.stringify(status, null, 2)
);

console.log(`✅ Plan created: .opencode/plans/plan-${featureName}.md`);
console.log(`📝 Status: pending`);
console.log(`\nTo implement this plan, run:`);
console.log(`/implement`);
```

## Status Reporting

### Generate Status Report

```typescript
import fs from 'fs';

const status = JSON.parse(fs.readFileSync('.opencode/.plan-status.json', 'utf-8'));

const totalPlans = Object.keys(status.plans).length;
const plansByStatus = {
  pending: 0,
  'in-progress': 0,
  'on-hold': 0,
  completed: 0,
  cancelled: 0
};

Object.values(status.plans).forEach(plan => {
  plansByStatus[plan.status]++;
});

console.log('📊 Plan Status Report\n');
console.log(`Total Plans: ${totalPlans}`);
console.log(`  ⏳ Pending: ${plansByStatus.pending}`);
console.log(`  🚧 In Progress: ${plansByStatus['in-progress']}`);
console.log(`  ⏸️  On Hold: ${plansByStatus['on-hold']}`);
console.log(`  ✅ Completed: ${plansByStatus.completed}`);
console.log(`  ❌ Cancelled: ${plansByStatus.cancelled}`);

// Completion rate
const completionRate = totalPlans > 0
  ? ((plansByStatus.completed / totalPlans) * 100).toFixed(1)
  : 0;

console.log(`\n📈 Completion Rate: ${completionRate}%`);
```

## Best Practices

### 1. Always Update Both Files

When changing plan status, update both:
- `.opencode/.plan-status.json`
- `plan-<feature-name>.md` frontmatter

This keeps them in sync.

### 2. Use Descriptive Feature Names

Good: `oauth-authentication`, `user-profile-edit`, `csv-data-export`
Bad: `auth`, `profile`, `export`

Feature names become keys in status file and filenames.

### 3. Keep Descriptions Brief

Status descriptions should be 1 sentence:
- "Add OAuth login with Google and GitHub providers" ✅
- "This feature will implement OAuth 2.0 authentication allowing users to sign in using their existing Google or GitHub accounts..." ❌

### 4. Don't Delete Completed Plans

Keep completed/cancelled plans in status file for history:
- Shows project progress
- Provides audit trail
- Helps avoid duplicate work

### 5. Use ISO-8601 Timestamps

Always use ISO-8601 format for timestamps:
- `new Date().toISOString()` in JavaScript
- Consistent format across all plans
- Easily sortable and parseable

## Summary

**Status File Purpose**:
- Single source of truth for all plans
- Tracks plan lifecycle (pending → in-progress → completed)
- Enables workflow automation (/implement command)

**Status Values**:
- `pending` - Plan created, ready to implement
- `in-progress` - Implementation started
- `on-hold` - Implementation paused
- `completed` - Implementation finished
- `cancelled` - Plan abandoned

**Key Operations**:
- Create status file on first plan
- Add entry when creating new plan
- Update status as plan progresses
- Sync with plan file frontmatter

**Workflow Integration**:
- `/plan` command creates plan and adds to status file
- `/implement` command lists pending plans and starts implementation
- Both commands update status file as work progresses

**Best Practices**:
- Always update both status file and plan file
- Use descriptive feature names
- Keep descriptions brief
- Don't delete completed plans
- Use ISO-8601 timestamps

The status file is the central hub for plan management, enabling automated workflows and providing visibility into project progress.
