---
name: command-creation
description: This skill should be used when the user asks to "create a command", "add a custom command", "make a slash command", "create /command", or needs guidance on creating custom commands in OpenCode.
---

# Command Creation for OpenCode

Create custom slash commands for repetitive tasks that execute specific prompts with dynamic arguments.

## What Commands Are

Custom commands let you define reusable prompts that can be triggered with `/command-name` in the OpenCode TUI. They provide:

- **Repetitive task automation** - Common workflows like testing, deployment, code review
- **Dynamic arguments** - Pass parameters to customize command behavior
- **Shell integration** - Include bash command output in prompts
- **File references** - Automatically include file contents
- **Agent and model selection** - Route commands to specific agents or models

Commands execute immediately when invoked, sending the configured prompt to the LLM.

## Quick Start

Create a command in three steps:

1. **Create command file**:
   ```bash
   mkdir -p .opencode/commands
   touch .opencode/commands/test.md
   ```

2. **Add frontmatter and content** to `test.md`:
   ```markdown
   ---
   description: Run tests with coverage
   agent: build
   model: anthropic/claude-3-5-sonnet-20241022
   ---
   
   Run the full test suite with coverage report and show any failures.
   Focus on the failing tests and suggest fixes.
   ```

3. **Use the command** in TUI:
   ```
   /test
   ```

That's it! The command will execute the prompt with the configured settings.

## File Locations

Create command files in these locations:

**Project-local**:
- `.opencode/commands/command-name.md`

**Global** (user-wide):
- `~/.config/opencode/commands/command-name.md`

Use project-local for repository-specific commands. Use global for general-purpose commands you use across projects.

## Creating Commands

### Method 1: Markdown Files (Recommended)

Create a markdown file in the `commands/` directory. The filename becomes the command name.

**Structure**:
```
.opencode/commands/
├── test.md          # /test command
├── review.md        # /review command
└── component.md     # /component command
```

**Example** - `.opencode/commands/review.md`:
```markdown
 
---
description: Review code changes
agent: plan
---

Review recent git commits:
!`git log --oneline -10`

Review these changes and suggest any improvements.
```

**Frontmatter fields**:
- `description` - Brief description shown in TUI (optional)
- `agent` - Which agent should execute the command (optional)
- `model` - Override default model (optional)
- `subtask` - Force subagent invocation (optional boolean)

The content after frontmatter becomes the command template.

### Method 2: JSON Configuration

Add commands to `opencode.jsonc` using the `command` option:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "command": {
    "test": {
      "template": "Run the full test suite with coverage report and show any failures.\nFocus on the failing tests and suggest fixes.",
      "description": "Run tests with coverage",
      "agent": "build",
      "model": "anthropic/claude-3-5-sonnet-20241022"
    }
  }
}
```

Use JSON for simple commands or when you want all configuration in one file.

## Command Templates

Templates support special syntax for dynamic behavior:

### 1. Arguments with $ARGUMENTS

Pass arguments to commands using the `$ARGUMENTS` placeholder:

`.opencode/commands/component.md`:
```markdown
 
---
description: Create a new component
---

Create a new React component named $ARGUMENTS with TypeScript support.
Include proper typing and basic structure.
```

**Usage**:
```
/component Button
```

This replaces `$ARGUMENTS` with `Button`.

### 2. Positional Arguments ($1, $2, $3, ...)

Access individual arguments using positional parameters:

`.opencode/commands/create-file.md`:
```markdown
 
---
description: Create a new file with content
---

Create a file named $1 in the directory $2
with the following content: $3
```

**Usage**:
```
/create-file config.json src "{ \"key\": \"value\" }"
```

This replaces:
- `$1` → `config.json`
- `$2` → `src`
- `$3` → `{ "key": "value" }`

### 3. Shell Output with !`command`

Inject bash command output into prompts using *!`command`* syntax:

`.opencode/commands/analyze-coverage.md`:
```markdown
 
---
description: Analyze test coverage
---

Here are the current test results:
!`npm test`

Based on these results, suggest improvements to increase coverage.
```

**More examples**:
```markdown
 
Recent commits:
!`git log --oneline -10`

Current branch status:
!`git status`

Package versions:
!`npm list --depth=0`
```

Commands run in your project's root directory and their output is included in the prompt.

### 4. File References with @

Include file contents using `@` followed by the filename:

`.opencode/commands/review-component.md`:
```markdown
 
---
description: Review component
---

Review the component in @src/components/Button.tsx.
Check for performance issues and suggest improvements.
```

The file content is automatically included in the prompt.

**Multiple files**:
```markdown
 
