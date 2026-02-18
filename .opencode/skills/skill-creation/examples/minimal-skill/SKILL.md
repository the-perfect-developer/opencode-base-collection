---
name: minimal-skill
description: This skill should be used when the user asks to "demonstrate minimal skill structure" or needs an example of the simplest possible skill configuration.
---

# Minimal Skill Example

This is the simplest possible OpenCode skill structure.

## What This Demonstrates

A minimal skill consists of:
- A single `SKILL.md` file
- YAML frontmatter with `name` and `description`
- Markdown content explaining the skill

No additional resources (references/, examples/, scripts/) are required.

## When to Use Minimal Structure

Use this structure when:
- Skill provides simple knowledge or guidance
- No detailed documentation needed
- No code examples or scripts required
- Content fits comfortably in 1,500-2,000 words

## Example Use Cases

**Good for minimal skills**:
- Quick reference guides
- Simple conventions or standards
- Brief workflows with few steps
- Pointer skills that direct to external resources

**Not good for minimal skills**:
- Complex multi-step workflows → Use standard structure
- Detailed API documentation → Use references/
- Code examples → Use examples/
- Utility scripts → Use scripts/

## Structure

```
minimal-skill/
└── SKILL.md
```

That's it! Just one file.

## Content Guidelines

Keep the content:
- **Focused** - Cover one specific topic
- **Concise** - 500-1,500 words
- **Actionable** - Clear steps or guidance
- **Self-contained** - Everything in this file

## Benefits

**Advantages**:
- Simple to create and maintain
- Low context cost
- Easy to understand
- Quick to load

**Limitations**:
- Can't handle complex topics
- No progressive disclosure within skill
- Everything loads at once
- Limited to ~2,000 words

## When to Upgrade

Upgrade to standard structure (add references/) when:
- Content exceeds 2,000 words
- Need detailed documentation
- Have multiple sub-topics
- Want better progressive disclosure

Upgrade to complete structure (add examples/ and scripts/) when:
- Need working code examples
- Have utility scripts
- Require automation tools

## Summary

Minimal skills are perfect for simple, focused guidance that fits in one file. They're easy to create, maintain, and use.

For more complex needs, consider the standard or complete skill structures demonstrated in the other examples.
