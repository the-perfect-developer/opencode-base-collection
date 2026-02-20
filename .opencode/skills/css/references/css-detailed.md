# Detailed CSS Guidelines

This document provides comprehensive guidance on CSS best practices, methodologies, and advanced patterns based on Google's style guide and industry standards.

## CSS Validation

### Using the W3C Validator

The [W3C CSS Validator](https://jigsaw.w3.org/css-validator/) checks for:
- Syntax errors
- Unknown properties
- Invalid values
- Browser-specific extensions

**When to allow validation errors:**
- Vendor-specific prefixes (`-webkit-`, `-moz-`, etc.)
- Cutting-edge features not yet in spec
- Intentional browser-specific hacks (rare)

### Common Validation Issues

```css
/* Valid but validator may warn */
.example {
  -webkit-appearance: none; /* Vendor prefix */
  appearance: none;
}

/* Invalid: typo */
.example {
  colr: red; /* Should be 'color' */
}

/* Invalid: wrong value type */
.example {
  display: red; /* 'red' is not a display value */
}
```

## Class Naming Deep Dive

### Functional vs Presentational

**Presentational (avoid):**
```css
.red-text {}
.big-font {}
.left-aligned {}
.rounded-corners {}
```

Why avoid:
- Hard to maintain when design changes
- Not semantic
- Couples style to markup

**Functional (recommended):**
```css
.error-message {}
.page-title {}
.user-avatar {}
.call-to-action {}
```

Benefits:
- Design changes don't require HTML updates
- Semantic meaning
- Self-documenting

### Generic Helpers

When functional names don't apply:

```css
.aux {} /* Auxiliary/helper element */
.alt {} /* Alternative styling */
.meta {} /* Metadata container */
.aside {} /* Supplementary content */
```

### Naming Length

Balance brevity and clarity:

```css
/* Too short */
.n {} /* What is 'n'? */
.btn {} /* Common abbreviation, acceptable */

/* Too long */
.user-profile-sidebar-navigation-menu-item {}

/* Balanced */
.nav-item {}
.user-profile {}
.sidebar-menu {}
```

### Multi-word Names

Always use hyphens:

```css
/* Not recommended */
.userProfile {} /* camelCase */
.user_profile {} /* snake_case */
.UserProfile {} /* PascalCase */

/* Recommended */
.user-profile {} /* kebab-case */
```

## Selector Best Practices

### Specificity Hierarchy

Understanding specificity (from highest to lowest):
1. Inline styles: `style="..."` (1,0,0,0)
2. IDs: `#id` (0,1,0,0)
3. Classes, attributes, pseudo-classes: `.class` `[attr]` `:hover` (0,0,1,0)
4. Elements, pseudo-elements: `div` `::before` (0,0,0,1)

```css
/* Specificity: 0,0,0,1 */
p {
  color: black;
}

/* Specificity: 0,0,1,0 - wins */
.text {
  color: blue;
}

/* Specificity: 0,1,0,0 - wins */
#content {
  color: red;
}

/* Specificity: 0,0,1,1 */
p.text {
  color: green;
}
```

### Avoiding Specificity Wars

```css
/* Not recommended: increasing specificity to override */
.button { background: blue; }
div.button { background: red; } /* Need to override */
div.container .button { background: green; } /* More override */
body div.container .button { background: yellow; } /* Specificity hell */

/* Recommended: use modifiers */
.button { background: blue; }
.button-primary { background: red; }
.button-secondary { background: green; }
.button-warning { background: yellow; }
```

### Type Selectors Performance

Type selectors with classes are slower:

```css
/* Slower: browser must check all <ul> elements */
ul.nav {}

/* Faster: only checks elements with .nav class */
.nav {}
```

**Exception:** When restricting to specific element type is semantically important:

```css
/* Acceptable: ensuring anchor styling */
a.button {
  text-decoration: none;
}
```

### Descendant Selectors

Avoid deep nesting:

```css
/* Not recommended: too specific, hard to override */
.header .nav .menu .item .link .icon {}

/* Recommended: flat structure */
.nav-icon {}
```

**Benefits:**
- Lower specificity
- Better performance
- Easier to maintain
- More reusable

### Attribute Selectors

Useful for targeting specific states:

```css
/* Exact match */
[type="text"] {}

/* Contains word */
[class~="button"] {}

/* Starts with */
[class^="icon-"] {}

/* Ends with */
[class$="-large"] {}

/* Contains substring */
[class*="button"] {}
```

## Shorthand Properties

### Font Shorthand

```css
/* Longhand */
font-style: italic;
font-variant: small-caps;
font-weight: bold;
font-size: 16px;
line-height: 1.5;
font-family: Arial, sans-serif;

/* Shorthand */
font: italic small-caps bold 16px/1.5 Arial, sans-serif;
```

**Syntax:**
```
font: [style] [variant] [weight] size/line-height family;
```

**Required:** `font-size` and `font-family`

### Background Shorthand

```css
/* Longhand */
background-color: #fff;
background-image: url(bg.png);
background-repeat: no-repeat;
background-position: center;
background-size: cover;

/* Shorthand */
background: #fff url(bg.png) no-repeat center/cover;
```

### Margin and Padding

```css
/* Longhand */
margin-top: 10px;
margin-right: 20px;
margin-bottom: 10px;
margin-left: 20px;

/* Shorthand: top right bottom left (clockwise) */
margin: 10px 20px 10px 20px;

/* Shorthand: top/bottom left/right */
margin: 10px 20px;

/* Shorthand: all sides */
margin: 10px;
```

### Border Shorthand

```css
/* Longhand */
border-width: 1px;
border-style: solid;
border-color: #000;

/* Shorthand */
border: 1px solid #000;

/* Individual sides */
border-top: 2px dashed red;
border-right: 1px solid blue;
```

### When to Avoid Shorthand

Avoid when only setting one value:

```css
/* Not recommended: resets other properties */
font: 14px; /* Resets weight, family, etc. */

/* Recommended */
font-size: 14px;
```

## Units and Values

### When to Include Units

```css
/* Always omit unit after 0 */
margin: 0;
padding: 0;
border-width: 0;

/* Exception: flex-basis */
flex: 0px; /* Unit required */
flex: 1 1 0px; /* Needed for IE11 */

/* Exception: time and angles always need units */
transition-duration: 0s;
transform: rotate(0deg);
```

### Relative vs Absolute Units

**Relative units (preferred for responsive design):**
```css
.container {
  width: 90%; /* Percentage */
  font-size: 1.2rem; /* Root em */
  padding: 2em; /* Em */
  margin: 1.5ch; /* Character width */
  height: 50vh; /* Viewport height */
}
```

**Absolute units:**
```css
.print-layout {
  width: 8.5in; /* Inches */
  font-size: 12pt; /* Points */
}

.icon {
  width: 24px; /* Pixels */
  height: 24px;
}
```

### Color Formats

```css
/* Hex: 3-char when possible */
color: #000; /* Not #000000 */
color: #fff; /* Not #ffffff */
color: #fb0; /* Not #ffbb00 */

/* Hex: 6-char when needed */
color: #fb0c3e; /* Can't be shortened */

/* RGB: for transparency */
color: rgb(255, 0, 0);
color: rgba(255, 0, 0, 0.5);

/* HSL: for color manipulation */
color: hsl(0, 100%, 50%);
color: hsla(0, 100%, 50%, 0.5);

/* Named colors: for debugging only */
color: red; /* Use hex in production */
```

### Leading Zeros

Always include leading zero:

```css
/* Not recommended */
font-size: .8em;
opacity: .5;
margin: -.5em;

/* Recommended */
font-size: 0.8em;
opacity: 0.5;
margin: -0.5em;
```

## The !important Problem

### Why Avoid !important

```css
.button {
  background: blue;
}

.button-primary {
  background: red !important; /* Now impossible to override */
}

/* This won't work */
.special-case .button-primary {
  background: green; /* Loses to !important */
}

/* Only this works */
.button-primary {
  background: green !important; /* !important arms race */
}
```

### Proper Specificity Usage

```css
/* Base style */
.button {
  background: blue;
}

/* Modifier with same specificity */
.button-primary {
  background: red;
}

/* Higher specificity for overrides */
.theme-dark .button-primary {
  background: darkred;
}

/* Even higher for specific contexts */
.modal .theme-dark .button-primary {
  background: crimson;
}
```

### Legitimate !important Uses

**1. Utility classes:**
```css
.hidden {
  display: none !important;
}

.text-center {
  text-align: center !important;
}
```

**2. Overriding inline styles:**
```html
<!-- Third-party widget with inline styles -->
<div style="color: red;">
```

```css
.widget-override {
  color: blue !important; /* Only way to override inline */
}
```

**3. Print styles:**
```css
@media print {
  .no-print {
    display: none !important;
  }
}
```

## CSS Methodologies

### BEM (Block Element Modifier)

```css
/* Block */
.menu {}

/* Element */
.menu__item {}
.menu__link {}

/* Modifier */
.menu--vertical {}
.menu__item--active {}
```

**Full example:**
```html
<nav class="menu menu--vertical">
  <ul class="menu__list">
    <li class="menu__item menu__item--active">
      <a class="menu__link" href="/">Home</a>
    </li>
    <li class="menu__item">
      <a class="menu__link" href="/about">About</a>
    </li>
  </ul>
</nav>
```

```css
.menu {
  display: flex;
}

.menu--vertical {
  flex-direction: column;
}

.menu__list {
  list-style: none;
  margin: 0;
  padding: 0;
}

.menu__item {
  padding: 0.5rem;
}

.menu__item--active {
  background: #e0e0e0;
}

.menu__link {
  color: #333;
  text-decoration: none;
}
```

### OOCSS (Object-Oriented CSS)

**Separate structure from skin:**

```css
/* Structure */
.button {
  border: 0;
  cursor: pointer;
  display: inline-block;
  padding: 0.5rem 1rem;
}

/* Skin */
.button-primary {
  background: blue;
  color: white;
}

.button-secondary {
  background: gray;
  color: white;
}
```

**Separate container from content:**

```css
/* Not recommended: location-dependent */
.sidebar .widget {
  width: 300px;
}

/* Recommended: reusable */
.widget {
  width: 300px;
}

.widget-narrow {
  width: 200px;
}
```

## Advanced Formatting

### Declaration Ordering Strategies

**Alphabetical:**
```css
.example {
  background: #fff;
  border: 1px solid #ddd;
  color: #333;
  display: block;
  margin: 1rem;
  padding: 1rem;
}
```

**By type (alternative):**
```css
.example {
  /* Positioning */
  position: relative;
  top: 0;
  right: 0;
  
  /* Display & Box Model */
  display: block;
  width: 100px;
  height: 100px;
  margin: 1rem;
  padding: 1rem;
  
  /* Typography */
  font-size: 1rem;
  line-height: 1.5;
  color: #333;
  
  /* Visual */
  background: #fff;
  border: 1px solid #ddd;
  
  /* Misc */
  cursor: pointer;
}
```

### Vendor Prefixes

Order prefixes alphabetically, standard property last:

```css
.example {
  -moz-border-radius: 4px;
  -webkit-border-radius: 4px;
  border-radius: 4px;
}
```

**Modern approach: use autoprefixer**

Write standard CSS, let tools add prefixes:

```css
/* You write */
.example {
  border-radius: 4px;
}

/* Autoprefixer outputs */
.example {
  -webkit-border-radius: 4px;
  border-radius: 4px;
}
```

### Multi-line vs Single-line

**Multi-line (recommended):**
```css
.selector {
  property: value;
}
```

**Single-line (only for very simple rules):**
```css
.icon-small { width: 16px; height: 16px; }
.icon-medium { width: 24px; height: 24px; }
.icon-large { width: 32px; height: 32px; }
```

## Responsive Design Patterns

### Mobile-First Approach

```css
/* Base: Mobile styles */
.container {
  padding: 1rem;
  width: 100%;
}

.grid {
  display: block;
}

/* Tablet: min-width */
@media (min-width: 768px) {
  .container {
    padding: 2rem;
    width: 750px;
  }
  
  .grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
  }
}

/* Desktop: min-width */
@media (min-width: 1024px) {
  .container {
    width: 960px;
  }
  
  .grid {
    grid-template-columns: repeat(3, 1fr);
  }
}
```

### Common Breakpoints

```css
/* Extra small: phones */
@media (min-width: 320px) {}

/* Small: large phones, small tablets */
@media (min-width: 576px) {}

/* Medium: tablets */
@media (min-width: 768px) {}

/* Large: desktops */
@media (min-width: 992px) {}

/* Extra large: large desktops */
@media (min-width: 1200px) {}
```

### Container Queries (Modern)

```css
.card-container {
  container-type: inline-size;
}

.card {
  padding: 1rem;
}

/* Style based on container width */
@container (min-width: 400px) {
  .card {
    padding: 2rem;
  }
}
```

## Performance Optimization

### Efficient Selectors

```css
/* Slow: browser reads right-to-left */
body div.container ul li a {}

/* Fast: specific class */
.nav-link {}
```

**Browser selector matching (right to left):**
1. Find all `<a>` elements
2. Filter those inside `<li>`
3. Filter those inside `<ul>`
4. Filter those inside `.container`
5. Filter those inside `<div>`
6. Filter those inside `<body>`

### Reducing Reflows

Properties that trigger layout recalculation:

```css
/* Expensive: triggers layout */
.example {
  width: 100px;
  height: 100px;
  margin: 10px;
  padding: 10px;
  border: 1px solid;
  position: absolute;
  top: 10px;
  left: 10px;
}

/* Cheaper: only affects paint */
.example {
  color: red;
  background: blue;
}

/* Cheapest: only affects composite */
.example {
  opacity: 0.5;
  transform: translateX(10px);
}
```

### Will-change Hint

```css
.animated {
  will-change: transform, opacity;
}

/* Apply before animation, remove after */
.animated:hover {
  transform: scale(1.1);
  opacity: 0.8;
}
```

**Don't overuse:**
```css
/* Not recommended: too many elements */
* {
  will-change: transform;
}

/* Recommended: specific elements that will animate */
.modal-overlay {
  will-change: opacity;
}
```

## Common CSS Patterns

### Centering

**Horizontal center:**
```css
.center-horizontal {
  margin-left: auto;
  margin-right: auto;
  width: 80%;
}
```

**Vertical center (flexbox):**
```css
.center-vertical {
  align-items: center;
  display: flex;
  min-height: 100vh;
}
```

**Both (flexbox):**
```css
.center-both {
  align-items: center;
  display: flex;
  justify-content: center;
  min-height: 100vh;
}
```

**Both (grid):**
```css
.center-both-grid {
  display: grid;
  min-height: 100vh;
  place-items: center;
}
```

### Clearfix (Legacy)

```css
.clearfix::after {
  clear: both;
  content: "";
  display: table;
}
```

**Modern alternative: use flexbox or grid instead of floats**

### Aspect Ratio

```css
/* Old method */
.aspect-ratio-16-9 {
  padding-bottom: 56.25%; /* 9/16 * 100 */
  position: relative;
}

/* Modern */
.aspect-ratio {
  aspect-ratio: 16 / 9;
}
```

### Truncate Text

```css
.truncate {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

/* Multi-line truncate */
.truncate-multiline {
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 3;
  overflow: hidden;
}
```

## Debugging CSS

### Outline Debugging

```css
/* Quick visual debugging */
* {
  outline: 1px solid red;
}

/* Element-specific */
.debug {
  outline: 2px solid lime;
}
```

### Common Issues

**Margin collapse:**
```css
/* Problem: margins collapse */
.item {
  margin-bottom: 20px;
}

.item + .item {
  margin-top: 20px; /* Collapses with previous margin */
}

/* Solution: use gap or padding */
.container {
  display: flex;
  flex-direction: column;
  gap: 20px;
}
```

**Z-index not working:**
```css
/* Problem: z-index requires positioning */
.element {
  z-index: 999; /* Doesn't work */
}

/* Solution: add position */
.element {
  position: relative;
  z-index: 999;
}
```

## Browser Compatibility

### Feature Queries

```css
/* Fallback */
.grid {
  display: block;
}

/* Progressive enhancement */
@supports (display: grid) {
  .grid {
    display: grid;
  }
}
```

### Vendor Prefixes (when needed)

```css
.example {
  -webkit-appearance: none;
  -moz-appearance: none;
  appearance: none;
}
```

**Use tools like [Can I Use](https://caniuse.com/) to check support**

## Validation Checklist

- [ ] Passes W3C CSS Validator
- [ ] Uses meaningful class names
- [ ] Avoids ID selectors
- [ ] Uses shorthand properties where appropriate
- [ ] Omits units after 0
- [ ] Includes leading zeros
- [ ] Uses 3-char hex when possible
- [ ] Avoids `!important`
- [ ] Consistent 2-space indentation
- [ ] Lowercase selectors and properties
- [ ] Single quotes (except `@charset`)
- [ ] Semicolons after all declarations
- [ ] Space after property colons
- [ ] Space before opening braces
- [ ] New line per selector and declaration
- [ ] Blank line between rules
- [ ] Alphabetized or consistently ordered declarations
