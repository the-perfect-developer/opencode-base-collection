# Best Practices Guide for OpenCode Skills

This guide provides comprehensive best practices for creating effective OpenCode skills, adapted from Claude's official skill authoring guidelines and tailored for the `.opencode` directory structure.

## Contents

- Core Principles
- Skill Structure Best Practices
- Content Guidelines
- Common Patterns
- Workflows and Feedback Loops
- Writing Effective Descriptions
- Iterative Development
- Testing and Evaluation

## Core Principles

### Concise is Key

The context window is a shared resource. Your skill competes with:
- System prompts
- Conversation history
- Other skills' metadata
- User requests

**Default assumption**: The LLM already has extensive knowledge.

Only add context the LLM doesn't already have. Challenge each piece of information:
- "Does the LLM really need this explanation?"
- "Can I assume the LLM knows this?"
- "Does this paragraph justify its token cost?"

**Good example: Concise** (approximately 50 tokens):
````markdown
## Extract PDF text

Use pdfplumber for text extraction:

```python
import pdfplumber

with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```
````

**Bad example: Too verbose** (approximately 150 tokens):
```markdown
## Extract PDF text

PDF (Portable Document Format) files are a common file format that contains
text, images, and other content. To extract text from a PDF, you'll need to
use a library. There are many libraries available for PDF processing, but we
recommend pdfplumber because it's easy to use and handles most cases well.
First, you'll need to install it using pip. Then you can use the code below...
```

The concise version assumes the LLM knows what PDFs are and how libraries work.

### Set Appropriate Degrees of Freedom

Match the level of specificity to the task's fragility and variability.

**High freedom** (text-based instructions):

Use when:
- Multiple approaches are valid
- Decisions depend on context
- Heuristics guide the approach

Example:
```markdown
## Code review process

1. Analyze the code structure and organization
2. Check for potential bugs or edge cases
3. Suggest improvements for readability and maintainability
4. Verify adherence to project conventions
```

**Medium freedom** (pseudocode or templates with parameters):

Use when:
- A preferred pattern exists
- Some variation is acceptable
- Configuration affects behavior

Example:
````markdown
## Generate report

Use this template and customize as needed:

```python
def generate_report(data, format="markdown", include_charts=True):
    # Process data
    # Generate output in specified format
    # Optionally include visualizations
```
````

**Low freedom** (specific scripts, few or no parameters):

Use when:
- Operations are fragile and error-prone
- Consistency is critical
- A specific sequence must be followed

Example:
````markdown
## Database migration

Run exactly this script:

```bash
python scripts/migrate.py --verify --backup
```

Do not modify the command or add additional flags.
````

**Analogy**: Think of the LLM as a robot exploring a path:
- **Narrow bridge with cliffs**: Only one safe way forward. Provide specific guardrails and exact instructions (low freedom).
- **Open field with no hazards**: Many paths lead to success. Give general direction and trust the LLM to find the best route (high freedom).

### Use Consistent Terminology

Choose one term and use it throughout the skill:

**Good - Consistent**:
- Always "API endpoint"
- Always "field"
- Always "extract"

**Bad - Inconsistent**:
- Mix "API endpoint", "URL", "API route", "path"
- Mix "field", "box", "element", "control"
- Mix "extract", "pull", "get", "retrieve"

Consistency helps the LLM understand and follow instructions.

## Skill Structure Best Practices

### Writing Effective Descriptions

The `description` field enables skill discovery and should include both what the skill does and when to use it.

**Always write in third person**. The description is injected into the system prompt, and inconsistent point-of-view can cause discovery problems.

- **Good:** "Processes Excel files and generates reports"
- **Avoid:** "I can help you process Excel files"
- **Avoid:** "You can use this to process Excel files"

**Be specific and include key terms**. Include both what the skill does and specific triggers/contexts for when to use it.

Each skill has exactly one description field. The description is critical for skill selection: the LLM uses it to choose the right skill from potentially 100+ available skills.

**Effective examples:**

**PDF Processing skill:**
```yaml
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
```

**Excel Analysis skill:**
```yaml
description: Analyze Excel spreadsheets, create pivot tables, generate charts. Use when analyzing Excel files, spreadsheets, tabular data, or .xlsx files.
```

**Git Commit Helper skill:**
```yaml
description: Generate descriptive commit messages by analyzing git diffs. Use when the user asks for help writing commit messages or reviewing staged changes.
```

