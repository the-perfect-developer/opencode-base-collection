# Subagents Reference

Comprehensive guide to configuring and using subagents in OpenCode.

## Overview

Subagents are specialized AI assistants that can be invoked for specific tasks. Unlike primary agents that you switch between during a session, subagents are invoked:

- **Automatically** by primary agents when they determine a specialized task is needed
- **Manually** by the user via @ mention syntax

Subagents enable focused, specialized work without cluttering your main conversation flow.

## Built-in Subagents

### General Subagent

**Purpose**: General-purpose multi-step tasks and complex research

**Default Configuration**:
- Mode: `subagent`
- Tools: Full access (except todo)
- Can make file changes when needed
- Use case: Execute multiple units of work in parallel

**When to Use**:
- Researching complex questions
- Multi-step tasks that need coordination
- Parallel execution of independent work
- Tasks requiring full tool access

**Automatic Invocation**:
Primary agents invoke General when they need to:
- Execute multiple independent tasks in parallel
- Perform complex research that spans multiple files
- Handle multi-step workflows

**Manual Invocation**:
```
@general help me refactor these three modules to use dependency injection
```

**Customization Example**:

```json
{
  "agent": {
    "general": {
      "description": "General-purpose agent for complex questions and multi-step tasks",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4-20250514",
      "temperature": 0.3,
      "tools": {
        "todo": false
      }
    }
  }
}
```

### Explore Subagent

**Purpose**: Fast, read-only codebase exploration

**Default Configuration**:
- Mode: `subagent`
- Tools: Read-only (cannot modify files)
- Optimized for quick searches
- Use case: Find patterns, search keywords, answer codebase questions

**When to Use**:
- Finding files by patterns (`src/components/**/*.tsx`)
- Searching code for keywords
- Answering questions about codebase structure
- Quick exploration without modification risk

**Automatic Invocation**:
Primary agents invoke Explore when they need to:
- Search for specific code patterns
- Understand codebase structure
- Find examples of specific implementations
- Locate files or functions

**Manual Invocation**:
```
@explore find all API endpoints related to user authentication
```

**Customization Example**:

```json
{
  "agent": {
    "explore": {
      "description": "Fast codebase exploration agent",
      "mode": "subagent",
      "model": "anthropic/claude-haiku-4-20250514",
      "temperature": 0.1,
      "tools": {
        "write": false,
        "edit": false,
        "bash": false
      }
    }
  }
}
```

**Thoroughness Levels**:
When calling Explore, specify thoroughness:
- `quick` - Basic searches
- `medium` - Moderate exploration
- `very thorough` - Comprehensive analysis

Example:
```
@explore very thorough - analyze the entire authentication flow
```

## Configuration Options for Subagents

### Mode

Set `mode: "subagent"` to make an agent invokable only by primary agents or @ mention:

```json
{
  "agent": {
    "my-subagent": {
      "description": "Specialized task handler",
      "mode": "subagent"
    }
  }
}
```

If set to `"all"` (default), the agent can function as both primary and subagent.

### Description (Critical for Subagents)

The description determines when primary agents will invoke the subagent automatically. Be specific about trigger conditions:

**Good Description**:
```json
{
  "agent": {
    "code-reviewer": {
      "description": "Reviews code for best practices, security issues, and performance problems. Use after completing implementation or when user requests code review.",
      "mode": "subagent"
    }
  }
}
```

**Bad Description**:
```json
{
  "agent": {
    "code-reviewer": {
      "description": "Reviews code",
      "mode": "subagent"
    }
  }
}
```

The description should include:
- What the subagent does
- When it should be invoked
- What tasks trigger its use

### Hidden Subagents

Hide a subagent from @ autocomplete menu:

```json
{
  "agent": {
    "internal-helper": {
      "description": "Internal helper for processing tasks",
      "mode": "subagent",
      "hidden": true
    }
  }
}
```

**Use Cases**:
- Internal subagents only invoked programmatically
- Implementation details users shouldn't access directly
- Specialized workflows triggered by other agents

**Behavior**:
- Not visible in @ autocomplete
- Still invokable via Task tool by primary agents
- Respects task permissions

