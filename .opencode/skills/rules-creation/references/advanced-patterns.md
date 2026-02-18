# Advanced Patterns for Rules

Advanced techniques for complex projects and sophisticated rule configurations.

## Multi-File Rule Strategies

### Strategy 1: Modular Rules Directory

Create a dedicated rules directory referenced via `opencode.json`:

**Directory structure**:
```
project/
├── opencode.json
├── .opencode/
│   └── rules/
│       ├── architecture.md
│       ├── code-style.md
│       ├── api-design.md
│       ├── testing.md
│       └── deployment.md
```

**opencode.json**:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    ".opencode/rules/*.md"
  ]
}
```

**Benefits**:
- Organized by topic
- Easy to maintain
- Can selectively enable/disable files
- Team members can own specific rule files

**When to use**: Projects with extensive guidelines (> 2000 words)

### Strategy 2: Layered Rules

Combine general rules with specific domain rules:

**Directory structure**:
```
project/
├── AGENTS.md                    (general project info)
├── opencode.json
└── .opencode/
    └── rules/
        ├── frontend/
        │   ├── react.md
        │   └── styling.md
        └── backend/
            ├── api.md
            └── database.md
```

**opencode.json**:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    ".opencode/rules/**/*.md"
  ]
}
```

**Benefits**:
- Clear separation of concerns
- Domain-specific detail
- General context always available

**When to use**: Full-stack projects or multi-domain applications

### Strategy 3: On-Demand Loading

Use AGENTS.md to instruct selective file loading:

**AGENTS.md**:
```markdown
# Project Rules

## Dynamic Rule Loading

When working on specific domains, load relevant rules:

- **Frontend work**: Read `.opencode/rules/frontend.md`
- **API development**: Read `.opencode/rules/api.md`
- **Database changes**: Read `.opencode/rules/database.md`
- **Infrastructure**: Read `.opencode/rules/infra.md`

Only load files relevant to the current task to optimize context usage.

## General Guidelines

[Core project info that's always relevant]
```

**Benefits**:
- Minimal context usage
- LLM loads only what's needed
- Scales to very large rule sets

**When to use**: Large projects where most rules aren't relevant to each task

## Monorepo Patterns

### Pattern 1: Shared Root + Package Rules

**Structure**:
```
monorepo/
├── AGENTS.md                 (shared conventions)
├── packages/
│   ├── api/
│   │   └── AGENTS.md         (API-specific)
│   ├── web/
│   │   └── AGENTS.md         (web-specific)
│   └── mobile/
│       └── AGENTS.md         (mobile-specific)
```

