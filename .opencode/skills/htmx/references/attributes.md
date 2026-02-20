# HTMX Attributes Reference

Complete reference for all htmx attributes.

## Core AJAX Attributes

### hx-get

Issues a GET request to the specified URL.

```html
<button hx-get="/data">Get Data</button>
```

### hx-post

Issues a POST request to the specified URL.

```html
<form hx-post="/submit">
    <input name="email">
    <button type="submit">Submit</button>
</form>
```

### hx-put

Issues a PUT request to the specified URL.

```html
<button hx-put="/update/123">Update</button>
```

### hx-patch

Issues a PATCH request to the specified URL.

```html
<button hx-patch="/partial-update/123">Partial Update</button>
```

### hx-delete

Issues a DELETE request to the specified URL.

```html
<button hx-delete="/item/123" hx-confirm="Are you sure?">Delete</button>
```

## Trigger Attributes

### hx-trigger

Specifies the event that triggers the request.

**Basic usage**:
```html
<div hx-get="/data" hx-trigger="mouseenter">Hover to load</div>
```

**Multiple triggers**:
```html
<div hx-get="/data" hx-trigger="mouseenter, focus">Load on hover or focus</div>
```

**Modifiers**:

- `once` - Request fires only once
```html
<div hx-get="/data" hx-trigger="click once">Click once</div>
```

- `changed` - Only trigger if value changed
```html
<input hx-get="/validate" hx-trigger="keyup changed">
```

- `delay:<time>` - Wait before triggering
```html
<input hx-get="/search" hx-trigger="keyup delay:500ms">
```

- `throttle:<time>` - Rate limit triggers
```html
<div hx-get="/track" hx-trigger="mousemove throttle:1s">Track movement</div>
```

- `from:<selector>` - Listen on different element
```html
<div hx-get="/data" hx-trigger="click from:body">Listen to body clicks</div>
```

**Trigger filters**:
```html
<!-- Only trigger if Ctrl key is pressed -->
<button hx-get="/data" hx-trigger="click[ctrlKey]">Ctrl+Click</button>

<!-- Only trigger if value equals specific string -->
<input hx-get="/search" hx-trigger="keyup[target.value.length > 3]">
```

**Special events**:

- `load` - Fires when element loads
```html
<div hx-get="/data" hx-trigger="load">Load on page load</div>
```

- `revealed` - Fires when scrolled into viewport
```html
<div hx-get="/more" hx-trigger="revealed">Infinite scroll</div>
```

- `intersect` - Fires on intersection with viewport
```html
<div hx-get="/data" hx-trigger="intersect once">Load when visible</div>
```

**Polling**:
```html
<!-- Poll every 2 seconds -->
<div hx-get="/updates" hx-trigger="every 2s">Updates</div>

<!-- Load polling pattern -->
<div hx-get="/progress" hx-trigger="load delay:1s" hx-swap="outerHTML">
    Checking progress...
</div>
```

## Target Attributes

### hx-target

Specifies where to load the response.

**ID selector**:
```html
<button hx-get="/data" hx-target="#result">Load</button>
<div id="result"></div>
```

**Extended selectors**:

- `this` - Target the element itself
```html
<div hx-get="/edit" hx-target="this">Click to edit</div>
```

- `closest <selector>` - Nearest ancestor
```html
<button hx-delete="/item" hx-target="closest tr">Delete row</button>
```

- `next <selector>` - Next sibling
```html
<button hx-get="/more" hx-target="next .container">Load next</button>
```

- `previous <selector>` - Previous sibling
```html
<button hx-get="/prev" hx-target="previous .item">Previous</button>
```

- `find <selector>` - First child descendant
```html
<div hx-get="/data" hx-target="find .content">
    <div class="content"></div>
</div>
```

### hx-swap

Controls how content is swapped in.

**Swap strategies**:

- `innerHTML` (default) - Replace inner HTML
```html
<div hx-get="/data" hx-swap="innerHTML">Content replaced</div>
```

- `outerHTML` - Replace entire element
```html
<div hx-get="/data" hx-swap="outerHTML">Element replaced</div>
```

- `afterbegin` - Prepend inside target
```html
<div hx-get="/item" hx-swap="afterbegin">New items prepended</div>
```

- `beforebegin` - Insert before target
```html
<div hx-get="/item" hx-swap="beforebegin">Insert before</div>
```

- `beforeend` - Append inside target
```html
<div hx-get="/item" hx-swap="beforeend">Append new items</div>
```

- `afterend` - Insert after target
```html
<div hx-get="/item" hx-swap="afterend">Insert after</div>
```

