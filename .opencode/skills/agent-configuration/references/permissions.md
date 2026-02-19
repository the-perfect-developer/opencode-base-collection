# Permissions Reference

Complete guide to the OpenCode permission system for controlling agent behavior.

## Overview

The permission system provides fine-grained control over what actions agents can take. Currently supports permissions for:

- **edit** - File editing operations
- **bash** - Shell command execution
- **webfetch** - Web content fetching

Permissions can be set globally and overridden per-agent, giving you flexible control over agent capabilities.

## Permission Levels

### Allow

Execute operations without user approval.

```json
{
  "permission": {
    "edit": "allow"
  }
}
```

**Use When**:
- Operation is safe and well-understood
- Agent is trusted with this capability
- Speed is important (no prompts)

**Examples**:
- Reading files
- Safe git commands (`git status`, `git diff`)
- Documentation updates

### Ask

Prompt user for approval before executing.

```json
{
  "permission": {
    "edit": "ask"
  }
}
```

**Use When**:
- Operation modifies important files
- You want visibility into agent actions
- Testing new agent configurations
- Operation has potential side effects

**Examples**:
- File modifications
- Most bash commands
- Web fetches to unknown domains

**User Experience**:
When set to `ask`, the agent requests approval before execution. You can:
- Approve the operation
- Deny the operation
- View full details before deciding

### Deny

Completely disable the operation.

```json
{
  "permission": {
    "edit": "deny"
  }
}
```

**Use When**:
- Agent should never perform this operation
- Creating read-only agents
- Restricting capabilities for safety

**Examples**:
- Preventing file writes in analysis agents
- Blocking bash commands in documentation agents
- Disabling web access for offline work

## Edit Permissions

Control file editing operations.

### Global Configuration

```json
{
  "permission": {
    "edit": "ask"
  }
}
```

Affects all file modification operations:
- Direct edits to files
- Patches and replacements
- File content modifications

### Agent Override

```json
{
  "permission": {
    "edit": "deny"
  },
  "agent": {
    "build": {
      "permission": {
        "edit": "allow"
      }
    },
    "plan": {
      "permission": {
        "edit": "deny"
      }
    }
  }
}
```

Agent-specific settings override global defaults.

### Common Patterns

**Read-Only Analysis**:
```json
{
  "agent": {
    "analyzer": {
      "permission": {
        "edit": "deny"
      },
      "tools": {
        "write": false
      }
    }
  }
}
```

**Cautious Editing**:
```json
{
  "agent": {
    "careful": {
      "permission": {
        "edit": "ask"
      }
    }
  }
}
```

**Full Trust**:
```json
{
  "agent": {
    "build": {
      "permission": {
        "edit": "allow"
      }
    }
  }
}
```

## Bash Permissions

Control shell command execution with pattern-based rules.

### Global Configuration

```json
{
  "permission": {
    "bash": "ask"
  }
}
```

### Pattern-Based Rules

Use glob patterns to control specific commands:

```json
{
  "permission": {
    "bash": {
      "*": "ask",
      "git status": "allow",
      "git diff*": "allow",
      "git push": "deny",
      "rm *": "deny"
    }
  }
}
```

**Pattern Matching Rules**:
- Last matching rule wins
- Put `*` wildcard first, specific rules after
- Use `*` for glob matching

### Command Examples

**Safe Git Commands**:
```json
{
  "permission": {
    "bash": {
      "*": "ask",
      "git status": "allow",
      "git log*": "allow",
      "git diff*": "allow",
      "git show*": "allow"
    }
  }
}
```

**Testing Commands**:
```json
{
  "permission": {
    "bash": {
      "*": "ask",
      "npm test": "allow",
      "pytest*": "allow",
      "jest*": "allow"
    }
  }
}
```

**Build Commands**:
```json
{
  "permission": {
    "bash": {
      "*": "ask",
      "npm run build": "allow",
      "npm run dev": "allow",
      "cargo build": "allow"
    }
  }
}
```

**Blocked Destructive Commands**:
```json
{
  "permission": {
    "bash": {
      "*": "ask",
      "rm *": "deny",
      "git reset --hard*": "deny",
      "git push --force*": "deny"
    }
  }
}
```