**Root AGENTS.md**:
```markdown
# Monorepo Overview

Pnpm workspace with shared packages.

## Workspace Commands

- `pnpm -r build` - Build all packages
- `pnpm --filter api dev` - Run specific package
- `pnpm -r test` - Test all packages

## Shared Conventions

- TypeScript strict mode
- Import shared code via workspace names: `@myapp/*`
- Shared types in `packages/types/`
```

**Package AGENTS.md** (packages/api/AGENTS.md):
```markdown
# API Package

Express API server with PostgreSQL.

## Structure

- `src/routes/` - Express route handlers
- `src/services/` - Business logic
- `src/db/` - Database queries (using Kysely)

## API Conventions

[Package-specific conventions]
```

**Behavior**: When in `packages/api/`, only API rules load (not web or mobile)

### Pattern 2: Centralized Rules with References

**Structure**:
```
monorepo/
├── opencode.json
└── .opencode/
    └── rules/
        ├── general.md
        ├── package-api.md
        ├── package-web.md
        └── package-mobile.md
```

**opencode.json**:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    ".opencode/rules/general.md",
    ".opencode/rules/package-*.md"
  ]
}
```

**Behavior**: All package rules load together (useful if working across packages)

### Pattern 3: Hybrid Approach

**Structure**:
```
monorepo/
├── AGENTS.md                 (minimal, points to .opencode/)
├── opencode.json
├── .opencode/
│   └── rules/
│       ├── general.md
│       ├── frontend.md
│       └── backend.md
└── packages/
    ├── api/
    └── web/
```

**AGENTS.md**:
```markdown
# Monorepo

See detailed rules in `.opencode/rules/`:
- `general.md` - Always read first
- `frontend.md` - For web package work
- `backend.md` - For API package work
```

**opencode.json**:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    ".opencode/rules/general.md"
  ]
}
```

**Behavior**: General rules always load, domain rules load on-demand

## Remote and Shared Rules

### Shared Organization Rules

**Use case**: Company-wide coding standards

**Setup**:
```bash
# Create organization rules repo
git clone git@github.com:my-org/coding-standards.git ~/.config/my-org-standards
```

**Global opencode.json** (~/.config/opencode/opencode.json):
```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    "~/.config/my-org-standards/typescript.md",
    "~/.config/my-org-standards/testing.md",
    "~/.config/my-org-standards/git.md"
  ]
}
```

**Benefits**:
- Consistent standards across all projects
- Version controlled
- Update once, applies everywhere
- Team synchronization via git pull

### Remote URL Rules

**Use case**: Public standards or external guidelines

**Project opencode.json**:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    "https://raw.githubusercontent.com/my-org/public-standards/main/api-design.md",
    "https://raw.githubusercontent.com/my-org/public-standards/main/security.md"
  ]
}
```

**Benefits**:
- No local setup needed
- Always up-to-date
- Shareable via URL

**Limitations**:
- 5 second timeout per URL
- Network dependency
- No offline access

### Hybrid Local + Remote

**Use case**: Mix company standards with project-specific rules

**Project opencode.json**:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    "https://raw.githubusercontent.com/my-org/standards/main/base.md",
    ".opencode/rules/project-specific.md"
  ]
}
```

## Conditional and Context-Aware Rules

### File Reference Pattern

Use AGENTS.md to create conditional loading based on task:

```markdown
# Project Rules

## Context-Aware Loading

Load additional rules based on what you're working on:

### Frontend Development
If modifying React components or UI, read:
- `.opencode/rules/react-patterns.md`
- `.opencode/rules/styling-guide.md`
- `.opencode/rules/accessibility.md`

### Backend Development
If modifying API or database, read:
- `.opencode/rules/api-design.md`
- `.opencode/rules/database-patterns.md`
- `.opencode/rules/security.md`

### Infrastructure
If modifying deployment or infrastructure, read:
- `.opencode/rules/aws-conventions.md`
- `.opencode/rules/deployment-process.md`

### Testing
If writing tests, read:
- `.opencode/rules/testing-strategy.md`

Load only files relevant to current work to preserve context space.
```

### Technology-Specific Rules

```markdown
# Multi-Technology Project

## Technology Detection

Identify technology from file extension and load relevant rules:

- **TypeScript files** (.ts, .tsx): Read `.opencode/rules/typescript.md`
- **Python files** (.py): Read `.opencode/rules/python.md`
- **SQL files** (.sql): Read `.opencode/rules/database.md`
- **YAML files** (.yml, .yaml): Read `.opencode/rules/infrastructure.md`
- **Dockerfile**: Read `.opencode/rules/docker.md`
```

## Environment-Specific Rules

### Multi-Environment Projects

**Structure**:
```
project/
├── .opencode/
│   └── rules/
│       ├── base.md
│       ├── development.md
│       ├── staging.md
│       └── production.md
```

**base.md**:
```markdown
# Base Rules

General coding standards that apply to all environments.

## When Deploying

Load environment-specific rules:
- Development: `.opencode/rules/development.md`
- Staging: `.opencode/rules/staging.md`
- Production: `.opencode/rules/production.md`
```

**production.md**:
```markdown
# Production Environment Rules

## Critical Checks Before Production Deploy

- [ ] All tests passing (unit, integration, E2E)
- [ ] Security scan completed
- [ ] Performance benchmarks met
- [ ] Database migrations tested on staging
- [ ] Rollback plan documented

## Production-Specific Settings

- Never log sensitive data (PII, tokens, keys)
- Use production database (read from `DATABASE_URL`)
- Enable monitoring and alerting
- Set `NODE_ENV=production`
```

## Migration and Evolution

### Version Tagging Pattern

Track rule changes over time:

```markdown
# Project Rules

**Last Updated**: 2024-01-15
**Version**: 2.0

## Recent Changes (v2.0)

- Migrated from Pages Router to App Router (Next.js 14)
- Switched from REST to tRPC
- Updated TypeScript to v5

## Current Patterns

[Current guidelines]

## Deprecated Patterns (Remove by 2024-06-01)

### Old Pages Router Pattern (v1.x)
If you encounter files in `pages/`, they're legacy. New routes go in `app/`.

### Old REST API Pattern (v1.x)
If you see `/api/rest/*` endpoints, they're being phased out. Use tRPC instead.
```

### Migration Instructions

```markdown
# Migration in Progress

## Active Migration: Pages Router → App Router

**Status**: 60% complete
**Target**: 2024-03-01

### Completed
- ✅ Home page migrated
- ✅ Dashboard migrated
- ✅ User profile migrated

### In Progress
- 🚧 Admin panel (do not modify)
- 🚧 Settings page (do not modify)

### TODO
- ⏳ Blog pages
- ⏳ Documentation pages

### How to Handle Files

**New features**: Always use App Router (in `app/`)

**Existing Pages Router files**: 
- Small changes: OK to modify in place
- Large changes: Migrate to App Router first

**Migration guide**: See `.opencode/docs/app-router-migration.md`
```

## Integration with Other Tools

### Cursor Rules Compatibility

If team uses both Cursor and OpenCode:

**Structure**:
```
project/
├── AGENTS.md          (OpenCode)
├── .cursorrules       (Cursor)
└── opencode.json
```

**opencode.json**:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    ".cursorrules"
  ]
}
```

**Benefit**: Single source of truth, loaded by both tools

### Documentation Integration

Reference existing docs without duplication:

**opencode.json**:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    "CONTRIBUTING.md",
    "docs/ARCHITECTURE.md",
    "docs/API.md"
  ]
}
```

**AGENTS.md** (minimal):
```markdown
# Project Overview

Detailed documentation loaded automatically:
- Architecture: `docs/ARCHITECTURE.md`
- API conventions: `docs/API.md`
- Contributing guidelines: `CONTRIBUTING.md`

This AGENTS.md contains only quick-reference info.

## Quick Commands

- `npm dev` - Start development
- `npm test` - Run tests
- `npm build` - Production build
```

## Performance Optimization

### Context Budget Management

Total instruction content should stay under ~10,000 words.

**Measure current usage**:
```bash
# Count words in all instruction files
wc -w AGENTS.md .opencode/rules/*.md
```

**Optimization strategies**:

1. **Remove redundancy**: One place for each piece of info
2. **Use references**: Link to external docs instead of copying
3. **Lazy loading**: Load files on-demand, not all at once
4. **Trim verbosity**: Remove unnecessary explanations

### Selective Loading Pattern

**AGENTS.md**:
```markdown
# Project (Optimized Context)

## Core Info (Always Relevant)

[Essential project info - 500 words max]

## Detailed Rules (Load As Needed)

Load only when relevant:

- Frontend: `.opencode/rules/frontend.md` (1500 words)
- Backend: `.opencode/rules/backend.md` (1500 words)
- DevOps: `.opencode/rules/devops.md` (1000 words)
- Testing: `.opencode/rules/testing.md` (800 words)

Total budget: 500 (core) + ~1500 (one detailed) = ~2000 words per session
```

**Benefit**: Stay within context budget by loading subset of rules

## Testing and Validation

### Validate Rules Loading

**Test that rules load**:
1. Start OpenCode session
2. Ask: "What are the coding standards for this project?"
3. Verify response includes info from AGENTS.md

**Test custom instructions**:
1. Add file to `opencode.json` instructions
2. Restart OpenCode session
3. Ask about content from that file
4. Verify it's included in response

### Test Rule Effectiveness

**Before/after comparison**:
1. Try a task before adding rules
2. Document LLM behavior
3. Add rules
4. Retry same task
5. Verify improvement

**Example**:
- **Before**: LLM uses npm instead of pnpm
- **Add rule**: "Use `pnpm` for all package operations"
- **After**: LLM consistently uses pnpm

### Validate Against Anti-Patterns

**Check for anti-patterns**:
- [ ] No general programming explanations
- [ ] No duplicated external documentation
- [ ] Under 2000 words (or files loaded selectively)
- [ ] Specific, not vague
- [ ] Examples are realistic

## Team Workflows

### Rule Ownership

Assign team members to maintain specific rule files:

```
.opencode/rules/
├── frontend.md        (owned by: @frontend-team)
├── backend.md         (owned by: @backend-team)
├── infrastructure.md  (owned by: @devops-team)
└── testing.md         (owned by: @qa-team)
```

**CODEOWNERS** file:
```
.opencode/rules/frontend.md @frontend-team
.opencode/rules/backend.md @backend-team
.opencode/rules/infrastructure.md @devops-team
.opencode/rules/testing.md @qa-team
```

### Rule Review Process

Treat rule changes like code:

1. **Create PR** for rule changes
2. **Review** by relevant team
3. **Test** with real OpenCode sessions
4. **Merge** when approved

**PR template**:
```markdown
## Rule Change

**File**: `.opencode/rules/api.md`
**Type**: Update existing pattern

## What Changed

- Updated error response format to include request ID
- Added new authentication pattern for service-to-service calls

## Testing

- [ ] Tested with OpenCode session
- [ ] LLM correctly applies new patterns
- [ ] No conflicts with existing rules

## Impact

- Affects all API development
- Existing error handlers may need updates
```

### Onboarding New Team Members

**Onboarding checklist**:
```markdown
# OpenCode Setup

## 1. Install OpenCode
[Installation instructions]

## 2. Clone Project
git clone <repo>

## 3. Review Project Rules
Read `AGENTS.md` to understand project conventions

## 4. Test OpenCode
- Start OpenCode: `opencode`
- Ask: "What are the code standards for this project?"
- Verify you get project-specific responses

## 5. Set Global Preferences (Optional)
Create `~/.config/opencode/AGENTS.md` with personal preferences
```

## Advanced opencode.json Patterns

### Conditional Instructions

Use multiple config files:

**opencode.json** (base):
```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    "AGENTS.md"
  ]
}
```

**opencode.dev.json** (development):
```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    "AGENTS.md",
    ".opencode/rules/development.md"
  ]
}
```

**Usage**:
```bash
# Production mode
opencode

# Development mode with extra rules
OPENCODE_CONFIG=opencode.dev.json opencode
```

### Glob Pattern Strategies

**Match all markdown in directory**:
```json
{
  "instructions": [".opencode/rules/*.md"]
}
```

**Recursive search**:
```json
{
  "instructions": [".opencode/**/*.md"]
}
```

**Specific pattern**:
```json
{
  "instructions": ["packages/*/AGENTS.md"]
}
```

**Multiple patterns**:
```json
{
  "instructions": [
    "docs/coding-*.md",
    ".opencode/rules/*.md",
    "packages/*/README.md"
  ]
}
```

### Priority Ordering

Files load in order specified. Put most important first:

```json
{
  "instructions": [
    ".opencode/rules/critical.md",
    ".opencode/rules/general.md",
    ".opencode/rules/optional.md"
  ]
}
```

If context budget exceeded, later files may be truncated.
