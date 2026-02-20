---
name: alpinejs
description: This skill should be used when the user asks to "add Alpine.js", "create Alpine component", "use Alpine directives", "build interactive UI with Alpine", or needs guidance on Alpine.js development patterns and best practices.
compatibility: opencode
---

# Alpine.js Development

Build reactive, declarative interfaces by adding Alpine.js directives directly to HTML markup.

## What is Alpine.js

Alpine.js is a lightweight JavaScript framework that provides reactive and declarative behavior directly in HTML markup. It offers Vue-like syntax and reactivity without the build step, making it perfect for enhancing static sites or adding interactivity to server-rendered pages.

**Key characteristics**:
- No build step required - include via CDN or npm
- Declarative syntax using HTML attributes (directives)
- Reactive data binding and state management
- Small footprint (~15kb gzipped)
- Works seamlessly with server-rendered HTML

## Installation

### Via CDN (Quick Start)

Add the script tag to your HTML `<head>`:

```html
<script defer src="https://cdn.jsdelivr.net/npm/[email protected]/dist/cdn.min.js"></script>
```

The `defer` attribute ensures Alpine loads after the HTML is parsed.

### Via npm

```bash
npm install alpinejs
```

Then import and initialize:

```javascript
import Alpine from 'alpinejs'
window.Alpine = Alpine
Alpine.start()
```

## Core Concepts

### State with x-data

Declare reactive state using the `x-data` directive. All Alpine components start with `x-data`:

```html
<div x-data="{ count: 0, message: 'Hello' }">
  <!-- State is accessible within this element and its children -->
</div>
```

**Key points**:
- Define data as a JavaScript object
- Properties are reactive - changes trigger UI updates
- Data is scoped to the element and its children
- Child elements can override parent data properties

### Event Handling with x-on

Listen to browser events using `x-on:` or the `@` shorthand:

```html
<button @click="count++">Increment</button>
<button x-on:click="count++">Increment (verbose)</button>
```

**Common event modifiers**:
- `.prevent` - Prevent default behavior
- `.stop` - Stop event propagation
- `.outside` - Trigger when clicking outside element
- `.window` - Listen on window object
- `.debounce` - Debounce the handler

**Key-specific listeners**:
```html
<input @keyup.enter="submit()">
<input @keyup.shift.enter="specialSubmit()">
```

### Templating and Display

**x-text** - Set element text content:
```html
<span x-text="message"></span>
```

**x-html** - Set element HTML (use only with trusted content):
```html
<div x-html="htmlContent"></div>
```

**x-show** - Toggle visibility with CSS display property:
```html
<div x-show="isVisible">Content</div>
```

**x-if** - Conditionally add/remove element from DOM:
```html
<template x-if="shouldShow">
  <div>Content</div>
</template>
```

**When to use x-show vs x-if**:
- Use `x-show` when toggling frequently (keeps element in DOM)
- Use `x-if` when conditionally rendering expensive content

### Looping with x-for

Iterate over arrays to render lists:

```html
<template x-for="item in items" :key="item.id">
  <li x-text="item.name"></li>
</template>
```

**Requirements**:
- Must be on a `<template>` element
- Should include `:key` for proper tracking

### Binding Attributes with x-bind

Dynamically bind HTML attributes using `x-bind:` or `:` shorthand:

```html
<img :src="imageUrl" :alt="description">
<button :disabled="isProcessing">Submit</button>
```

**Class binding** (special object syntax):
```html
<div :class="{ 'active': isActive, 'error': hasError }">
```

**Style binding**:
```html
<div :style="{ color: textColor, fontSize: size + 'px' }">
```

### Two-Way Binding with x-model

Bind input values to data properties:

```html
<input x-model="username" type="text">
<textarea x-model="message"></textarea>
<select x-model="country">
  <option value="us">United States</option>
  <option value="ca">Canada</option>
</select>
```

**Modifiers**:
- `.number` - Convert to number
- `.debounce` - Debounce input
- `.throttle` - Throttle input

## Common Patterns

### Toggle Component

```html
<div x-data="{ open: false }">
  <button @click="open = !open">Toggle</button>
  <div x-show="open" x-transition>
    Content to show/hide
  </div>
</div>
```

### Dropdown Component

```html
<div x-data="{ open: false }">
  <button @click="open = !open">Open Dropdown</button>
  <div x-show="open" @click.outside="open = false">
    <a href="#">Option 1</a>
    <a href="#">Option 2</a>
  </div>
</div>
```

### Search/Filter List

```html
<div x-data="{
  search: '',
  items: ['Apple', 'Banana', 'Cherry'],
  get filteredItems() {
    return this.items.filter(i => 
      i.toLowerCase().includes(this.search.toLowerCase())
    )
  }
}">
  <input x-model="search" placeholder="Search...">
  <template x-for="item in filteredItems" :key="item">
    <div x-text="item"></div>
  </template>
</div>
```

### Form with Validation