### Task Permissions

Control which subagents a primary agent can invoke:

```json
{
  "agent": {
    "orchestrator": {
      "mode": "primary",
      "permission": {
        "task": {
          "*": "deny",
          "orchestrator-*": "allow",
          "code-reviewer": "ask"
        }
      }
    }
  }
}
```

**Permission Levels**:
- `allow` - Can invoke without approval
- `ask` - Prompt user before invoking
- `deny` - Cannot invoke (removed from Task tool description)

**Pattern Matching**:
- Use glob patterns for flexibility
- Last matching rule wins
- Put `*` wildcard first, specific rules after

**Example Strategies**:

**Whitelist Approach**:
```json
{
  "permission": {
    "task": {
      "*": "deny",
      "explore": "allow",
      "general": "allow"
    }
  }
}
```

**Ask Before Complex Operations**:
```json
{
  "permission": {
    "task": {
      "*": "allow",
      "expensive-*": "ask",
      "destructive-*": "deny"
    }
  }
}
```

**User Override**:
Users can always invoke any subagent directly via @ mention, even if task permissions would deny it.

### Model Selection

Subagents default to using the primary agent's model, but can override:

```json
{
  "agent": {
    "fast-explorer": {
      "description": "Quick codebase exploration",
      "mode": "subagent",
      "model": "anthropic/claude-haiku-4-20250514"
    },
    "deep-analyzer": {
      "description": "In-depth code analysis",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4-20250514"
    }
  }
}
```

**Strategy**:
- Use faster/cheaper models for simple tasks (Haiku for exploration)
- Use capable models for complex tasks (Sonnet for analysis)
- Match model to task complexity

### Tool Configuration

Control which tools subagents can access:

```json
{
  "agent": {
    "readonly-analyzer": {
      "description": "Analyzes code without modifications",
      "mode": "subagent",
      "tools": {
        "write": false,
        "edit": false,
        "bash": false,
        "read": true,
        "glob": true,
        "grep": true
      }
    }
  }
}
```

**Common Patterns**:

**Read-Only**:
```json
{
  "tools": {
    "write": false,
    "edit": false,
    "bash": false
  }
}
```

**Documentation Writer**:
```json
{
  "tools": {
    "bash": false,
    "write": true,
    "edit": true
  }
}
```

**Analysis with Safe Commands**:
```json
{
  "tools": {
    "write": false,
    "edit": false
  },
  "permission": {
    "bash": {
      "*": "deny",
      "git diff*": "allow",
      "git log*": "allow",
      "grep *": "allow"
    }
  }
}
```

## Invoking Subagents

### Automatic Invocation

Primary agents automatically invoke subagents based on:
- Task description matching subagent description
- Tool requirements
- Workflow needs

**Example Flow**:
1. User: "Find all authentication endpoints and review them"
2. Primary agent identifies two tasks:
   - Find endpoints (matches Explore description)
   - Review code (matches code-reviewer description)
3. Primary agent invokes `@explore` to find endpoints
4. Primary agent invokes `@code-reviewer` to review findings

### Manual Invocation

Use @ mention syntax to invoke subagents directly:

**Basic Invocation**:
```
@explore find the database connection logic
```

**With Context**:
```
@code-reviewer review the changes in src/auth.ts for security issues
```

**Multiple Subagents**:
```
@explore find all API routes
@general refactor them to use the new middleware
```

### @ Autocomplete

When you type `@`, OpenCode shows available subagents (except hidden ones):
- Subagent name
- Description
- Visual indicator of availability

Press Tab to autocomplete or arrow keys to select.

## Child Sessions and Navigation

### Understanding Child Sessions

When a subagent is invoked, it creates a **child session**:
- Separate conversation thread
- Own context and history
- Can spawn its own child sessions

**Session Hierarchy**:
```
Parent Session (Primary Agent)
├── Child Session 1 (@explore - finding endpoints)
├── Child Session 2 (@general - refactoring)
└── Child Session 3 (@code-reviewer - reviewing)
```

### Navigation Commands

**Cycle Forward** (Leader+Right):
- Parent → Child 1 → Child 2 → Child 3 → Parent

