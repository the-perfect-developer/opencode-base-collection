---
name: htmx
description: Provides guidance for building dynamic interactive web applications using htmx library with AJAX requests and dynamic content swapping
---

# HTMX Skill

Provides guidance for building dynamic, interactive web applications using htmx - a library that enables modern browser features directly from HTML attributes.

## Overview

htmx extends HTML with attributes that allow any element to issue HTTP requests and update page content without writing JavaScript. It brings the power of AJAX, CSS Transitions, WebSockets, and Server-Sent Events directly into HTML markup.

**Core Philosophy**: Server returns HTML (not JSON), keeping you in the hypermedia/HATEOAS model. Any element can issue requests, not just anchors and forms. Any event can trigger requests, not just clicks and submissions.

## Core Concepts

### AJAX Attributes

Use these attributes to issue HTTP requests:

- `hx-get="/url"` - Issues GET request
- `hx-post="/url"` - Issues POST request  
- `hx-put="/url"` - Issues PUT request
- `hx-patch="/url"` - Issues PATCH request
- `hx-delete="/url"` - Issues DELETE request

```html
<button hx-post="/clicked" hx-target="#result">
    Click Me!
</button>
<div id="result"></div>
```

### Triggering Requests

Control when requests fire with `hx-trigger`:

**Default triggers**: `input/textarea/select` use `change`, `form` uses `submit`, everything else uses `click`

**Custom triggers**:
```html
<!-- Trigger on mouseenter -->
<div hx-get="/data" hx-trigger="mouseenter">Hover me</div>

<!-- Trigger on keyup with delay -->
<input hx-get="/search" hx-trigger="keyup changed delay:500ms">

<!-- Multiple triggers -->
<div hx-get="/data" hx-trigger="mouseenter, focus">
```

**Modifiers**:
- `once` - Only trigger once
- `changed` - Only if value changed
- `delay:500ms` - Wait before issuing request
- `throttle:1s` - Rate limit requests
- `from:<selector>` - Listen on different element

**Filters**:
```html
<!-- Only trigger if Ctrl key pressed -->
<div hx-get="/clicked" hx-trigger="click[ctrlKey]">Ctrl+Click</div>
```

**Special events**:
- `load` - Fires when element loads
- `revealed` - Fires when scrolled into viewport
- `every 2s` - Poll every 2 seconds

### Targeting and Swapping

Control where and how content is inserted:

**Target selection** with `hx-target`:
```html
<button hx-get="/data" hx-target="#result">Load</button>
<div id="result"></div>
```

**Extended selectors**:
- `this` - The element itself
- `closest <selector>` - Nearest ancestor matching selector
- `next <selector>` - Next sibling matching selector
- `previous <selector>` - Previous sibling matching selector
- `find <selector>` - First child descendant

**Swap strategies** with `hx-swap`:
- `innerHTML` (default) - Replace inner content
- `outerHTML` - Replace entire element
- `afterbegin` - Prepend inside target
- `beforebegin` - Insert before target
- `beforeend` - Append inside target
- `afterend` - Insert after target
- `delete` - Delete target regardless of response
- `none` - Don't swap content

**Swap modifiers**:
```html
<button hx-get="/data" hx-swap="innerHTML swap:100ms settle:200ms">
```

### Request Indicators

Show loading state during requests:

```html
<button hx-get="/slow">
    Click Me!
    <img class="htmx-indicator" src="/spinner.gif">
</button>
```

The `htmx-indicator` class has `opacity:0` by default. When request starts, `htmx-request` class is added to the element, which makes indicators visible.

Specify custom indicator target:
```html
<button hx-get="/data" hx-indicator="#loading">Load</button>
<div id="loading" class="htmx-indicator">Loading...</div>
```

## Common Patterns

### Active Search

```html
<input type="text" name="q"
    hx-get="/search"
    hx-trigger="keyup changed delay:500ms"
    hx-target="#search-results"
    placeholder="Search...">
<div id="search-results"></div>
```

### Infinite Scroll

```html
<div hx-get="/more-items" 
     hx-trigger="revealed"
     hx-swap="afterend">
    Load More...
</div>
```

### Click to Edit

```html
<div hx-get="/edit/123" hx-target="this" hx-swap="outerHTML">
    <label>Name:</label> John Doe
</div>
```

### Delete with Confirmation

```html
<button hx-delete="/item/123"
        hx-confirm="Are you sure?"
        hx-target="closest tr"
        hx-swap="outerHTML swap:1s">
    Delete
</button>
```

### Out-of-Band Swaps

Update multiple parts of the page from one response:

```html
<!-- Response HTML -->
<div id="main-content">Main update</div>
<div id="notification" hx-swap-oob="true">
    New notification!
</div>
```

The element with `hx-swap-oob="true"` swaps into its matching ID anywhere on the page.

## Form Handling

### Basic Form Submission

```html
<form hx-post="/submit" hx-target="#result">
    <input name="email" type="email">
    <button type="submit">Submit</button>
</form>
```

### Including Additional Values

```html
<!-- Include other elements -->
<button hx-post="/save" 
        hx-include="[name='email']">
    Save
</button>

<!-- Add extra values -->
<button hx-post="/save" 
        hx-vals='{"priority": "high"}'>
    Save
</button>
```

### File Upload

```html
<form hx-post="/upload" 
      hx-encoding="multipart/form-data"
      hx-target="#result">
    <input type="file" name="file">
    <button type="submit">Upload</button>
</form>
```

Listen for upload progress:
```javascript
htmx.on('htmx:xhr:progress', function(evt) {
    htmx.find('#progress').value = evt.detail.loaded/evt.detail.total * 100;
});
```

