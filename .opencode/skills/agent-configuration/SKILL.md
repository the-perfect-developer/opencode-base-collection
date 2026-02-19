---
name: agent-configuration
description: This skill should be used when the user asks to "configure agents", "create a custom agent", "set up agent permissions", "customize agent behavior", "switch agents", or needs guidance on OpenCode agent system.
---

# Agent Configuration

Configure and customize OpenCode agents for specialized tasks and workflows.

## Overview

OpenCode agents are specialized AI assistants that can be configured for specific tasks. The agent system supports two types:

- **Primary agents** - Main assistants you interact with directly (switchable via Tab key)
- **Subagents** - Specialized assistants invoked by primary agents or via @ mention

Agents can be customized with specific prompts, models, tool access, and permissions to create focused workflows optimized for different development scenarios.

## Core Concepts

### Agent Types

**Primary Agents**
- Main conversation partners
- Switch between them using Tab key or configured keybind
- Examples: Build (full access), Plan (restricted for analysis)

**Subagents**
- Invoked automatically by primary agents for specialized tasks
- Can be manually invoked with @ mention (e.g., `@general help me search`)
- Examples: General (multi-step tasks), Explore (codebase exploration)

### Built-in Agents

OpenCode includes four primary built-in agents:

**Build** (Primary)
- Default agent with all tools enabled
- Full file operations and system commands
- Standard development work

**Plan** (Primary)
- Restricted agent for planning and analysis
- File edits and bash commands set to `ask` by default
- Analyzes and suggests without modifying code

**General** (Subagent)
- General-purpose for complex questions and multi-step tasks
- Full tool access except todo
- Execute multiple units of work in parallel

**Explore** (Subagent)
- Fast, read-only codebase exploration
- Cannot modify files
- Find patterns, search keywords, answer codebase questions

### Switching and Invoking Agents

**Switch primary agents**:
- Press Tab key during a session
- Cycles through available primary agents

**Invoke subagents**:
- Automatically by primary agents based on descriptions
- Manually via @ mention: `@explore find the authentication logic`

**Navigate between sessions**:
- Leader+Right: Cycle forward (parent → child1 → child2 → parent)
- Leader+Left: Cycle backward

## Configuration Methods

### JSON Configuration

Configure agents in `opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "agent": {
    "build": {
      "mode": "primary",
      "model": "anthropic/claude-sonnet-4-20250514",
      "temperature": 0.3,
      "tools": {
        "write": true,
        "edit": true,
        "bash": true
      }
    },
    "code-reviewer": {
      "description": "Reviews code for best practices and potential issues",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4-20250514",
      "prompt": "You are a code reviewer. Focus on security, performance, and maintainability.",
      "tools": {
        "write": false,
        "edit": false
      }
    }
  }
}
```

### Markdown Configuration

Create agent files in:
- Global: `~/.config/opencode/agents/`
- Project: `.opencode/agents/`

Example `~/.config/opencode/agents/review.md`:

```markdown
---
description: Reviews code for quality and best practices
mode: subagent
model: anthropic/claude-sonnet-4-20250514
temperature: 0.1
tools:
  write: false
  edit: false
  bash: false
---

You are in code review mode. Focus on:
- Code quality and best practices
- Potential bugs and edge cases
- Performance implications
- Security considerations

Provide constructive feedback without making direct changes.
```

## Essential Configuration Options

### Description (Required)
Brief description of what the agent does and when to use it.

```json
{
  "agent": {
    "review": {
      "description": "Reviews code for best practices and potential issues"
    }
  }
}
```

### Mode
Controls how the agent can be used.

- `primary` - Main agent, switchable via Tab
- `subagent` - Invoked by other agents or @ mention
- `all` - Both (default if not specified)

### Model
Override the model for specific agents.

```json
{
  "agent": {
    "plan": {
      "model": "anthropic/claude-haiku-4-20250514"
    }
  }
}
```

Model format: `provider/model-id`

### Temperature
Control response randomness and creativity (0.0-1.0).

- 0.0-0.2: Focused, deterministic (code analysis)
- 0.3-0.5: Balanced (general development)
- 0.6-1.0: Creative (brainstorming)

### Tools
Enable or disable specific tools.

```json
{
  "agent": {
    "plan": {
      "tools": {
        "write": false,
        "bash": false,
        "mymcp_*": false  // Wildcard to disable MCP server tools
      }
    }
  }
}
```

