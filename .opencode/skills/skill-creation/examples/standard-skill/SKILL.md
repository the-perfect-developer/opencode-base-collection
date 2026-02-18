---
name: standard-skill
description: This skill should be used when the user asks to "demonstrate standard skill structure", "show skill with references", or needs an example of the recommended skill organization pattern.
---

# Standard Skill Example

This demonstrates the recommended OpenCode skill structure with progressive disclosure.

## What This Demonstrates

A standard skill consists of:
- `SKILL.md` with core content (~1,500-2,000 words)
- `references/` directory with detailed documentation
- Progressive disclosure for efficient context usage

This is the **recommended structure** for most skills.

## When to Use Standard Structure

Use this structure when:
- Content exceeds 2,000 words total
- Need detailed documentation
- Have multiple sub-topics
- Want efficient progressive disclosure

This covers 80% of skill use cases.

## Structure

```
standard-skill/
├── SKILL.md
└── references/
    └── detailed-guide.md
```

**SKILL.md** contains:
- Overview and key concepts
- Core workflows and procedures
- Quick reference material
- Pointers to references/

**references/** contains:
- Detailed patterns and techniques
- Comprehensive documentation
- Troubleshooting guides
- Advanced use cases

## Progressive Disclosure in Action

### Level 1: Metadata (Always Loaded)

The skill name and description from frontmatter:
- ~50-100 words
- Helps agents decide whether to load skill

### Level 2: SKILL.md Body (Loaded When Triggered)

Core content in this file:
- ~1,500-2,000 words
- Essential procedures and workflows
- Quick reference tables
- Loaded when agent decides skill is relevant

### Level 3: References (Loaded As Needed)

Detailed documentation in `references/`:
- 2,000-5,000+ words per file
- Loaded only when agent needs specific details
- Keeps context efficient

## Content Allocation Strategy

### What Goes in SKILL.md

**Include**:
- Purpose and overview
- Core workflows (step-by-step)
- Quick reference tables
- Common use cases
- Pointers to references/

**Keep focused**: 1,500-2,000 words

### What Goes in references/

**Include**:
- Detailed patterns and techniques
- Comprehensive API documentation
- Edge cases and troubleshooting
- Advanced use cases
- Migration guides

**Be comprehensive**: 2,000-5,000+ words per file

## Example: API Design Skill

Here's how a real skill might be organized:

**SKILL.md** (1,800 words):
```markdown
# API Design

## Overview
Core principles of RESTful API design...

## Core Workflow
1. Define resources
2. Choose HTTP methods
3. Design URL structure
4. Define response formats
5. Handle errors

## Quick Reference: HTTP Methods
| Method | Purpose      | Idempotent |
|--------|-------------|------------|
| GET    | Retrieve    | Yes        |
| POST   | Create      | No         |
| PUT    | Replace     | Yes        |
| PATCH  | Update      | No         |
| DELETE | Remove      | Yes        |

## Common Patterns
[Brief overview of pagination, filtering, sorting]

## Additional Resources
- **`references/rest-principles.md`** - Detailed REST constraints
- **`references/authentication.md`** - Auth strategies
- **`references/versioning.md`** - API versioning approaches
```

**references/rest-principles.md** (2,400 words):
```markdown
# Detailed REST Principles

## Resource-Oriented Design
[Comprehensive explanation - 800 words]

## Uniform Interface
[Detailed coverage - 600 words]

## Statelessness
[In-depth discussion - 500 words]

## HATEOAS
[Complete guide - 500 words]
```

**references/authentication.md** (2,100 words):
```markdown
# Authentication Strategies

## API Keys
[Detailed guide - 500 words]

## OAuth 2.0
[Comprehensive coverage - 800 words]

## JWT
[Complete explanation - 500 words]

## Best Practices
[Security guidance - 300 words]
```

## Benefits

### Context Efficiency

**Without progressive disclosure**:
- Single file: 6,300 words
- All loaded when skill triggers
- High context cost

**With progressive disclosure**:
- SKILL.md: 1,800 words (always loaded)
- references/: 4,500 words (loaded as needed)
- **71% reduction** in typical context usage

### Maintainability

**Organized structure**:
- Core content separate from details
- Easy to update specific topics
- Clear responsibility per file

**Scalability**:
- Add new reference files as topics grow
- SKILL.md stays focused
- No single file becomes unwieldy

## Creating a Standard Skill

### Step 1: Create Structure

```bash
mkdir -p my-skill/references
touch my-skill/SKILL.md
```

### Step 2: Write SKILL.md

Create frontmatter and core content:

```yaml
---
name: my-skill
description: This skill should be used when the user asks to "trigger 1", "trigger 2", or needs specific guidance.
---

# My Skill

## Overview
[2-3 sentences]

## Core Workflow
[Essential procedures]

## Quick Reference
[Tables, commands]

## Additional Resources
- **`references/detailed-guide.md`** - Comprehensive documentation
```

### Step 3: Create Reference Files

Add detailed documentation:

```bash
touch my-skill/references/detailed-guide.md
```

Write comprehensive content in each reference file.

### Step 4: Reference Resources

Always mention reference files in SKILL.md so agents know they exist.

## When to Upgrade

Upgrade to complete structure when:
- Need working code examples → Add examples/
- Have utility scripts → Add scripts/
- Require automation tools → Add scripts/

See `complete-skill` example for full structure.

## Additional Resources

### Reference Files

This skill includes demonstration reference files:
- **`references/detailed-guide.md`** - Example of detailed documentation structure

Study this reference to see how to organize comprehensive content separate from core SKILL.md content.

## Summary

**Standard structure** (SKILL.md + references/) is the recommended pattern for most skills:

**Use when**:
- Content exceeds 2,000 words
- Need detailed documentation
- Want progressive disclosure

**Benefits**:
- Efficient context usage
- Better organization
- Easy to maintain
- Scalable as content grows

**Structure**:
```
skill-name/
├── SKILL.md (1,500-2,000 words)
└── references/
    ├── topic1.md (2,000-5,000 words)
    ├── topic2.md (2,000-5,000 words)
    └── topic3.md (2,000-5,000 words)
```

This is the sweet spot for most OpenCode skills - focused core content with detailed references available on demand.