**Cycle Backward** (Leader+Left):
- Parent ← Child 1 ← Child 2 ← Child 3 ← Parent

**Default Leader Key**: Space bar (customizable in config)

### Workflow Example

1. Working in parent session with Build agent
2. Agent invokes `@explore` to find files
3. Press Leader+Right to view explore session
4. Review search results
5. Press Leader+Left to return to parent session
6. Agent invokes `@general` for refactoring
7. Press Leader+Right to view general session
8. Monitor refactoring progress
9. Press Leader+Right to cycle back to parent

## Common Subagent Patterns

### Code Review Subagent

```json
{
  "agent": {
    "code-reviewer": {
      "description": "Reviews code for quality, security, and performance. Use after implementation or when user requests review.",
      "mode": "subagent",
      "temperature": 0.1,
      "tools": {
        "write": false,
        "edit": false
      },
      "prompt": "{file:./prompts/code-review.txt}"
    }
  }
}
```

### Documentation Generator

```json
{
  "agent": {
    "docs-writer": {
      "description": "Generates and maintains documentation. Use when user requests documentation or docstrings.",
      "mode": "subagent",
      "temperature": 0.3,
      "tools": {
        "bash": false
      },
      "prompt": "{file:./prompts/documentation.txt}"
    }
  }
}
```

### Test Generator

```json
{
  "agent": {
    "test-writer": {
      "description": "Generates unit tests and integration tests. Use when user requests tests or after implementing features.",
      "mode": "subagent",
      "temperature": 0.2,
      "tools": {
        "write": true,
        "edit": true
      },
      "permission": {
        "bash": {
          "*": "deny",
          "npm test": "allow",
          "pytest*": "allow"
        }
      }
    }
  }
}
```

### Security Auditor

```json
{
  "agent": {
    "security-auditor": {
      "description": "Performs security audits and identifies vulnerabilities. Use when reviewing security-critical code or user requests security review.",
      "mode": "subagent",
      "temperature": 0.1,
      "tools": {
        "write": false,
        "edit": false
      },
      "prompt": "{file:./prompts/security-audit.txt}"
    }
  }
}
```

### Performance Analyzer

```json
{
  "agent": {
    "perf-analyzer": {
      "description": "Analyzes code for performance issues and optimization opportunities. Use when user reports performance problems or requests optimization.",
      "mode": "subagent",
      "temperature": 0.1,
      "tools": {
        "write": false,
        "edit": false
      },
      "permission": {
        "bash": {
          "*": "deny",
          "npm run benchmark": "allow"
        }
      }
    }
  }
}
```

### Refactoring Specialist

```json
{
  "agent": {
    "refactorer": {
      "description": "Refactors code for better structure and maintainability. Use when user requests refactoring or code improvement.",
      "mode": "subagent",
      "temperature": 0.2,
      "tools": {
        "write": true,
        "edit": true
      },
      "permission": {
        "bash": {
          "*": "ask",
          "npm test": "allow",
          "git diff": "allow"
        }
      }
    }
  }
}
```

## Best Practices

### Description Writing

**Be Specific About When to Invoke**:

Good:
```
"Reviews code for security vulnerabilities. Use when reviewing authentication, authorization, or data handling code, or when user requests security review."
```

Bad:
```
"Reviews code"
```

**Include Trigger Phrases**:

Good:
```
"Generates API documentation from OpenAPI specs. Use when user mentions 'API docs', 'OpenAPI', or 'swagger documentation'."
```

Bad:
```
"Generates documentation"
```

**Mention Prerequisites**:

Good:
```
"Analyzes bundle size and suggests optimizations. Use after build is complete or when user reports slow load times."
```

Bad:
```
"Optimizes bundles"
```

### Tool Selection

**Match Tools to Purpose**:

**Analysis/Review** (read-only):
```json
{
  "tools": {
    "write": false,
    "edit": false,
    "bash": false
  }
}
```

**Generation** (write but careful):
```json
{
  "tools": {
    "write": true,
    "edit": true,
    "bash": false
  }
}
```

