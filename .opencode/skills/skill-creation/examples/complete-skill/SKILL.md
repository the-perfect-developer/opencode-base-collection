---
name: complete-skill
description: This skill should be used when the user asks to "demonstrate complete skill structure", "show all skill features", or needs an example of a skill with references, examples, and scripts.
---

# Complete Skill Example

This demonstrates the full OpenCode skill structure with all features: references, examples, and scripts.

## What This Demonstrates

A complete skill includes:
- `SKILL.md` with core content (~1,500-2,000 words)
- `references/` with detailed documentation
- `examples/` with working code samples
- `scripts/` with utility tools
- Full progressive disclosure

Use this structure for complex domains requiring comprehensive support.

## Structure

```
complete-skill/
├── SKILL.md
├── references/
│   ├── patterns.md
│   └── advanced.md
├── examples/
│   └── working-example.sh
└── scripts/
    └── validate.sh
```

## When to Use Complete Structure

Use this structure when:
- Need working code examples users can copy
- Have utility scripts for validation or automation
- Require comprehensive documentation
- Building complex domain skill

This is for ~20% of skills with sophisticated requirements.

## Three-Level Progressive Disclosure

### Level 1: Metadata (Always Loaded)

From frontmatter - agents always see this:
```yaml
name: complete-skill
description: This skill should be used when the user asks to "demonstrate complete skill structure"...
```

Size: ~50-100 words  
Purpose: Help agents decide whether to load skill

### Level 2: SKILL.md Body (Loaded When Triggered)

This file you're reading now:
- Core workflows and procedures
- Quick reference material
- Pointers to all resources

Size: ~1,500-2,000 words  
Purpose: Provide essential guidance

### Level 3: Bundled Resources (Loaded As Needed)

