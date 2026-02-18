---
name: rules-creation
description: This skill should be used when the user asks to "create rules", "add custom instructions", "set up AGENTS.md", "configure project rules", "add global rules", or needs guidance on customizing OpenCode behavior with custom instructions.
compatibility: opencode
---

# Rules Creation for OpenCode

Configure custom instructions to guide OpenCode's behavior for your projects and personal workflows.

## What Rules Are

Rules are custom instructions defined in `AGENTS.md` files that OpenCode includes in the LLM's context. They allow you to:

- **Define project conventions** - Code standards, architecture patterns, naming conventions
- **Specify workflows** - Build processes, deployment procedures, testing approaches
- **Document context** - Project structure, technology stack, team practices
- **Set preferences** - Personal coding style, communication preferences

Rules customize how OpenCode works without requiring configuration changes.

## Quick Start

Create rules in three steps:

1. **Run the `/init` command** in OpenCode to auto-generate project rules:
   ```
   /init
   ```
   This scans your project and creates `AGENTS.md` with project-specific context.

2. **Or create manually**:
   ```bash
   # Project rules
   touch AGENTS.md
   
   # Global rules
   mkdir -p ~/.config/opencode
   touch ~/.config/opencode/AGENTS.md
   ```

3. **Add instructions** using markdown:
   ```markdown
   # Project Name
   Brief description of the project.
   
   ## Code Standards
   - Use TypeScript with strict mode
   - Follow functional programming patterns
   
   ## Project Structure
   - src/ - Source code
   - tests/ - Test files
   ```

## Rule Types

### Project Rules

Place `AGENTS.md` in your project root for project-specific instructions that apply when working in that directory or subdirectories.

**Use project rules for**:
- Code style and standards
- Project architecture
- Technology stack details
- Team conventions
- Build and deployment procedures

**Commit to version control** - Project rules should be shared with your team via Git.

**Example location**:
```
my-project/
├── AGENTS.md          ← Project rules
├── src/
└── package.json
```

### Global Rules

Create `~/.config/opencode/AGENTS.md` for personal rules that apply to all OpenCode sessions.

**Use global rules for**:
- Personal coding preferences
- Communication style
- Tool preferences
- Cross-project conventions

**Keep personal** - Global rules are not committed to Git and remain on your machine.

### Custom Instructions via opencode.json

Reference existing documentation files as instructions using the `instructions` field:

**Project configuration** (`opencode.json`):
```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    "CONTRIBUTING.md",
    "docs/guidelines.md",
    ".cursor/rules/*.md"
  ]
}
```

**Global configuration** (`~/.config/opencode/opencode.json`):
```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    "https://raw.githubusercontent.com/my-org/shared-rules/main/style.md"
  ]
}
```

Instructions support:
- **Local files** - Relative paths and glob patterns
- **Remote URLs** - Fetch from web (5 second timeout)
- **Multiple files** - Combined with AGENTS.md files

This reuses existing documentation rather than duplicating to AGENTS.md.

## Rule Precedence

OpenCode loads rules in this order (first match wins in each category):

**1. Local files** (searches up from current directory):
- `AGENTS.md` (OpenCode standard)
- `CLAUDE.md` (Claude Code compatibility)

**2. Global file**:
- `~/.config/opencode/AGENTS.md`
- `~/.claude/CLAUDE.md` (unless disabled)

**3. Custom instructions**:
- Files from `opencode.json` `instructions` field

All matched files combine together in final context.

## Writing Effective Rules

### Structure Guidelines

**Start with context**:
```markdown
# Project Name
Brief 2-3 sentence overview of what the project is.
```

**Organize by topic**:
```markdown
## Project Structure
Directory layout and key files

## Code Standards
Language-specific conventions

## Development Workflow
Build, test, and deployment procedures
```

**Be specific**:
```markdown
✓ Good:
- Import shared code using workspace names: `@my-app/core/example`
- All functions go in `packages/functions/`
- Use `bun` not `npm` for package management

✗ Too vague:
- Follow best practices
- Use good code style
```

### Content Best Practices

**DO**:
- Be concise and actionable
- Use examples and code snippets
- Document project-specific patterns
- Explain "why" for non-obvious decisions
- Keep rules focused on what's unique to your project

**DON'T**:
- Explain general programming concepts
- Duplicate standard language documentation
- Add time-sensitive information (dates, versions)
- Include secrets or credentials
- Write essays - be brief

### Example Structure

```markdown
# SST v3 Monorepo Project

This is an SST v3 monorepo using TypeScript and bun workspaces.

## Project Structure

- `packages/` - Workspace packages (functions, core, web)
- `infra/` - Infrastructure split by service (storage.ts, api.ts)
- `sst.config.ts` - Main SST configuration

## Code Standards

- TypeScript with strict mode enabled
- Shared code in `packages/core/` with proper exports
- Functions in `packages/functions/`
- Infrastructure files in `infra/`

## Monorepo Conventions

- Import shared modules: `@my-app/core/example`
- Use `bun` for all package operations
- Run tests from root: `bun test`
```

## Initialization Workflow

Use the `/init` command to auto-generate project rules:

1. **Navigate to project root** in OpenCode
2. **Run `/init` command**
3. **OpenCode scans the project**:
   - Analyzes directory structure
   - Detects technology stack
   - Identifies patterns
   - Generates `AGENTS.md` with context
4. **Review and customize** the generated file
5. **Commit to Git** to share with team

