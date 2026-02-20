---
name: planning
description: This skill should be used when the user asks to "create an implementation plan", "plan a feature", "create detailed plan", "analyze requirements", or needs comprehensive project planning with requirements gathering and architectural analysis.
---

# Implementation Planning

Create comprehensive, actionable implementation plans for features and projects through structured requirement gathering, codebase analysis, and detailed planning.

## What This Skill Provides

This skill enables creating comprehensive, actionable implementation plans that include:

- **Structured requirement gathering** - Systematic questions to understand features completely
- **Codebase analysis** - Automated exploration of project structure and patterns
- **Multi-phase planning** - Requirements, research, architecture, implementation details
- **Parallel agent coordination** - Leverage specialized agents for complex analysis

## When to Use This Skill

Use this skill when:
- User requests a detailed implementation plan
- Feature requires architectural decisions
- Need to analyze existing codebase before implementation
- Multiple teams or modules are involved
- Security, performance, or scalability considerations exist

## Core Planning Workflow

Follow this six-phase workflow to create comprehensive plans:

### Phase 1: Requirement Gathering

**FIRST**: Ask for a feature name (kebab-case):
```
Examples: "oauth-authentication", "user-profile", "data-export"
```

The feature name becomes the plan filename: `.opencode/plans/plan-<feature-name>.md`

**THEN**: Ask requirement questions:
- What is the goal or feature to be implemented?
- What are the key requirements and constraints?
- Are there specific technical requirements or preferences?
- What is the expected outcome or deliverables?
- Are there dependencies or integration points?

**Important**: Don't proceed without the feature name and clear answers.

### Phase 2: Context Analysis

Analyze the project automatically:

**Project Structure**:
```bash
find . -type f -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.py" -o -name "*.go" -o -name "*.java" | head -50
```

**Git Context**:
```bash
git status
git log --oneline -10
```

**Codebase Analysis**:
1. Use the **explore agent** to identify:
   - Relevant files and modules
   - Existing patterns and conventions
   - Technology stack and frameworks
   - Architecture patterns

2. Load appropriate skills based on detected technologies:
   - TypeScript, Python, Go, etc.
   - Framework-specific skills (React, Vue, etc.)

3. Use parallel subagents where beneficial:
   - Frontend analysis (if applicable)
   - Backend analysis (if applicable)
   - Database schema review (if applicable)
   - API design review (if applicable)

### Phase 3: Research and Verification

**Web Search** for uncertain approaches:
- Official documentation
- Current best practices
- Known issues or gotchas
- Relevant examples or patterns

**Consult Documentation**:
- Framework documentation
- Library API references
- Internal project documentation

### Phase 4: Planning with Subagents

Utilize specialized agents in parallel where appropriate:

1. **Architecture Agent** - System design decisions
2. **Security Agent** - Security considerations
3. **Performance Agent** - Performance optimization strategies
4. **Frontend Agent** - UI/UX implementation (if applicable)
5. **Backend Agent** - Server-side implementation (if applicable)

Run agents in parallel when work is independent to maximize efficiency.

### Phase 5: Create Implementation Plan

Generate a detailed plan with these sections:

1. **Overview** - Summary, goals, success criteria, high-level approach
2. **Technical Architecture** - Components, data flow, integration points
3. **Implementation Steps** - Step-by-step tasks with file changes and code snippets
4. **Dependencies** - External packages, internal modules, API integrations
5. **Testing Strategy** - Unit, integration, E2E tests required
6. **Security Considerations** - Auth impacts, validation, best practices
7. **Performance Considerations** - Impact, optimization, scalability
8. **Migration Path** - Breaking changes, data migration, rollback strategy
9. **Documentation Updates** - Code docs, README, API docs
10. **Rollout Plan** - Deployment steps, feature flags, monitoring

See **`references/plan-structure.md`** for detailed section templates.

### Phase 6: Output Plan File and User Verification

**Present plan summary to user for verification**:
```
📋 Plan Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Feature: <feature-name>
Description: <brief description>

Key Components:
• <Component 1>
• <Component 2>
• <Component 3>

Implementation Steps: <count> steps
Estimated Complexity: <Low/Medium/High>

Dependencies:
• <Dependency 1>
• <Dependency 2>

Security Considerations: <Yes/No>
Performance Considerations: <Yes/No>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Please review the plan summary above.
Would you like to proceed with this plan? (yes/no)
```

**Wait for user confirmation**:
- If user confirms: Proceed with implementation using `/implement`
- If user wants changes: Ask what needs to be modified and update the plan
- If user rejects: Ask if they want to gather different requirements

## Plan Quality Standards

The plan file must be:
- **Comprehensive** - Cover all aspects of implementation
- **Actionable** - Clear steps that can be followed directly
- **Detailed** - Include code snippets, file paths, specific instructions
- **Ready to implement** - No ambiguity or missing information

## Execution Checklist

- [ ] Start by asking for feature name
- [ ] Ask requirement questions thoroughly
- [ ] Use agents in parallel when tasks are independent
- [ ] Load skills proactively based on detected technologies
- [ ] Web search for verification of best practices
- [ ] Think step-by-step through the phases
- [ ] Be thorough enough for another developer to implement
- [ ] Verify user understanding of the plan before proceeding to implementation

## Additional Resources

### Reference Files

- **`references/plan-structure.md`** - Detailed templates for all 10 plan sections
- **`references/requirement-questions.md`** - Comprehensive question catalog for different feature types
- **`references/agent-coordination.md`** - Strategies for parallel agent usage
- **`references/plan-tracking.md`** - Plan status management and workflow integration

## Quick Reference: Feature Name Examples

| Feature Type | Good Name | Bad Name |
|--------------|-----------|----------|
| Authentication | `oauth-authentication` | `auth`, `login` |
| User Profile | `user-profile-edit` | `profile`, `user` |
| Data Export | `csv-data-export` | `export`, `download` |
| API Integration | `stripe-payment-api` | `payments`, `stripe` |
| Database Migration | `user-table-migration` | `migration`, `db-update` |

Feature names should be:
- Descriptive and specific
- Lowercase with hyphens (kebab-case)
- Unique within the project
- 2-4 words typically

## Summary

Use this skill to create comprehensive implementation plans that:
1. Gather complete requirements upfront
2. Analyze existing codebase automatically
3. Research best practices and verify approaches
4. Coordinate specialized agents in parallel
5. Generate detailed, actionable plans
6. Present plans to users for confirmation before proceeding

The resulting plans are production-ready and can be handed to any developer for implementation without additional questions.