### Agent-Specific Bash Permissions

```json
{
  "agent": {
    "tdd": {
      "description": "Test-driven development agent",
      "permission": {
        "bash": {
          "*": "deny",
          "npm test": "allow",
          "pytest*": "allow",
          "git diff*": "allow"
        }
      }
    },
    "deployer": {
      "description": "Deployment agent",
      "permission": {
        "bash": {
          "*": "ask",
          "git status": "allow",
          "npm run build": "allow",
          "git push": "ask"
        }
      }
    }
  }
}
```

### Markdown Agent Configuration

```markdown
---
description: Test runner agent
mode: subagent
permission:
  bash:
    "*": ask
    "npm test": allow
    "pytest*": allow
    "jest*": allow
---

Run tests and analyze results.
```

## WebFetch Permissions

Control web content fetching.

### Global Configuration

```json
{
  "permission": {
    "webfetch": "ask"
  }
}
```

### Agent Override

```json
{
  "agent": {
    "docs-fetcher": {
      "permission": {
        "webfetch": "allow"
      }
    },
    "offline-agent": {
      "permission": {
        "webfetch": "deny"
      }
    }
  }
}
```

### Common Patterns

**Documentation Agent** (needs web access):
```json
{
  "agent": {
    "docs": {
      "description": "Fetches and analyzes documentation",
      "permission": {
        "webfetch": "allow",
        "edit": "allow",
        "bash": "deny"
      }
    }
  }
}
```

**Offline Agent** (no web access):
```json
{
  "agent": {
    "offline": {
      "description": "Works without internet",
      "permission": {
        "webfetch": "deny"
      }
    }
  }
}
```

**Cautious Web Access**:
```json
{
  "agent": {
    "researcher": {
      "permission": {
        "webfetch": "ask"
      }
    }
  }
}
```

## Task Permissions

Control which subagents an agent can invoke.

### Syntax

```json
{
  "agent": {
    "orchestrator": {
      "permission": {
        "task": {
          "pattern": "allow|ask|deny"
        }
      }
    }
  }
}
```

### Pattern Matching

**Wildcard Deny, Specific Allow**:
```json
{
  "agent": {
    "restricted": {
      "permission": {
        "task": {
          "*": "deny",
          "explore": "allow",
          "code-reviewer": "allow"
        }
      }
    }
  }
}
```

**Allow Most, Ask for Expensive**:
```json
{
  "agent": {
    "cost-aware": {
      "permission": {
        "task": {
          "*": "allow",
          "expensive-*": "ask",
          "deep-analyzer": "ask"
        }
      }
    }
  }
}
```

**Namespace Isolation**:
```json
{
  "agent": {
    "frontend": {
      "permission": {
        "task": {
          "*": "deny",
          "frontend-*": "allow"
        }
      }
    },
    "backend": {
      "permission": {
        "task": {
          "*": "deny",
          "backend-*": "allow"
        }
      }
    }
  }
}
```

### Behavior

**When set to `deny`**:
- Subagent removed from Task tool description
- Agent won't attempt to invoke it
- Users can still invoke via @ mention

**When set to `ask`**:
- Agent can attempt invocation
- User prompted for approval
- Useful for expensive or complex subagents

**When set to `allow`**:
- Agent can invoke freely
- No user approval needed
- Fast, automated workflows

### User Override

Important: Users can always invoke any subagent directly via @ mention, even if task permissions would deny it.

**Example**:
```json
{
  "agent": {
    "build": {
      "permission": {
        "task": {
          "expensive-analyzer": "deny"
        }
      }
    }
  }
}
```

Build agent cannot invoke `expensive-analyzer`, but user can still type:
```
@expensive-analyzer analyze this complex codebase
```

## Permission Hierarchy

### Precedence Order

1. **Agent-specific permissions** (highest priority)
2. **Global permissions**
3. **Tool defaults** (lowest priority)

### Example

```json
{
  "permission": {
    "edit": "deny"
  },
  "agent": {
    "build": {
      "permission": {
        "edit": "allow"
      }
    },
    "plan": {
      "permission": {
        "edit": "deny"
      }
    },
    "review": {
      // Inherits global "deny"
    }
  }
}
```