Avoid vague descriptions:

```yaml
description: Helps with documents  # Too vague
```
```yaml
description: Processes data  # Too vague
```

### Naming Conventions

Use consistent naming patterns. We recommend using **gerund form** (verb + -ing) for skill names.

Remember that the `name` field must use lowercase letters, numbers, and hyphens only.

**Good naming examples (gerund form)**:
- `processing-pdfs`
- `analyzing-spreadsheets`
- `managing-databases`
- `testing-code`
- `writing-documentation`

**Acceptable alternatives**:
- Noun phrases: `pdf-processing`, `spreadsheet-analysis`
- Action-oriented: `process-pdfs`, `analyze-spreadsheets`

**Avoid**:
- Vague names: `helper`, `utils`, `tools`
- Overly generic: `documents`, `data`, `files`
- Inconsistent patterns within your skill collection

### Progressive Disclosure Patterns

SKILL.md serves as an overview that points Claude to detailed materials as needed.

**Practical guidance:**
- Keep SKILL.md body under 500 lines for optimal performance
- Split content into separate files when approaching this limit
- Use the patterns below to organize instructions, code, and resources effectively

#### Pattern 1: High-level guide with references

````markdown
---
name: pdf-processing
description: Extracts text and tables from PDF files, fills forms, and merges documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
---

# PDF Processing

## Quick start

Extract text with pdfplumber:
```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```

## Advanced features

**Form filling**: See `references/forms.md` for complete guide
**API reference**: See `references/api-reference.md` for all methods
**Examples**: See `examples/` for common patterns
````

The LLM loads forms.md, api-reference.md, or examples only when needed.

#### Pattern 2: Domain-specific organization

For skills with multiple domains, organize content by domain to avoid loading irrelevant context.

```text
bigquery-skill/
├── SKILL.md (overview and navigation)
└── references/
    ├── finance.md (revenue, billing metrics)
    ├── sales.md (opportunities, pipeline)
    ├── product.md (API usage, features)
    └── marketing.md (campaigns, attribution)
```

#### Pattern 3: Conditional details

Show basic content, link to advanced content:

```markdown
# DOCX Processing

## Creating documents

Use docx-js for new documents. See `references/docx-js.md`.

## Editing documents

For simple edits, modify the XML directly.

**For tracked changes**: See `references/redlining.md`
**For OOXML details**: See `references/ooxml.md`
```

### Avoid Deeply Nested References

The LLM may partially read files when they're referenced from other referenced files.

**Keep references one level deep from SKILL.md**. All reference files should link directly from SKILL.md.

**Bad example: Too deep**:
```markdown
# SKILL.md
See `references/advanced.md`...

# advanced.md
See `references/details.md`...

# details.md
Here's the actual information...
```

**Good example: One level deep**:
```markdown
# SKILL.md

**Basic usage**: [instructions in SKILL.md]
**Advanced features**: See `references/advanced.md`
**API reference**: See `references/api-reference.md`
**Examples**: See `examples/`
```

### Structure Longer Reference Files with Table of Contents

For reference files longer than 100 lines, include a table of contents at the top.

**Example**:
```markdown
# API Reference

## Contents
- Authentication and setup
- Core methods (create, read, update, delete)
- Advanced features (batch operations, webhooks)
- Error handling patterns
- Code examples

## Authentication and setup
...

## Core methods
...
```

## Content Guidelines

### Avoid Time-Sensitive Information

Don't include information that will become outdated:

**Bad example: Time-sensitive** (will become wrong):
```markdown
If you're doing this before August 2025, use the old API.
After August 2025, use the new API.
```

**Good example** (use "old patterns" section):
```markdown
## Current method

Use the v2 API endpoint: `api.example.com/v2/messages`

## Old patterns

<details>
<summary>Legacy v1 API (deprecated 2025-08)</summary>

The v1 API used: `api.example.com/v1/messages`

This endpoint is no longer supported.
</details>
```

### Always Use Forward Slashes in Paths

Always use forward slashes in file paths, even on Windows:

- ✓ **Good**: `scripts/helper.py`, `references/guide.md`
- ✗ **Avoid**: `scripts\helper.py`, `references\guide.md`

Unix-style paths work across all platforms, while Windows-style paths cause errors on Unix systems.

### Avoid Offering Too Many Options

Don't present multiple approaches unless necessary:

**Bad example: Too many choices** (confusing):
"You can use pypdf, or pdfplumber, or PyMuPDF, or pdf2image, or..."

**Good example: Provide a default** (with escape hatch):
````markdown
Use pdfplumber for text extraction:
```python
import pdfplumber
```

For scanned PDFs requiring OCR, use pdf2image with pytesseract instead.
````

## Common Patterns

### Template Pattern

Provide templates for output format. Match the level of strictness to your needs.

**For strict requirements** (like API responses or data formats):

````markdown
## Report structure

ALWAYS use this exact template structure:

```markdown
# [Analysis Title]

## Executive summary
[One-paragraph overview of key findings]

## Key findings
- Finding 1 with supporting data
- Finding 2 with supporting data
- Finding 3 with supporting data

## Recommendations
1. Specific actionable recommendation
2. Specific actionable recommendation
```
````

**For flexible guidance** (when adaptation is useful):

````markdown
## Report structure

Here is a sensible default format, but use your best judgment based on the analysis:

```markdown
# [Analysis Title]

## Executive summary
[Overview]

## Key findings
[Adapt sections based on what you discover]

## Recommendations
[Tailor to the specific context]
```

Adjust sections as needed for the specific analysis type.
````

### Examples Pattern

For skills where output quality depends on seeing examples, provide input/output pairs:

````markdown
## Commit message format

Generate commit messages following these examples:

**Example 1:**
Input: Added user authentication with JWT tokens
Output:
```
feat(auth): implement JWT-based authentication

Add login endpoint and token validation middleware
```

**Example 2:**
Input: Fixed bug where dates displayed incorrectly in reports
Output:
```
fix(reports): correct date formatting in timezone conversion

Use UTC timestamps consistently across report generation
```

**Example 3:**
Input: Updated dependencies and refactored error handling
Output:
```
chore: update dependencies and refactor error handling

- Upgrade lodash to 4.17.21
- Standardize error response format across endpoints
```

Follow this style: type(scope): brief description, then detailed explanation.
````

### Conditional Workflow Pattern

Guide the LLM through decision points:

```markdown
## Document modification workflow

1. Determine the modification type:

   **Creating new content?** → Follow "Creation workflow" below
   **Editing existing content?** → Follow "Editing workflow" below

2. Creation workflow:
   - Use docx-js library
   - Build document from scratch
   - Export to .docx format

3. Editing workflow:
   - Unpack existing document
   - Modify XML directly
   - Validate after each change
   - Repack when complete
```

If workflows become large or complicated, consider pushing them into separate files.

## Workflows and Feedback Loops

### Use Workflows for Complex Tasks

Break complex operations into clear, sequential steps. For particularly complex workflows, provide a checklist that the LLM can copy into its response.

**Example 1: Research synthesis workflow** (for skills without code):

````markdown
## Research synthesis workflow

Copy this checklist and track your progress:

```
Research Progress:
- [ ] Step 1: Read all source documents
- [ ] Step 2: Identify key themes
- [ ] Step 3: Cross-reference claims
- [ ] Step 4: Create structured summary
- [ ] Step 5: Verify citations
```

**Step 1: Read all source documents**

Review each document in the `sources/` directory. Note the main arguments and supporting evidence.

**Step 2: Identify key themes**

Look for patterns across sources. What themes appear repeatedly? Where do sources agree or disagree?

[... detailed steps ...]
````

**Example 2: PDF form filling workflow** (for skills with code):

````markdown
## PDF form filling workflow

Copy this checklist and check off items as you complete them:

```
Task Progress:
- [ ] Step 1: Analyze the form (run analyze_form.py)
- [ ] Step 2: Create field mapping (edit fields.json)
- [ ] Step 3: Validate mapping (run validate_fields.py)
- [ ] Step 4: Fill the form (run fill_form.py)
- [ ] Step 5: Verify output (run verify_output.py)
```

**Step 1: Analyze the form**

Run: `python scripts/analyze_form.py input.pdf`

This extracts form fields and their locations, saving to `fields.json`.

[... detailed steps ...]
````

### Implement Feedback Loops

**Common pattern**: Run validator → fix errors → repeat

**Example 1: Style guide compliance** (for skills without code):

```markdown
## Content review process

1. Draft your content following the guidelines in `references/style-guide.md`
2. Review against the checklist:
   - Check terminology consistency
   - Verify examples follow the standard format
   - Confirm all required sections are present
3. If issues found:
   - Note each issue with specific section reference
   - Revise the content
   - Review the checklist again
4. Only proceed when all requirements are met
5. Finalize and save the document
```

