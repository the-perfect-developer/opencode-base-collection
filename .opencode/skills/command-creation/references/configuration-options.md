# Configuration Options Reference

Complete reference for all configuration options when creating OpenCode commands.

## Overview

Commands can be configured using:
1. **Markdown files** with YAML frontmatter (`.opencode/commands/*.md`)
2. **JSON configuration** in `opencode.jsonc`

Both methods support the same options with slightly different syntax.

## Configuration Methods

### Markdown Files

**Location**: `.opencode/commands/command-name.md` or `~/.config/opencode/commands/command-name.md`

**Structure**:
```markdown
---
option1: value1
option2: value2
---

Template content goes here.
```

**Example**:
```markdown
---
description: Run tests with coverage
agent: build
model: anthropic/claude-3-5-sonnet-20241022
subtask: false
---

Run the full test suite with coverage:
!`npm test -- --coverage`

Analyze failures and suggest fixes.
```

### JSON Configuration

**Location**: `opencode.jsonc` in project root or `~/.config/opencode/opencode.jsonc`

**Structure**:
```json
{
  "command": {
    "command-name": {
      "template": "...",
      "option1": "value1",
      "option2": "value2"
    }
  }
}
```

**Example**:
```json
{
  "command": {
    "test": {
      "template": "Run the full test suite with coverage:\n!`npm test -- --coverage`\n\nAnalyze failures and suggest fixes.",
      "description": "Run tests with coverage",
      "agent": "build",
      "model": "anthropic/claude-3-5-sonnet-20241022",
      "subtask": false
    }
  }
}
```

## Configuration Options

### template

**Type**: String  
**Required**: Yes (for JSON), No (for markdown)  
**Description**: The prompt template sent to the LLM when the command executes.

**JSON**:
```json
{
  "command": {
    "review": {
      "template": "Review the code and suggest improvements."
    }
  }
}
```

**Markdown**: The content after frontmatter becomes the template:
```markdown
---
description: Review code
---

Review the code and suggest improvements.
```

**Supports**:
- Arguments: `$ARGUMENTS`, `$1`, `$2`, etc.
- Shell commands: *!`command`*
- File references: `@path/to/file`

**Multi-line templates** (JSON):
```json
{
  "template": "Line 1\nLine 2\nLine 3"
}
```

Or use array (if supported by your JSON parser):
```json
{
  "template": [
    "Line 1",
    "Line 2",
    "Line 3"
  ]
}
```

### description

**Type**: String  
**Required**: No  
**Default**: None  
**Description**: Brief description shown in the TUI when typing the command.

**JSON**:
```json
{
  "command": {
    "test": {
      "description": "Run tests with coverage"
    }
  }
}
```

**Markdown**:
```yaml
---
description: Run tests with coverage
---
```

**Best practices**:
- Keep it short (1-5 words)
- Describe what the command does, not how
- Use imperative form: "Run tests" not "Runs tests"

**Examples**:
- ✅ "Run tests with coverage"
- ✅ "Deploy to production"
- ✅ "Review recent changes"
- ❌ "This command runs the test suite"
- ❌ "Use this to deploy"

### agent

**Type**: String  
**Required**: No  
**Default**: Current agent  
**Description**: Which agent should execute the command.

**JSON**:
```json
{
  "command": {
    "build": {
      "agent": "build"
    }
  }
}
```

**Markdown**:
```yaml
---
agent: build
---
```

**Valid values**: Any configured agent name (see `opencode.jsonc` agents configuration).

**Common agents**:
- `general` - General-purpose tasks
- `build` - Build and test operations
- `plan` - Planning and architecture
- Custom agents defined in your configuration

**Agent modes**:
- If the agent is a **subagent** (`mode: "subagent"` in agent config), the command triggers a subagent invocation by default
- If you want to force **primary** behavior, set `subtask: false`

### subtask

**Type**: Boolean  
**Required**: No  
**Default**: `false` (or `true` if agent is a subagent)  
**Description**: Force the command to trigger a subagent invocation.

**JSON**:
```json
{
  "command": {
    "analyze": {
      "subtask": true
    }
  }
}
```

**Markdown**:
```yaml
---
subtask: true
---
```

**When to use**:
- Long-running tasks that shouldn't pollute primary context
- Analysis or research tasks
- When you want isolated context for the command
- Force subagent behavior even if agent `mode` is `primary`

**Effects**:
- Command execution happens in a separate context
- Results are returned to the main agent
- Main conversation context is not affected

**Example use case**:
```markdown
---
description: Analyze codebase architecture
agent: general
subtask: true
---

Analyze the entire codebase architecture:
!`find src -name "*.ts" | head -100`

Provide a detailed report on:
- Project structure
- Design patterns used
- Potential improvements
```

### model

**Type**: String  
**Required**: No  
**Default**: Agent's default model  
**Description**: Override the default model for this command.

**JSON**:
```json
{
  "command": {
    "analyze": {
      "model": "anthropic/claude-3-5-sonnet-20241022"
    }
  }
}
```

**Markdown**:
```yaml
---
model: anthropic/claude-3-5-sonnet-20241022
---
```

**Valid values**: Any configured model provider and model name.

**Common models**:
- `anthropic/claude-3-5-sonnet-20241022` - Fast, capable
- `anthropic/claude-3-opus-20240229` - Most capable
- `openai/gpt-4-turbo-preview` - OpenAI's latest
- `openai/gpt-3.5-turbo` - Fast, economical

