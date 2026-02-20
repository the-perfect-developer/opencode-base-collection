---
description: Create a new OpenCode command with interactive requirements gathering
agent: build
model: github-copilot/claude-sonnet-4.6
---

Create a new custom command $1

Follow these steps:

## Step 1: Gather Requirements

Before creating the command, ask the user the following questions to gather complete requirements:

1. **Command Name**: What should the command be called? (e.g., "test", "deploy", "review")
   - Must be lowercase, no spaces
   - Will be invoked as `/command-name`

2. **Description**: What does this command do? (Brief, one-line description)
   - This appears in the TUI when typing the command

3. **Purpose**: What is the main task this command should accomplish?
   - Be specific about the workflow or task

4. **Arguments**: Does the command need arguments?
   - None (command runs as-is)
   - Single argument (use $ARGUMENTS or $1)
   - Multiple arguments (use $1, $2, $3, etc.)
   - If yes, what does each argument represent?

5. **Dynamic Content**: Should the command include:
   - Shell command output? (e.g., git status, npm test)
   - File contents? (e.g., config files, templates)
   - Both?
   - If yes, specify which commands/files

6. **Agent**: Which agent should execute this command?
   - Default: Current agent
   - build: For testing, building, deployment tasks
   - plan: For code review, analysis tasks
   - explore: For codebase exploration
   - general: For general tasks
   - Other custom agent?

7. **Subagent Mode**: Should this run as a subagent task?
   - Yes: For long-running or complex tasks (keeps main context clean)
   - No: For quick tasks in current context

8. **Model Override**: Should this use a specific model?
   - Default: Use project default
   - Specific model: Provide model name (e.g., "anthropic/claude-3-5-sonnet-20241022")

## Step 2: Create the Command

After gathering all requirements, create the command file in `.opencode/commands/` with:

1. Proper YAML frontmatter with description, agent, model, subtask settings
2. Well-structured template with:
   - Clear instructions for the LLM
   - Proper use of $ARGUMENTS or $1, $2, $3 for parameters
   - Shell commands using !`command` syntax if needed
   - File references using @path/to/file syntax if needed
3. Context and examples if helpful

## Step 3: Validate and Test

After creating the command:
1. Show the user the created command file
2. Explain how to use it with examples
3. Mention they can test it by running `/command-name` in the TUI

## Resources

Refer to the skill for detailed guidance:
@.opencode/skills/command-creation/SKILL.md

## Best Practices

**DO**:
- Ask ALL questions before creating the command
- Use clear, specific descriptions
- Keep templates focused on a single task
- Use positional arguments ($1, $2) for multiple parameters
- Leverage shell commands for dynamic context
- Use subagent mode for complex/long-running tasks
- Test the command after creation

**DON'T**:
- Skip questions or make assumptions
- Create overly complex templates
- Use shell commands that modify system state
- Include sensitive data in templates
- Forget to document what arguments the command expects

## Examples

Good command examples:
- **test**: Run tests with coverage and analyze failures
- **component**: Generate React component with TypeScript
- **review**: Review recent git changes with quality checks
- **deploy**: Multi-step deployment to specified environment
- **doc**: Generate documentation for specified files

Refer to bundled examples in `.opencode/skills/command-creation/examples/`:
- **test-command.md** - Test execution with coverage
- **component-command.md** - Component generation with arguments
- **review-command.md** - Code review with git integration
- **deploy-command.md** - Multi-step deployment workflow