**Example 2: Document editing process** (for skills with code):

```markdown
## Document editing process

1. Make your edits to `word/document.xml`
2. **Validate immediately**: `python scripts/validate.py unpacked_dir/`
3. If validation fails:
   - Review the error message carefully
   - Fix the issues in the XML
   - Run validation again
4. **Only proceed when validation passes**
5. Rebuild: `python scripts/pack.py unpacked_dir/ output.docx`
6. Test the output document
```

## Iterative Development

### Develop Skills Iteratively with the LLM

The most effective skill development process involves the LLM itself. Work with one LLM session ("Session A") to create a skill that will be used by other sessions ("Session B").

**Creating a new skill:**

1. **Complete a task without a skill**: Work through a problem with Session A using normal prompting. Notice what information you repeatedly provide.

2. **Identify the reusable pattern**: After completing the task, identify what context you provided that would be useful for similar future tasks.

3. **Ask Session A to create a skill**: "Create a skill that captures this pattern we just used. Include the [relevant information]."

4. **Review for conciseness**: Check that Session A hasn't added unnecessary explanations.

5. **Improve information architecture**: Ask Session A to organize the content more effectively.

6. **Test on similar tasks**: Use the skill with Session B (a fresh session with the skill loaded) on related use cases.

7. **Iterate based on observation**: If Session B struggles, return to Session A with specifics.

**Iterating on existing skills:**

1. **Use the skill in real workflows**: Give Session B (with the skill loaded) actual tasks
2. **Observe Session B's behavior**: Note where it struggles, succeeds, or makes unexpected choices
3. **Return to Session A for improvements**: Share observations and ask for refinements
4. **Apply and test changes**: Update the skill and test again with Session B
5. **Repeat based on usage**: Continue observe-refine-test cycle

### Build Evaluations First

**Create evaluations BEFORE writing extensive documentation.**

**Evaluation-driven development:**
1. **Identify gaps**: Run the LLM on representative tasks without a skill. Document failures
2. **Create evaluations**: Build scenarios that test these gaps
3. **Establish baseline**: Measure the LLM's performance without the skill
4. **Write minimal instructions**: Create just enough to address gaps
5. **Iterate**: Execute evaluations and refine

### Observe How the LLM Navigates Skills

Pay attention to how the LLM uses skills in practice:

- **Unexpected exploration paths**: Does the LLM read files in an order you didn't anticipate?
- **Missed connections**: Does the LLM fail to follow references to important files?
- **Overreliance on certain sections**: If the LLM repeatedly reads the same file, consider whether that content should be in SKILL.md
- **Ignored content**: If the LLM never accesses a bundled file, it might be unnecessary

## Testing and Evaluation

### Test with Real Use Cases

Before finalizing a skill:

1. Test with actual phrases users would say
2. Verify skill loads when expected
3. Confirm content is helpful for the task
4. Iterate based on real usage

### Gather Team Feedback

1. Share skills with teammates and observe their usage
2. Ask: Does the skill activate when expected? Are instructions clear? What's missing?
3. Incorporate feedback to address blind spots

## Summary Checklist

Before sharing a skill, verify:

### Core quality
- [ ] Description is specific and includes key terms
- [ ] Description includes both what the skill does and when to use it
- [ ] Description is written in third person
- [ ] SKILL.md body is under 500 lines
- [ ] Additional details are in separate files (if needed)
- [ ] No time-sensitive information (or in "old patterns" section)
- [ ] Consistent terminology throughout
- [ ] Examples are concrete, not abstract
- [ ] File references are one level deep
- [ ] Progressive disclosure used appropriately
- [ ] Workflows have clear steps
- [ ] All paths use forward slashes

### Content efficiency
- [ ] Content is concise (assumes LLM has prior knowledge)
- [ ] Appropriate degree of freedom set for each task type
- [ ] Default options provided (not too many choices)
- [ ] No unnecessary explanations

### Testing
- [ ] Tested with real usage scenarios
- [ ] Trigger phrases match user language
- [ ] Skill loads when expected
- [ ] Team feedback incorporated (if applicable)

Use these best practices to create effective, discoverable, and maintainable OpenCode skills that work efficiently within the `.opencode` directory structure.