Compare @src/old-api.ts and @src/new-api.ts.
Identify breaking changes and migration steps.
```

## Configuration Options

### template (required for JSON)

The prompt sent to the LLM when the command executes.

**JSON**:
```json
{
  "command": {
    "test": {
      "template": "Run tests and report failures."
    }
  }
}
```

**Markdown**: Content after frontmatter is the template.

### description (optional)

Brief description shown in the TUI when typing the command.

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

### agent (optional)

Specify which agent should execute the command.

**JSON**:
```json
{
  "command": {
    "review": {
      "agent": "plan"
    }
  }
}
```

**Markdown**:
```yaml
---
agent: plan
---
```

If the agent is a subagent, the command triggers a subagent invocation by default. Disable with `subtask: false`.

**Default**: Current agent if not specified.

### subtask (optional)

Force the command to trigger a subagent invocation. Useful to avoid polluting primary context.

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

This forces subagent behavior even if the agent's `mode` is `primary`.

### model (optional)

Override the default model for this command.

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

## Common Patterns

### Testing Commands

`.opencode/commands/test.md`:
```markdown
 
---
description: Run tests with coverage
agent: build
---

Run the full test suite with coverage report:
!`npm test -- --coverage`

Analyze failures and suggest fixes.
```

### Code Review Commands

`.opencode/commands/review.md`:
```markdown
 
---
description: Review recent changes
---

Recent commits:
!`git log --oneline -10`

Changed files:
!`git diff --name-only HEAD~5`

Review these changes for:
- Code quality issues
- Performance concerns
- Security vulnerabilities
```

### Component Generation Commands

`.opencode/commands/component.md`:
```markdown
 
---
description: Create React component
---

Create a new React component named $1:
- Location: src/components/$1.tsx
- Include TypeScript types
- Add basic props interface
- Follow project conventions from @src/components/Example.tsx
```

**Usage**: `/component Button`

### Deployment Commands

`.opencode/commands/deploy.md`:
```markdown
 
---
description: Deploy to environment
agent: build
subtask: true
---

Deploy to $1 environment:
!`git status`

Steps:
1. Run pre-deployment checks
2. Build production bundle
3. Deploy to $1
4. Verify deployment
```

**Usage**: `/deploy staging`

### Documentation Commands

`.opencode/commands/doc.md`:
```markdown
 
---
description: Generate documentation
---

Generate documentation for $ARGUMENTS:

Code to document:
@$ARGUMENTS

Create comprehensive documentation including:
- Function/class description
- Parameters and return values
- Usage examples
- Edge cases
```

**Usage**: `/doc src/utils/parser.ts`

## Built-in Commands

OpenCode includes built-in commands:
- `/init` - Initialize OpenCode in a project
- `/undo` - Undo last change
- `/redo` - Redo last undone change
- `/share` - Share conversation
- `/help` - Show help

**Note**: Custom commands can override built-in commands. If you define a custom command with the same name, it will replace the built-in version.

## Best Practices

**DO**:
- Use markdown files for easier editing and version control
- Include clear descriptions for discoverability
- Use positional arguments for multiple parameters
- Leverage shell commands for dynamic context
- Test commands before sharing with team
- Use subagent mode for long-running or complex tasks
- Keep templates focused on a single task

**DON'T**:
- Create overly complex templates with too many arguments
- Use shell commands that modify system state
- Include sensitive data in command templates
- Override built-in commands unless necessary
- Forget to document what arguments commands expect

## Examples

See working examples in the `examples/` directory:
- **`test-command.md`** - Test execution with coverage
- **`component-command.md`** - Component generation with arguments
- **`review-command.md`** - Code review with git integration
- **`deploy-command.md`** - Multi-step deployment workflow

## Troubleshooting

**Command doesn't appear**:
1. Verify file is in `.opencode/commands/` or `~/.config/opencode/commands/`
2. Check filename is lowercase with `.md` extension
3. Ensure YAML frontmatter is valid (if used)

**Arguments not replaced**:
1. Check you're using `$ARGUMENTS` or `$1`, `$2`, etc.
2. Verify you're passing arguments: `/command arg1 arg2`

**Shell command fails**:
1. Test command in terminal first: `bash -c "your command"`
2. Check command runs from project root
3. Verify command exists on system

**File reference not working**:
1. Check file path is correct relative to project root
2. Verify file exists: `ls path/to/file`
3. Use forward slashes even on Windows

## Additional Resources

### Reference Files

For detailed information:
- **`references/template-syntax.md`** - Complete template syntax reference
- **`references/configuration-options.md`** - All configuration options explained
- **`references/common-patterns.md`** - More command patterns and examples

### Example Files

Working examples in `examples/`:
- **`test-command.md`** - Test execution
- **`component-command.md`** - Component generation
- **`review-command.md`** - Code review
- **`deploy-command.md`** - Deployment workflow

## Quick Reference

**Markdown command structure**:
```markdown
 
---
description: Brief description
agent: agent-name
model: model-name
subtask: true
---

Template content with $ARGUMENTS or $1, $2
Include shell output: !`command`
Include files: @path/to/file
```

**JSON command structure**:
```json
{
  "command": {
    "name": {
      "template": "Prompt text",
      "description": "Brief description",
      "agent": "agent-name",
      "model": "model-name",
      "subtask": true
    }
  }
}
```

**Special syntax**:
- `$ARGUMENTS` - All arguments as single string
- `$1`, `$2`, `$3` - Individual arguments by position
- *!`command`* - Shell command output
- `@path/to/file` - File contents