## Request Synchronization

Coordinate requests between elements with `hx-sync`:

```html
<form hx-post="/store">
    <input name="title" 
           hx-post="/validate"
           hx-trigger="change"
           hx-sync="closest form:abort">
    <button type="submit">Submit</button>
</form>
```

Strategies:
- `drop` - Drop this request if target is in flight
- `abort` - Abort target request if this triggers
- `replace` - Abort target and issue this request
- `queue` - Queue this request after target

## Boosting

Progressive enhancement for regular links and forms:

```html
<div hx-boost="true">
    <a href="/page1">Page 1</a>
    <a href="/page2">Page 2</a>
</div>
```

Links and forms become AJAX requests that target the body. Works without JavaScript enabled (graceful degradation).

## History Support

Add URLs to browser history:

```html
<a hx-get="/blog" hx-push-url="true">Blog</a>
```

When user clicks back button, htmx restores the previous state. For history to work, URLs must return complete pages when visited directly.

**Disable history caching** for sensitive data:
```html
<div hx-history="false">Sensitive content</div>
```

## Headers

### Request Headers

htmx automatically sends:
- `HX-Request: true` - Identifies htmx requests
- `HX-Trigger` - ID of triggering element
- `HX-Target` - ID of target element
- `HX-Current-URL` - Current page URL
- `HX-Prompt` - User response to prompt

Use these to return partial HTML vs full pages:
```python
if request.headers.get('HX-Request'):
    return render_template('partial.html')
return render_template('full_page.html')
```

### Response Headers

Control client behavior from server:

- `HX-Trigger` - Trigger client-side events
- `HX-Redirect` - Client-side redirect (full page)
- `HX-Location` - Client-side redirect (AJAX)
- `HX-Refresh` - Force page refresh
- `HX-Retarget` - Change target element
- `HX-Reswap` - Change swap strategy

```python
response.headers['HX-Trigger'] = 'itemUpdated'
response.headers['HX-Trigger'] = '{"showMessage": "Saved!"}'
```

## Validation

htmx integrates with HTML5 validation:

```html
<form hx-post="/submit">
    <input name="email" type="email" required>
    <button type="submit">Submit</button>
</form>
```

Set `htmx.config.reportValidityOfForms = true` to show validation messages.

**Custom validation**:
```javascript
htmx.on('htmx:validation:validate', function(evt) {
    if (evt.target.value === 'forbidden') {
        evt.target.setCustomValidity('This value is forbidden');
        evt.detail.valid = false;
    }
});
```

## Events and Scripting

### Event Handling

Use `hx-on` for inline event handlers:

```html
<button hx-get="/data" 
        hx-on::before-request="this.classList.add('loading')"
        hx-on::after-request="this.classList.remove('loading')">
    Load
</button>
```

### JavaScript API

```javascript
// Trigger requests programmatically
htmx.ajax('GET', '/data', '#target');

// Listen to events
htmx.on('htmx:afterSwap', function(evt) {
    console.log('Content swapped');
});

// Process new content
htmx.process(document.body);

// Trigger events
htmx.trigger('#element', 'myEvent', {detail: {foo: 'bar'}});
```

## CSS Transitions

Keep element IDs stable across swaps for automatic transitions:

```html
<!-- Before -->
<div id="content">Old content</div>

<!-- After (same ID) -->
<div id="content" class="highlight">New content</div>
```

```css
.highlight {
    background-color: yellow;
    transition: background-color 1s ease-in;
}
```

htmx preserves the DOM element and transitions the class change.

## Configuration

Configure globally or via meta tag:

```html
<meta name="htmx-config" content='{
    "defaultSwapStyle": "outerHTML",
    "defaultSwapDelay": 100,
    "defaultSettleDelay": 200,
    "historyCacheSize": 20
}'>
```

Or in JavaScript:
```javascript
htmx.config.defaultSwapStyle = 'outerHTML';
htmx.config.timeout = 5000; // 5 second timeout
```

## Installation

### CDN (Recommended for quick start)

```html
<script src="https://cdn.jsdelivr.net/npm/htmx.org@2.0.8/dist/htmx.min.js"></script>
```

### npm

```bash
npm install htmx.org@2.0.8
```

Then import:
```javascript
import 'htmx.org';
```

### Download

Download from jsDelivr and include locally:
```html
<script src="/js/htmx.min.js"></script>
```

## Best Practices

1. **Keep IDs stable** - Use consistent IDs across requests for CSS transitions
2. **Return appropriate content** - Return partials for htmx requests, full pages for direct access
3. **Use semantic HTML** - htmx enhances HTML, so start with good markup
4. **Progressive enhancement** - Use `hx-boost` so features work without JavaScript
5. **Handle errors** - Listen to `htmx:responseError` and `htmx:sendError` events
6. **Validate inputs** - Enable `htmx.config.reportValidityOfForms = true`
7. **Test without JavaScript** - Ensure core functionality works when JS is disabled

## Debugging

Enable logging:
```javascript
htmx.logAll();
```

Or set custom logger:
```javascript
htmx.logger = function(elt, event, data) {
    if(console) {
        console.log(event, elt, data);
    }
}
```

Use browser DevTools to inspect:
- Network tab for request/response details
- `HX-*` headers in request/response
- Event listeners on elements
- `htmx-*` classes during swap lifecycle

## Additional Resources

For comprehensive details:
- **`references/attributes.md`** - Complete attribute reference
- **`references/events.md`** - All htmx events and lifecycle
- **`references/examples.md`** - Advanced patterns and real-world examples
- **`references/server-side.md`** - Server-side implementation patterns
