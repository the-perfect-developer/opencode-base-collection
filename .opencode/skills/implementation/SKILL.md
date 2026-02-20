---
name: implementation
description: This skill should be used when the user asks to "implement a plan", "execute implementation", "build from plan", "implement feature", or needs to orchestrate execution of an implementation plan with specialized engineering agents.
---

# Implementation Orchestration

Execute implementation plans by orchestrating specialized engineering agents, ensuring quality through expert consultation, and maintaining comprehensive tracking throughout the build process.

## What This Skill Provides

This skill enables executing implementation plans through:

- **Agent orchestration** - Coordinate specialized agents (frontend, backend, security, etc.)
- **Task breakdown and tracking** - Create comprehensive todo lists from plans
- **Parallel execution** - Run independent tasks simultaneously for efficiency
- **Quality assurance** - Security, performance, and code quality reviews
- **Execution management** - Track implementation progress and completion

## When to Use This Skill

Use this skill when:
- User requests implementation of a plan (from extended-planning session)
- Coordinating multiple specialized agents
- Building complex features requiring expert consultation
- Want to ensure quality throughout implementation

## Core Implementation Workflow

Follow this six-phase workflow to execute implementation plans:

### Phase 1: Plan Analysis & Task Breakdown

**Analyze complexity** of each section:
- Simple tasks → `@junior-engineer`
- Frontend tasks → `@frontend-engineer`
- Backend tasks → `@backend-engineer`
- Complex tasks → `@architect` then engineer

**Identify critical aspects**:
- Security implications → Always `@security-expert`
- Performance-critical code → Always `@performance-engineer`
- Architectural decisions → Always `@architect`

**Create task list** using TodoWrite:
- Break plan into discrete tasks
- Mark dependencies
- Prioritize based on plan order

See **`references/agent-selection.md`** for detailed agent assignment rules.

### Phase 2: Orchestration Strategy

**Parallel execution** for independent tasks:
- Multiple frontend components simultaneously
- Independent backend services in parallel
- Tests written while implementation ongoing

**Sequential execution** for dependent tasks:
- Database schema before API implementation
- Core services before dependent features
- Architectural decisions before implementation

See **`references/parallel-execution.md`** for coordination patterns.

### Phase 3: Execution Workflow

For each task in the plan:

**1. Pre-Implementation Consultation**

For complex/sensitive tasks:
1. Consult `@architect` for design approach
2. Consult `@security-expert` if security-related
3. Consult `@performance-engineer` if performance-critical
4. Get approval before proceeding

**2. Task Assignment**

Assign to appropriate agent:
- Simple tasks → `@junior-engineer`
- UI/frontend → `@frontend-engineer`
- APIs/backend → `@backend-engineer`

**3. Skill Loading**

Load appropriate skills based on technology:
- TypeScript/JavaScript → `typescript-style` or `javascript` skill
- Python → `python` skill
- Go → `go` skill
- CSS/Tailwind → `css` or `tailwind-css` skill
- HTML → `html` skill

**4. Documentation & Research**

Use web search for:
- Official framework documentation
- Library API references
- Best practices
- Known issues or gotchas

**5. Implementation**

Give agents clear, specific instructions:
```
Task: [Specific task from plan]
Context: [Relevant context]
Requirements:
  - [Requirement 1]
  - [Requirement 2]
Files to modify/create:
  - [File path 1]
Success criteria:
  - [How to verify completion]
```

**6. Verification**

After each task:
1. Run relevant tests
2. Check for type errors
3. Verify functionality
4. Run linter/formatter
5. Check security implications
6. Mark todo as completed

See **`references/execution-workflow.md`** for detailed implementation steps.

### Phase 4: Quality Assurance

**Security Review**:
- Before committing security code, get `@security-expert` review
- Verify input validation
- Check authentication/authorization
- Review data handling

**Performance Review**:
- Before committing performance-critical code, get `@performance-engineer` review
- Check query efficiency
- Verify caching implementation
- Review resource usage

**Code Quality**:
- Follow style guide (use loaded skills)
- Maintain consistency
- Add appropriate comments
- Update documentation

