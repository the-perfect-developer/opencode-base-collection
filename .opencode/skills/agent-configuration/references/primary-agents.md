# Primary Agents Reference

In-depth guide to configuring and using primary agents in OpenCode.

## Overview

Primary agents are the main AI assistants you interact with directly during your OpenCode sessions. You can switch between them using the Tab key (or your configured `switch_agent` keybind) to access different tool permissions and behaviors.

## Built-in Primary Agents

### Build Agent

**Purpose**: Standard development work with full access

**Default Configuration**:
- Mode: `primary`
- Tools: All enabled
- Permissions: Full access to file operations and system commands
- Use case: General development, implementing features, fixing bugs

**When to Use**:
- Implementing new features
- Modifying existing code
- Running build commands
- Full development workflow

**Customization Example**:

```json
{
  "agent": {
    "build": {
      "mode": "primary",
      "model": "anthropic/claude-sonnet-4-20250514",
      "temperature": 0.3,
      "prompt": "{file:./prompts/build.txt}",
      "tools": {
        "write": true,
        "edit": true,
        "bash": true
      }
    }
  }
}
```

### Plan Agent

**Purpose**: Analysis and planning without making changes

**Default Configuration**:
- Mode: `primary`
- Tools: Read access enabled, write operations restricted
- Permissions:
  - `edit`: Set to `ask` by default
  - `bash`: Set to `ask` by default
- Use case: Code review, architecture planning, analysis

**When to Use**:
- Analyzing code structure
- Planning architectural changes
- Reviewing code without modifications
- Generating implementation plans

**Permission Behavior**:
The Plan agent prompts for approval before:
- Writing or editing files
- Running bash commands

**Customization Example**:

```json
{
  "agent": {
    "plan": {
      "mode": "primary",
      "model": "anthropic/claude-haiku-4-20250514",
      "temperature": 0.1,
      "permission": {
        "edit": "ask",
        "bash": {
          "*": "ask",
          "git status": "allow",
          "git diff*": "allow"
        }
      },
      "tools": {
        "write": false,
        "edit": false
      }
    }
  }
}
```

### Hidden System Agents

OpenCode includes three hidden primary agents for internal operations:

**Compaction** (`mode: primary`, `hidden: true`)
- Compacts long context into summaries
- Runs automatically when needed
- Not user-selectable

**Title** (`mode: primary`, `hidden: true`)
- Generates short session titles
- Runs automatically
- Not user-selectable

**Summary** (`mode: primary`, `hidden: true`)
- Creates session summaries
- Runs automatically
- Not user-selectable

## Configuration Options for Primary Agents

### Mode

Set `mode: "primary"` to make an agent switchable via Tab key.

```json
{
  "agent": {
    "my-agent": {
      "mode": "primary"
    }
  }
}
```

If set to `"all"` (default), the agent can function as both primary and subagent.

### Model Selection

Override the global model for specific agents:

```json
{
  "agent": {
    "fast-planner": {
      "mode": "primary",
      "model": "anthropic/claude-haiku-4-20250514"
    },
    "deep-thinker": {
      "mode": "primary",
      "model": "anthropic/claude-sonnet-4-20250514"
    }
  }
}
```

**Model Format**: `provider/model-id`

Common providers:
- `anthropic/` - Anthropic models
- `openai/` - OpenAI models
- `opencode/` - OpenCode Zen models

### Temperature Control

Adjust response creativity and randomness (0.0-1.0):

```json
{
  "agent": {
    "analyzer": {
      "mode": "primary",
      "temperature": 0.1,
      "prompt": "Analyze code with precision"
    },
    "creative": {
      "mode": "primary",
      "temperature": 0.7,
      "prompt": "Generate creative solutions"
    }
  }
}
```

**Recommended Ranges**:
- **0.0-0.2**: Focused, deterministic responses
  - Code analysis
  - Architecture review
  - Debugging assistance

- **0.3-0.5**: Balanced responses
  - General development
  - Feature implementation
  - Refactoring

- **0.6-1.0**: Creative responses
  - Brainstorming
  - API design exploration
  - Alternative solutions

### Top P (Nucleus Sampling)