Result:
- **build**: Can edit (agent override)
- **plan**: Cannot edit (agent override)
- **review**: Cannot edit (global default)

## Common Configuration Patterns

### Plan Agent (Analysis Only)

```json
{
  "agent": {
    "plan": {
      "permission": {
        "edit": "deny",
        "bash": {
          "*": "ask",
          "git status": "allow",
          "git diff*": "allow",
          "git log*": "allow"
        },
        "webfetch": "ask"
      }
    }
  }
}
```

### Build Agent (Full Access)

```json
{
  "agent": {
    "build": {
      "permission": {
        "edit": "allow",
        "bash": {
          "*": "ask",
          "git status": "allow",
          "npm test": "allow"
        },
        "webfetch": "allow"
      }
    }
  }
}
```

### Security Auditor (Read-Only)

```json
{
  "agent": {
    "security": {
      "permission": {
        "edit": "deny",
        "bash": {
          "*": "deny",
          "git diff*": "allow",
          "grep*": "allow"
        },
        "webfetch": "deny"
      }
    }
  }
}
```

### Test Runner (Limited Bash)

```json
{
  "agent": {
    "tester": {
      "permission": {
        "edit": "allow",
        "bash": {
          "*": "deny",
          "npm test": "allow",
          "pytest*": "allow",
          "jest*": "allow",
          "cargo test": "allow"
        },
        "webfetch": "deny"
      }
    }
  }
}
```

### Documentation Writer (No Bash)

```json
{
  "agent": {
    "docs": {
      "permission": {
        "edit": "allow",
        "bash": "deny",
        "webfetch": "allow"
      }
    }
  }
}
```

### Cautious Agent (Ask Everything)

```json
{
  "agent": {
    "cautious": {
      "permission": {
        "edit": "ask",
        "bash": "ask",
        "webfetch": "ask"
      }
    }
  }
}
```

## Best Practices

### Start Restrictive

Begin with restrictive permissions and open up as needed:

```json
{
  "agent": {
    "new-agent": {
      "permission": {
        "edit": "ask",
        "bash": "ask",
        "webfetch": "ask"
      }
    }
  }
}
```

After validating behavior:

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
        },
        "webfetch": "allow"
      }
    }
  }
}
```

### Least Privilege Principle

Grant only permissions needed for the agent's purpose:

**Analysis Agent** (read-only):
```json
{
  "permission": {
    "edit": "deny",
    "bash": "deny",
    "webfetch": "deny"
  }
}
```

**Documentation Agent** (write docs, fetch web):
```json
{
  "permission": {
    "edit": "allow",
    "bash": "deny",
    "webfetch": "allow"
  }
}
```

### Allow Safe Commands

Identify safe, commonly-used commands and allow them:

```json
{
  "permission": {
    "bash": {
      "*": "ask",
      "git status": "allow",
      "git diff": "allow",
      "git log*": "allow",
      "ls *": "allow",
      "pwd": "allow"
    }
  }
}
```

### Block Dangerous Commands

Explicitly deny destructive operations:

```json
{
  "permission": {
    "bash": {
      "*": "ask",
      "rm -rf*": "deny",
      "git reset --hard*": "deny",
      "git push --force*": "deny",
      "sudo *": "deny"
    }
  }
}
```

### Pattern Ordering

Put wildcard first, specific rules after (last match wins):

**Correct**:
```json
{
  "permission": {
    "bash": {
      "*": "ask",
      "git status": "allow"
    }
  }
}
```

**Incorrect** (specific rule overridden):
```json
{
  "permission": {
    "bash": {
      "git status": "allow",
      "*": "ask"
    }
  }
}
```

Result in incorrect version: `git status` requires approval (overridden by later `*` rule).

### Test Command Access

For test-focused agents, allow test commands:

```json
{
  "permission": {
    "bash": {
      "*": "deny",
      "npm test": "allow",
      "npm run test*": "allow",
      "pytest*": "allow",
      "jest*": "allow",
      "cargo test": "allow",
      "go test*": "allow"
    }
  }
}
```

## Markdown Configuration

Permissions in markdown agent files:

```markdown
---
description: Cautious development agent
mode: primary
permission:
  edit: ask
  bash:
    "*": ask
    "git status": allow
    "git diff*": allow
  webfetch: ask
