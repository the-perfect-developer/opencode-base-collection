---
name: javascript
description: "This skill should be used when the user asks to \"write JavaScript code\", \"follow JavaScript style guide\", \"format JS files\", \"create Node.js scripts\", or needs guidance on JavaScript/Node.js coding standards and best practices."
---

# JavaScript/Node.js Style Guide

Apply Google JavaScript Style Guide conventions to JavaScript and Node.js code. This skill provides essential coding standards, formatting rules, and best practices for writing clean, maintainable JavaScript.

**Note**: Google recommends migrating to TypeScript. This guide is for JavaScript projects that have not yet migrated.

## Core Principles

### File Basics

**File naming**:
- Use lowercase only
- Use underscores (`_`) or dashes (`-`) but no other punctuation
- Extension must be `.js`
- Examples: `my_module.js`, `user-service.js`

**File encoding**:
- UTF-8 only
- Use special escape sequences for special characters (`\'`, `\"`, `\\`, `\b`, `\f`, `\n`, `\r`, `\t`, `\v`)
- For non-ASCII: use actual Unicode character (e.g., `∞`) or hex escape (e.g., `\u221e`) based on readability

**Indentation**:
- Use 2 spaces (never tabs)
- No trailing whitespace

## Module System

### ES Modules (Preferred)

Use `import` and `export` statements:

```javascript
// Imports
import './sideeffects.js';
import * as goog from '../closure/goog/goog.js';
import {name, value} from './sibling.js';

// Named exports only (no default exports)
export class Foo { ... }
export function bar() { ... }

// Or export together
class Foo { ... }
function bar() { ... }
export {Foo, bar};
```

**Import rules**:
- Include `.js` extension in paths (required)
- Use `lowerCamelCase` for module import names: `import * as fileOne from '../file-one.js';`
- Keep same name for named imports, avoid aliasing unless necessary
- Do not use default exports
- Import statements are exception to 80-column limit (do not wrap)

**Avoid circular dependencies** - Do not create import cycles between modules.

## Variable Declarations

### Use const and let

```javascript
// Use const by default
const MAX_COUNT = 100;
const users = [];

// Use let only when reassignment needed
let currentIndex = 0;

// NEVER use var
```

**One variable per declaration**:
```javascript
// Good
const a = 1;
const b = 2;

// Bad
const a = 1, b = 2;
```

**Declare close to first use**:
```javascript
// Good - declared when needed
function process(items) {
  // ... some code ...
  const result = items.map(x => x * 2);
  return result;
}
```

## Formatting

### Braces

**K&R style** (Egyptian brackets):
```javascript
class InnerClass {
  constructor() {}

  method(foo) {
    if (condition(foo)) {
      try {
        something();
      } catch (err) {
        recover();
      }
    }
  }
}
```

**Rules**:
- No line break before opening brace
- Line break after opening brace
- Line break before closing brace
- Line break after closing brace (except before `else`, `catch`, `while`, comma, semicolon)

**Always use braces** for control structures (even single statements):
```javascript
// Good
if (condition) {
  doSomething();
}

// Exception: single-line if without else
if (shortCondition()) foo();

// Bad
if (condition)
  doSomething();
```

### Column Limit

**80 characters** with exceptions:
- `import` and `export from` statements
- Long URLs, shell commands, file paths in comments
- Lines where wrapping is impossible

### Line Wrapping

**Break at higher syntactic levels**:
```javascript
// Good
currentEstimate =
    calc(currentEstimate + x * currentEstimate) /
        2.0;

// Bad
currentEstimate = calc(currentEstimate + x *
    currentEstimate) / 2.0;
```

**Continuation lines**: indent at least +4 spaces from original line.

### Whitespace

**Horizontal spacing**:
- Space after reserved words: `if (`, `for (`, `catch (`
- No space for `function` and `super`: `function(`, `super(`
- Space before opening brace: `if (x) {`, `class Foo {`
- Space around binary/ternary operators: `a + b`, `x ? y : z`
- Space after comma/semicolon: `foo(a, b);`
- Space after colon in objects: `{a: 1, b: 2}`
- Space around `//`: `// comment`