- `delete` - Delete target
```html
<button hx-delete="/item" hx-swap="delete">Delete</button>
```

- `none` - Don't swap (useful for side effects only)
```html
<button hx-post="/track" hx-swap="none">Track click</button>
```

**Swap modifiers**:

- `swap:<time>` - Delay between clearing old content and inserting new
```html
<div hx-get="/data" hx-swap="innerHTML swap:100ms"></div>
```

- `settle:<time>` - Delay between insertion and settling
```html
<div hx-get="/data" hx-swap="innerHTML settle:100ms"></div>
```

- `transition:true` - Use View Transitions API
```html
<div hx-get="/data" hx-swap="innerHTML transition:true"></div>
```

- `scroll:<direction>` - Scroll target to top/bottom
```html
<div hx-get="/data" hx-swap="beforeend scroll:bottom"></div>
```

- `show:<direction>` - Scroll target into view
```html
<div hx-get="/data" hx-swap="innerHTML show:top"></div>
```

- `focus-scroll:true/false` - Control focus scrolling
```html
<div hx-get="/data" hx-swap="innerHTML focus-scroll:false"></div>
```

- `ignoreTitle:true` - Don't update document title
```html
<div hx-get="/data" hx-swap="innerHTML ignoreTitle:true"></div>
```

## Request Modification Attributes

### hx-include

Include additional elements in the request.

```html
<button hx-post="/submit" hx-include="[name='user_id']">
    Submit
</button>
<input type="hidden" name="user_id" value="123">
```

### hx-vals

Add extra values to the request (JSON format).

```html
<button hx-post="/save" hx-vals='{"priority": "high"}'>
    Save
</button>

<!-- Dynamic values using js: prefix -->
<button hx-post="/save" hx-vals='js:{timestamp: Date.now()}'>
    Save with timestamp
</button>
```

### hx-params

Filter which parameters to include.

```html
<!-- Include only specific params -->
<form hx-post="/submit" hx-params="email,password">
    <input name="email">
    <input name="password">
    <input name="tracking_id">  <!-- Not sent -->
</form>

<!-- Exclude specific params -->
<form hx-post="/submit" hx-params="*,!tracking_id">
    <input name="email">
    <input name="tracking_id">  <!-- Not sent -->
</form>

<!-- Send none -->
<button hx-post="/click" hx-params="none">Click</button>
```

### hx-headers

Add custom headers to request.

```html
<button hx-get="/data" 
        hx-headers='{"X-API-Key": "secret123"}'>
    Get Data
</button>
```

### hx-encoding

Set the encoding type for the request.

```html
<!-- File upload -->
<form hx-post="/upload" hx-encoding="multipart/form-data">
    <input type="file" name="file">
    <button type="submit">Upload</button>
</form>
```

## Indicator Attributes

### hx-indicator

Specify which element should show the loading indicator.

```html
<button hx-get="/slow" hx-indicator="#spinner">
    Load Data
</button>
<div id="spinner" class="htmx-indicator">Loading...</div>
```

### hx-disabled-elt

Add `disabled` attribute to elements during request.

```html
<form hx-post="/submit">
    <input name="email">
    <button type="submit" hx-disabled-elt="this">Submit</button>
</form>

<!-- Disable multiple elements -->
<button hx-post="/save" hx-disabled-elt="find button">
    Save
</button>
```

## Synchronization Attributes

### hx-sync

Coordinate requests between elements.

**Strategies**:

- `drop` - Drop this request if target is busy
```html
<button hx-get="/data" hx-sync="this:drop">Only one request</button>
```

- `abort` - Abort target request if this fires
```html
<form hx-post="/save">
    <input hx-post="/validate" hx-sync="closest form:abort">
    <button type="submit">Submit</button>
</form>
```

- `replace` - Abort target and issue this request
```html
<input hx-get="/search" hx-sync="this:replace">
```

- `queue` - Queue this after target
```html
<button hx-get="/data" hx-sync="this:queue">Queued request</button>
```

**Queue options**:
- `queue first` - Queue at the beginning
- `queue last` - Queue at the end (default)
- `queue all` - Queue all requests

```html
<button hx-get="/data" hx-sync="this:queue last">Load</button>
```

## Selection Attributes

### hx-select

Select specific content from response.

```html
<button hx-get="/page" hx-select="#content">
    Load content section only
</button>
```

### hx-select-oob

Select content for out-of-band swaps.

```html
<button hx-get="/data" hx-select-oob="#notifications,#messages">
    Load and update sidebar
</button>
```

### hx-swap-oob

