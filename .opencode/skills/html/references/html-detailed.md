# Detailed HTML Guidelines

This document provides comprehensive guidance on HTML best practices based on Google's style guide.

## HTML Validity and Structure

### Document Type Declaration

The HTML5 doctype is required to prevent quirks mode rendering:

```html
<!doctype html>
```

**Why this matters:**
- Without doctype: Browser renders in "quirks mode"
- Different doctype: May render in "limited-quirks mode"
- These modes don't follow standard HTML/CSS behavior
- Causes subtle failures and incompatibilities

### Character Encoding

Always specify UTF-8 encoding in HTML documents:

```html
<meta charset="utf-8">
```

**Best practices:**
- Place `<meta charset="utf-8">` early in `<head>`
- Don't use Byte Order Mark (BOM)
- Ensure editor saves files as UTF-8
- CSS files assume UTF-8, no encoding declaration needed

### Complete Valid Document Structure

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Page Title</title>
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <main>
    <h1>Main Heading</h1>
    <p>Content goes here.</p>
  </main>
  <script src="script.js"></script>
</body>
</html>
```

## Semantic HTML Usage

### Heading Hierarchy

Use headings to create document structure:

```html
<!-- Correct hierarchy -->
<h1>Site Title</h1>
  <h2>Section 1</h2>
    <h3>Subsection 1.1</h3>
    <h3>Subsection 1.2</h3>
  <h2>Section 2</h2>

<!-- Incorrect: skips levels -->
<h1>Site Title</h1>
  <h3>Should be h2</h3>
```

**Guidelines:**
- One `h1` per page (typically page title)
- Don't skip heading levels
- Don't use headings for styling (use CSS)
- Headings provide document outline for screen readers

### Link Elements

Use `<a>` for navigation, not `<div>` or `<span>`:

```html
<!-- Not recommended -->
<div onclick="navigate('/page')">Click here</div>
<span class="link" onclick="goTo('/page')">Link text</span>

<!-- Recommended -->
<a href="/page">Link text</a>
```

**Benefits:**
- Keyboard accessible (Tab navigation)
- Screen reader compatible
- Right-click context menu works
- Shows URL in status bar
- Can be opened in new tab

### Button Elements

Use `<button>` for actions, `<a>` for navigation:

```html
<!-- Not recommended -->
<div class="button" onclick="submit()">Submit</div>
<a href="#" onclick="submit(); return false;">Submit</a>

<!-- Recommended -->
<button type="submit">Submit</button>
<button type="button" onclick="handleClick()">Click Me</button>
```

**Button types:**
- `type="submit"`: Submits form (default in `<form>`)
- `type="button"`: Generic button, no default behavior
- `type="reset"`: Resets form fields

### Lists

Use appropriate list types:

```html
<!-- Unordered lists (no sequence) -->
<ul>
  <li>Red</li>
  <li>Green</li>
  <li>Blue</li>
</ul>

<!-- Ordered lists (sequence matters) -->
<ol>
  <li>Preheat oven</li>
  <li>Mix ingredients</li>
  <li>Bake for 30 minutes</li>
</ol>

<!-- Description lists (key-value pairs) -->
<dl>
  <dt>HTML</dt>
  <dd>HyperText Markup Language</dd>
  <dt>CSS</dt>
  <dd>Cascading Style Sheets</dd>
</dl>
```

### Tables

Use tables for tabular data only, not layout:

```html
<table>
  <caption>Sales Report Q1 2024</caption>
  <thead>
    <tr>
      <th scope="col">Product</th>
      <th scope="col">Units Sold</th>
      <th scope="col">Revenue</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">Widget A</th>
      <td>1,234</td>
      <td>$12,340</td>
    </tr>
    <tr>
      <th scope="row">Widget B</th>
      <td>5,678</td>
      <td>$56,780</td>
    </tr>
  </tbody>
  <tfoot>
    <tr>
      <th scope="row">Total</th>
      <td>6,912</td>
      <td>$69,120</td>
    </tr>
  </tfoot>
</table>
```

**Accessibility features:**
- `<caption>`: Table title for screen readers
- `scope="col"`: Header applies to column
- `scope="row"`: Header applies to row
- `<thead>`, `<tbody>`, `<tfoot>`: Semantic grouping

### Forms

Create accessible forms:

```html
<form action="/submit" method="post">
  <div class="form-group">
    <label for="username">Username:</label>
    <input type="text" id="username" name="username" required>
  </div>
  
  <div class="form-group">
    <label for="email">Email:</label>
    <input type="email" id="email" name="email" required>
  </div>
  
  <div class="form-group">
    <label for="country">Country:</label>
    <select id="country" name="country">
      <option value="">Select a country</option>
      <option value="us">United States</option>
      <option value="uk">United Kingdom</option>
    </select>
  </div>
  
  <fieldset>
    <legend>Subscription</legend>
    <label>
      <input type="radio" name="plan" value="free"> Free
    </label>
    <label>
      <input type="radio" name="plan" value="premium"> Premium
    </label>
  </fieldset>
  
  <button type="submit">Submit</button>