Alternative to temperature for controlling diversity:

```json
{
  "agent": {
    "balanced": {
      "mode": "primary",
      "top_p": 0.9
    }
  }
}
```

Lower values = more focused, higher values = more diverse.

### Max Steps

Limit the number of agentic iterations:

```json
{
  "agent": {
    "quick-thinker": {
      "mode": "primary",
      "steps": 5
    }
  }
}
```

When the limit is reached, the agent provides a summary and recommended next steps.

### Custom Prompts

Provide specialized instructions via prompt files:

```json
{
  "agent": {
    "reviewer": {
      "mode": "primary",
      "prompt": "{file:./prompts/code-review.txt}"
    }
  }
}
```

Path is relative to the config file location.

Example prompt file `./prompts/code-review.txt`:

```
You are a senior code reviewer. Focus on:

1. Code Quality
   - Readability and maintainability
   - Adherence to best practices
   - Proper error handling

2. Performance
   - Algorithmic efficiency
   - Resource usage
   - Potential bottlenecks

3. Security
   - Input validation
   - Authentication/authorization
   - Data exposure risks

Provide constructive, specific feedback with examples.
```

### Tool Configuration

Control which tools are available:

```json
{
  "agent": {
    "readonly": {
      "mode": "primary",
      "tools": {
        "write": false,
        "edit": false,
        "bash": false,
        "webfetch": true,
        "read": true,
        "glob": true,
        "grep": true
      }
    }
  }
}
```

**Wildcard Support**:

```json
{
  "agent": {
    "no-mcp": {
      "mode": "primary",
      "tools": {
        "mymcp_*": false
      }
    }
  }
}
```

### Permission Configuration

Fine-grained control over agent actions:

```json
{
  "agent": {
    "cautious": {
      "mode": "primary",
      "permission": {
        "edit": "ask",
        "bash": {
          "*": "ask",
          "git status": "allow",
          "git log*": "allow",
          "git diff*": "allow",
          "grep *": "allow",
          "git push": "deny"
        },
        "webfetch": "ask"
      }
    }
  }
}
```

**Permission Levels**:
- `allow` - Execute without approval
- `ask` - Prompt user for approval
- `deny` - Disable completely

**Bash Permission Patterns**:
- Use glob patterns for flexibility
- Last matching rule takes precedence
- Put `*` wildcard first, specific rules after

### Color Customization

Customize agent appearance in UI:

```json
{
  "agent": {
    "build": {
      "mode": "primary",
      "color": "#4CAF50"
    },
    "plan": {
      "mode": "primary",
      "color": "accent"
    }
  }
}
```

**Options**:
- Hex colors: `#FF5733`
- Theme colors: `primary`, `secondary`, `accent`, `success`, `warning`, `error`, `info`

### Provider-Specific Options

Additional options are passed through to the provider:

```json
{
  "agent": {
    "deep-thinker": {
      "mode": "primary",
      "model": "openai/gpt-5",
      "reasoningEffort": "high",
      "textVerbosity": "low"
    }
  }
}
```

These options are model and provider-specific. Check your provider's documentation.

## Switching Between Primary Agents

### During a Session

**Tab Key** (or configured `switch_agent` keybind):
- Cycles through all primary agents
- Shows current agent in UI
- Context preserved during switch

**Workflow Example**:
1. Start with Build agent
2. Implement feature
3. Press Tab to switch to Plan agent
4. Review implementation
5. Press Tab back to Build agent
6. Make adjustments based on review

### Navigation Commands

**Session Navigation**:
- **Leader+Right**: Cycle forward through sessions (parent → child1 → child2 → parent)
- **Leader+Left**: Cycle backward through sessions

Where Leader is typically the space key or your configured leader key.

## Common Primary Agent Patterns

### Full-Stack Development Agent

```json
{
  "agent": {
    "fullstack": {
      "description": "Full-stack development with frontend and backend expertise",
      "mode": "primary",
      "model": "anthropic/claude-sonnet-4-20250514",
      "temperature": 0.3,
      "prompt": "{file:./prompts/fullstack.txt}",
      "tools": {
        "write": true,
        "edit": true,
        "bash": true
      }
    }
  }
}
```

