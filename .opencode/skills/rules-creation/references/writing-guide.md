# Writing Guide for Effective Rules

Best practices for writing clear, concise, and effective AGENTS.md files.

## Core Principles

### Assume LLM Knowledge

The LLM already knows programming languages, frameworks, and standard practices. Only document what's **unique to your project**.

**DON'T explain general concepts**:
```markdown
❌ BAD:
## React Best Practices
- Use functional components instead of class components
- React hooks let you use state in functional components
- useEffect runs after render
```

**DO explain project-specific patterns**:
```markdown
✓ GOOD:
## React Patterns
- Use the `useAppState` hook from `@app/state` for global state
- All API calls go through `@app/api` service layer
- Co-locate styles: ComponentName.tsx + ComponentName.module.css
```

### Be Concise

Every word in AGENTS.md consumes LLM context. Be ruthlessly concise.

**DON'T be verbose**:
```markdown
❌ BAD:
When you are implementing new features, please make sure that you 
carefully consider the existing architecture patterns that we have 
established. It's very important that all new code follows our 
conventions to maintain consistency across the codebase.
```

**DO be direct**:
```markdown
✓ GOOD:
Follow established architecture patterns when adding features.
```

### Be Specific

Vague guidance is ineffective. Use concrete examples and specific instructions.

**DON'T be vague**:
```markdown
❌ BAD:
- Follow best practices
- Use good naming conventions
- Write clean code
```

**DO be specific**:
```markdown
✓ GOOD:
- Import shared code using workspace names: `@myapp/core/utils`
- Functions in `packages/functions/`, infrastructure in `infra/`
- Use `bun` not `npm` for all package operations
```

## Structure and Organization

### Recommended Structure

```markdown
# [Project Name]

[2-3 sentence project overview]

## Project Structure

[Directory layout with brief explanations]

## Code Standards

[Language-specific conventions]

## Development Workflow

[Build, test, deploy procedures]

## [Additional sections as needed]

[Other project-specific guidelines]
```

### Section Guidelines

**Project Name and Overview**:
```markdown
# SST v3 Monorepo Project

This is an SST v3 monorepo using TypeScript and bun workspaces for 
a full-stack serverless application.
```

Keep overview to 2-3 sentences maximum.

**Project Structure**:
```markdown
## Project Structure

- `packages/functions/` - Lambda functions
- `packages/core/` - Shared business logic
- `packages/web/` - Next.js frontend
- `infra/` - Infrastructure as code (SST)
- `sst.config.ts` - Main SST configuration
```

Use relative paths from project root. Add brief descriptions.

**Code Standards**:
```markdown
## Code Standards

### TypeScript
- Strict mode enabled
- Explicit return types for exported functions
- Prefer interfaces over types for objects

### Imports
- Use workspace imports: `@myapp/core/utils`
- No relative imports across packages
- Sort: external, workspace, relative
```

Group by language or technology. Use sub-headings.

**Development Workflow**:
```markdown
## Development Workflow

### Local Development
- `bun dev` - Start all services
- `bun test` - Run tests with watch mode
- `bun lint` - Lint and format

### Deployment
- `bun run deploy:staging` - Deploy to staging
- `bun run deploy:prod` - Deploy to production
- Always deploy staging first for testing
```

Include key commands and important procedures.

## Content Guidelines

### What to Include

**Project-specific information**:
- Custom architecture patterns
- Internal library usage
- Workspace/monorepo conventions
- Deployment procedures
- Testing strategies unique to your project
- API conventions specific to your system
- Database schema patterns

**Technology stack details**:
- Specific versions if critical (Node 20+, React 18)
- Framework configuration (SST v3, Next.js app router)
- Tools used (bun, pnpm, etc.)
- Infrastructure platforms (AWS, Vercel, etc.)

**Team conventions**:
- Code review requirements
- Branch naming patterns
- Commit message formats
- PR description templates

### What to Exclude

**General programming knowledge**:
- How React hooks work
- What TypeScript is
- Standard HTTP methods
- Common design patterns

**Standard documentation**:
- Framework API docs (link instead)
- Library usage (link instead)
- Language syntax

**Time-sensitive information**:
- Current sprint goals
- Upcoming deadlines
- Temporary workarounds (document in code instead)
- Specific version numbers that change frequently