If `AGENTS.md` already exists, `/init` adds to it rather than replacing.

## Referencing External Files

While OpenCode doesn't auto-parse file references in AGENTS.md, you can achieve similar functionality:

### Method 1: opencode.json (Recommended)

Use the `instructions` field to reference files:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    "docs/development-standards.md",
    "test/testing-guidelines.md",
    "packages/*/AGENTS.md"
  ]
}
```

**Benefits**:
- Clean and maintainable
- Supports glob patterns
- Works with monorepos
- Automatic loading

### Method 2: Manual Instructions in AGENTS.md

Teach OpenCode to load files on-demand:

```markdown
# Project Rules

## External File Loading

CRITICAL: When you encounter a file reference (e.g., @docs/api-standards.md), 
use your Read tool to load it when relevant to the current task.

Instructions:
- Load references on need-to-know basis (lazy loading)
- Treat loaded content as mandatory instructions
- Follow references recursively when needed

## Development Guidelines

For TypeScript style: @docs/typescript-guidelines.md
For React patterns: @docs/react-patterns.md
For API design: @docs/api-standards.md

## General Guidelines

Read immediately: @rules/general-guidelines.md
```

**Use case**: Modular rules, shared standards, keeping AGENTS.md concise.

## Claude Code Compatibility

OpenCode supports Claude Code conventions as fallbacks:

**Project rules**:
- `CLAUDE.md` (used if no `AGENTS.md`)

**Global rules**:
- `~/.claude/CLAUDE.md` (used if no `~/.config/opencode/AGENTS.md`)

**Disable compatibility** via environment variables:
```bash
export OPENCODE_DISABLE_CLAUDE_CODE=1          # Disable all .claude support
export OPENCODE_DISABLE_CLAUDE_CODE_PROMPT=1   # Disable ~/.claude/CLAUDE.md only
```

## Common Patterns

### Monorepo Rules

```markdown
# Monorepo Project

## Workspace Structure
- `packages/shared` - Shared utilities
- `packages/api` - Backend service
- `packages/web` - Frontend application

## Import Conventions
- Use workspace imports: `@myapp/shared/utils`
- No relative imports across packages
- Run builds from root: `npm run build`
```

### Technology Stack

```markdown
## Stack
- **Backend**: Node.js 20, Express, PostgreSQL
- **Frontend**: React 18, TypeScript, Vite
- **Testing**: Vitest, React Testing Library
- **CI/CD**: GitHub Actions

## Key Commands
- `npm run dev` - Start development servers
- `npm run test` - Run all tests
- `npm run lint` - Lint and format
```

### Code Style

```markdown
## Code Standards

### TypeScript
- Use strict mode
- Prefer interfaces over types for objects
- Explicit return types for exported functions

### React
- Use functional components with hooks
- Co-locate styles with components
- Use named exports, not default

### Testing
- Unit tests in `__tests__/` directories
- Integration tests in `tests/` at root
- Aim for 80% coverage on core logic
```

### API Conventions

```markdown
## API Design

### REST Endpoints
- Use plural nouns: `/users`, `/orders`
- Version in URL: `/api/v1/users`
- Standard methods: GET, POST, PUT, DELETE

### Error Handling
- Return proper HTTP status codes
- JSON error format:
  ```json
  {
    "error": "Error message",
    "code": "ERROR_CODE"
  }
  ```
```

## Troubleshooting

**Rules not applied**:
1. Check file name is `AGENTS.md` (all caps)
2. Verify file is in project root or `~/.config/opencode/`
3. Ensure markdown syntax is valid
4. Restart OpenCode session

**Duplicate rules**:
- If both `AGENTS.md` and `CLAUDE.md` exist, only `AGENTS.md` is used
- Global `~/.config/opencode/AGENTS.md` takes precedence over `~/.claude/CLAUDE.md`

**Instructions not loading**:
1. Validate JSON syntax in `opencode.json`
2. Check file paths are correct
3. Verify glob patterns match intended files
4. Check network connectivity for remote URLs

**Claude Code compatibility issues**:
- Disable with environment variables if conflicts occur
- Migrate to OpenCode conventions for better control

## Additional Resources

### Reference Files

For detailed guidance:
- **`references/file-locations.md`** - Complete file location rules and precedence
- **`references/writing-guide.md`** - In-depth writing best practices
- **`references/advanced-patterns.md`** - Advanced techniques for complex projects

### Example Files

Working examples in `examples/`:
- **`examples/simple-project.md`** - Basic project rules
- **`examples/monorepo.md`** - Monorepo with multiple packages
- **`examples/fullstack.md`** - Full-stack application
- **`examples/global-rules.md`** - Personal global preferences

## Quick Reference

**Create project rules**:
```bash
# Auto-generate
/init

# Or manual
touch AGENTS.md
```

**Create global rules**:
```bash
mkdir -p ~/.config/opencode
touch ~/.config/opencode/AGENTS.md
```

**Reference external files** (opencode.json):
```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    "CONTRIBUTING.md",
    "docs/*.md",
    "https://example.com/rules.md"
  ]
}
```

**File precedence** (first match wins):
1. `AGENTS.md` / `CLAUDE.md` (local)
2. `~/.config/opencode/AGENTS.md` / `~/.claude/CLAUDE.md` (global)
3. Files from `opencode.json` `instructions`

**Disable Claude Code compatibility**:
```bash
export OPENCODE_DISABLE_CLAUDE_CODE=1
```
