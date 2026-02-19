# Custom Agent Examples

Practical, real-world agent configurations for various development scenarios.

## Overview

This document provides ready-to-use agent configurations for common development workflows. Each example includes:

- Complete configuration
- Use case description
- When to use the agent
- How to invoke it

Copy and adapt these examples for your own projects.

## Development Workflow Agents

### Full-Stack Development Agent

**Use Case**: Building web applications with frontend and backend components.

**Configuration** (JSON):

```json
{
  "agent": {
    "fullstack": {
      "description": "Full-stack web development with React/Node.js expertise. Use when working on both frontend and backend code.",
      "mode": "primary",
      "model": "anthropic/claude-sonnet-4-20250514",
      "temperature": 0.3,
      "tools": {
        "write": true,
        "edit": true,
        "bash": true
      },
      "permission": {
        "bash": {
          "*": "ask",
          "npm install": "ask",
          "npm run dev": "allow",
          "npm run build": "allow",
          "npm test": "allow"
        }
      }
    }
  }
}
```

**Configuration** (Markdown):

`~/.config/opencode/agents/fullstack.md`:

```markdown
---
description: Full-stack web development with React/Node.js expertise. Use when working on both frontend and backend code.
mode: primary
model: anthropic/claude-sonnet-4-20250514
temperature: 0.3
permission:
  bash:
    "*": ask
    "npm run dev": allow
    "npm run build": allow
    "npm test": allow
---

You are a full-stack development expert specializing in modern web applications.

Focus on:
- Component-based architecture
- RESTful API design
- Database integration
- Testing and deployment
```

**Usage**: Switch to this agent (Tab key) when working on full-stack features.

### Mobile Development Agent

**Use Case**: Building mobile applications with React Native or Flutter.

```json
{
  "agent": {
    "mobile": {
      "description": "Mobile app development with React Native. Use for iOS/Android development.",
      "mode": "primary",
      "model": "anthropic/claude-sonnet-4-20250514",
      "temperature": 0.3,
      "permission": {
        "bash": {
          "*": "ask",
          "npm start": "allow",
          "npx react-native*": "allow",
          "flutter*": "allow"
        }
      }
    }
  }
}
```

### DevOps Agent

**Use Case**: Infrastructure, deployment, and CI/CD workflows.

```json
{
  "agent": {
    "devops": {
      "description": "DevOps and infrastructure management. Use for deployment, Docker, K8s, and CI/CD.",
      "mode": "primary",
      "temperature": 0.2,
      "permission": {
        "bash": {
          "*": "ask",
          "docker ps": "allow",
          "docker images": "allow",
          "kubectl get*": "allow",
          "git status": "allow"
        },
        "edit": "ask"
      }
    }
  }
}
```

## Code Quality Agents

### Code Reviewer

**Use Case**: Automated code review focusing on quality and best practices.

```json
{
  "agent": {
    "code-reviewer": {
      "description": "Reviews code for quality, best practices, and potential issues. Use after implementation or when user requests review.",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4-20250514",
      "temperature": 0.1,
      "tools": {
        "write": false,
        "edit": false
      },
      "permission": {
        "bash": {
          "*": "deny",
          "git diff*": "allow"
        }
      }
    }
  }
}
```

**Prompt File** (`./prompts/code-review.txt`):

```
You are a senior code reviewer. Analyze code for:

1. Code Quality
   - Readability and clarity
   - Maintainability
   - Adherence to SOLID principles
   - Proper naming conventions

2. Best Practices
   - Design patterns usage
   - Error handling
   - Logging and debugging
   - Code organization

3. Performance
   - Algorithm efficiency
   - Resource usage
   - Potential bottlenecks
   - Caching opportunities

4. Testing
   - Test coverage
   - Edge cases
   - Test quality

Provide specific, actionable feedback with code examples.
```

**Invocation**:
```
@code-reviewer review the authentication module
```

### Security Auditor

**Use Case**: Security-focused code analysis.

```markdown
---
description: Performs security audits and identifies vulnerabilities. Use when reviewing security-critical code or user requests security analysis.
mode: subagent
model: anthropic/claude-sonnet-4-20250514
temperature: 0.1
tools:
  write: false
  edit: false
permission:
  bash:
    "*": deny
    "git diff*": allow
    "grep*": allow
---

You are a security expert. Focus on:

- Input validation and sanitization
- Authentication and authorization flaws
- SQL injection vulnerabilities
- XSS and CSRF risks
- Sensitive data exposure
- Cryptography misuse
- Dependency vulnerabilities
- Configuration security

Provide severity ratings (Critical, High, Medium, Low) and remediation guidance.
```

