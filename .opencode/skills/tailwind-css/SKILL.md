---
name: tailwind-css
description: This skill should be used when the user asks to "use Tailwind CSS", "install Tailwind", "style with Tailwind", "add Tailwind utilities", "create responsive design with Tailwind", or needs guidance on Tailwind CSS utility-first styling and configuration.
---

# Tailwind CSS

Build modern, responsive web interfaces using utility-first CSS with Tailwind CSS.

## Overview

Tailwind CSS is a utility-first CSS framework that generates CSS by scanning HTML files, JavaScript components, and templates for class names. It provides single-purpose utility classes that compose together directly in markup, enabling rapid UI development without writing custom CSS.

## Core Principles

### Utility-First Styling

Apply styles by combining single-purpose utility classes directly in markup:

```html
<div class="mx-auto flex max-w-sm items-center gap-x-4 rounded-xl bg-white p-6 shadow-lg">
  <img class="size-12 shrink-0" src="/logo.svg" alt="Logo" />
  <div>
    <div class="text-xl font-medium text-black">Title</div>
    <p class="text-gray-500">Description text</p>
  </div>
</div>
```

### Mobile-First Responsive Design

Unprefixed utilities apply to all screen sizes. Prefixed utilities apply at specified breakpoint and above:

```html
<!-- Width 16 on mobile, 32 on medium screens, 48 on large screens -->
<img class="w-16 md:w-32 lg:w-48" src="..." />
```

### State Variants

Prefix utilities with state variants to apply styles conditionally:

```html
<!-- Hover, focus, and dark mode variants -->
<button class="bg-sky-500 hover:bg-sky-700 focus:ring-2 dark:bg-sky-900">
  Save
</button>
```

## Installation

### Using Vite (Recommended)

1. **Install dependencies**:
   ```bash
   npm install tailwindcss @tailwindcss/vite
   ```

2. **Configure Vite plugin** in `vite.config.ts`:
   ```typescript
   import { defineConfig } from 'vite'
   import tailwindcss from '@tailwindcss/vite'

   export default defineConfig({
     plugins: [tailwindcss()],
   })
   ```

3. **Import Tailwind** in CSS file:
   ```css
   @import "tailwindcss";
   ```

4. **Start development**:
   ```bash
   npm run dev
   ```

### Using PostCSS

1. **Install dependencies**:
   ```bash
   npm install tailwindcss @tailwindcss/postcss
   ```

2. **Configure PostCSS** in `postcss.config.js`:
   ```javascript
   module.exports = {
     plugins: {
       '@tailwindcss/postcss': {}
     }
   }
   ```

3. **Import Tailwind** in CSS file:
   ```css
   @import "tailwindcss";
   ```

### Using Tailwind CLI

1. **Install globally or as dev dependency**:
   ```bash
   npm install -D tailwindcss
   ```

2. **Create input CSS** with Tailwind imports:
   ```css
   @import "tailwindcss";
   ```

3. **Build CSS**:
   ```bash
   npx tailwindcss -i ./src/input.css -o ./dist/output.css --watch
   ```

## Common Utility Patterns

### Layout

```html
<!-- Flexbox -->
<div class="flex items-center justify-between gap-4">

<!-- Grid -->
<div class="grid grid-cols-3 gap-6">

<!-- Container with max width -->
<div class="mx-auto max-w-7xl px-4">
```

### Typography

```html
<!-- Heading -->
<h1 class="text-4xl font-bold text-gray-900">

<!-- Paragraph -->
<p class="text-base text-gray-600 leading-relaxed">

<!-- Truncate text -->
<p class="truncate">
```

### Spacing

```html
<!-- Padding -->
<div class="p-6">           <!-- All sides -->
<div class="px-4 py-2">     <!-- Horizontal and vertical -->

<!-- Margin -->
<div class="m-4">           <!-- All sides -->
<div class="mt-8 mb-4">     <!-- Top and bottom -->
```

### Colors

```html
<!-- Background -->
<div class="bg-blue-500">

<!-- Text -->
<p class="text-red-600">

<!-- Border -->
<div class="border border-gray-300">
```

