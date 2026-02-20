---
name: markdown
description: This skill should be used when the user asks to "format markdown", "write markdown documentation", "follow markdown style guide", "apply markdown conventions", or needs guidance on markdown best practices.
compatibility: opencode
---

# Skill: markdown

Apply Google Markdown style guide conventions to documentation.

## Overview

This skill provides markdown formatting guidelines based on the Google Markdown Style Guide. It helps create readable, portable, and maintainable markdown documentation with consistent formatting across projects.

## Core Principles

Balance three goals:
1. **Source text is readable and portable** - Plain text should be easy to read
2. **Corpus is maintainable** - Consistent formatting across teams and time
3. **Syntax is simple** - Easy to remember and apply

## Essential Formatting Rules

### Document Structure

Every markdown document should follow this layout:

```markdown
# Document Title

Short introduction (1-3 sentences providing high-level overview).

[TOC]

## Topic

Content.

## See also

* https://link-to-more-info
```

**Key elements**:
- **H1 title** - First heading at level 1, matching or similar to filename
- **Introduction** - Brief overview for newcomers
- **[TOC]** - Table of contents after introduction (if supported by hosting)
- **H2+ headings** - All subsequent headings start from level 2
- **See also** - Miscellaneous links at bottom

### Headings

**Use ATX-style headings**:
```markdown
# Heading 1
## Heading 2
### Heading 3
```

**Best practices**:
- Add spacing: blank line before and after headings
- Space after `#`: `## Heading` not `##Heading`
- Use unique, descriptive names for each heading
- One H1 heading per document (the title)
- Follow sentence case capitalization for titles

**Example**:
```markdown
## Foo
### Foo summary
### Foo example

## Bar
### Bar summary
### Bar example
```

### Lists

**Nested list spacing** - Use 4-space indent:
```markdown
1.  First item (2 spaces after number).
    Wrapped text uses 4-space indent.
2.  Second item.

*   Bullet item (3 spaces after asterisk).
    Wrapped text uses 4-space indent.
    1.  Nested numbered item.
        8-space indent for wrapped text.
    2.  Another nested item.
*   Back to bullets.
```

**Lazy numbering** for long lists:
```markdown
1.  First item.
1.  Second item.
    1.  Nested item.
    1.  Another nested item.
1.  Third item.
```

### Code

**Inline code** - Use backticks for short code:
```markdown
Run `script.sh` to start the process.
Check the `field_name` in the table.
```

**Code blocks** - Use fenced blocks with language:
````markdown
```python
def foo(bar):
    return bar * 2
```
````

**Best practices**:
- Always declare the language
- Use fenced blocks, not indented blocks
- Escape newlines in shell commands with `\`
- Nest code blocks in lists with proper indentation

### Links

**Inline links**:
```markdown
See the [Markdown guide](markdown.md) for more info.
```

**Reference links** for long URLs or repeated links:
```markdown
See the [style guide] for details.

[style guide]: https://google.github.io/styleguide/docguide/style.html
```

**Best practices**:
- Use informative link titles (not "here" or "link")
- Use explicit paths, avoid `../` relative paths
- Define reference links after first use, before next heading
- Use reference links in tables to keep cells readable

### Line Length

Follow 80-character line limit for better tool integration and code review.

**Exceptions**:
- Links
- Tables
- Headings
- Code blocks

**Example**:
```markdown
*   See the
    [documentation](https://very-long-url.example.com/path/to/docs).
    for more details.
```

### Tables

Use tables for tabular data that needs quick scanning. Avoid for data better presented as lists.

**Good table use**:
- Uniform data distribution
- Many parallel items with distinct attributes
- Need for quick comparison

**Example**:
```markdown
Transport | Favored by | Advantages
--------- | ---------- | -----------
Swallow   | Coconuts   | Fast when unladen
Bicycle   | Miss Gulch | Weatherproof

```

Use reference links to keep table cells manageable.

### Trailing Whitespace

Don't use trailing whitespace. Use backslash for line breaks:
```markdown
This line needs a break,\
so it continues here.
```

Better: avoid `<br />` entirely by using paragraph breaks (double newline).

## Quick Reference

**Headings**:
- ATX-style: `# H1`, `## H2`, `### H3`
- Add blank lines before/after
- One H1 per document

**Lists**:
- 4-space indent for all nested content
- Lazy numbering: `1.` for all items in long lists

**Code**:
- Inline: `` `code` ``
- Blocks: ` ```language ` with language specified

**Links**:
- Informative titles
- Reference links for long/repeated URLs

**Line length**:
- 80 characters (except links, tables, headings, code)

**Whitespace**:
- No trailing whitespace
- Use `\` for line breaks if needed

## Common Mistakes to Avoid

❌ Don't use setext-style headings:
```markdown
Heading
-------
```

❌ Don't write vague link titles:
```markdown
Click [here](url) for more info.
```

❌ Don't use indented code blocks:
```markdown
    code without language specified
```

❌ Don't nest with inconsistent spacing:
```markdown
* Item
 * Badly indented nested item
```

✅ Do use ATX-style headings with spacing:
```markdown
## Heading
```

✅ Do write descriptive link titles:
```markdown
See the [installation guide](url) for setup instructions.
```

✅ Do use fenced code blocks with language:
````markdown
```python
print("Hello")
```
````

✅ Do use consistent 4-space nesting:
```markdown
*   Item
    *   Properly indented nested item
```

## Additional Resources

### Reference Files

For complete style guide details:
- **`references/style-guide.md`** - Full Google Markdown Style Guide with all rules, examples, and edge cases

## See Also

* [Google Markdown Style Guide](https://google.github.io/styleguide/docguide/style.html)
* [CommonMark Specification](https://spec.commonmark.org/)