**Invocation**:
```
@security-auditor audit the payment processing code
```

### Performance Analyzer

**Use Case**: Identify performance bottlenecks and optimization opportunities.

```json
{
  "agent": {
    "perf-analyzer": {
      "description": "Analyzes code for performance issues and optimization opportunities. Use when user reports slowness or requests optimization.",
      "mode": "subagent",
      "temperature": 0.1,
      "tools": {
        "write": false,
        "edit": false
      },
      "permission": {
        "bash": {
          "*": "deny",
          "npm run benchmark": "allow",
          "node --prof*": "allow"
        }
      }
    }
  }
}
```

## Testing Agents

### Test Generator

**Use Case**: Automatic test generation for code.

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
          "pytest*": "allow",
          "jest*": "allow"
        }
      }
    }
  }
}
```

**Prompt File** (`./prompts/test-writer.txt`):

```
You are a testing expert. Generate comprehensive tests:

1. Unit Tests
   - Test individual functions/methods
   - Cover edge cases and error conditions
   - Use descriptive test names
   - Follow AAA pattern (Arrange, Act, Assert)

2. Integration Tests
   - Test component interactions
   - Test external integrations
   - Mock external dependencies appropriately

3. Test Quality
   - High coverage of critical paths
   - Clear, maintainable tests
   - Proper setup and teardown
   - Avoid test interdependencies

Use the project's existing testing framework and conventions.
```

**Invocation**:
```
@test-writer generate tests for the UserService class
```

### TDD Agent

**Use Case**: Test-driven development workflow.

```json
{
  "agent": {
    "tdd": {
      "description": "Test-driven development workflow. Writes tests first, then implementation.",
      "mode": "primary",
      "temperature": 0.2,
      "permission": {
        "bash": {
          "*": "deny",
          "npm test": "allow",
          "npm run test:watch": "allow",
          "pytest*": "allow",
          "jest*": "allow"
        }
      }
    }
  }
}
```

## Documentation Agents

### Documentation Writer

**Use Case**: Generate and maintain project documentation.

```markdown
---
description: Writes and maintains technical documentation. Use when user requests docs, README updates, or API documentation.
mode: subagent
temperature: 0.3
tools:
  bash: false
permission:
  edit: allow
  webfetch: allow
---

You are a technical writer. Create clear, comprehensive documentation.

Focus on:
- User-friendly language
- Clear structure with headings
- Code examples and usage
- Common pitfalls and troubleshooting
- Links to related resources

Use Markdown formatting and follow the project's documentation style.
```

**Invocation**:
```
@docs-writer update the API documentation for the new endpoints
```

### API Documentation Generator

**Use Case**: Generate OpenAPI/Swagger documentation.

```json
{
  "agent": {
    "api-docs": {
      "description": "Generates API documentation from OpenAPI specs. Use when user mentions API docs, OpenAPI, or Swagger.",
      "mode": "subagent",
      "temperature": 0.2,
      "tools": {
        "write": true,
        "edit": true,
        "bash": false
      },
      "permission": {
        "webfetch": "allow"
      }
    }
  }
}
```

## Specialized Language Agents

### Python Specialist

**Use Case**: Python-specific development and best practices.

```json
{
  "agent": {
    "python-expert": {
      "description": "Python development expert. Use for Python-specific questions, Django, Flask, data science.",
      "mode": "primary",
      "temperature": 0.3,
      "permission": {
        "bash": {
          "*": "ask",
          "python -m*": "allow",
          "pip install*": "ask",
          "pytest*": "allow",
          "python manage.py*": "allow"
        }
      }
    }
  }
}
```

### Rust Specialist

**Use Case**: Rust development with focus on safety and performance.

```json
{
  "agent": {
    "rust-expert": {
      "description": "Rust development expert. Use for Rust-specific questions, ownership, lifetimes, async.",
      "mode": "primary",
      "temperature": 0.3,
      "permission": {
        "bash": {
          "*": "ask",
          "cargo build": "allow",
          "cargo test": "allow",
          "cargo run": "allow",
          "cargo clippy": "allow"
        }
      }
    }
  }
}
```

### Go Specialist

**Use Case**: Go development with focus on concurrency and simplicity.

```json
{
  "agent": {
    "go-expert": {
      "description": "Go development expert. Use for Go-specific questions, goroutines, channels, microservices.",
      "mode": "primary",
      "temperature": 0.3,
      "permission": {
        "bash": {
          "*": "ask",
          "go build": "allow",
          "go test*": "allow",
          "go run": "allow",
          "go mod*": "allow"
        }
      }
    }
  }
}
```

## Workflow-Specific Agents

### Refactoring Specialist

**Use Case**: Code refactoring and architecture improvements.

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

**Prompt File** (`./prompts/refactoring.txt`):

```
You are a refactoring expert. Improve code while maintaining functionality:

1. Code Smells to Address
   - Long methods/functions
   - Duplicate code
   - Large classes
   - Too many parameters
   - Complex conditionals

2. Refactoring Techniques
   - Extract method/function
   - Extract class/module
   - Introduce parameter object
   - Replace conditional with polymorphism
   - Simplify conditional expressions

3. Principles
   - Keep changes small and focused
   - Run tests after each change
   - Maintain backward compatibility
   - Document breaking changes

Always run tests to verify refactoring doesn't break functionality.
```

### Bug Hunter

**Use Case**: Debugging and bug investigation.

```json
{
  "agent": {
    "debugger": {
      "description": "Investigates and fixes bugs. Use when user reports errors or unexpected behavior.",
      "mode": "primary",
      "temperature": 0.1,
      "permission": {
        "bash": {
          "*": "ask",
          "git log*": "allow",
          "git diff*": "allow",
          "git show*": "allow",
          "npm test": "allow"
        }
      }
    }
  }
}
```

### Migration Specialist

**Use Case**: Framework or library migrations.

```markdown
---
description: Assists with framework and library migrations. Use when upgrading dependencies or migrating to new frameworks.
mode: subagent
temperature: 0.2
permission:
  bash:
    "*": ask
    "npm outdated": allow
    "npm run test": allow
---

You are a migration expert. Guide smooth transitions:

1. Pre-Migration
   - Document current state
   - Identify breaking changes
   - Plan migration steps
   - Set up rollback strategy

2. Migration Process
   - Update dependencies incrementally
   - Fix breaking changes
   - Update tests
   - Update documentation

3. Validation
   - Run full test suite
   - Verify critical paths
   - Check for deprecation warnings
   - Performance comparison