**Secrets or credentials**:
- API keys
- Database passwords
- Access tokens
- Internal URLs (if sensitive)

## Writing Style

### Use Imperative Form

Write instructions as commands, not suggestions.

**DON'T use "should", "could", "you might"**:
```markdown
❌ BAD:
- You should use TypeScript strict mode
- It would be good to run tests before committing
- You might want to check the style guide
```

**DO use direct imperatives**:
```markdown
✓ GOOD:
- Use TypeScript strict mode
- Run tests before committing
- Follow the style guide at docs/style.md
```

### Use Active Voice

Active voice is clearer and more concise than passive voice.

**DON'T use passive voice**:
```markdown
❌ BAD:
- Tests should be written for all new features
- The build must be run before deploying
- Documentation should be updated when APIs change
```

**DO use active voice**:
```markdown
✓ GOOD:
- Write tests for all new features
- Run the build before deploying
- Update documentation when APIs change
```

### Use Lists and Formatting

Make content scannable with formatting.

**Use bullet lists**:
```markdown
## Key Commands

- `bun dev` - Start development server
- `bun test` - Run tests
- `bun build` - Create production build
```

**Use code blocks**:
```markdown
## Import Pattern

Import shared code using workspace names:

```typescript
import { formatDate } from '@myapp/core/utils'
import { UserService } from '@myapp/api/services'
```
```

**Use tables for comparisons**:
```markdown
## Environment Variables

| Variable | Development | Production |
|----------|-------------|------------|
| API_URL  | localhost:3000 | api.prod.com |
| LOG_LEVEL | debug | error |
```

## Examples and Code Snippets

### When to Include Examples

Include code examples for:
- Non-obvious patterns
- Project-specific abstractions
- Complex configurations
- Common tasks

**Don't include examples for**:
- Standard language features
- Well-documented framework APIs
- Trivial operations

### Example Quality

**Make examples realistic**:
```markdown
❌ BAD (too abstract):
```typescript
function doThing(param: Thing): Result {
  return processData(param)
}
```

✓ GOOD (realistic):
```typescript
// Fetch user data using the API service
async function getUserProfile(userId: string): Promise<UserProfile> {
  return apiClient.get(`/users/${userId}`)
}
```
```

**Make examples complete**:
```markdown
❌ BAD (incomplete):
```typescript
useAppState()
```

✓ GOOD (complete):
```typescript
import { useAppState } from '@myapp/state'

function MyComponent() {
  const { user, setUser } = useAppState()
  // ...
}
```
```

## Common Patterns

### Monorepo Rules

```markdown
# Monorepo Project

This is a pnpm workspace monorepo with shared packages.

## Workspace Structure

- `packages/shared/` - Shared utilities and types
- `packages/api/` - Backend API service
- `packages/web/` - Frontend application
- `packages/mobile/` - React Native mobile app

## Import Conventions

Use workspace imports, not relative paths between packages:

```typescript
// ✓ Correct
import { validateEmail } from '@myapp/shared/validators'

// ✗ Incorrect
import { validateEmail } from '../../shared/src/validators'
```

## Package Management

- Use `pnpm` for all operations
- Run commands from root: `pnpm -r test` (all packages)
- Run in specific package: `pnpm --filter api test`
```

### Full-Stack Application

```markdown
# Full-Stack Application

MERN stack application (MongoDB, Express, React, Node.js).

## Architecture

- `server/` - Express API server
- `client/` - React frontend (Vite)
- `shared/` - TypeScript types shared between server and client

## API Conventions

### Endpoints
- Version in path: `/api/v1/users`
- Plural resource names: `/users`, `/orders`
- Use standard HTTP methods (GET, POST, PUT, DELETE)

### Error Handling
All errors return JSON with format:
```json
{
  "error": "Error message",
  "code": "ERROR_CODE",
  "details": {}
}
```

## Environment Variables

Required in `.env`:
- `DATABASE_URL` - MongoDB connection string
- `JWT_SECRET` - Secret for JWT signing
- `PORT` - Server port (default 3000)
```

### Testing Conventions