**Vertical spacing**:
- Blank line between methods
- Blank lines within methods to create logical groups (sparingly)

### Semicolons

**Required** - Every statement must end with semicolon:
```javascript
const x = 1;  // Required
doSomething();  // Required
```

## Arrays and Objects

### Array Literals

```javascript
// Use trailing commas
const values = [
  'first value',
  'second value',
];

// Never use Array constructor
const a = [x1, x2, x3];  // Good
const b = new Array(x1, x2, x3);  // Bad

// Destructuring
const [a, b, c, ...rest] = generateResults();
let [, b,, d] = someArray;  // Skip unused elements

// Spread operator
[...foo]  // Preferred over Array.prototype.slice.call(foo)
[...foo, ...bar]  // Preferred over foo.concat(bar)
```

### Object Literals

```javascript
// Use trailing commas
const obj = {
  a: 0,
  b: 1,
};

// Never use Object constructor
const o = {a: 0, b: 1};  // Good
const o = new Object();  // Bad

// Don't mix quoted and unquoted keys
{
  width: 42,
  height: 50,
}  // Good - all unquoted (struct style)

{
  'width': 42,
  'maxWidth': 43,
}  // Good - all quoted (dict style)

{
  width: 42,
  'maxWidth': 43,
}  // Bad - mixed

// Method shorthand
const obj = {
  value: 1,
  method() {
    return this.value;
  },
};

// Shorthand properties
const foo = 1;
const bar = 2;
const obj = {foo, bar};

// Destructuring
function process({num, str = 'default'} = {}) {}
```

## Classes

### Class Declaration

```javascript
class MyClass {
  // Constructor
  constructor(value) {
    /** @private @const */
    this.value_ = value;
    
    /** @private */
    this.mutableField = 0;
  }

  // Methods
  getValue() {
    return this.value_;
  }

  /** @override */
  toString() {
    return `MyClass(${this.value_})`;
  }
}

// Inheritance
class ChildClass extends MyClass {
  constructor(value, extra) {
    super(value);  // Must call super() first
    this.extra = extra;
  }
}
```

**Rules**:
- Constructors are optional
- Define all fields in constructor
- Use `@const` for never-reassigned fields
- Use `@private`, `@protected` for non-public fields
- Private field names may end with underscore
- No semicolons after methods
- Call `super()` before accessing `this` in subclasses

## Functions

### Arrow Functions

**Preferred** for callbacks and short functions:
```javascript
// Good
const squares = numbers.map(n => n * n);

items.forEach((item) => {
  process(item);
});

// Use when 'this' from outer scope needed
class Timer {
  start() {
    setInterval(() => {
      this.tick();  // 'this' refers to Timer instance
    }, 1000);
  }
}
```

**Rules**:
- Prefer arrow functions for callbacks
- Use arrow functions to preserve `this` binding
- Omit parens for single parameter: `x => x * 2`
- Use parens for zero or multiple params: `() => 42`, `(a, b) => a + b`
- Always use braces for multi-line bodies

### Function Declarations

```javascript
function myFunction(param1, param2) {
  return param1 + param2;
}

// Optional parameters with defaults
function greet(name = 'Guest') {
  return `Hello, ${name}`;
}

// Rest parameters
function sum(...numbers) {
  return numbers.reduce((a, b) => a + b, 0);
}
```

## Control Structures

### Conditionals

```javascript
// Standard if-else
if (condition) {
  doSomething();
} else if (otherCondition) {
  doOther();
} else {
  doDefault();
}

// Ternary for simple cases
const value = condition ? trueValue : falseValue;
```

### Loops

```javascript
// For-of for iterables
for (const item of items) {
  process(item);
}

// Traditional for loop
for (let i = 0; i < array.length; i++) {
  process(array[i]);
}

// For-in for object properties (use with caution)
for (const key in object) {
  if (object.hasOwnProperty(key)) {
    process(object[key]);
  }
}
```

### Switch Statements