Prioritize stability and minimal disruption.
```

## Project-Type Agents

### Frontend Agent

**Use Case**: Frontend-focused development.

```json
{
  "agent": {
    "frontend": {
      "description": "Frontend development with React, CSS, accessibility. Use for UI/UX work.",
      "mode": "primary",
      "temperature": 0.3,
      "permission": {
        "bash": {
          "*": "ask",
          "npm run dev": "allow",
          "npm run build": "allow",
          "npm run lint": "allow"
        },
        "task": {
          "*": "deny",
          "frontend-*": "allow",
          "explore": "allow",
          "code-reviewer": "allow"
        }
      }
    }
  }
}
```

### Backend Agent

**Use Case**: Backend and API development.

```json
{
  "agent": {
    "backend": {
      "description": "Backend API development with Node.js, databases, authentication. Use for server-side work.",
      "mode": "primary",
      "temperature": 0.3,
      "permission": {
        "bash": {
          "*": "ask",
          "npm run dev": "allow",
          "docker-compose up": "allow",
          "npm test": "allow"
        },
        "task": {
          "*": "deny",
          "backend-*": "allow",
          "explore": "allow",
          "security-auditor": "allow"
        }
      }
    }
  }
}
```

### Data Science Agent

**Use Case**: Data analysis and machine learning.

```json
{
  "agent": {
    "data-scientist": {
      "description": "Data science and ML development with Python, Jupyter, pandas. Use for data analysis and ML tasks.",
      "mode": "primary",
      "temperature": 0.3,
      "permission": {
        "bash": {
          "*": "ask",
          "python -m jupyter*": "allow",
          "python -m pytest": "allow",
          "pip install*": "ask"
        }
      }
    }
  }
}
```

## Multi-Agent Workflows

### Orchestrator Pattern

**Use Case**: Complex workflows requiring multiple specialized agents.

```json
{
  "agent": {
    "orchestrator": {
      "description": "Orchestrates complex multi-step workflows by coordinating specialized agents.",
      "mode": "primary",
      "temperature": 0.3,
      "permission": {
        "task": {
          "explore": "allow",
          "code-reviewer": "allow",
          "test-writer": "allow",
          "docs-writer": "allow",
          "security-auditor": "ask"
        },
        "bash": "ask",
        "edit": "allow"
      }
    }
  }
}
```

**Example Workflow**:
1. User: "Implement user authentication with OAuth"
2. Orchestrator invokes @explore to find existing auth code
3. Orchestrator implements OAuth integration
4. Orchestrator invokes @test-writer to generate tests
5. Orchestrator invokes @security-auditor to review
6. Orchestrator invokes @docs-writer to document

### Feature Development Team

**Use Case**: Complete feature development with quality checks.

```json
{
  "agent": {
    "feature-dev": {
      "description": "Complete feature development with testing and review",
      "mode": "primary",
      "permission": {
        "task": {
          "*": "deny",
          "explore": "allow",
          "test-writer": "allow",
          "code-reviewer": "allow"
        }
      }
    },
    "feature-explorer": {
      "description": "Explores codebase for feature context",
      "mode": "subagent",
      "hidden": true,
      "tools": {
        "write": false,
        "edit": false
      }
    },
    "feature-tester": {
      "description": "Generates tests for new features",
      "mode": "subagent",
      "hidden": true,
      "permission": {
        "bash": {
          "*": "deny",
          "npm test": "allow"
        }
      }
    }
  }
}
```

## Environment-Specific Agents

### Production Debugger

**Use Case**: Safe debugging in production environments.

```json
{
  "agent": {
    "prod-debug": {
      "description": "Production-safe debugging and investigation. Read-only with limited bash.",
      "mode": "primary",
      "temperature": 0.1,
      "tools": {
        "write": false,
        "edit": false
      },
      "permission": {
        "bash": {
          "*": "deny",
          "git log*": "allow",
          "git show*": "allow",
          "docker logs*": "allow",
          "kubectl logs*": "allow"
        }
      }
    }
  }
}
```

### Development Playground

**Use Case**: Experimentation and prototyping.

```json
{
  "agent": {
    "playground": {
      "description": "Experimental development and prototyping. Full permissions for rapid iteration.",
      "mode": "primary",
      "temperature": 0.5,
      "permission": {
        "bash": "allow",
        "edit": "allow",
        "webfetch": "allow"
      }
    }
  }
}
```

## Cost-Optimized Agents

### Fast Planner

**Use Case**: Quick planning with cheaper models.

```json
{
  "agent": {
    "quick-plan": {
      "description": "Fast planning and analysis with Haiku. Use for quick reviews and planning.",
      "mode": "primary",
      "model": "anthropic/claude-haiku-4-20250514",
      "temperature": 0.1,
      "steps": 3,
      "tools": {
        "write": false,
        "edit": false
      },
      "permission": {
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

### Budget Explorer

**Use Case**: Code exploration with minimal tokens.

```json
{
  "agent": {
    "budget-explore": {
      "description": "Cost-effective codebase exploration",
      "mode": "subagent",
      "model": "anthropic/claude-haiku-4-20250514",
      "temperature": 0.1,
      "steps": 5,
      "tools": {
        "write": false,
        "edit": false,
        "bash": false
      }
    }
  }
}
```

## Tips for Custom Agents

### Naming

**Good Names**:
- Descriptive: `code-reviewer`, `test-writer`, `frontend`
- Role-based: `security-auditor`, `perf-analyzer`
- Language-specific: `python-expert`, `rust-expert`

**Avoid**:
- Generic: `agent1`, `helper`, `worker`
- Too long: `advanced-code-quality-reviewer-with-security`

### Descriptions

**Effective Descriptions Include**:
1. What the agent does
2. When to invoke it
3. Specific trigger phrases users would say

**Example**:
```
"Reviews code for quality, security, and performance. Use after implementation, when user requests review, or mentions code quality."
```

### Temperature Selection

**Task-Based Guidelines**:
- 0.0-0.1: Security audits, bug analysis
- 0.1-0.2: Code review, testing, refactoring
- 0.2-0.4: Documentation, feature development
- 0.4-0.6: Design, architecture, brainstorming

### Permission Strategy

**Progressive Permission Opening**:

1. **Start** (restrictive):
```json
{
  "permission": {
    "edit": "ask",
    "bash": "ask"
  }
}
```

2. **Test** agent behavior

3. **Open up** safe operations:
```json
{
  "permission": {
    "edit": "allow",
    "bash": {
      "*": "ask",
      "git status": "allow",
      "npm test": "allow"
    }
  }
}
```