```html
<div x-data="{ 
  email: '', 
  get isValid() { 
    return this.email.includes('@') 
  } 
}">
  <input x-model="email" type="email">
  <button :disabled="!isValid">Submit</button>
  <span x-show="!isValid" class="error">Invalid email</span>
</div>
```

## Transitions

Add smooth transitions with `x-transition`:

**Simple transition**:
```html
<div x-show="open" x-transition>
  Content with fade and scale transition
</div>
```

**Custom duration**:
```html
<div x-show="open" x-transition.duration.500ms>
```

**Separate in/out durations**:
```html
<div 
  x-show="open"
  x-transition:enter.duration.500ms
  x-transition:leave.duration.1000ms
>
```

**Transition specific properties**:
```html
<div x-show="open" x-transition.opacity>
<div x-show="open" x-transition.scale>
```

## Reusable Components

Define reusable component logic with `Alpine.data()`:

```javascript
Alpine.data('dropdown', () => ({
  open: false,
  toggle() {
    this.open = !this.open
  },
  close() {
    this.open = false
  }
}))
```

Use in HTML:

```html
<div x-data="dropdown">
  <button @click="toggle">Toggle</button>
  <div x-show="open" @click.outside="close">
    Dropdown content
  </div>
</div>
```

## Global State

Share state across components using `Alpine.store()`:

```javascript
Alpine.store('auth', {
  user: null,
  loggedIn: false,
  login(user) {
    this.user = user
    this.loggedIn = true
  }
})
```

Access in templates:

```html
<div x-data>
  <span x-show="$store.auth.loggedIn" x-text="$store.auth.user"></span>
  <button @click="$store.auth.login('John')">Login</button>
</div>
```

## Magic Properties

Alpine provides magic properties accessible anywhere:

- `$el` - Reference to current DOM element
- `$refs` - Access elements marked with `x-ref`
- `$store` - Access global stores
- `$watch` - Watch for data changes
- `$dispatch` - Dispatch custom events
- `$nextTick` - Execute after next DOM update
- `$root` - Access root element of component
- `$data` - Access entire data object
- `$id` - Generate unique IDs

**Example using $refs**:
```html
<div x-data>
  <input x-ref="emailInput" type="email">
  <button @click="$refs.emailInput.focus()">Focus Email</button>
</div>
```

## Best Practices

**Keep data objects simple** - Start with minimal state and add as needed:
```html
<!-- Good -->
<div x-data="{ open: false }">

<!-- Avoid over-engineering -->
<div x-data="{ state: { ui: { modal: { open: false } } } }">
```

**Use getters for computed values**:
```javascript
{
  items: [1, 2, 3],
  get total() {
    return this.items.reduce((sum, i) => sum + i, 0)
  }
}
```

**Prevent FOUC (Flash of Unstyled Content)** with `x-cloak`:
```html
<style>
  [x-cloak] { display: none !important; }
</style>
<div x-data x-cloak>
  <!-- Content hidden until Alpine initializes -->
</div>
```

**Extract complex logic to Alpine.data()**:
```javascript
// Instead of inline in HTML
Alpine.data('complexForm', () => ({
  // Complex initialization and methods
}))
```

**Use event modifiers appropriately**:
```html
<form @submit.prevent="handleSubmit">
<div @click.outside="close">
```

## Common Gotchas

**x-for requires template element**:
```html
<!-- Wrong -->
<div x-for="item in items">

<!-- Correct -->
<template x-for="item in items">
  <div x-text="item"></div>
</template>
```

**x-if also requires template**:
```html
<template x-if="condition">
  <div>Content</div>
</template>
```

**Accessing parent scope** - Use `this` when needed:
```javascript
{
  items: ['a', 'b'],
  get filteredItems() {
    return this.items.filter(...)  // Must use this.items
  }
}
```

**Script defer is important**:
```html
<!-- Ensures Alpine loads after DOM is ready -->
<script defer src="...alpine.min.js"></script>
```

## Quick Reference

| Directive | Purpose | Example |
|-----------|---------|---------|
| `x-data` | Define component state | `<div x-data="{ count: 0 }">` |
| `x-text` | Set text content | `<span x-text="message">` |
| `x-html` | Set HTML content | `<div x-html="content">` |
| `x-show` | Toggle visibility | `<div x-show="isVisible">` |
| `x-if` | Conditional rendering | `<template x-if="show">` |
| `x-for` | Loop over array | `<template x-for="item in items">` |
| `x-on/@` | Listen to events | `<button @click="handler">` |
| `x-bind/:` | Bind attributes | `<img :src="url">` |
| `x-model` | Two-way binding | `<input x-model="value">` |
| `x-transition` | Add transitions | `<div x-show="open" x-transition>` |

## Additional Resources

For comprehensive directive documentation and advanced patterns:
- **`references/directives-reference.md`** - Complete guide to all Alpine directives
- **`references/advanced-patterns.md`** - Advanced component patterns and techniques

Official documentation: https://alpinejs.dev
