---
description: Gather requirements, analyze code, and create implementation plan
agent: plan
model: github-copilot/claude-sonnet-4.6
agents:
  - general
  - explore
  - security-expert
  - performance-engineer
  - architect
---

$1

# Extended Planning Workflow

You are tasked with creating a comprehensive implementation plan.

**IMPORTANT**: Load the `planning` skill for detailed workflow instructions:

```
Use the Skill tool to load: planning
```

The planning skill provides:
- Six-phase planning workflow
- Requirement gathering questions
- Codebase analysis strategies
- Agent coordination patterns
- Plan structure templates
- Plan status tracking

## Quick Overview

Follow this high-level workflow (see planning skill for details):

1. **Phase 1: Requirement Gathering** - Ask for feature name and gather requirements
2. **Phase 2: Context Analysis** - Analyze project structure and codebase
3. **Phase 3: Research and Verification** - Verify approaches and best practices
4. **Phase 4: Planning with Subagents** - Coordinate specialized agents in parallel
5. **Phase 5: Create Implementation Plan** - Generate detailed implementation plan
5. **Phase 6: Finalize and Communicate** - Summarize the plan to the user

## Available Agents

You can invoke the following specialized agents:
- **@general** - General-purpose agent for research and multi-step tasks
- **@explore** - Fast codebase exploration and pattern searching
- **@security-expert** - Security audits, threat modeling, cryptography
- **@performance-engineer** - Performance optimization and profiling
- **@architect** - System design, architectural patterns, design decisions

## Essential Rules

1. **Start by asking for feature name** (kebab-case: "oauth-authentication", "user-profile")
2. **Load the planning skill** for complete instructions
3. **Use agents in parallel** when tasks are independent

## After Creating Plan

Present the complete plan to the user and ask for their feedback. Wait for user confirmation or requested changes before proceeding.

---

**For complete instructions, load the planning skill.**
