# Google Markdown Style Guide - Complete Reference

This document contains the complete Google Markdown Style Guide for detailed reference.

## Table of Contents

1. [Philosophy](#philosophy)
2. [Document Layout](#document-layout)
3. [Character Line Limit](#character-line-limit)
4. [Trailing Whitespace](#trailing-whitespace)
5. [Headings](#headings)
6. [Lists](#lists)
7. [Code](#code)
8. [Links](#links)
9. [Images](#images)
10. [Tables](#tables)
11. [HTML in Markdown](#html-in-markdown)

## Philosophy

### Minimum Viable Documentation

A small set of fresh and accurate docs is better than sprawling, loose assembly of documentation in various states of disrepair.

**Best practices**:
- Identify what you really need: release docs, API docs, testing guidelines
- Delete cruft frequently and in small batches
- Engineers should take ownership and keep docs updated with same care as tests

### Better is Better than Best

Standards for documentation review differ from code reviews. Fast iteration is key.

**As a reviewer**:
1. LGTM immediately when reasonable; trust comments will be fixed
2. Suggest alternatives rather than vague comments
3. Start your own follow-up CL for substantial changes
4. Avoid "You should also..." comments
5. Only hold up submission if CL makes docs worse

**As an author**:
1. Avoid wasting cycles with trivial arguments
2. Capitulate early and move on
3. Cite the Better/Best Rule as needed

### Core Goals

Balance these three goals:

1. **Source text is readable and portable** - Write plain text that's easy to read
2. **Markdown corpus is maintainable over time** - Consistent formatting across teams
3. **Syntax is simple and easy to remember** - Reduce cognitive overhead

## Document Layout

Standard document structure:

```markdown
# Document Title

Short introduction.

[TOC]

## Topic

Content.

## See also

* https://link-to-more-info
```

### Document Title

- First heading should be level-one
- Ideally same or similar to filename
- Used as page `<title>` in HTML output

### Author

Optional. If you want to claim ownership, add under the title. However, revision history generally suffices.

### Short Introduction

1-3 sentences providing high-level overview. Consider newcomers who don't have context.

Ask: "What is this? Why would I use it?"

### Table of Contents

Use `[TOC]` directive if hosting supports it (e.g., Gitiles).

**Placement**: After introduction, before first H2.

```markdown
# My Page

This is my introduction **before** the TOC.

[TOC]

## My first H2
```

**Why placement matters**:
- `[TOC]` inserts HTML into DOM at directive location
- Screen readers and keyboard navigation affected by placement
- Place after intro so assistive tech encounters it at logical point

### Topics

Rest of headings start from level 2.

### See Also

Put miscellaneous links at bottom for users who want more or didn't find what they needed.

## Character Line Limit

### 80-Character Limit

Markdown follows 80-character line limit convention from code.

**Reasons**:
- **Tooling integration** - Tools designed for code work better with consistent formatting
- **Quality** - Engineers use coding habits, improving documentation quality
- **Code Search** - Doesn't soft wrap; 80-char lines easier to read

### Exceptions

Lines can exceed 80 characters for:
- **Links** - URLs and surrounding punctuation
- **Tables** - May run long (but keep readable)
- **Headings** - No wrapping needed
- **Code blocks** - Code formatting takes precedence

**Example**:
```markdown
*   See the
    [documentation](https://gerrit.googlesource.com/gitiles/+/HEAD/Documentation/markdown.md).
    and find the logfile.
```

Note: text before and after link gets wrapped.

## Trailing Whitespace

### Don't Use Trailing Whitespace

CommonMark spec says two spaces at line end insert `<br />`, but:
- Many directories have presubmit checks for trailing whitespace
- IDEs often clean it up automatically

### Use Backslash for Line Breaks

Use trailing backslash sparingly:

```markdown
For some reason I just really want a break here,\
though it's probably not necessary.
```

### Prefer Paragraph Breaks

Best practice: avoid `<br />` altogether. Pair of newlines creates paragraph tag. Get used to that.

## Headings

### ATX-Style Headings

Use `#` style:

```markdown
# Heading 1
## Heading 2
### Heading 3
```

**Don't use setext-style** (underlines):

```markdown
Heading - do you remember what level? DO NOT DO THIS.
---------
```

**Reasons**:
- Annoying to maintain
- Doesn't fit with rest of heading syntax
- Editor confusion: Does `---` mean H1 or H2?

### Use Unique, Complete Names for Headings

Use unique and fully descriptive names for each heading, even sub-sections.

**Why**: Link anchors constructed from headings. Unique names ensure intuitive anchor links.

**Bad**:
```markdown
## Foo
### Summary
### Example
## Bar
### Summary
### Example
```

**Good**:
```markdown
## Foo
### Foo summary
### Foo example
## Bar
### Bar summary
### Bar example
```

### Add Spacing to Headings

**Prefer**:
- Space after `#`
- Newlines before and after heading

```markdown
...text before.

## Heading 2

Text after...
```

**Avoid**:
```markdown
...text before.

##Heading 2
Text after... DO NOT DO THIS.
```

Lack of spacing harder to read in source.

### Use Single H1 Heading

Use one H1 heading as document title. Subsequent headings should be H2 or deeper.

See [Document Layout](#document-layout) for structure.

### Capitalization of Titles and Headers

Follow [Google Developer Documentation Style Guide capitalization rules](https://developers.google.com/style/capitalization#capitalization-in-titles-and-headings).

Use sentence case for most headings.

## Lists

### Use Lazy Numbering for Long Lists

Markdown renders numbered lists correctly regardless of source numbering.

**For long lists** (especially nested), use "lazy" numbering:

```markdown
1.  Foo.
1.  Bar.
    1.  Foofoo.
    1.  Barbar.
1.  Baz.
```

**For small lists** that won't change, use actual numbers (nicer to read):

```markdown
1.  Foo.
2.  Bar.
3.  Baz.
```

### Nested List Spacing

Use **4-space indent** for both numbered and bulleted lists:

```markdown
1.  Use 2 spaces after item number, so text is indented 4 spaces.
    Use 4-space indent for wrapped text.
2.  Use 2 spaces again for next item.

*   Use 3 spaces after bullet, so text is indented 4 spaces.
    Use 4-space indent for wrapped text.
    1.  Use 2 spaces with numbered lists.
        Wrapped text needs 8-space indent.
    2.  Looks nice, doesn't it?
*   Back to bulleted list, indented 3 spaces.
```

**Bad** (inconsistent spacing):
```markdown
* One space,
with no indent for wrapped text.
     1. Irregular nesting... DO NOT DO THIS.
```

**For small, single-line lists**, one space can suffice:

```markdown
* Foo
* Bar
* Baz

1. Foo
2. Bar
```

### Why 4-Space Indent

Makes layout consistent for wrapped text even without nesting:

```markdown
*   Foo,
    wrapped with 4-space indent.

1.  Two spaces for list item
    and 4 spaces before wrapped text.
2.  Back to 2 spaces.
```

## Code

### Inline Code

Backticks designate `inline code` rendered literally.

**Use for**:
- Short code quotations
- Field names
- Command names
- File types (generic, not specific files)

```markdown
Run `really_cool_script.sh arg`.
Check the `foo_bar_whammy` field.
Be sure to update your `README.md`!
```

### Use Code Span for Escaping

Wrap text in backticks when you don't want Markdown processing:

```markdown
An example path: `Markdown/foo/Markdown/bar.md`
An example query: `https://www.google.com/search?q=$TERM`
```

Prevents bad autolinking or other unwanted formatting.

### Code Blocks

For multi-line code, use fenced code blocks:

````markdown
```python
def foo(self, bar):
    self.bar = bar
```
````

### Declare the Language

**Always specify the language** explicitly:

````markdown
```python
print("Hello")
```
````

**Benefits**:
- Syntax highlighter knows what to do
- Next editor doesn't have to guess
- Some features tied to language specifiers

### Use Fenced Code Blocks Instead of Indented

Four-space indenting also creates code blocks, but **strongly recommend fencing**.

**Indented code blocks** (discouraged):
```markdown
You'll need to run:

    bazel run :thing -- --foo
```

**Problems with indented blocks**:
- Cannot specify language
- Beginning/end ambiguous
- Harder to search in Code Search
- Some Markdown features require language specifiers

**Fenced blocks** (recommended):
````markdown
```shell
bazel run :thing -- --foo
```
````

### Escape Newlines

For command-line snippets meant to be copied, escape newlines with backslash:

````markdown
```shell
bazel run :target -- --flag --foo=longlonglonglonglongvalue \
  --bar=anotherlonglonglonglonglonglonglonglonglonglongvalue
```
````

Users can copy and paste directly into terminal.

### Nest Code Blocks Within Lists

Indent code blocks to match list level:

````markdown
*   Bullet.

    ```c++
    int foo;
    ```

*   Next bullet.
````

**Alternative** - 4 additional spaces from list indent:

```markdown
*   Bullet.

        int foo;

*   Next bullet.
```

## Links

### Shorten Your Links

Long links make source Markdown hard to read and break 80-character wrapping.

**Wherever possible, shorten links**.

### Use Explicit Paths for Links Within Markdown

Use explicit path for Markdown links:

```markdown
[documentation](/path/to/other/markdown/page.md)
```

Don't use full qualified URL for internal links:

```markdown
[documentation](https://bad-full-url.example.com/path/to/other/markdown/page.md)
```

### Avoid Relative Paths Unless Within Same Directory

Relative paths fairly safe within same directory:

```markdown
[other page](other-page-in-same-dir.md)
[another page](/path/to/another/dir/other-page.md)
```

**Avoid** relative links needing `../`:

```markdown
[bad path](../../bad/path/to/another/dir/other-page.md)
```

### Use Informative Markdown Link Titles

Links catch the eye. Make them informative.

**Bad** (vague titles):
```markdown
See the guide for more info: [link](markdown.md), or check out the
style guide [here](/styleguide/docguide/style.html).

Check out: [https://example.com/foo/bar](https://example.com/foo/bar).
```

Titles "here", "link", or duplicating URL tell reader nothing.

**Good** (descriptive titles):
```markdown
See the [Markdown guide](markdown.md) for more info, or check out the
[style guide](/styleguide/docguide/style.html).

Check out a [typical test result](https://example.com/foo/bar).
```

Write sentence naturally, then wrap most appropriate phrase with link.

### Reference Links

Split link use from link definition for long URLs:

```markdown
See the [Markdown style guide][style], which has suggestions for making
docs more readable.

[style]: http://Markdown/corp/Markdown/docs/reference/style.md
```

### Use Reference Links for Long Links

Use reference links when URL length detracts from readability.

**Not appropriate** (link not that long):
```markdown
The [style guide][style_guide] says not to use reference links unless
you have to.

[style_guide]: https://google.com/Markdown-style
```

**Just inline it**:
```markdown
The [style guide](https://google.com/Markdown-style) says not to use
reference links unless you have to.
```

**Appropriate** (very long URL):
```markdown
The [style guide] says not to use reference links unless you have to.

[style guide]: https://docs.google.com/document/d/13HQBxfhCwx8lVRuN2Wf6poqvAfVeEXmFVcawP5I6B3c/edit
```

### Use Reference Links to Reduce Duplication

Use reference links when referencing same destination multiple times:

```markdown
The [style guide] mentions this. Later, the [style guide] says...

[style guide]: https://long-url.example.com/document
```

### Use Reference Links in Tables

Keep table content short with reference links:

**Bad** (long inline links):
```markdown
Site                                                             | Description
---------------------------------------------------------------- | -----------
[site 1](http://google.com/excessively/long/path/example_site_1) | Example 1
[site 2](http://google.com/excessively/long/path/example_site_2) | Example 2
```

**Good** (reference links):
```markdown
Site     | Description
-------- | -----------
[site 1] | Example 1
[site 2] | Example 2

[site 1]: http://google.com/excessively/long/path/example_site_1
[site 2]: http://google.com/excessively/long/path/example_site_2
```

### Define Reference Links After First Use

Put reference link definitions just before next heading (end of section).

Think of reference links like footnotes, current section like current page.

**Makes it easy to**:
- Find link destination in source
- Keep text flow free from clutter
- Avoid "footnote overload" at bottom of long files

**Exception**: Reference links used in multiple sections go at document end (avoids dangling links when sections move).

**Bad** (definition far from use):
```markdown
# Header

Some text with a [link][link_def].

More text with same [link][link_def].

## Header 2

... lots of text ...

## Header 3

Different [link][different_link_def].

[link_def]: http://reallyreallyreallylonglink.com
[different_link_def]: http://differentreallyreallylonglink.com
```

**Good** (definition before next header):
```markdown
# Header

Some text with a [link][link_def].

More text with same [link][link_def].

[link_def]: http://reallyreallyreallylonglink.com

## Header 2

... lots of text ...

## Header 3

Different [link][different_link_def].

[different_link_def]: http://differentreallyreallylonglink.com
```

## Images

Use images sparingly. Prefer simple screenshots.

**Philosophy**: Plain text gets users to communication faster with less distraction and procrastination.

**When to use images**:
- Easier to *show* than *describe* (e.g., UI navigation)
- Provide appropriate alt text for accessibility
- Readers who cannot see images still need to understand content

**Best practices**:
- Use when showing beats describing
- Always include descriptive alt text
- Keep images simple
- Consider file size and loading time

**Syntax**:
```markdown
![Alt text describing image](path/to/image.png)
```

See [Gitiles image syntax](https://gerrit.googlesource.com/gitiles/+/HEAD/Documentation/markdown.md#Images).

## Tables

### When to Use Tables

Use tables for:
- Presentation of tabular data
- Data that needs quick scanning
- Relatively uniform data distribution
- Many parallel items with distinct attributes

### When Not to Use Tables

Avoid tables when:
- Data better presented in lists
- Only a few rows or columns
- Cells contain rambling prose
- Poor data distribution (empty cells, non-varying columns)

### Example: Bad Table Use

```markdown
Fruit  | Metrics      | Grows on | Curvature | Attributes     | Notes
------ | ------------ | -------- | --------- | -------------- | -----
Apple  | Very popular | Trees    |           | Juicy, Sweet   | Keep doctors away
Banana | Very popular | Trees    | 16 deg    | Convenient     | Apes prefer mangoes...
```

**Problems**:
- **Poor distribution** - Several columns don't differ; empty cells
- **Unbalanced dimensions** - Few rows vs many columns
- **Rambling prose** - Tables should be succinct

### Example: List Alternative

Often lists work better:

```markdown
## Fruits

Both types are highly popular, sweet, and grow on trees.

### Apple

*   Juicy
*   Firm

Apples keep doctors away.

### Banana

*   Convenient
*   Soft
*   16 degrees average curvature

Contrary to popular belief, most apes prefer mangoes.
```

More spacious and easier to scan.

### Example: Good Table Use

```markdown
Transport        | Favored by     | Advantages
---------------- | -------------- | -----------
Swallow          | Coconuts       | Fast when unladen
Bicycle          | Miss Gulch     | Weatherproof
X-34 landspeeder | Whiny farmboys | Cheap
```

**Good because**:
- Uniform data distribution
- Parallel items with distinct attributes
- Compact and scannable
- Reference links keep cells manageable

## HTML in Markdown

### Strongly Prefer Markdown to HTML

**Prefer standard Markdown** wherever possible. Avoid HTML hacks.

If you can't accomplish something, reconsider whether you really need it.

**Why avoid HTML**:
- Reduces readability
- Limits portability
- Reduces usefulness of integrations
- Tools may present as plain text or fail to render

**Exception**: Big tables might require HTML, but even then, consider alternatives.

**Remember**: Markdown meets almost all documentation needs already.

### Gitiles Doesn't Render HTML

Many Markdown platforms (like Gitiles) don't render HTML for security reasons.

HTML will appear as plain text or be stripped, making docs broken or confusing.

### Stick to Pure Markdown

For best compatibility and maintainability:
- Use standard Markdown features
- Avoid `<div>`, `<span>`, `<style>` tags
- Don't use inline HTML for formatting
- Keep it simple and portable

## Capitalization

### Use Original Names

Use original names of products, tools, and binaries, preserving capitalization.

**Good**:
```markdown
# Markdown style guide

`Markdown` is a platform for internal engineering documentation.
```

**Bad**:
```markdown
# markdown style guide

`markdown` is a platform for internal engineering documentation.
```

### Follow Brand Capitalization

- GitHub (not Github or github)
- JavaScript (not Javascript or javascript)  
- macOS (not MacOS or macos)
- Python (not python in prose, though `python` command is lowercase)

When in doubt, check official documentation for proper capitalization.

## Summary

The Google Markdown Style Guide emphasizes:

1. **Readability** - Source text should be pleasant to read
2. **Consistency** - Use same patterns throughout corpus
3. **Simplicity** - Keep syntax simple and memorable
4. **Maintainability** - Make it easy for next person
5. **Portability** - Standard Markdown works everywhere

Follow these conventions to create documentation that's easy to write, review, and maintain across teams and time.