**Automation** (full access with safeguards):
```json
{
  "tools": {
    "write": true,
    "edit": true
  },
  "permission": {
    "bash": {
      "*": "ask",
      "npm test": "allow"
    }
  }
}
```

### Temperature Selection

**Use Low Temperature (0.0-0.2)**:
- Code review
- Security audits
- Bug analysis
- Performance analysis

**Use Medium Temperature (0.2-0.4)**:
- Test generation
- Refactoring
- Documentation writing

**Use Higher Temperature (0.4-0.6)**:
- Creative problem solving
- Alternative implementations
- Design exploration

### Permission Strategy

**Start with Restrictive Defaults**:
```json
{
  "agent": {
    "new-subagent": {
      "permission": {
        "edit": "ask",
        "bash": "ask"
      }
    }
  }
}
```

**Open Up for Proven Safe Operations**:
```json
{
  "agent": {
    "tested-subagent": {
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

### Naming Conventions

**Clear, Purpose-Driven Names**:
- `code-reviewer` - Reviews code
- `docs-writer` - Writes documentation
- `test-generator` - Generates tests
- `security-auditor` - Security audits
- `perf-analyzer` - Performance analysis

**Avoid Generic Names**:
- `helper` - What kind of help?
- `worker` - What work?
- `processor` - Processing what?

## Troubleshooting

### Subagent Not Appearing in @ Autocomplete

**Check**:
1. `mode` is set to `subagent` or `all`
2. Not marked as `hidden: true`
3. Not `disable: true`
4. Configuration syntax is valid

### Subagent Not Auto-Invoked

**Check**:
1. Description clearly indicates when to use
2. Task permissions allow invocation
3. Primary agent has Task tool enabled
4. Description matches the task at hand

### Subagent Creates Wrong Child Session

**Check**:
1. Verify subagent description matches intent
2. Check if multiple subagents have similar descriptions
3. Review task permissions
4. Consider manual invocation via @ mention

### Cannot Navigate to Child Session

**Check**:
1. Child session was actually created
2. Using correct keybind (Leader+Right/Left)
3. Leader key is configured correctly
4. Try manual @ mention invocation

## Advanced Patterns

### Chained Subagents

Create workflows where subagents invoke other subagents:

```json
{
  "agent": {
    "orchestrator": {
      "description": "Orchestrates complex multi-step workflows",
      "mode": "subagent",
      "permission": {
        "task": {
          "explore": "allow",
          "code-reviewer": "allow",
          "test-generator": "allow"
        }
      }
    }
  }
}
```

### Conditional Subagents

Subagents that adapt based on context:

```json
{
  "agent": {
    "smart-analyzer": {
      "description": "Analyzes code and chooses appropriate review type based on file type and context",
      "mode": "subagent",
      "permission": {
        "task": {
          "security-auditor": "allow",
          "perf-analyzer": "allow",
          "style-checker": "allow"
        }
      }
    }
  }
}
```

### Specialized Explorers

Different exploration strategies for different needs:

```json
{
  "agent": {
    "quick-explore": {
      "description": "Fast file pattern matching",
      "mode": "subagent",
      "model": "anthropic/claude-haiku-4-20250514",
      "tools": { "bash": false }
    },
    "deep-explore": {
      "description": "Comprehensive codebase analysis",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4-20250514",
      "tools": { "bash": true },
      "permission": {
        "bash": {
          "*": "deny",
          "grep*": "allow",
          "git log*": "allow"
        }
      }
    }
  }
}
```

## Quick Reference

### @ Invocation Syntax

```
@subagent-name your instruction here
```

### Navigation Keys

- **Leader+Right**: Next child session
- **Leader+Left**: Previous child session

### Essential Configuration

```json
{
  "agent": {
    "my-subagent": {
      "description": "Specific description with triggers",
      "mode": "subagent",
      "model": "provider/model-id",
      "temperature": 0.1,
      "tools": { "write": false },
      "permission": { "bash": "ask" },
      "hidden": false
    }
  }
}
```

### Task Permissions

```json
{
  "permission": {
    "task": {
      "*": "allow/ask/deny",
      "pattern-*": "allow/ask/deny"
    }
  }
}
```