</form>
```

**Key points:**
- Always associate `<label>` with form controls using `for`/`id`
- Use `<fieldset>` and `<legend>` for grouping
- Use appropriate input types (`email`, `tel`, `url`, etc.)
- Include `required` attribute for required fields

## Multimedia and Accessibility

### Images

#### Meaningful Images

Provide descriptive alt text:

```html
<img src="chart-q1-sales.png" 
     alt="Bar chart showing Q1 sales: Product A $50k, Product B $75k, Product C $30k">
```

#### Decorative Images

Use empty alt for decorative images:

```html
<img src="decorative-line.png" alt="">
```

#### Complex Images

Use longer descriptions for complex visuals:

```html
<figure>
  <img src="infographic.png" alt="Customer journey map">
  <figcaption>
    The customer journey has 5 stages: Awareness, Consideration, 
    Purchase, Retention, and Advocacy. Each stage has different 
    touchpoints and objectives.
  </figcaption>
</figure>
```

### Video

Provide multiple accessibility features:

```html
<video controls>
  <source src="video.mp4" type="video/mp4">
  <source src="video.webm" type="video/webm">
  <track kind="captions" src="captions-en.vtt" srclang="en" label="English">
  <track kind="subtitles" src="subtitles-es.vtt" srclang="es" label="Español">
  <p>Your browser doesn't support HTML5 video. 
     <a href="video.mp4">Download the video</a> instead.</p>
</video>
```

### Audio

```html
<audio controls>
  <source src="podcast.mp3" type="audio/mpeg">
  <source src="podcast.ogg" type="audio/ogg">
  <p>Your browser doesn't support HTML5 audio. 
     <a href="podcast.mp3">Download the audio</a> instead.</p>
</audio>
```

## Separation of Concerns

### Avoiding Inline Styles

```html
<!-- Not recommended -->
<div style="color: red; font-size: 18px; margin: 10px;">
  Content
</div>

<!-- Recommended -->
<div class="alert-message">
  Content
</div>
```

CSS file:
```css
.alert-message {
  color: red;
  font-size: 18px;
  margin: 10px;
}
```

### Avoiding Inline Event Handlers

```html
<!-- Not recommended -->
<button onclick="handleClick()">Click Me</button>
<a href="#" onclick="doSomething(); return false;">Link</a>

<!-- Recommended -->
<button class="submit-btn">Click Me</button>
<a href="/page" class="action-link">Link</a>
```

JavaScript file:
```javascript
document.querySelector('.submit-btn').addEventListener('click', handleClick);
document.querySelector('.action-link').addEventListener('click', handleAction);
```

### Minimal External Resources

```html
<!-- Not recommended: too many files -->
<link rel="stylesheet" href="reset.css">
<link rel="stylesheet" href="typography.css">
<link rel="stylesheet" href="layout.css">
<link rel="stylesheet" href="components.css">
<link rel="stylesheet" href="utilities.css">

<!-- Recommended: combine into fewer files -->
<link rel="stylesheet" href="main.css">
```

## ID Attributes Best Practices

### Why Avoid IDs

IDs create global window properties:

```html
<div id="userProfile"></div>
```

JavaScript:
```javascript
// This works but is problematic
console.log(window.userProfile); // <div id="userProfile"></div>
console.log(userProfile); // Same as above - global variable!
```

### When IDs Are Required

Use hyphens to prevent JavaScript conflicts:

```html
<!-- Not recommended: creates window.userProfile -->
<div id="userProfile"></div>

<!-- Recommended: window['user-profile'] can't be a variable -->
<div aria-describedby="user-profile">
  <div id="user-profile"></div>
</div>
```

### Prefer Classes and Data Attributes

```html
<!-- For styling: use classes -->
<div class="user-profile"></div>

<!-- For scripting: use data attributes -->
<div data-user-id="12345" data-role="admin"></div>
```

JavaScript:
```javascript
const element = document.querySelector('[data-user-id="12345"]');
const userId = element.dataset.userId; // "12345"
const role = element.dataset.role; // "admin"
```

## Optional Tag Omission

HTML5 allows omitting certain tags for brevity:

### Complete Version

```html
<!doctype html>
<html>
  <head>
    <title>Full Version</title>
  </head>
  <body>
    <p>Paragraph 1.</p>
    <p>Paragraph 2.</p>
  </body>
</html>
```

### Minimal Version

```html
<!doctype html>
<title>Minimal Version</title>
<p>Paragraph 1.
<p>Paragraph 2.
```

### What Can Be Omitted

- `<html>`, `</html>`
- `<head>`, `</head>`
- `<body>`, `</body>`
- Closing `</p>`, `</li>`, `</dt>`, `</dd>`, `</option>`, `</thead>`, `</tbody>`, `</tfoot>`, `</tr>`, `</td>`, `</th>`

### When to Keep Tags

Keep tags for:
- Clarity in complex documents
- Team consistency preferences
- When using attributes on optional elements

## Formatting Edge Cases

### Inline vs Block Line Breaks

```html
<!-- Inline elements: keep together -->
<p>This is a <a href="/page">link to a page</a> in a sentence.</p>