### Fast Planning Agent

```json
{
  "agent": {
    "quick-plan": {
      "description": "Fast planning and analysis with cheaper model",
      "mode": "primary",
      "model": "anthropic/claude-haiku-4-20250514",
      "temperature": 0.1,
      "steps": 3,
      "permission": {
        "edit": "deny",
        "bash": "deny"
      }
    }
  }
}
```

### Security-Focused Agent

```json
{
  "agent": {
    "security": {
      "description": "Security-focused development and review",
      "mode": "primary",
      "temperature": 0.1,
      "prompt": "{file:./prompts/security.txt}",
      "permission": {
        "bash": {
          "*": "ask",
          "git diff*": "allow"
        }
      }
    }
  }
}
```

### Test-Driven Development Agent

```json
{
  "agent": {
    "tdd": {
      "description": "Test-driven development workflow",
      "mode": "primary",
      "temperature": 0.2,
      "prompt": "{file:./prompts/tdd.txt}",
      "permission": {
        "bash": {
          "*": "ask",
          "npm test": "allow",
          "pytest*": "allow",
          "jest*": "allow"
        }
      }
    }
  }
}
```

## Best Practices

### Temperature Selection

**Use Low Temperature (0.0-0.2) for**:
- Code analysis
- Bug investigation
- Security audits
- Architecture review

**Use Medium Temperature (0.3-0.5) for**:
- Feature implementation
- Refactoring
- General development

**Use High Temperature (0.6-1.0) for**:
- Brainstorming sessions
- Creative problem-solving
- Exploring alternatives

### Permission Strategy

**Start Restrictive, Open Up as Needed**:
```json
{
  "agent": {
    "new-agent": {
      "permission": {
        "edit": "ask",
        "bash": "ask"
      }
    }
  }
}
```

After validating behavior, allow specific safe operations:
```json
{
  "agent": {
    "new-agent": {
      "permission": {
        "edit": "allow",
        "bash": {
          "*": "ask",
          "git status": "allow",
          "npm test": "allow"
        }
      }
    }
  }
}
```

### Model Selection Strategy

**Cost vs Capability Tradeoff**:
- Use faster/cheaper models (Haiku) for planning and analysis
- Use capable models (Sonnet) for complex implementation
- Use most capable models for critical tasks

### Naming Conventions

**Clear, Descriptive Names**:
- `build` - Standard development
- `plan` - Planning and analysis
- `quick-plan` - Fast planning with cheaper model
- `security-review` - Security-focused review
- `tdd` - Test-driven development

**Avoid Generic Names**:
- `agent1`, `agent2` - Not descriptive
- `test` - Too vague
- `helper` - What kind of help?

## Troubleshooting

### Agent Not Appearing in Tab Cycle

**Check**:
1. `mode` is set to `primary` or `all`
2. Agent is not `hidden: true`
3. Agent is not `disable: true`
4. Configuration file syntax is valid

### Agent Has Wrong Permissions

**Check**:
1. Permission configuration in agent definition
2. Global permission settings in config
3. Agent-specific permissions override global settings

### Model Not Loading

**Check**:
1. Model ID format: `provider/model-id`
2. Provider is configured correctly
3. Model is available in your provider account
4. Run `opencode models` to see available models

### Temperature Not Taking Effect

**Check**:
1. Temperature value is between 0.0 and 1.0
2. Model supports temperature parameter
3. Provider-specific configuration isn't overriding

## Quick Reference

### Essential Fields

```json
{
  "agent": {
    "my-agent": {
      "description": "What the agent does",
      "mode": "primary",
      "model": "provider/model-id",
      "temperature": 0.3,
      "tools": { "write": true },
      "permission": { "edit": "ask" }
    }
  }
}
```

### Keyboard Shortcuts

- **Tab**: Switch between primary agents
- **Leader+Right**: Next child session
- **Leader+Left**: Previous child session

### Permission Levels

- `allow`: No approval needed
- `ask`: Prompt user
- `deny`: Disabled

### Temperature Guide

- 0.0-0.2: Analysis, review
- 0.3-0.5: Development
- 0.6-1.0: Brainstorming