---

Development agent that asks for approval before making changes.
```

## Troubleshooting

### Permission Not Taking Effect

**Check**:
1. Agent-specific permission overrides global
2. Pattern ordering (last match wins)
3. Syntax is valid JSON or YAML
4. Permission key is spelled correctly

### Bash Command Still Prompts

**Check**:
1. Pattern matches the actual command
2. More specific rule isn't overriding
3. Global permission isn't set to `ask`

**Debug by Adding Specificity**:
```json
{
  "permission": {
    "bash": {
      "*": "ask",
      "git status": "allow",
      "git status *": "allow"
    }
  }
}
```

### Agent Can't Invoke Subagent

**Check**:
1. Task permissions allow the subagent
2. Pattern matching is correct
3. Subagent isn't hidden (hidden subagents can still be invoked)

**Test with `allow`**:
```json
{
  "permission": {
    "task": {
      "*": "allow"
    }
  }
}
```

### User Can't Override Permission

Remember: Task permissions control agent behavior, not user behavior. Users can always:
- Invoke subagents via @ mention
- Approve operations when prompted
- Override agent suggestions

## Advanced Patterns

### Environment-Based Permissions

Use different permissions for different environments:

**Development** (permissive):
```json
{
  "agent": {
    "dev": {
      "permission": {
        "edit": "allow",
        "bash": "allow"
      }
    }
  }
}
```

**Production** (restrictive):
```json
{
  "agent": {
    "prod": {
      "permission": {
        "edit": "ask",
        "bash": {
          "*": "deny",
          "git status": "allow",
          "git diff*": "allow"
        }
      }
    }
  }
}
```

### Role-Based Permissions

Create agents for different roles:

**Junior Developer** (guided):
```json
{
  "agent": {
    "junior": {
      "permission": {
        "edit": "ask",
        "bash": "ask",
        "task": {
          "*": "allow"
        }
      }
    }
  }
}
```

**Senior Developer** (autonomous):
```json
{
  "agent": {
    "senior": {
      "permission": {
        "edit": "allow",
        "bash": {
          "*": "ask",
          "git status": "allow",
          "npm test": "allow"
        },
        "task": {
          "*": "allow"
        }
      }
    }
  }
}
```

### Task-Specific Permissions

Agents optimized for specific workflows:

**Refactoring** (full edit, limited bash):
```json
{
  "agent": {
    "refactor": {
      "permission": {
        "edit": "allow",
        "bash": {
          "*": "deny",
          "npm test": "allow",
          "git diff": "allow"
        }
      }
    }
  }
}
```

**Deployment** (no edit, controlled bash):
```json
{
  "agent": {
    "deploy": {
      "permission": {
        "edit": "deny",
        "bash": {
          "*": "ask",
          "git status": "allow",
          "npm run build": "allow",
          "git push": "ask"
        }
      }
    }
  }
}
```

## Quick Reference

### Permission Levels
- `allow` - No approval needed
- `ask` - Prompt user
- `deny` - Disabled

### Bash Pattern Syntax
```json
{
  "bash": {
    "*": "level",
    "exact command": "level",
    "pattern*": "level"
  }
}
```

### Task Permission Syntax
```json
{
  "task": {
    "*": "level",
    "subagent-name": "level",
    "pattern-*": "level"
  }
}
```

### Global vs Agent-Specific
```json
{
  "permission": {
    "edit": "deny"
  },
  "agent": {
    "build": {
      "permission": {
        "edit": "allow"
      }
    }
  }
}
```

### Common Safe Commands
```json
{
  "bash": {
    "git status": "allow",
    "git diff*": "allow",
    "git log*": "allow",
    "npm test": "allow",
    "ls *": "allow"
  }
}
```

### Common Blocked Commands
```json
{
  "bash": {
    "rm -rf*": "deny",
    "git reset --hard*": "deny",
    "git push --force*": "deny",
    "sudo *": "deny"
  }
}
```