### Permissions
Control what actions an agent can take.

Permission levels:
- `allow` - Execute without approval
- `ask` - Prompt for approval
- `deny` - Disable the tool

```json
{
  "agent": {
    "build": {
      "permission": {
        "edit": "ask",
        "bash": {
          "*": "ask",
          "git status *": "allow",
          "git push": "ask"
        },
        "webfetch": "deny"
      }
    }
  }
}
```

### Prompt
Custom system prompt file for the agent.

```json
{
  "agent": {
    "review": {
      "prompt": "{file:./prompts/code-review.txt}"
    }
  }
}
```

Path is relative to config file location.

### Max Steps
Maximum agentic iterations before text-only response.

```json
{
  "agent": {
    "quick-thinker": {
      "steps": 5
    }
  }
}
```

### Additional Options

**hidden** - Hide subagent from @ autocomplete menu

```json
{
  "agent": {
    "internal-helper": {
      "mode": "subagent",
      "hidden": true
    }
  }
}
```

**color** - Customize UI appearance (hex color or theme color)

```json
{
  "agent": {
    "creative": {
      "color": "#ff6b6b"
    }
  }
}
```

**top_p** - Alternative to temperature for controlling diversity (0.0-1.0)

## Creating Custom Agents

### Interactive Creation

Use the built-in command:

```bash
opencode agent create
```

This interactive process:
1. Asks where to save (global or project)
2. Requests agent description
3. Generates system prompt and identifier
4. Lets you select tool access
5. Creates markdown file with configuration

### Manual Creation Steps

1. **Identify the use case** - What specific task or workflow?

2. **Choose configuration method** - JSON in `opencode.json` or markdown file

3. **Set required fields**:
   - `description` - When to use this agent
   - `mode` - Primary or subagent

4. **Configure tools and permissions** - What can the agent access?

5. **Add custom prompt** (optional) - Specialized instructions

6. **Test the agent** - Try it on real tasks and iterate

## Common Patterns

### Read-Only Analysis Agent

```json
{
  "agent": {
    "analyzer": {
      "description": "Analyzes code without making changes",
      "mode": "subagent",
      "tools": {
        "write": false,
        "edit": false,
        "bash": false
      }
    }
  }
}
```

### Documentation Writer

```markdown
---
description: Writes and maintains project documentation
mode: subagent
tools:
  bash: false
---

You are a technical writer. Create clear, comprehensive documentation.

Focus on:
- Clear explanations
- Proper structure
- Code examples
- User-friendly language
```

### Security Auditor

```markdown
---
description: Performs security audits and identifies vulnerabilities
mode: subagent
tools:
  write: false
  edit: false
---

You are a security expert. Focus on identifying potential security issues.

Look for:
- Input validation vulnerabilities
- Authentication and authorization flaws
- Data exposure risks
- Dependency vulnerabilities
- Configuration security issues
```

### Faster Model for Planning

```json
{
  "agent": {
    "quick-plan": {
      "description": "Fast planning with cheaper model",
      "mode": "primary",
      "model": "anthropic/claude-haiku-4-20250514",
      "temperature": 0.1,
      "permission": {
        "edit": "deny",
        "bash": "deny"
      }
    }
  }
}
```

## Quick Reference

### Switch Agents
- Tab key - Cycle through primary agents
- @ mention - Invoke subagent (e.g., `@explore find auth code`)

### Navigate Sessions
- Leader+Right - Next child session
- Leader+Left - Previous child session

### Configuration Locations
- Global JSON: `~/.config/opencode/opencode.json`
- Project JSON: `.opencode/opencode.json`
- Global agents: `~/.config/opencode/agents/`
- Project agents: `.opencode/agents/`

### Permission Levels
- `allow` - No approval needed
- `ask` - Prompt user
- `deny` - Disabled

### Temperature Ranges
- 0.0-0.2: Focused (analysis, planning)
- 0.3-0.5: Balanced (general dev)
- 0.6-1.0: Creative (brainstorming)

## Additional Resources

### Reference Files

For detailed information:
- **`references/primary-agents.md`** - In-depth primary agent configuration
- **`references/subagents.md`** - Subagent setup and invocation strategies
- **`references/permissions.md`** - Complete permission system details

### Example Files

Working examples in `examples/`:
- **`custom-agents.md`** - Real-world custom agent configurations
