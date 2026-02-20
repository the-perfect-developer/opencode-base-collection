# Alpine.js Directives Reference

Comprehensive reference for all Alpine.js directives with detailed examples and use cases.

## Table of Contents

- [Core Directives](#core-directives)
- [Templating Directives](#templating-directives)
- [Utility Directives](#utility-directives)
- [Lifecycle Directives](#lifecycle-directives)

## Core Directives

### x-data

Declares a new Alpine component scope with reactive data.

**Syntax**:
```html
<div x-data="{ property: value, ... }">
```

**Inline object**:
```html
<div x-data="{ 
  count: 0, 
  message: 'Hello',
  increment() { this.count++ }
}">
```

**Reference to Alpine.data() component**:
```html
<div x-data="componentName">
```

**Data-less component** (access Alpine features without data):
```html
<div x-data @click="alert('Hello')">
```

**Scope and nesting**:
- Child components inherit parent data
- Child properties override parent properties with same name
- Access parent scope with normal JavaScript scoping rules

**Examples**:

Simple counter:
```html
<div x-data="{ count: 0 }">
  <button @click="count++">+</button>
  <span x-text="count"></span>
</div>
```

Nested scopes:
```html
<div x-data="{ color: 'red' }">
  <span x-text="color"></span> <!-- red -->
  
  <div x-data="{ color: 'blue' }">
    <span x-text="color"></span> <!-- blue -->
  </div>
</div>
```

### x-bind

Bind JavaScript values to HTML attributes.

**Syntax**:
```html
<element x-bind:attribute="expression">
<element :attribute="expression">  <!-- shorthand -->
```

**Basic binding**:
```html
<img :src="imageSrc" :alt="imageAlt">
<a :href="url">Link</a>
<button :disabled="isLoading">Submit</button>
```

**Class binding** (object syntax):
```html
<div :class="{ 'active': isActive, 'text-bold': isBold }">
```

**Class binding** (array syntax):
```html
<div :class="[baseClass, isActive ? 'active' : '']">
```

**Style binding** (object):
```html
<div :style="{ 
  color: textColor, 
  fontSize: size + 'px',
  backgroundColor: bgColor 
}">
```

**Bind entire object of attributes**:
```html
<button x-bind="buttonAttributes">
```

Where `buttonAttributes` is:
```javascript
{
  type: 'submit',
  class: 'btn-primary',
  disabled: isLoading
}
```

**Boolean attributes**:
```html
<input :required="isRequired">
<details :open="isOpen">
```

### x-on

Listen for browser events on an element.

**Syntax**:
```html
<element x-on:event="expression">
<element @event="expression">  <!-- shorthand -->
```

**Basic events**:
```html
<button @click="count++">Click</button>
<form @submit="handleSubmit">
<input @input="handleInput">
<div @mouseenter="highlight">
```

**Access event object**:
```html
<button @click="console.log($event)">
<input @keyup="handleKey($event)">
```

**Pass parameters**:
```html
<button @click="deleteItem(item.id)">Delete</button>
```

**Modifiers**:

`.prevent` - Call `event.preventDefault()`:
```html
<form @submit.prevent="handleSubmit">
```

`.stop` - Call `event.stopPropagation()`:
```html
<div @click.stop="handleClick">
```

`.outside` - Only trigger when clicking outside element:
```html
<div @click.outside="close">
```

`.window` - Listen on window instead of element:
```html
<div @resize.window="handleResize">
<div @keyup.escape.window="closeModal">
```

`.document` - Listen on document:
```html
<div @scroll.document="handleScroll">
```

`.once` - Only trigger once:
```html
<button @click.once="initialize">
```

`.debounce` - Debounce handler:
```html
<input @input.debounce="search">
<input @input.debounce.500ms="search">
```

`.throttle` - Throttle handler:
```html
<div @scroll.throttle="handleScroll">
<div @scroll.throttle.750ms="handleScroll">
```

`.self` - Only trigger if event.target is element itself:
```html
<div @click.self="handleBackdropClick">
```

`.camel` - Convert event name to camelCase:
```html
<div @custom-event.camel="handler">  <!-- listens for customEvent -->
```

`.dot` - Event names with dots:
```html
<div @foo.bar="handler">  <!-- listens for foo.bar -->
```

`.passive` - Use passive event listener:
```html
<div @touchstart.passive="handler">
```

**Key modifiers**:
```html
<input @keyup.enter="submit">
<input @keyup.escape="cancel">
<input @keyup.tab="nextField">
<input @keyup.delete="remove">
<input @keyup.space="toggle">
<input @keyup.up="previous">
<input @keyup.down="next">
<input @keyup.left="back">
<input @keyup.right="forward">
<input @keyup.page-down="pageDown">
```

**Combination modifiers**:
```html
<input @keyup.shift.enter="specialSubmit">
<input @keyup.ctrl.slash="showHelp">
<form @submit.prevent.stop="handleSubmit">
```

**Custom key codes**:
```html
<input @keyup.65="handleA">  <!-- Key code for 'a' -->
```

### x-model

Create two-way data binding on input elements.

**Syntax**:
```html
<input x-model="propertyName">
```

**Input types**:

Text input:
```html
<input type="text" x-model="username">
<input type="email" x-model="email">
<input type="password" x-model="password">
```

Textarea:
```html
<textarea x-model="message"></textarea>
```

Checkbox (boolean):
```html
<input type="checkbox" x-model="agreed">
```

Checkbox (array):
```html
<input type="checkbox" value="apple" x-model="fruits">
<input type="checkbox" value="orange" x-model="fruits">
<!-- fruits = ['apple', 'orange'] -->
```

Radio buttons:
```html
<input type="radio" value="red" x-model="color">
<input type="radio" value="blue" x-model="color">
```

Select:
```html
<select x-model="country">
  <option value="us">USA</option>
  <option value="ca">Canada</option>
</select>
```

Select multiple:
```html
<select x-model="countries" multiple>
  <option value="us">USA</option>
  <option value="ca">Canada</option>
</select>
```

**Modifiers**:

`.lazy` - Update on change instead of input:
```html
<input x-model.lazy="username">
```

`.number` - Convert value to number:
```html
<input x-model.number="age" type="number">
```

`.debounce` - Debounce updates:
```html
<input x-model.debounce="search">
<input x-model.debounce.500ms="search">
```

`.throttle` - Throttle updates:
```html
<input x-model.throttle="search">
<input x-model.throttle.1s="search">
```

`.fill` - Fill input with initial value:
```html
<input x-model.fill="username">
```

## Templating Directives

### x-text

Set the text content of an element.

**Syntax**:
```html
<element x-text="expression">
```

**Examples**:
```html
<span x-text="message"></span>
<h1 x-text="title"></h1>
<p x-text="'Count: ' + count"></p>
<div x-text="items.length + ' items'"></div>
```

**Note**: Replaces all child content.

### x-html

Set the innerHTML of an element.

**Syntax**:
```html
<element x-html="expression">
```

**Examples**:
```html
<div x-html="htmlContent"></div>
<div x-html="'<strong>Bold</strong> text'"></div>
```

**Security warning**: Only use with trusted content. Never use with user-provided content to avoid XSS vulnerabilities.

### x-show

Toggle element visibility using CSS display property.

**Syntax**:
```html
<element x-show="expression">
```

**Examples**:
```html
<div x-show="isVisible">Content</div>
<div x-show="count > 5">Count is greater than 5</div>
<span x-show="!isLoading">Ready</span>
```

**Behavior**:
- Sets `display: none` when false
- Restores original display value when true
- Element remains in DOM
- Best for frequently toggled content

**With transitions**:
```html
<div x-show="open" x-transition>
  Animated content
</div>
```

### x-if

Conditionally add/remove elements from the DOM.

**Syntax**:
```html
<template x-if="expression">
  <element>...</element>
</template>
```

**Requirements**:
- Must be on a `<template>` tag
- Template must have single root element

**Examples**:
```html
<template x-if="isLoggedIn">
  <div>Welcome back!</div>
</template>

<template x-if="user.role === 'admin'">
  <button>Admin Panel</button>
</template>
```

**When to use**:
- Element won't be toggled frequently
- Content is expensive to render
- You need element completely removed from DOM

### x-for

Loop over arrays or objects.

**Syntax**:
```html
<template x-for="item in items" :key="item.id">
  <element>...</element>
</template>
```

**Requirements**:
- Must be on a `<template>` tag
- Should include `:key` for proper tracking
- Template must have single root element

**Array iteration**:
```html
<template x-for="item in items" :key="item">
  <li x-text="item"></li>
</template>
```

**With index**:
```html
<template x-for="(item, index) in items" :key="index">
  <li>
    <span x-text="index + 1"></span>: <span x-text="item"></span>
  </li>
</template>
```

**Object iteration**:
```html
<template x-for="(value, key) in object" :key="key">
  <div>
    <strong x-text="key"></strong>: <span x-text="value"></span>
  </div>
</template>
```

**Range iteration**:
```html
<template x-for="i in 10" :key="i">
  <div x-text="i"></div>
</template>
```

**Nested loops**:
```html
<template x-for="group in groups" :key="group.id">
  <div>
    <h3 x-text="group.name"></h3>
    <template x-for="item in group.items" :key="item.id">
      <p x-text="item.name"></p>
    </template>
  </div>
</template>
```

## Utility Directives

### x-transition

Add enter/leave transitions to elements.

**Simple transition**:
```html
<div x-show="open" x-transition>
```

**Duration modifiers**:
```html
<div x-transition.duration.500ms>
<div x-transition.duration.2s>
```

**Opacity only**:
```html
<div x-transition.opacity>
```

**Scale only**:
```html
<div x-transition.scale>
```

**Separate enter/leave**:
```html
<div
  x-transition:enter.duration.500ms
  x-transition:leave.duration.1000ms
>
```

**Custom CSS classes** (Tailwind example):
```html
<div
  x-show="open"
  x-transition:enter="transition ease-out duration-300"
  x-transition:enter-start="opacity-0 transform scale-90"
  x-transition:enter-end="opacity-100 transform scale-100"
  x-transition:leave="transition ease-in duration-300"
  x-transition:leave-start="opacity-100 transform scale-100"
  x-transition:leave-end="opacity-0 transform scale-90"
>
```

**Origin modifier**:
```html
<div x-transition.scale.origin.top>
```

### x-ref

Reference elements directly.

**Syntax**:
```html
<element x-ref="name">
```

**Access via $refs**:
```html
<div x-data>
  <input x-ref="email" type="email">
  <button @click="$refs.email.focus()">Focus Email</button>
</div>
```

**Multiple refs**:
```html
<div x-data>
  <input x-ref="first">
  <input x-ref="last">
  <button @click="$refs.first.value = $refs.last.value">
    Copy
  </button>
</div>
```

### x-cloak

Hide elements until Alpine initializes.

**Setup**:
```html
<style>
  [x-cloak] { display: none !important; }
</style>
```

**Usage**:
```html
<div x-data x-cloak>
  <!-- Hidden until Alpine initializes -->
</div>
```

**Prevents FOUC** (Flash of Unstyled Content) by hiding elements with unprocessed directives.

### x-ignore

Prevent Alpine from processing an element and its children.

**Syntax**:
```html
<div x-ignore>
  <!-- Alpine won't process anything here -->
  <div x-data>This won't work</div>
</div>
```

**Use cases**:
- Integrate with other JavaScript libraries
- Display code examples with Alpine syntax
- Performance optimization for static content

### x-teleport

Move elements to different part of the DOM.

**Syntax**:
```html
<template x-teleport="selector">
  <element>...</element>
</template>
```

**Examples**:

Teleport to body:
```html
<template x-teleport="body">
  <div>This will be appended to body</div>
</template>
```

Teleport to specific element:
```html
<template x-teleport="#modal-container">
  <div>Modal content</div>
</template>
```

**Common use case - Modals**:
```html
<div x-data="{ open: false }">
  <button @click="open = true">Open Modal</button>
  
  <template x-teleport="body">
    <div x-show="open" class="modal-overlay">
      <div class="modal">
        <button @click="open = false">Close</button>
        Modal content
      </div>
    </div>
  </template>
</div>
```

## Lifecycle Directives

### x-init

Run code when Alpine initializes an element.

**Syntax**:
```html
<div x-init="expression">
```

**Examples**:

Initialize data:
```html
<div x-data="{ posts: [] }" x-init="posts = await fetchPosts()">
```

Run side effect:
```html
<div x-data x-init="console.log('Component initialized')">
```

Call method:
```html
<div x-data="{ init() { /* initialization code */ } }" x-init="init()">
```

Focus input on mount:
```html
<input x-init="$el.focus()">
```

**Note**: `x-init` runs after Alpine processes the element but before it processes children.

### x-effect

Re-run code when dependencies change.

**Syntax**:
```html
<div x-effect="expression">
```

**Examples**:

Log when data changes:
```html
<div x-data="{ count: 0 }" x-effect="console.log('Count is:', count)">
  <button @click="count++">Increment</button>
</div>
```

Sync with localStorage:
```html
<div 
  x-data="{ value: '' }"
  x-effect="localStorage.setItem('myValue', value)"
>
```

**Automatic dependency tracking**: Alpine automatically tracks which properties are used in the effect and re-runs when they change.

### x-modelable

Make a component's internal property bindable with x-model from parent.

**Child component**:
```html
<div x-data="{ 
  value: '',
  setValue(newValue) {
    this.value = newValue
  }
}" x-modelable="value" x-model="value">
  <input :value="value" @input="setValue($event.target.value)">
</div>
```

**Parent usage**:
```html
<div x-data="{ parentValue: '' }">
  <child-component x-model="parentValue"></child-component>
</div>
```

### x-id

Generate unique IDs for accessibility.

**Syntax**:
```html
<div x-id="['id1', 'id2']">
```

**Example - Accessible form**:
```html
<div x-data x-id="['email-input', 'email-error']">
  <label :for="$id('email-input')">Email</label>
  <input type="email" :id="$id('email-input')" :aria-describedby="$id('email-error')">
  <span :id="$id('email-error')">Error message</span>
</div>
```

**Ensures unique IDs** even when component is used multiple times on the page.

## Quick Reference Table

| Directive | Purpose | Requires Template |
|-----------|---------|-------------------|
| `x-data` | Define component state | No |
| `x-bind`/`:` | Bind attribute | No |
| `x-on`/`@` | Listen to event | No |
| `x-text` | Set text content | No |
| `x-html` | Set HTML content | No |
| `x-model` | Two-way binding | No |
| `x-show` | Toggle visibility | No |
| `x-if` | Conditional render | Yes |
| `x-for` | Loop | Yes |
| `x-transition` | Add transitions | No |
| `x-ref` | Element reference | No |
| `x-cloak` | Hide until ready | No |
| `x-ignore` | Skip processing | No |
| `x-teleport` | Move in DOM | Yes |
| `x-init` | Run on initialize | No |
| `x-effect` | Run on change | No |
| `x-modelable` | Make modelable | No |
| `x-id` | Generate IDs | No |