**When to use different models**:
- **Fast tasks** - Use smaller models (3.5-turbo, claude-sonnet)
- **Complex analysis** - Use larger models (opus, gpt-4)
- **Cost-sensitive** - Use economical models
- **Specialized tasks** - Use domain-specific models

**Example**:
```markdown
---
description: Quick code review
model: anthropic/claude-3-5-sonnet-20241022
---

Review this code quickly for obvious issues:
@$1
```

## Configuration Precedence

When the same command is defined in multiple locations:

1. **Project-local markdown** (`.opencode/commands/*.md`) - Highest priority
2. **Global markdown** (`~/.config/opencode/commands/*.md`)
3. **Project opencode.jsonc** (`opencode.jsonc` in project root)
4. **Global opencode.jsonc** (`~/.config/opencode/opencode.jsonc`) - Lowest priority

**Example**:
- If `test.md` exists in `.opencode/commands/`, it overrides any `test` command in `opencode.jsonc`
- Project config overrides global config

## Complete Examples

### Simple Command (Markdown)

`.opencode/commands/format.md`:
```markdown
---
description: Format code
---

Format all code files:
!`npm run format`

Report any formatting changes.
```

### Simple Command (JSON)

```json
{
  "command": {
    "format": {
      "template": "Format all code files:\n!`npm run format`\n\nReport any formatting changes.",
      "description": "Format code"
    }
  }
}
```

### Command with All Options (Markdown)

`.opencode/commands/deploy.md`:
```markdown
---
description: Deploy application
agent: build
model: anthropic/claude-3-5-sonnet-20241022
subtask: true
---

Deploy application to $1 environment:

Current status:
!`git status`

Package version:
@package.json

Steps:
1. Verify build passes
2. Run tests
3. Deploy to $1
4. Verify deployment
```

### Command with All Options (JSON)

```json
{
  "command": {
    "deploy": {
      "template": "Deploy application to $1 environment:\n\nCurrent status:\n!`git status`\n\nPackage version:\n@package.json\n\nSteps:\n1. Verify build passes\n2. Run tests\n3. Deploy to $1\n4. Verify deployment",
      "description": "Deploy application",
      "agent": "build",
      "model": "anthropic/claude-3-5-sonnet-20241022",
      "subtask": true
    }
  }
}
```

## Markdown vs JSON: When to Use Each

### Use Markdown Files When:
- ✅ You want version control for commands
- ✅ Templates are multi-line or complex
- ✅ You prefer editing in an editor
- ✅ You want to share commands across projects (via global config)
- ✅ You need syntax highlighting for templates

### Use JSON Configuration When:
- ✅ You want all configuration in one file
- ✅ Commands are simple and short
- ✅ You prefer programmatic configuration
- ✅ You use configuration management tools

**Recommendation**: Use markdown files for most commands. They're easier to edit, maintain, and share.

## Validation

### Valid Command Names

Command names (for markdown files or JSON keys):
- Must be lowercase
- Can contain letters, numbers, hyphens
- Cannot start or end with hyphen
- No spaces or special characters

**Valid**:
- ✅ `test`
- ✅ `deploy-prod`
- ✅ `analyze-coverage`
- ✅ `review-pr`

**Invalid**:
- ❌ `Test` (uppercase)
- ❌ `deploy_prod` (underscore)
- ❌ `-deploy` (starts with hyphen)
- ❌ `deploy prod` (space)

### Valid YAML Frontmatter

Frontmatter must be valid YAML:

**Valid**:
```yaml
---
description: Run tests
agent: build
---
```

**Invalid**:
```yaml
---
description: Run tests
agent build  # Missing colon
---
```

**Invalid**:
```yaml
description: Run tests  # Missing opening ---
agent: build
---
```

### Valid JSON

JSON configuration must be valid JSON/JSONC:

**Valid**:
```json
{
  "command": {
    "test": {
      "template": "Run tests"
    }
  }
}
```

**Invalid**:
```json
{
  "command": {
    "test": {
      template: "Run tests"  // Missing quotes on key
    }
  }
}
```

## Environment-Specific Configuration

Use different commands for different environments:

**Development**:
`.opencode/commands/deploy-dev.md`:
```markdown
---
description: Deploy to development
agent: build
---

Deploy to development:
!`npm run deploy:dev`
```

**Production**:
`.opencode/commands/deploy-prod.md`:
```markdown
---
description: Deploy to production
agent: build
model: anthropic/claude-3-opus-20240229
subtask: true
---

Deploy to production:
!`npm run deploy:prod`

⚠️ This is a production deployment. Verify:
- All tests pass
- No uncommitted changes
- Changelog updated
```

## Advanced Patterns

### Dynamic Agent Selection

Use different agents based on task complexity:

**Simple review** - Fast agent:
```markdown
---
description: Quick review
agent: general
model: anthropic/claude-3-5-sonnet-20241022
---

Quick code review of @$1
```

**Deep analysis** - Powerful agent:
```markdown
---
description: Deep analysis
agent: plan
model: anthropic/claude-3-opus-20240229
subtask: true
---

Deep architectural analysis of @$1
```

### Chained Commands

Create commands that suggest next steps:

```markdown
---
description: Run CI pipeline
agent: build
---

Run CI pipeline:
!`npm run ci`

If successful, run: /deploy-staging
If failed, run: /analyze-failures
```

### Contextual Commands

Commands that adapt based on current state:

```markdown
---
description: Smart deploy
---

Current branch: !`git branch --show-current`
Uncommitted changes: !`git status --short`

If on main and clean:
  Run: /deploy-prod
Otherwise:
  Run: /deploy-dev
```
