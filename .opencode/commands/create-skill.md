---
description: Create a new OpenCode skill with proper structure and frontmatter
agent: build
model: github-copilot/claude-sonnet-4.6
---

Create a new skill $1


## Best Practices

**DO**:
- Include 3-5 specific trigger phrases in description
- Keep SKILL.md focused (1,500-2,000 words ideal)
- Use progressive disclosure for large skills
- Write in imperative form and third person
- Provide working examples in examples/
- Test with real use cases
- Use consistent terminology throughout

**DON'T**:
- Use vague descriptions without trigger phrases
- Put everything in SKILL.md without using references/
- Write in second person ("you should") or first person ("I can help")
- Skip validation before using
- Create deeply nested references (keep one level)

## Examples

Refer to bundled examples in `.opencode/skills/skill-creation/examples/`:
- **minimal-skill/** - Simplest possible skill
- **standard-skill/** - Recommended structure (SKILL.md + references/)
- **complete-skill/** - All features demonstrated

## Resources

For complete specifications and detailed guidance:
- **`.opencode/skills/skill-creation/SKILL.md`** - Full skill creation guide
- **`.opencode/skills/skill-creation/references/frontmatter-spec.md`** - Complete frontmatter specification
- **`.opencode/skills/skill-creation/references/progressive-disclosure.md`** - Loading strategy details
- **`.opencode/skills/skill-creation/references/common-mistakes.md`** - Anti-patterns to avoid
- **`.opencode/skills/skill-creation/references/best-practices-guide.md`** - Comprehensive best practices