### Responsive Design

```html
<!-- Stack on mobile, row on medium+ screens -->
<div class="flex flex-col md:flex-row">

<!-- Different padding at breakpoints -->
<div class="p-4 md:p-6 lg:p-8">

<!-- Hide on mobile, show on large screens -->
<div class="hidden lg:block">
```

## Breakpoints Reference

| Prefix | Min Width | CSS |
|--------|-----------|-----|
| `sm` | 40rem (640px) | `@media (width >= 40rem)` |
| `md` | 48rem (768px) | `@media (width >= 48rem)` |
| `lg` | 64rem (1024px) | `@media (width >= 64rem)` |
| `xl` | 80rem (1280px) | `@media (width >= 80rem)` |
| `2xl` | 96rem (1536px) | `@media (width >= 96rem)` |

## State Variants

Apply utilities based on element state:

```html
<!-- Hover -->
<button class="bg-blue-500 hover:bg-blue-700">

<!-- Focus -->
<input class="border-gray-300 focus:border-blue-500 focus:ring-2">

<!-- Active -->
<button class="active:bg-blue-800">

<!-- Disabled -->
<button class="disabled:opacity-50 disabled:cursor-not-allowed">

<!-- Dark mode -->
<div class="bg-white dark:bg-gray-800">

<!-- Group hover (parent-based) -->
<a class="group">
  <span class="group-hover:underline">Link</span>
</a>
```

## Arbitrary Values

Use square bracket syntax for one-off values:

```html
<!-- Custom color -->
<div class="bg-[#1da1f2]">

<!-- Custom spacing -->
<div class="top-[117px]">

<!-- Complex grid -->
<div class="grid-cols-[200px_1fr_1fr]">

<!-- Using calc -->
<div class="h-[calc(100vh-4rem)]">

<!-- CSS variables -->
<div class="bg-(--brand-color)">
```

## Customization

### Theme Variables

Customize design tokens using CSS variables in `@theme`:

```css
@import "tailwindcss";

@theme {
  --color-brand: #ff6347;
  --font-sans: 'Inter', system-ui, sans-serif;
  --spacing-18: 4.5rem;
  --breakpoint-3xl: 120rem;
}
```

### Adding Custom Utilities

Define custom utilities in `@layer utilities`:

```css
@import "tailwindcss";

@layer utilities {
  .text-balance {
    text-wrap: balance;
  }
  
  .scrollbar-hide {
    scrollbar-width: none;
    &::-webkit-scrollbar {
      display: none;
    }
  }
}
```

## Managing Duplication

### Extract Components

For repeated patterns, create reusable components:

```jsx
// React component
export function Button({ variant, children }) {
  const baseClasses = "px-4 py-2 rounded-lg font-medium";
  const variants = {
    primary: "bg-blue-500 text-white hover:bg-blue-700",
    secondary: "bg-gray-200 text-gray-900 hover:bg-gray-300"
  };
  
  return (
    <button className={`${baseClasses} ${variants[variant]}`}>
      {children}
    </button>
  );
}
```

### Custom CSS Classes

For template-based projects, create reusable CSS classes:

```css
@layer components {
  .btn-primary {
    border-radius: calc(infinity * 1px);
    background-color: var(--color-blue-500);
    padding-inline: var(--spacing-4);
    padding-block: var(--spacing-2);
    font-weight: var(--font-weight-semibold);
    color: white;
    
    &:hover {
      @media (hover: hover) {
        background-color: var(--color-blue-700);
      }
    }
  }
}
```

## Framework Integration

Tailwind integrates with popular frameworks:

- **Next.js** - Add `@tailwindcss/vite` to Next.js config
- **Laravel** - Use Vite with Laravel Mix
- **SvelteKit** - Add to Vite config
- **Vue/Nuxt** - Vite plugin integration
- **Angular** - Configure with build system
- **React** - Vite or Create React App setup

Consult **`references/framework-setup.md`** for detailed framework-specific instructions.

## Best Practices

### DO

