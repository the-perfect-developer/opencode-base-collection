---
name: css
description: Apply Google CSS style guide conventions to CSS code
---

# CSS Style Guide

This skill applies Google's CSS style guide conventions to ensure clean, maintainable, and efficient CSS code.

## Core Principles

### Valid CSS

Use valid CSS code tested with [W3C CSS Validator](https://jigsaw.w3.org/css-validator/):
- Catches errors early
- Ensures browser compatibility
- Improves maintainability
- Exception: vendor-specific prefixes and required proprietary syntax

### Meaningful Class Names

Use functional or generic class names, not presentational:

```css
/* Not recommended: presentational */
.button-green {}
.clear {}
.yee-1901 {} /* meaningless */

/* Recommended: functional */
.gallery {}
.login {}
.video {}
.aux {} /* generic helper */
.alt {} /* generic alternative */
```

### Avoid ID Selectors

IDs have high specificity and reduce reusability:

```css
/* Not recommended */
#example {}
#navigation {}

/* Recommended */
.example {}
.navigation {}
```

## CSS Style Rules

### Class Naming Conventions

**Use short but meaningful names:**

```css
/* Not recommended */
.navigation {}
.atr {}

/* Recommended */
.nav {}
.author {}
```

**Use hyphens as delimiters:**

```css
/* Not recommended */
.demoimage {}
.error_status {}

/* Recommended */
.video-id {}
.ads-sample {}
```

**Use prefixes for large projects (optional):**

```css
/* For namespacing in large projects */
.adw-help {} /* AdWords */
.maia-note {} /* Maia */
```

### Avoid Type Selectors

Don't qualify class names with type selectors:

```css
/* Not recommended */
ul.example {}
div.error {}

/* Recommended */
.example {}
.error {}
```

**Reason:** Performance and flexibility

### Shorthand Properties

Use shorthand when possible:

```css
/* Not recommended */
border-top-style: none;
font-family: palatino, georgia, serif;
font-size: 100%;
line-height: 1.6;
padding-bottom: 2em;
padding-left: 1em;
padding-right: 1em;
padding-top: 0;

/* Recommended */
border-top: 0;
font: 100%/1.6 palatino, georgia, serif;
padding: 0 1em 2em;
```

### Units

**Omit units after 0 values:**

```css
/* Not recommended */
margin: 0px;
padding: 0em;

/* Recommended */
margin: 0;
padding: 0;

/* Exception: required units */
flex: 0px; /* flex-basis requires unit */
flex: 1 1 0px; /* needed in IE11 */
```

**Include leading 0s:**

```css
/* Not recommended */
font-size: .8em;

/* Recommended */
font-size: 0.8em;
```

### Color Values

**Use 3-character hex when possible:**

```css
/* Not recommended */
color: #eebbcc;

/* Recommended */
color: #ebc;
```

**Use lowercase:**

```css
/* Not recommended */
color: #E5E5E5;

/* Recommended */
color: #e5e5e5;
```

### Important Declarations

Avoid `!important` - use specificity instead:

```css
/* Not recommended */
.example {
  font-weight: bold !important;
}

/* Recommended */
.example {
  font-weight: bold;
}

/* If override needed, increase specificity */
.container .example {
  font-weight: bold;
}
```

### Browser Hacks

Avoid CSS hacks and user agent detection - use progressive enhancement:

```css
/* Not recommended */
.example {
  width: 100px\9; /* IE hack */
}

/* Recommended: Use feature queries */
@supports (display: grid) {
  .example {
    display: grid;
  }
}
```

## Formatting Rules

### Indentation

Indent by 2 spaces (no tabs):

```css
.example {
  color: blue;
}

@media screen, projection {

  html {
    background: #fff;
    color: #444;
  }

}
```

### Declaration Order

Alphabetize declarations for consistency (optional):

```css
/* Recommended */
background: fuchsia;
border: 1px solid;
-moz-border-radius: 4px;
-webkit-border-radius: 4px;
border-radius: 4px;
color: black;
text-align: center;
text-indent: 2em;
```

**Note:** Ignore vendor prefixes for sorting, but keep them grouped

### Semicolons

Always end declarations with semicolons:

```css
/* Not recommended */
.test {
  display: block;
  height: 100px
}

/* Recommended */
.test {
  display: block;
  height: 100px;
}
```

### Property-Value Spacing

Single space after colon, no space before:

```css
/* Not recommended */
h3 {
  font-weight:bold;
}

/* Recommended */
h3 {
  font-weight: bold;
}
```

### Declaration Block Spacing

Single space before opening brace, same line:

```css
/* Not recommended: missing space */
.video{
  margin-top: 1em;
}

/* Not recommended: unnecessary line break */
.video
{
  margin-top: 1em;
}

/* Recommended */
.video {
  margin-top: 1em;
}
```

### Selector and Declaration Separation

New line for each selector and declaration:

```css
/* Not recommended */
a:focus, a:active {
  position: relative; top: 1px;
}

/* Recommended */
h1,
h2,
h3 {
  font-weight: normal;
  line-height: 1.2;
}
```

### Rule Separation

Blank line between rules:

```css
html {
  background: #fff;
}

body {
  margin: auto;
  width: 50%;
}
```

### Quotation Marks

Use single quotes for attribute selectors and property values:

```css
/* Not recommended */
@import url("https://www.google.com/css/maia.css");

html {
  font-family: "open sans", arial, sans-serif;
}

/* Recommended */
@import url(https://www.google.com/css/maia.css);

html {
  font-family: 'open sans', arial, sans-serif;
}

/* Exception: @charset requires double quotes */
@charset "utf-8";
```

**Do not quote URLs:**

```css
/* Recommended */
background: url(images/bg.png);
```

## Organizing CSS

### Section Comments

Group related rules with comments (optional):

```css
/* Header */

.adw-header {}

.adw-header-logo {}

/* Footer */

.adw-footer {}

/* Gallery */

.adw-gallery {}

.adw-gallery-item {}
```

### File Organization

Organize CSS files logically:

```css
/* Base styles */
html,
body {
  margin: 0;
  padding: 0;
}

/* Typography */
h1, h2, h3 {
  font-family: 'Arial', sans-serif;
}

/* Layout */
.container {
  max-width: 1200px;
  margin: 0 auto;
}

/* Components */
.button {
  padding: 10px 20px;
}

/* Utilities */
.hidden {
  display: none;
}
```

## Best Practices

### Specificity Management

Keep specificity low for easier overrides:

```css
/* Not recommended: too specific */
html body div.container ul.nav li.item a.link {}

/* Recommended */
.nav-link {}
```

### Avoid Over-nesting

```css
/* Not recommended */
.header .nav .menu .item .link {
  color: blue;
}

/* Recommended */
.nav-link {
  color: blue;
}
```

### Mobile-First Media Queries

```css
/* Base styles for mobile */
.container {
  width: 100%;
}

/* Progressively enhance for larger screens */
@media (min-width: 768px) {
  .container {
    width: 750px;
  }
}

@media (min-width: 1024px) {
  .container {
    width: 960px;
  }
}
```

### Reusable Classes

Create utility classes for common patterns:

```css
/* Layout utilities */
.flex {
  display: flex;
}

.flex-center {
  display: flex;
  justify-content: center;
  align-items: center;
}

/* Spacing utilities */
.mt-1 { margin-top: 0.5rem; }
.mt-2 { margin-top: 1rem; }
.mt-3 { margin-top: 1.5rem; }
```

## Quick Reference

| Rule | Convention |
|------|------------|
| Indentation | 2 spaces |
| Case | Lowercase |
| Quotes | Single (`'`) except `@charset` |
| Semicolons | Required after every declaration |
| Units | Omit after `0` |
| Leading zeros | Always include (`0.8em`) |
| Hex colors | 3-char when possible, lowercase |
| ID selectors | Avoid |
| Type selectors | Don't qualify classes |
| `!important` | Avoid |
| Property order | Alphabetical (optional) |
| Line breaks | New line per selector/declaration |
| Rule separation | Blank line between rules |
| Comments | Section comments for organization |

## Common Patterns

### Button Component

```css
.button {
  background-color: #007bff;
  border: 0;
  border-radius: 4px;
  color: #fff;
  cursor: pointer;
  display: inline-block;
  font-size: 1rem;
  padding: 0.5rem 1rem;
  text-align: center;
  text-decoration: none;
}

.button:hover {
  background-color: #0056b3;
}

.button-secondary {
  background-color: #6c757d;
}

.button-large {
  font-size: 1.25rem;
  padding: 0.75rem 1.5rem;
}
```

### Card Component

```css
.card {
  background: #fff;
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 1.5rem;
}

.card-header {
  border-bottom: 1px solid #ddd;
  margin-bottom: 1rem;
  padding-bottom: 0.5rem;
}

.card-title {
  font-size: 1.5rem;
  margin: 0;
}

.card-body {
  line-height: 1.6;
}
```

### Grid System

```css
.grid {
  display: grid;
  gap: 1rem;
  grid-template-columns: repeat(12, 1fr);
}

.col-4 {
  grid-column: span 4;
}

.col-6 {
  grid-column: span 6;
}

.col-12 {
  grid-column: span 12;
}
```

## Additional Resources

- **`references/css-detailed.md`** - Advanced CSS patterns, methodologies, and best practices
- [W3C CSS Validator](https://jigsaw.w3.org/css-validator/)
- [Google HTML/CSS Style Guide](https://google.github.io/styleguide/htmlcssguide.html)

## Summary

Write CSS that is:
- **Valid**: Passes W3C validation
- **Semantic**: Meaningful class names
- **Maintainable**: Low specificity, avoid IDs
- **Consistent**: Follow formatting rules
- **Efficient**: Use shorthand, avoid repetition
- **Readable**: Proper spacing and organization
- **Lowercase**: All selectors and properties
- **Quoted**: Single quotes (except `@charset`)