See **`references/quality-assurance.md`** for comprehensive QA guidelines.

### Phase 5: Testing & Validation

Run tests according to plan's testing strategy:
```bash
git status
npm test || pytest || go test ./...
```

If tests fail:
1. Analyze failures
2. Assign fixes to appropriate agent
3. Re-run tests
4. Repeat until passing

### Phase 6: Final Steps & Documentation

**1. Documentation**
- Update README if needed
- Add/update code comments
- Generate API docs if applicable
- Update user documentation

**2. Git Status Check**
```bash
git status
git diff --stat
```

**3. Implementation Summary**

Display completion status:
```
✅ Implementation completed
📊 Summary:
- Tasks completed: <count>
- Files changed: <count>
- Tests: <passing/total>
```

See **`references/completion-workflow.md`** for final step details.

## Agent Selection Quick Reference

| Task Type | Primary Agent | Consult | Skills to Load |
|-----------|---------------|---------|----------------|
| Simple bug fix | @junior-engineer | - | Language skill |
| UI component | @frontend-engineer | - | Frontend skills |
| API endpoint | @backend-engineer | @architect | Language skill |
| Authentication | @backend-engineer | @security-expert, @architect | Security patterns |
| Performance optimization | @backend-engineer | @performance-engineer | - |
| Architecture change | @architect | - | - |
| Database schema | @backend-engineer | @architect | - |

## Orchestration Best Practices

**DO**:
- ✅ Use TodoWrite to track all tasks
- ✅ Run independent agents in parallel
- ✅ Load relevant skills before implementation
- ✅ Consult experts (architect, security, performance) early
- ✅ Web search for documentation and best practices
- ✅ Mark todos as completed immediately
- ✅ Run tests frequently
- ✅ Keep security and performance experts in the loop

**DON'T**:
- ❌ Skip plan analysis
- ❌ Assign complex tasks to junior-engineer
- ❌ Forget to load appropriate skills
- ❌ Implement security features without security-expert review
- ❌ Skip performance review for critical paths
- ❌ Make architectural decisions without architect consultation
- ❌ Forget to update tests
- ❌ Leave todos in "in_progress" state

## Error Handling

If implementation fails:

1. **Analyze the error**: What went wrong? Which component?
2. **Consult appropriate expert**: Type errors → Architect, Security → Security Expert
3. **Assign fix**: Simple → junior-engineer, Complex → specialist
4. **Verify fix**: Run tests, check functionality, update todos

## Execution Checklist

- [ ] Create comprehensive todo list from plan sections
- [ ] Analyze task complexity for agent assignment
- [ ] Consult experts for complex/critical tasks
- [ ] Load appropriate skills based on technology
- [ ] Execute tasks (parallel when possible)
- [ ] Verify each task completion
- [ ] Run tests frequently
- [ ] Perform security and performance reviews
- [ ] Update documentation
- [ ] Display implementation summary

## Additional Resources

### Reference Files

- **`references/agent-selection.md`** - Detailed rules for choosing the right agent for each task type
- **`references/parallel-execution.md`** - Strategies for coordinating parallel agent execution
- **`references/execution-workflow.md`** - Step-by-step implementation workflow with examples
- **`references/quality-assurance.md`** - Comprehensive QA guidelines for security, performance, and code quality
- **`references/completion-workflow.md`** - Final steps, status updates, and summary generation

## Quick Start Example

```
1. User: "/implement" (after planning session)
2. Create todo list from plan sections
3. Start task 1: Consult @architect
4. Execute task 1: Assign to @backend-engineer
5. Verify task 1: Run tests
6. Mark task 1 complete
7. Continue through all tasks
8. Display summary
```

## Summary

Use this skill to orchestrate complex implementations by:
1. Analyzing plan requirements and breaking into tasks
2. Assigning tasks to appropriate agents based on complexity
3. Coordinating parallel execution where possible
4. Consulting experts (architect, security, performance) early
5. Ensuring quality through comprehensive reviews
6. Tracking progress with todos
7. Completing implementation with full documentation and testing

The resulting implementations are production-ready, thoroughly tested, and properly documented.