- Use utility classes for rapid prototyping and development
- Apply mobile-first responsive design patterns
- Leverage state variants for interactive elements
- Create components for repeated UI patterns
- Use theme variables for consistent design tokens
- Compose utilities to build complex designs
- Use arbitrary values for one-off customizations

### DON'T

- Fight the utility-first approach with excessive custom CSS
- Use `sm:` prefix to target mobile (use unprefixed instead)
- Duplicate long class lists (extract components)
- Ignore dark mode styling (`dark:` variant)
- Mix Tailwind with large amounts of traditional CSS
- Override utilities with `!important` unnecessarily
- Create deeply nested custom component styles

## Common Patterns

### Card Component

```html
<div class="overflow-hidden rounded-lg bg-white shadow-md">
  <img class="h-48 w-full object-cover" src="image.jpg" alt="" />
  <div class="p-6">
    <h3 class="text-xl font-semibold">Card Title</h3>
    <p class="mt-2 text-gray-600">Card description text.</p>
    <button class="mt-4 rounded bg-blue-500 px-4 py-2 text-white hover:bg-blue-700">
      Action
    </button>
  </div>
</div>
```

### Form Input

```html
<div class="space-y-2">
  <label class="block text-sm font-medium text-gray-700" for="email">
    Email
  </label>
  <input
    id="email"
    type="email"
    class="w-full rounded-lg border border-gray-300 px-4 py-2 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500"
    placeholder="you@example.com"
  />
</div>
```

### Navigation Bar

```html
<nav class="border-b border-gray-200 bg-white">
  <div class="mx-auto flex max-w-7xl items-center justify-between px-4 py-4">
    <div class="text-xl font-bold">Brand</div>
    <div class="hidden space-x-6 md:flex">
      <a href="#" class="text-gray-700 hover:text-blue-500">Home</a>
      <a href="#" class="text-gray-700 hover:text-blue-500">About</a>
      <a href="#" class="text-gray-700 hover:text-blue-500">Contact</a>
    </div>
  </div>
</nav>
```

## Troubleshooting

**Styles not applying**:
- Verify Tailwind is imported in CSS
- Check build process is running
- Ensure classes are detected in source files
- Confirm no conflicting CSS overriding utilities

**Responsive variants not working**:
- Add viewport meta tag to HTML `<head>`
- Use mobile-first approach (unprefixed for mobile)
- Check breakpoint prefix spelling

**Dark mode not working**:
- Verify `dark:` variant is configured
- Check system/manual dark mode preference
- Ensure parent has dark mode class if using class strategy

**Build output too large**:
- Tailwind only includes used utilities by default
- Verify source file detection is working
- Check for overly broad file patterns

## Additional Resources

### Reference Files

For detailed information:
- **`references/framework-setup.md`** - Framework-specific installation guides for Next.js, Laravel, Vue, Angular, and more
- **`references/utility-reference.md`** - Comprehensive utility class reference organized by category
- **`references/customization-guide.md`** - Deep dive on theme customization, plugins, and extending Tailwind

### Official Documentation

- **Tailwind CSS Docs** - https://tailwindcss.com/docs
- **Playground** - https://play.tailwindcss.com
- **GitHub** - https://github.com/tailwindlabs/tailwindcss

## Quick Reference

**Installation**:
```bash
npm install tailwindcss @tailwindcss/vite
```

**Vite Config**:
```typescript
import tailwindcss from '@tailwindcss/vite'
export default defineConfig({ plugins: [tailwindcss()] })
```

**Import in CSS**:
```css
@import "tailwindcss";
```

**Common Utilities**:
- Layout: `flex`, `grid`, `block`, `inline-block`
- Spacing: `p-4`, `m-2`, `gap-4`, `space-x-2`
- Sizing: `w-full`, `h-screen`, `max-w-lg`
- Typography: `text-lg`, `font-bold`, `leading-relaxed`
- Colors: `bg-blue-500`, `text-white`, `border-gray-300`
- Responsive: `md:flex-row`, `lg:grid-cols-3`
- State: `hover:bg-blue-700`, `focus:ring-2`, `dark:bg-gray-800`
