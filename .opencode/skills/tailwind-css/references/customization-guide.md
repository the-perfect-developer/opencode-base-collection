# Customization Guide

Deep dive on customizing Tailwind CSS through theme configuration, plugins, and extensions.

## Table of Contents

- [Theme Customization](#theme-customization)
- [CSS Variables](#css-variables)
- [Custom Utilities](#custom-utilities)
- [Custom Components](#custom-components)
- [Plugins](#plugins)
- [Dark Mode Configuration](#dark-mode-configuration)
- [Content Detection](#content-detection)

## Theme Customization

Tailwind CSS uses CSS custom properties (variables) for theme configuration. Customize the design system by defining theme variables in the `@theme` directive.

### Basic Theme Structure

```css
@import "tailwindcss";

@theme {
  /* Colors */
  --color-brand: #3b82f6;
  --color-accent: #10b981;
  
  /* Spacing */
  --spacing-128: 32rem;
  
  /* Typography */
  --font-sans: 'Inter', system-ui, sans-serif;
  --font-mono: 'Fira Code', monospace;
  
  /* Breakpoints */
  --breakpoint-3xl: 120rem;
  
  /* Shadows */
  --shadow-custom: 0 10px 40px rgba(0, 0, 0, 0.1);
}
```

### Customizing Colors

Add custom colors or override defaults:

```css
@theme {
  /* Custom brand colors */
  --color-primary-50: #eff6ff;
  --color-primary-100: #dbeafe;
  --color-primary-500: #3b82f6;
  --color-primary-900: #1e3a8a;
  
  /* Single color value */
  --color-brand: #ff6347;
  --color-success: oklch(0.7 0.2 145);
  
  /* Override default */
  --color-blue-500: #0066cc;
}
```

Use in markup:

```html
<div class="bg-primary-500 text-primary-50">
<button class="bg-brand hover:opacity-90">
```

### Color Format

Tailwind v4 uses OKLCH color format for better perceptual uniformity. Convert colors:

```css
@theme {
  /* Traditional hex */
  --color-brand: #3b82f6;
  
  /* OKLCH (recommended) */
  --color-brand: oklch(0.6 0.2 250);
  
  /* RGB */
  --color-brand: rgb(59 130 246);
}
```

Benefits of OKLCH:
- Better perceptual uniformity
- Easier to generate color scales
- Better support for wide color gamuts

### Customizing Spacing

Extend or modify the spacing scale:

```css
@theme {
  /* Add custom spacing */
  --spacing-18: 4.5rem;     /* 72px */
  --spacing-128: 32rem;     /* 512px */
  
  /* Modify existing */
  --spacing-4: 1.25rem;     /* Change from 1rem */
}
```

Use in markup:

```html
<div class="p-18 m-128">
```

### Customizing Typography

Configure font families, sizes, and weights:

```css
@theme {
  /* Font families */
  --font-sans: 'Inter', system-ui, sans-serif;
  --font-serif: 'Merriweather', Georgia, serif;
  --font-mono: 'Fira Code', 'Courier New', monospace;
  --font-display: 'Playfair Display', serif;
  
  /* Font sizes */
  --font-size-xxs: 0.625rem;
  --font-size-xxl: 2rem;
  
  /* Font weights */
  --font-weight-hairline: 100;
  --font-weight-heavy: 900;
  
  /* Line heights */
  --line-height-tighter: 1.1;
  --line-height-looser: 2.5;
  
  /* Letter spacing */
  --letter-spacing-tightest: -0.05em;
  --letter-spacing-widest: 0.1em;
}
```

Use in markup:

```html
<h1 class="font-display text-xxl font-heavy">
<p class="font-sans leading-looser tracking-widest">
```

### Customizing Breakpoints

Add or modify responsive breakpoints:

```css
@theme {
  /* Add custom breakpoints */
  --breakpoint-xs: 30rem;      /* 480px */
  --breakpoint-3xl: 120rem;    /* 1920px */
  
  /* Modify existing */
  --breakpoint-lg: 65rem;      /* Change from 64rem */
}
```

Use in markup:

```html
<div class="grid-cols-1 xs:grid-cols-2 3xl:grid-cols-6">
```

### Customizing Shadows

Create custom shadow definitions:

```css
@theme {
  --shadow-soft: 0 2px 15px rgba(0, 0, 0, 0.08);
  --shadow-brutal: 8px 8px 0 rgba(0, 0, 0, 1);
  --shadow-glow: 0 0 20px rgba(59, 130, 246, 0.5);
  --shadow-layered: 
    0 1px 3px rgba(0, 0, 0, 0.12),
    0 1px 2px rgba(0, 0, 0, 0.24);
}
```

Use in markup:

```html
<div class="shadow-soft">
<div class="shadow-brutal">
<div class="shadow-glow">
```

### Customizing Border Radius

Add custom border radius values:

```css
@theme {
  --radius-button: 0.5rem;
  --radius-card: 1rem;
  --radius-modal: 1.5rem;
  --radius-pill: 9999px;
}
```

Use in markup:

```html
<button class="rounded-button">
<div class="rounded-card">
```

### Removing Default Values

Reset theme values to `initial` to remove them:

```css
@theme {
  /* Remove specific breakpoint */
  --breakpoint-2xl: initial;
  
  /* Remove all breakpoints and redefine */
  --breakpoint-*: initial;
  --breakpoint-mobile: 30rem;
  --breakpoint-tablet: 48rem;
  --breakpoint-desktop: 80rem;
  
  /* Remove all spacing and redefine */
  --spacing-*: initial;
  --spacing-small: 0.5rem;
  --spacing-medium: 1rem;
  --spacing-large: 2rem;
}
```

## CSS Variables

Tailwind v4 generates CSS variables for all theme values, making them accessible in custom CSS.

### Accessing Theme Variables

Use theme variables in custom CSS:

```css
.custom-element {
  color: var(--color-blue-500);
  padding: var(--spacing-4);
  font-family: var(--font-sans);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-md);
}
```

### Dynamic CSS Variables

Set CSS variables dynamically and reference with utilities:

```html
<!-- Set variable inline -->
<div style="--custom-color: #ff6347">
  <p class="text-(--custom-color)">Red text</p>
  <div class="bg-(--custom-color)">Red background</div>
</div>

<!-- Set variable in component -->
<button 
  style="--btn-color: #3b82f6; --btn-hover: #2563eb"
  class="bg-(--btn-color) hover:bg-(--btn-hover)"
>
  Dynamic button
</button>
```

Use in JavaScript frameworks:

```jsx
// React example
function Card({ accentColor }) {
  return (
    <div style={{ '--accent': accentColor }}>
      <div className="border-l-4 border-(--accent)">
        <h3 className="text-(--accent)">Title</h3>
      </div>
    </div>
  );
}
```

## Custom Utilities

Create custom utility classes using `@layer utilities`.

### Basic Custom Utilities

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
  
  .glass {
    background: rgba(255, 255, 255, 0.1);
    backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.2);
  }
}
```

Use in markup:

```html
<p class="text-balance">
<div class="overflow-auto scrollbar-hide">
<div class="glass">
```

### Utilities with Variants

Create utilities that work with hover, focus, and responsive variants:

```css
@layer utilities {
  .outline-dashed {
    outline-style: dashed;
  }
  
  .animate-fade-in {
    animation: fadeIn 0.5s ease-in;
  }
  
  @keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
  }
}
```

Automatically works with variants:

```html
<div class="hover:outline-dashed">
<div class="md:animate-fade-in">
```

### Utilities with CSS Variables

Create utilities that accept CSS variables:

```css
@layer utilities {
  .text-shadow-custom {
    text-shadow: var(--text-shadow-x, 2px) 
                 var(--text-shadow-y, 2px) 
                 var(--text-shadow-blur, 4px) 
                 var(--text-shadow-color, rgba(0, 0, 0, 0.5));
  }
}
```

Use with inline variables:

```html
<h1 
  class="text-shadow-custom"
  style="--text-shadow-color: rgba(255, 0, 0, 0.5)"
>
  Custom shadow
</h1>
```

## Custom Components

Extract repeated patterns into reusable component classes using `@layer components`.

### Component Classes

```css
@import "tailwindcss";

@layer components {
  .btn {
    padding: var(--spacing-2) var(--spacing-4);
    border-radius: calc(infinity * 1px);
    font-weight: var(--font-weight-semibold);
    transition: all 0.2s;
    
    &:focus {
      outline: 2px solid var(--color-blue-500);
      outline-offset: 2px;
    }
  }
  
  .btn-primary {
    background-color: var(--color-blue-500);
    color: white;
    
    &:hover {
      @media (hover: hover) {
        background-color: var(--color-blue-700);
      }
    }
    
    &:active {
      background-color: var(--color-blue-800);
    }
  }
  
  .btn-secondary {
    background-color: var(--color-gray-200);
    color: var(--color-gray-900);
    
    &:hover {
      @media (hover: hover) {
        background-color: var(--color-gray-300);
      }
    }
  }
  
  .card {
    background-color: white;
    border-radius: var(--radius-lg);
    padding: var(--spacing-6);
    box-shadow: var(--shadow-md);
    
    @media (prefers-color-scheme: dark) {
      background-color: var(--color-gray-800);
    }
  }
  
  .input {
    width: 100%;
    padding: var(--spacing-2) var(--spacing-3);
    border: 1px solid var(--color-gray-300);
    border-radius: var(--radius-md);
    
    &:focus {
      outline: none;
      border-color: var(--color-blue-500);
      box-shadow: 0 0 0 3px var(--color-blue-100);
    }
    
    &:disabled {
      background-color: var(--color-gray-100);
      cursor: not-allowed;
    }
  }
}
```

Use in markup:

```html
<button class="btn btn-primary">Save</button>
<button class="btn btn-secondary">Cancel</button>
<div class="card">...</div>
<input class="input" type="text">
```

### Combining Components with Utilities

Component classes work alongside utilities:

```html
<button class="btn btn-primary text-lg shadow-lg">
  Large button with extra shadow
</button>

<div class="card mt-4 max-w-md">
  Card with margin and max width
</div>
```

## Plugins

Extend Tailwind with JavaScript plugins for complex customizations.

### Plugin Structure

Create a plugin file (`tailwind.plugin.js`):

```javascript
export default function({ addUtilities, addComponents, theme }) {
  // Add custom utilities
  addUtilities({
    '.no-scrollbar': {
      'scrollbar-width': 'none',
      '&::-webkit-scrollbar': {
        display: 'none',
      },
    },
  })
  
  // Add custom components
  addComponents({
    '.container': {
      maxWidth: theme('--breakpoint-lg'),
      marginLeft: 'auto',
      marginRight: 'auto',
      paddingLeft: theme('--spacing-4'),
      paddingRight: theme('--spacing-4'),
    },
  })
}
```

Use in CSS:

```css
@import "tailwindcss";
@plugin "./tailwind.plugin.js";
```

### Advanced Plugin Example

Plugin with multiple features:

```javascript
export default function({ addUtilities, addVariant, matchUtilities, theme }) {
  // Custom variant
  addVariant('hocus', ['&:hover', '&:focus'])
  
  // Dynamic utilities
  matchUtilities(
    {
      'text-shadow': (value) => ({
        textShadow: value,
      }),
    },
    {
      values: {
        sm: '1px 1px 2px rgba(0, 0, 0, 0.5)',
        md: '2px 2px 4px rgba(0, 0, 0, 0.5)',
        lg: '4px 4px 8px rgba(0, 0, 0, 0.5)',
      },
    }
  )
  
  // Responsive utilities
  addUtilities({
    '.content-auto': {
      contentVisibility: 'auto',
    },
    '.content-hidden': {
      contentVisibility: 'hidden',
    },
  })
}
```

Use in markup:

```html
<button class="hocus:bg-blue-500">
<h1 class="text-shadow-lg">
<div class="content-auto">
```

## Dark Mode Configuration

Configure dark mode behavior and customize dark mode colors.

### Dark Mode Strategy

Tailwind supports automatic (system preference) or manual (class-based) dark mode.

Default (automatic):

```css
/* Automatically uses system preference */
<div class="bg-white dark:bg-gray-900">
```

Manual (class-based):

```css
@import "tailwindcss";

@variant dark (&:where(.dark, .dark *));
```

Then add `.dark` class to root:

```html
<html class="dark">
  <!-- Dark mode enabled -->
</html>
```

### Dark Mode Colors

Define dark mode specific colors:

```css
@theme {
  --color-bg-light: #ffffff;
  --color-bg-dark: #1a1a1a;
  --color-text-light: #000000;
  --color-text-dark: #ffffff;
}
```

Use with dark mode utilities:

```html
<div class="bg-bg-light dark:bg-bg-dark">
  <p class="text-text-light dark:text-text-dark">
    Automatic dark mode text
  </p>
</div>
```

### Custom Dark Mode Utilities

Create dark mode aware component classes:

```css
@layer components {
  .panel {
    background-color: white;
    color: black;
    
    @media (prefers-color-scheme: dark) {
      background-color: var(--color-gray-900);
      color: white;
    }
  }
}
```

## Content Detection

Configure which files Tailwind scans for class names.

### Default Detection

Tailwind automatically detects classes in common file types:
- HTML (`.html`, `.htm`)
- JavaScript (`.js`, `.jsx`, `.ts`, `.tsx`)
- Vue (`.vue`)
- Svelte (`.svelte`)
- PHP (`.php`)
- Twig (`.twig`)

### Custom Content Paths

Specify additional files or patterns in CSS:

```css
@import "tailwindcss";

@source "../components/**/*.jsx";
@source "../pages/**/*.tsx";
@source "./emails/*.html";
```

### Safelist Classes

Prevent specific classes from being purged:

```css
@import "tailwindcss";

/* Always include these classes */
@utility bg-red-500;
@utility text-blue-700;
@utility hover:bg-green-500;
```

### Dynamic Class Names

For dynamically generated classes, use safelisting or template literals:

```jsx
// Bad - won't be detected
const buttonColor = 'blue'
<button className={`bg-${buttonColor}-500`}>

// Good - will be detected
<button className={color === 'blue' ? 'bg-blue-500' : 'bg-red-500'}>

// Good - safelist in CSS
@utility bg-blue-500;
@utility bg-red-500;
@utility bg-green-500;
```

## Best Practices

### DO

- Use theme variables for consistency
- Define colors in OKLCH format for better perceptual uniformity
- Create component classes for complex, repeated patterns
- Use `@layer` directives to organize custom CSS
- Leverage CSS variables for dynamic theming
- Test dark mode thoroughly
- Document custom utilities and components
- Use plugins for reusable, shareable functionality

### DON'T

- Override too many default theme values
- Create overly specific component classes
- Mix Tailwind utilities with extensive custom CSS
- Generate dynamic class names with string concatenation
- Forget to test responsive behavior
- Ignore accessibility in custom components
- Create utilities that conflict with Tailwind's naming
- Over-complicate theme structure

## Examples

### Complete Theme Example

```css
@import "tailwindcss";

@theme {
  /* Brand colors */
  --color-primary: oklch(0.6 0.2 250);
  --color-secondary: oklch(0.7 0.15 145);
  
  /* Semantic colors */
  --color-success: oklch(0.7 0.2 145);
  --color-warning: oklch(0.75 0.2 85);
  --color-error: oklch(0.6 0.25 25);
  
  /* Typography */
  --font-sans: 'Inter', system-ui, sans-serif;
  --font-heading: 'Playfair Display', serif;
  
  /* Spacing scale */
  --spacing-18: 4.5rem;
  
  /* Custom breakpoints */
  --breakpoint-xs: 30rem;
  --breakpoint-3xl: 120rem;
  
  /* Shadows */
  --shadow-soft: 0 2px 15px rgba(0, 0, 0, 0.08);
  --shadow-elevated: 0 10px 40px rgba(0, 0, 0, 0.15);
}

@layer components {
  .btn {
    padding: var(--spacing-2) var(--spacing-4);
    border-radius: calc(infinity * 1px);
    font-weight: var(--font-weight-semibold);
    transition: all 0.2s;
  }
  
  .btn-primary {
    background-color: var(--color-primary);
    color: white;
    
    &:hover {
      opacity: 0.9;
    }
  }
}

@layer utilities {
  .text-balance {
    text-wrap: balance;
  }
}
```

### Advanced Customization Example

```css
@import "tailwindcss";

@theme {
  /* Design tokens */
  --radius-sm: 0.25rem;
  --radius-md: 0.5rem;
  --radius-lg: 1rem;
  --radius-full: 9999px;
  
  /* Animation timings */
  --duration-fast: 150ms;
  --duration-normal: 300ms;
  --duration-slow: 500ms;
  
  /* Z-index scale */
  --z-dropdown: 1000;
  --z-modal: 2000;
  --z-toast: 3000;
}

@layer utilities {
  /* Custom animations */
  .animate-slide-in {
    animation: slideIn var(--duration-normal) ease-out;
  }
  
  @keyframes slideIn {
    from {
      transform: translateY(-100%);
      opacity: 0;
    }
    to {
      transform: translateY(0);
      opacity: 1;
    }
  }
  
  /* Z-index utilities */
  .z-dropdown {
    z-index: var(--z-dropdown);
  }
  
  .z-modal {
    z-index: var(--z-modal);
  }
  
  .z-toast {
    z-index: var(--z-toast);
  }
}

@layer components {
  .modal {
    position: fixed;
    inset: 0;
    z-index: var(--z-modal);
    display: flex;
    align-items: center;
    justify-content: center;
    background-color: rgba(0, 0, 0, 0.5);
  }
  
  .modal-content {
    background-color: white;
    border-radius: var(--radius-lg);
    padding: var(--spacing-6);
    max-width: 32rem;
    box-shadow: var(--shadow-elevated);
    animation: slideIn var(--duration-normal) ease-out;
    
    @media (prefers-color-scheme: dark) {
      background-color: var(--color-gray-800);
    }
  }
}
```
