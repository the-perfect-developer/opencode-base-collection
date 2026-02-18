# Common Patterns and Anti-Patterns

This reference demonstrates how to organize pattern documentation for a skill.

## Purpose

Pattern documentation helps agents and users understand:
- Proven approaches (patterns)
- Approaches to avoid (anti-patterns)
- When to use each pattern
- Implementation guidance

## Pattern Catalog

### Pattern 1: Incremental Implementation

**What**: Build skills iteratively, starting simple and adding complexity

**When to use**:
- Creating new skill
- Uncertain about requirements
- Want fast initial results

**Implementation**:

1. **Start minimal** - Single SKILL.md file
2. **Test with real use cases** - Gather feedback
3. **Add references** - When content exceeds 2,000 words
4. **Add examples** - When users need code samples
5. **Add scripts** - When automation provides value

**Benefits**:
- Quick to initial version
- Learn requirements through usage
- Avoid over-engineering
- Adapt based on real needs

**Example**:

```
Iteration 1:
skill-name/
└── SKILL.md (800 words)

Iteration 2:
skill-name/
├── SKILL.md (1,200 words)
└── references/
    └── detailed.md (1,500 words)

Iteration 3:
skill-name/
├── SKILL.md (1,800 words)
├── references/
│   ├── detailed.md (2,500 words)
│   └── advanced.md (1,800 words)
└── examples/
    └── example.sh
```

---

### Pattern 2: Topic-Based Reference Organization

**What**: Organize references/ by topic, not by document type

**When to use**:
- Multiple distinct topics
- Each topic has substantial content
- Want clear separation of concerns

**Implementation**:

Good (topic-based):
```
references/
├── authentication.md    - All auth-related content
├── authorization.md     - All authz-related content
└── encryption.md        - All encryption-related content
```

Bad (type-based):
```
references/
├── concepts.md          - Mixed concepts from all topics
├── examples.md          - Mixed examples from all topics
└── troubleshooting.md   - Mixed troubleshooting from all topics
```

**Benefits**:
- Related information together
- Easy to find topic-specific details
- Natural organization
- Scales better

---

### Pattern 3: Executable Examples

**What**: Make all examples runnable without modification

**When to use**:
- Providing code samples
- Users need working implementations
- Want to demonstrate best practices

**Implementation**:

```bash
#!/bin/bash
# examples/complete-workflow.sh
#
# This example demonstrates a complete workflow.
# Run it directly: ./examples/complete-workflow.sh
#
# Prerequisites:
# - bash 4.0+
# - git installed
# - Current directory is a git repository

set -euo pipefail

echo "Step 1: Checking git status..."
git status

echo "Step 2: Creating feature branch..."
git checkout -b feature/example

echo "Step 3: Making changes..."
echo "Example content" > example.txt
git add example.txt

echo "Step 4: Committing..."
git commit -m "Add example file"

echo "Workflow complete!"
echo "To cleanup: git checkout main && git branch -D feature/example"
```

**Benefits**:
- Users can test immediately
- Reduces confusion
- Demonstrates best practices in working code
- Easier to maintain (can run to verify)

---

### Pattern 4: Self-Documenting Scripts

**What**: Scripts include usage information and help text

**When to use**:
- All utility scripts
- Any script users might run directly

**Implementation**:

```bash
#!/bin/bash
# scripts/validate.sh - Validate skill structure

# Usage information
usage() {
    cat <<EOF
Usage: $0 <skill-path>

Validates OpenCode skill structure and frontmatter.

Arguments:
  skill-path    Path to skill directory containing SKILL.md

Examples:
  $0 .opencode/skills/my-skill
  $0 ~/.config/opencode/skills/global-skill

Exit codes:
  0 - Validation passed
  1 - Validation failed
  2 - Usage error
EOF
}

# Show help if requested or no arguments
if [[ $# -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    usage
    exit 0
fi

# ... validation logic ...
```

**Benefits**:
- Self-documenting
- Users can get help with -h
- Clear usage examples
- Professional presentation

---

### Pattern 5: Progressive Complexity in Content

**What**: Order content from simple to complex

**When to use**:
- Writing any skill content
- Content spans beginner to advanced

**Implementation**:

SKILL.md structure:
```markdown
# Skill Name

## Overview (simplest)
Quick introduction, what this skill provides

## Getting Started (simple)
Minimal working example

## Common Use Cases (moderate)
Typical scenarios with step-by-step guidance

## Advanced Techniques (complex)
For experienced users, pointer to references/advanced.md
```