```javascript
switch (value) {
  case 'option1':
    handleOption1();
    break;

  case 'option2':
    handleOption2();
    break;

  default:
    handleDefault();
}
```

## Modern Features

### Template Literals

```javascript
// Use for string interpolation
const message = `Hello, ${name}!`;

// Multi-line strings
const html = `
  <div>
    <h1>${title}</h1>
  </div>
`;
```

### Promises and Async/Await

```javascript
// Prefer async/await
async function fetchData() {
  try {
    const response = await fetch(url);
    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Failed:', error);
    throw error;
  }
}

// Promise chains when appropriate
fetch(url)
  .then(response => response.json())
  .then(data => process(data))
  .catch(error => console.error(error));
```

## Comments

### Implementation Comments

```javascript
// Single-line comments use //
// Multiple single-line comments for
// longer explanations.

/*
 * Multi-line comment style.
 * Subsequent lines start with * aligned
 * with the * on the previous line.
 */

// Parameter name comments for clarity
someFunction(obviousParam, /* shouldRender= */ true, /* name= */ 'hello');
```

### JSDoc

**Use JSDoc for**:
- All classes
- All methods and functions (public and private)
- Properties when needed for clarity

```javascript
/**
 * Brief description of the function.
 * 
 * @param {string} name The user's name
 * @param {number=} age Optional age parameter
 * @return {string} Greeting message
 */
function greet(name, age) {
  return `Hello, ${name}`;
}

/**
 * Class representing a point.
 */
class Point {
  /**
   * Create a point.
   * @param {number} x The x coordinate
   * @param {number} y The y coordinate
   */
  constructor(x, y) {
    /** @private @const {number} */
    this.x_ = x;
    /** @private @const {number} */
    this.y_ = y;
  }
}
```

## Node.js Specific

### Module Exports

```javascript
// ES modules in Node.js (use .mjs or "type": "module" in package.json)
export class Service {}
export function helper() {}

// CommonJS (when ES modules not available)
class Service {}
function helper() {}

module.exports = {Service, helper};
```

### Error Handling

```javascript
// Always handle errors in async code
async function processFile(path) {
  try {
    const content = await fs.promises.readFile(path, 'utf8');
    return JSON.parse(content);
  } catch (error) {
    console.error(`Failed to process ${path}:`, error);
    throw error;
  }
}

// Use Error objects
throw new Error('Something went wrong');
throw new TypeError('Expected string');
```

## Common Patterns

### Object Property Access

```javascript
// Check existence
if (obj.property != null) {
  // Property exists and is not null/undefined
}

// Use optional chaining
const value = obj?.deeply?.nested?.property;

// Nullish coalescing
const result = value ?? defaultValue;
```

### Array Operations

```javascript
// Prefer array methods over loops
const doubled = numbers.map(n => n * 2);
const evens = numbers.filter(n => n % 2 === 0);
const sum = numbers.reduce((acc, n) => acc + n, 0);

// Check if array contains item
if (array.includes(item)) { }

// Find item
const found = array.find(item => item.id === targetId);
```

## Quick Reference

**Variable declaration**: `const` (default), `let` (when reassignment needed), never `var`  
**Indentation**: 2 spaces  
**Semicolons**: Required  
**String quotes**: Single `'` or backticks `` ` `` for templates  
**Braces**: K&R style, always use for control structures  
**Line length**: 80 characters  
**Naming**: `lowerCamelCase` for variables/functions, `UpperCamelCase` for classes  
**Imports**: Use `.js` extension, no default exports  
**Comments**: `//` for single-line, `/* */` for multi-line  

## Additional Resources

### Reference Files

For comprehensive coverage of specific topics:
- **`references/advanced-features.md`** - Advanced JavaScript patterns, promises, generators, proxies
- **`references/jsdoc-guide.md`** - Complete JSDoc annotation guide
- **`references/naming-conventions.md`** - Detailed naming rules for all identifier types
- **`references/disallowed-features.md`** - Features to avoid and their alternatives

### Complete Style Guide

The full Google JavaScript Style Guide is available at:
https://google.github.io/styleguide/jsguide.html