```markdown
## Testing Strategy

### Unit Tests
- Co-located with source: `UserService.ts` → `UserService.test.ts`
- Use Vitest as test runner
- Mock external dependencies

### Integration Tests
- Located in `tests/integration/`
- Use test database (configured via `TEST_DATABASE_URL`)
- Clean up test data in `afterEach`

### E2E Tests
- Located in `tests/e2e/`
- Use Playwright for browser testing
- Run against local dev server

### Commands
- `npm test` - Run all tests
- `npm run test:unit` - Unit tests only
- `npm run test:integration` - Integration tests only
- `npm run test:e2e` - E2E tests only

### Coverage
- Aim for 80%+ coverage on business logic
- Don't test trivial getters/setters
- Focus coverage on critical paths
```

## Anti-Patterns

### Too Much Detail

**DON'T over-explain**:
```markdown
❌ BAD:
## React Components

React is a JavaScript library for building user interfaces. It uses 
a component-based architecture where you build encapsulated components 
that manage their own state. Components can be either class-based or 
functional. We prefer functional components because they're simpler 
and work better with hooks. Hooks were introduced in React 16.8 and 
they let you use state and other React features without writing a class.

When you create a component, you should think about whether it needs 
state or if it can be a pure presentational component...

[5 more paragraphs]
```

**DO be concise**:
```markdown
✓ GOOD:
## React Components

- Use functional components with hooks
- Keep components small (< 200 lines)
- Co-locate styles: Component.tsx + Component.module.css
- Extract logic to custom hooks in `src/hooks/`
```

### Too Vague

**DON'T be vague**:
```markdown
❌ BAD:
## Code Quality

- Write clean code
- Follow best practices
- Use good naming conventions
- Comment your code appropriately
- Refactor when needed
```

**DO be specific**:
```markdown
✓ GOOD:
## Code Quality

- Function names: `verbNoun` (getUserData, calculateTotal)
- Component names: `PascalCase` (UserProfile, DataTable)
- Max function length: 50 lines (extract if longer)
- Comment WHY not WHAT (intent over implementation)
- Refactor if cyclomatic complexity > 10
```

### Duplicating Documentation

**DON'T duplicate external docs**:
```markdown
❌ BAD:
## Next.js Routing

Next.js uses file-system based routing. Pages are created by adding 
files to the pages directory. For example, pages/about.js maps to 
/about. You can create dynamic routes using brackets...

[Copying entire Next.js routing docs]
```

**DO reference and explain project usage**:
```markdown
✓ GOOD:
## Routing

Using Next.js App Router (not Pages Router).

Routes in `app/` directory:
- `app/dashboard/` - Protected routes (requires auth)
- `app/(public)/` - Public routes (landing, about)
- `app/api/` - API routes (prefer tRPC over REST)

See [Next.js routing docs](https://nextjs.org/docs/app/building-your-application/routing)
```

## Length Guidelines

### Target Length

**Ideal**: 300-800 words (most projects)
**Acceptable**: 100-1500 words
**Maximum**: 2000 words (complex projects)

If exceeding 2000 words, consider:
- Using `opencode.json` `instructions` to reference separate files
- Creating multiple focused rule files
- Removing unnecessary content

### Measuring Impact

Each word in AGENTS.md costs LLM context tokens. Ask for each section:
- Is this information unique to my project?
- Will this help the LLM perform better?
- Can this be shorter without losing clarity?

If answering "no" to any question, revise or remove.

## Validation Checklist

Before finalizing AGENTS.md:

**Content**:
- [ ] Focuses on project-specific information
- [ ] No general programming explanations
- [ ] No duplicated external documentation
- [ ] All examples are realistic and complete
- [ ] Specific commands and patterns included

**Structure**:
- [ ] Clear headings and sections
- [ ] Scannable (lists, code blocks, tables)
- [ ] Logical organization (general → specific)
- [ ] No more than 3 heading levels

**Writing**:
- [ ] Imperative form ("Use X" not "You should use X")
- [ ] Active voice
- [ ] Concise (no unnecessary words)
- [ ] Specific (concrete examples, not vague principles)

**Length**:
- [ ] Under 2000 words
- [ ] Every section justified
- [ ] No redundancy

**Technical**:
- [ ] Valid Markdown syntax
- [ ] Code blocks have language hints
- [ ] File paths use forward slashes
- [ ] All referenced files exist