references/ structure:
```markdown
# Advanced Techniques

## Moderate Complexity Techniques
Start with somewhat advanced topics

## High Complexity Techniques
Progress to very advanced topics

## Expert-Level Optimizations
End with expert content
```

**Benefits**:
- Accessible to all skill levels
- Natural learning progression
- Easy to find right level
- Don't overwhelm beginners

## Anti-Patterns to Avoid

### Anti-Pattern 1: Premature Optimization

**What**: Creating complete structure before knowing requirements

**Why it's bad**:
- Wasted effort on unused features
- Harder to change later
- Over-engineered for actual needs

**Example**:

```
# Creating elaborate structure for simple skill
skill-name/
├── SKILL.md
├── references/
│   ├── theory.md           ← Never referenced
│   ├── history.md          ← Not needed
│   └── future-plans.md     ← Speculative
├── examples/
│   ├── beginner.sh         ← Overkill
│   ├── intermediate.sh     ← Not used
│   └── advanced.sh         ← Unused
└── scripts/
    ├── validate.sh         ← Not needed
    ├── test.sh            ← Not needed
    └── deploy.sh          ← Not relevant
```

**Better approach**: Start minimal, add structure as needed

---

### Anti-Pattern 2: Orphaned Resources

**What**: Creating files not referenced in SKILL.md

**Why it's bad**:
- Agents don't know files exist
- Wasted effort
- Maintenance burden

**Example**:

```
# SKILL.md never mentions these files:
references/
├── secret-patterns.md      ← Not referenced
└── hidden-guide.md         ← Not referenced
```

**Fix**: Always add "Additional Resources" section in SKILL.md

---

### Anti-Pattern 3: Content Duplication

**What**: Same information in multiple files

**Why it's bad**:
- Must update multiple places
- Wastes context
- Creates confusion if versions differ

**Example**:

SKILL.md:
```markdown
## Authentication
[800 words about authentication]
```

references/auth.md:
```markdown
## Authentication
[Same 800 words about authentication]
```

**Fix**: Summary in SKILL.md, details in reference

---

### Anti-Pattern 4: Vague Resource Descriptions

**What**: Referencing files without explaining when to use them

**Why it's bad**:
- Agents don't know when to load
- Users don't know which to read
- Reduces resource usage

**Example**:

Bad:
```markdown
## Additional Resources
- references/file1.md
- references/file2.md
- references/file3.md
```

Good:
```markdown
## Additional Resources

### Reference Files

- **`references/patterns.md`** - Common design patterns  
  Use when: Designing new implementations

- **`references/troubleshooting.md`** - Problem resolution  
  Use when: Encountering errors or unexpected behavior

- **`references/advanced.md`** - Advanced techniques  
  Use when: Optimizing or handling complex scenarios
```

---

### Anti-Pattern 5: Non-Executable Examples

**What**: Code examples that can't run without modification

**Why it's bad**:
- Users must figure out placeholders
- Increases friction
- Higher chance of errors

**Example**:

Bad:
```bash
# examples/workflow.sh
git checkout <branch-name>
git commit -m "<your-message>"
git push <remote> <branch>
```

Good:
```bash
# examples/workflow.sh
#!/bin/bash
BRANCH="${1:-feature/example}"
MESSAGE="${2:-Add example changes}"
REMOTE="${3:-origin}"

git checkout "$BRANCH"
git commit -m "$MESSAGE"
git push "$REMOTE" "$BRANCH"
```

## Pattern Selection Guide

Use this guide to choose the right pattern:

| Scenario | Pattern | Anti-Pattern to Avoid |
|----------|---------|----------------------|
| Creating new skill | Incremental Implementation | Premature Optimization |
| Organizing references | Topic-Based Organization | Type-Based Organization |
| Writing examples | Executable Examples | Non-Executable Examples |
| Creating scripts | Self-Documenting Scripts | Minimal/No Documentation |
| Structuring content | Progressive Complexity | Random Organization |
| Adding resources | Referenced Resources | Orphaned Resources |

## Summary

**Use these patterns**:
- Incremental Implementation - Build iteratively
- Topic-Based References - Organize by subject
- Executable Examples - Make code runnable
- Self-Documenting Scripts - Include help text
- Progressive Complexity - Simple to advanced

**Avoid these anti-patterns**:
- Premature Optimization - Don't over-engineer
- Orphaned Resources - Always reference files
- Content Duplication - One canonical location
- Vague Descriptions - Explain when to use
- Non-Executable Examples - Make code runnable

Following these patterns leads to well-organized, maintainable, and effective skills.