**references/** - Detailed docs loaded when agents need specifics:
- `patterns.md` - Common patterns and anti-patterns
- `advanced.md` - Advanced techniques

**examples/** - Working code loaded when agents need samples:
- `working-example.sh` - Complete runnable script

**scripts/** - Utilities executed or loaded as needed:
- `validate.sh` - Validation tool

## Content Allocation

### SKILL.md Content

**Include here**:
- Purpose and overview (you're reading it)
- Core workflows (next section)
- Quick reference tables
- Pointers to all resources

**Keep focused**: 1,500-2,000 words

### references/ Content

**Include in reference files**:
- Detailed patterns and techniques
- Comprehensive explanations
- Edge cases and troubleshooting
- Advanced use cases

**Be comprehensive**: 2,000-5,000+ words per file

### examples/ Content

**Include in example files**:
- Complete working code
- Configuration files
- Templates users can copy
- Real-world usage demonstrations

**Make runnable**: Users should be able to execute directly

### scripts/ Content

**Include in script files**:
- Validation tools
- Testing helpers
- Automation utilities
- Parsing tools

**Make executable**: Scripts should run with clear outputs

## Core Workflows

### Workflow 1: Using References

When agents need detailed information:

1. Agent reads SKILL.md and sees pointer to reference
2. Agent reads specific reference file (e.g., `references/patterns.md`)
3. Agent applies detailed guidance from reference
4. Reference stays loaded only while needed

**Example**:
```markdown
User: "What are the common patterns for this?"
Agent: [Loads skill] → [Reads SKILL.md] → [Sees references/patterns.md mentioned]
       → [Reads references/patterns.md] → [Applies patterns]
```

### Workflow 2: Using Examples

When agents need working code:

1. Agent reads SKILL.md and sees pointer to example
2. Agent reads example file (e.g., `examples/working-example.sh`)
3. Agent adapts example for user's use case
4. User can run example directly

**Example**:
```markdown
User: "Show me how this works"
Agent: [Loads skill] → [Reads SKILL.md] → [Sees examples/working-example.sh]
       → [Reads example] → [Adapts for user] → [User runs script]
```

### Workflow 3: Using Scripts

When validation or automation needed:

1. Agent reads SKILL.md and sees pointer to script
2. Agent executes script (without loading into context)
3. Script returns results
4. Agent uses results to continue

**Example**:
```markdown
User: "Validate my configuration"
Agent: [Loads skill] → [Reads SKILL.md] → [Sees scripts/validate.sh]
       → [Executes script] → [Gets validation results] → [Reports to user]
```

**Key benefit**: Scripts can execute without consuming context.

## Resource Organization

### references/patterns.md

**Purpose**: Common patterns and anti-patterns  
**Size**: ~2,500 words  
**When loaded**: When agent needs pattern guidance

Contains:
- Pattern catalog
- When to use each pattern
- Implementation examples
- Anti-patterns to avoid

### references/advanced.md

**Purpose**: Advanced techniques  
**Size**: ~2,200 words  
**When loaded**: When agent needs advanced guidance

Contains:
- Complex scenarios
- Performance optimization
- Edge case handling
- Integration strategies

### examples/working-example.sh

**Purpose**: Runnable demonstration  
**Type**: Bash script  
**When loaded**: When agent needs code sample

Features:
- Complete working code
- Comments explaining each step
- Can be executed directly
- Demonstrates best practices

### scripts/validate.sh

**Purpose**: Validation utility  
**Type**: Bash script  
**When loaded**: When validation needed (often just executed)

Features:
- Validates configuration or setup
- Returns clear success/failure
- Provides helpful error messages
- Executable without reading

## Benefits of Complete Structure

### Comprehensive Support

Users get:
- Conceptual understanding (SKILL.md)
- Detailed knowledge (references/)
- Working examples (examples/)
- Automation tools (scripts/)

### Efficient Context Usage

Despite comprehensive content:
- Only SKILL.md loaded initially (~1,800 words)
- References loaded when needed (~4,700 words available)
- Examples loaded when needed (~200 words)
- Scripts executed without loading (~150 words)

**Total**: 6,850 words of content  
**Typical load**: 1,800 words (73% efficiency)

### Better Organization

Clear separation:
- **SKILL.md**: What and how (essentials)
- **references/**: Why and when (details)
- **examples/**: Show me (code)
- **scripts/**: Do it for me (automation)

## Creating a Complete Skill

### Step 1: Create Structure

```bash
mkdir -p my-skill/{references,examples,scripts}
touch my-skill/SKILL.md
```

### Step 2: Write SKILL.md

Core content with pointers:

```yaml
---
name: my-skill
description: This skill should be used when the user asks to "trigger 1", "trigger 2"...
---

# My Skill

## Overview
[Purpose and key concepts]

## Core Workflows
[Essential procedures]

## Quick Reference
[Tables, commands]

## Additional Resources

### Reference Files
- **`references/patterns.md`** - Common patterns
- **`references/advanced.md`** - Advanced techniques

### Example Files
- **`examples/basic.sh`** - Simple example
- **`examples/advanced.sh`** - Complex example

### Utility Scripts
- **`scripts/validate.sh`** - Validate configuration
- **`scripts/test.sh`** - Run tests
```

### Step 3: Create References

Detailed documentation:

```bash
touch my-skill/references/patterns.md
touch my-skill/references/advanced.md
```

Write comprehensive content (2,000-5,000 words each).

### Step 4: Create Examples

Working code samples:

```bash
touch my-skill/examples/basic.sh
touch my-skill/examples/advanced.sh
chmod +x my-skill/examples/*.sh
```

Write complete, runnable examples.

### Step 5: Create Scripts

Utility tools:

```bash
touch my-skill/scripts/validate.sh
touch my-skill/scripts/test.sh
chmod +x my-skill/scripts/*.sh
```

Write helpful automation scripts.

### Step 6: Reference Everything

Ensure SKILL.md mentions all resources so agents know they exist.

## When to Use Each Component

### Use references/ when:
- [ ] Need detailed explanations
- [ ] Have comprehensive documentation
- [ ] Cover edge cases and troubleshooting
- [ ] Provide advanced techniques

### Use examples/ when:
- [ ] Users need working code to copy
- [ ] Demonstrating complex configurations
- [ ] Showing real-world usage
- [ ] Teaching through code

### Use scripts/ when:
- [ ] Same operation repeated frequently
- [ ] Need deterministic validation
- [ ] Want to avoid rewriting code
- [ ] Can automate complex tasks

## Additional Resources

### Reference Files

Detailed documentation in references/:

- **`references/patterns.md`** - Common patterns and anti-patterns  
  Study this to see how to organize pattern documentation

- **`references/advanced.md`** - Advanced techniques and strategies  
  Study this to see how to structure advanced content

### Example Files

Working code in examples/:

- **`examples/working-example.sh`** - Complete demonstration script  
  Study this to see how to write clear, runnable examples

### Utility Scripts

Automation tools in scripts/:

- **`scripts/validate.sh`** - Validation utility  
  Study this to see how to write helpful validation scripts

## Summary

**Complete structure** offers maximum capability:

**Components**:
```
skill-name/
├── SKILL.md              (1,500-2,000 words - core)
├── references/           (2,000-5,000 words each - details)
│   ├── patterns.md
│   └── advanced.md
├── examples/             (working code - samples)
│   └── working-example.sh
└── scripts/              (utilities - automation)
    └── validate.sh
```

**Use when**:
- Need comprehensive support
- Have working examples to share
- Want automation utilities
- Building complex domain skill

**Benefits**:
- Users get everything they need
- Efficient context usage (progressive disclosure)
- Better organization and maintainability
- Reusable automation (scripts)

**Tradeoffs**:
- More effort to create
- More files to maintain
- Only needed for complex domains

For most skills, the **standard structure** (SKILL.md + references/) is sufficient. Use the complete structure only when examples and scripts provide clear value.