Mark element in response for out-of-band swap (used in response HTML).

```html
<!-- Response HTML -->
<div id="main">Main content</div>
<div id="notifications" hx-swap-oob="true">
    3 new messages
</div>
<div id="timestamp" hx-swap-oob="innerHTML:#footer">
    Last updated: 10:30 AM
</div>
```

## History Attributes

### hx-push-url

Push URL into browser history.

```html
<!-- Push the request URL -->
<a hx-get="/page1" hx-push-url="true">Page 1</a>

<!-- Push custom URL -->
<button hx-get="/data" hx-push-url="/custom-url">Load</button>
```

### hx-replace-url

Replace current URL in history.

```html
<button hx-get="/page" hx-replace-url="true">Replace URL</button>
```

### hx-history

Control history behavior for the element.

```html
<!-- Disable history for sensitive data -->
<div hx-history="false">
    <form hx-post="/login">...</form>
</div>
```

### hx-history-elt

Specify element to snapshot for history.

```html
<div hx-history-elt="#main-content">
    <div id="main-content">Content to snapshot</div>
</div>
```

## Boosting Attributes

### hx-boost

Convert links and forms to AJAX requests.

```html
<div hx-boost="true">
    <a href="/page1">Page 1</a>
    <a href="/page2">Page 2</a>
    <form action="/submit" method="post">
        <button type="submit">Submit</button>
    </form>
</div>
```

## Validation Attributes

### hx-validate

Force validation before request.

```html
<input name="email" 
       hx-post="/validate" 
       hx-trigger="change"
       hx-validate="true">
```

### hx-confirm

Show confirmation dialog before request.

```html
<button hx-delete="/item/123" 
        hx-confirm="Are you sure you want to delete this?">
    Delete
</button>
```

### hx-prompt

Prompt user for input before request.

```html
<button hx-delete="/item" 
        hx-prompt="Enter item name to confirm">
    Delete
</button>
```

## Extension Attributes

### hx-ext

Enable extensions for element and children.

```html
<!-- Enable JSON encoding extension -->
<div hx-ext="json-enc">
    <form hx-post="/api/save">...</form>
</div>

<!-- Enable multiple extensions -->
<div hx-ext="json-enc,debug">...</div>

<!-- Disable extension on child -->
<div hx-ext="json-enc">
    <form hx-post="/standard" hx-ext="ignore:json-enc">...</form>
</div>
```

## Inheritance Control Attributes

### hx-disinherit

Prevent attribute inheritance.

```html
<!-- Don't inherit hx-confirm -->
<div hx-confirm="Are you sure?">
    <button hx-delete="/item/1">Delete 1</button>
    <button hx-delete="/item/2" hx-disinherit="hx-confirm">
        Delete 2 (no confirm)
    </button>
</div>

<!-- Don't inherit any attributes -->
<button hx-disinherit="*">Independent</button>
```

### hx-inherit

Enable inheritance when disabled by default.

```html
<div hx-inherit="hx-target">
    <!-- Will inherit hx-target from parent -->
</div>
```

## Preservation Attributes

### hx-preserve

Preserve element across swaps.

```html
<!-- Video player continues across content swaps -->
<video id="player" hx-preserve="true">
    <source src="/video.mp4">
</video>
```

## Control Attributes

### hx-disable

Disable htmx processing for element and children.

```html
<div hx-disable>
    <button hx-get="/data">Won't work - htmx disabled</button>
</div>
```

## Event Handling Attributes

### hx-on

Handle htmx events inline.

```html
<button hx-get="/data"
        hx-on::before-request="this.classList.add('loading')"
        hx-on::after-request="this.classList.remove('loading')"
        hx-on:htmx:response-error="alert('Error!')">
    Load Data
</button>
```

Syntax: `hx-on::<short-event-name>` or `hx-on:<full-event-name>`

## Request Configuration Attributes

### hx-request

Configure various aspects of the request.

```html
<button hx-get="/data" 
        hx-request='{"timeout": 5000, "credentials": true}'>
    Load with 5s timeout
</button>
```

Options:
- `timeout` - Request timeout in milliseconds
- `credentials` - Include credentials (cookies, auth)
- `noHeaders` - Don't add htmx headers

## CSS Classes

htmx automatically manages these CSS classes:

- `htmx-request` - Added to element during request
- `htmx-swapping` - Added before swap
- `htmx-settling` - Added during settle phase
- `htmx-added` - Added to new content

Use these for styling:

```css
.htmx-request {
    opacity: 0.5;
}

.htmx-swapping {
    transition: opacity 200ms;
    opacity: 0;
}
```