<!-- Block elements: new lines -->
<article>
  <h2>Article Title</h2>
  <p>Article content.</p>
</article>
```

### List Item Formatting

```html
<!-- Option 1: closing tags omitted -->
<ul>
  <li>First item
  <li>Second item
  <li>Third item
</ul>

<!-- Option 2: closing tags included -->
<ul>
  <li>First item</li>
  <li>Second item</li>
  <li>Third item</li>
</ul>

<!-- Both are valid, be consistent within project -->
```

### Attribute Wrapping

For many attributes, use consistent wrapping:

```html
<!-- Option 1: First attribute on same line -->
<button mat-icon-button color="primary" class="menu-button"
    (click)="openMenu()">
  <mat-icon>menu</mat-icon>
</button>

<!-- Option 2: Each attribute indented -->
<button
    mat-icon-button
    color="primary"
    class="menu-button"
    (click)="openMenu()">
  <mat-icon>menu</mat-icon>
</button>

<!-- Option 3: Aligned attributes -->
<button mat-icon-button
        color="primary"
        class="menu-button"
        (click)="openMenu()">
  <mat-icon>menu</mat-icon>
</button>
```

## Comments and Documentation

### Section Comments

```html
<!-- Header -->
<header>
  <nav>...</nav>
</header>

<!-- Main Content -->
<main>
  <article>...</article>
</main>

<!-- Footer -->
<footer>
  <p>Copyright 2024</p>
</footer>
```

### TODO Comments

```html
<!-- TODO: Add proper error handling -->
<form action="/submit" method="post">
  ...
</form>

<!-- TODO: Replace with semantic time element -->
<span class="date">2024-02-19</span>
```

### Conditional Comments (Legacy IE)

```html
<!--[if IE]>
  <link rel="stylesheet" href="ie-fixes.css">
<![endif]-->
```

Note: Modern development doesn't need IE conditional comments.

## Protocol Best Practices

### Always Use HTTPS

```html
<!-- Not recommended -->
<script src="//cdn.example.com/lib.js"></script>
<img src="http://example.com/image.jpg">

<!-- Recommended -->
<script src="https://cdn.example.com/lib.js"></script>
<img src="https://example.com/image.jpg">
```

### Relative URLs for Same-Origin Resources

```html
<!-- For resources on same domain -->
<link rel="stylesheet" href="/css/styles.css">
<script src="/js/app.js"></script>
<img src="/images/logo.png">
```

## Common Pitfalls

### Using Divs for Everything

```html
<!-- Not recommended -->
<div class="header">
  <div class="nav">
    <div class="nav-item">Home</div>
  </div>
</div>
<div class="content">
  <div class="article">
    <div class="title">Title</div>
    <div class="text">Content</div>
  </div>
</div>

<!-- Recommended -->
<header>
  <nav>
    <a href="/">Home</a>
  </nav>
</header>
<main>
  <article>
    <h1>Title</h1>
    <p>Content</p>
  </article>
</main>
```

### Missing Alt Text

```html
<!-- Not recommended -->
<img src="photo.jpg">
<img src="photo.jpg" alt="photo">

<!-- Recommended -->
<img src="photo.jpg" alt="Team meeting in conference room">
<img src="decorative.jpg" alt="">
```

### Using Deprecated Elements

Avoid deprecated HTML elements:

```html
<!-- Not recommended -->
<center>Centered text</center>
<font color="red">Red text</font>
<b>Bold text</b>
<i>Italic text</i>

<!-- Recommended -->
<div class="text-center">Centered text</div>
<span class="text-danger">Red text</span>
<strong>Bold text</strong>
<em>Italic text</em>
```

## Validation and Testing

### W3C Validation

Use [W3C Validator](https://validator.w3.org/nu/) to check HTML:

```bash
# Via upload, URL, or direct input
# Checks for:
# - Syntax errors
# - Missing required attributes
# - Deprecated elements
# - Nesting violations
```

### Accessibility Testing

Tools for accessibility:
- [WAVE Web Accessibility Evaluation Tool](https://wave.webaim.org/)
- [axe DevTools](https://www.deque.com/axe/devtools/)
- Browser DevTools Lighthouse audit

### Browser Testing

Test across browsers:
- Chrome/Edge (Chromium)
- Firefox
- Safari
- Mobile browsers

## Summary Checklist

- [ ] Document starts with `<!doctype html>`
- [ ] UTF-8 charset declared
- [ ] HTTPS for all external resources
- [ ] Valid HTML (passes W3C validator)
- [ ] Semantic elements used appropriately
- [ ] All images have appropriate alt text
- [ ] Forms have associated labels
- [ ] No inline styles or event handlers
- [ ] Consistent 2-space indentation
- [ ] Lowercase element and attribute names
- [ ] Double quotes for attribute values
- [ ] No trailing whitespace
- [ ] IDs use hyphens when required
- [ ] Type attributes omitted for CSS/JS
