---
name: typescript-style
description: This skill should be used when the user asks to "write TypeScript code", "format TypeScript", "follow TypeScript style guide", "TypeScript best practices", or needs guidance on Google's TypeScript coding conventions.
license: CC-BY-3.0
compatibility: opencode
---

# Google TypeScript Style Guide

Apply Google's TypeScript Style Guide conventions for consistent, maintainable TypeScript code.

## Overview

This skill provides guidelines for writing TypeScript code following Google's internal style guide. It covers source file structure, language features, naming conventions, type annotations, and best practices specific to TypeScript development.

## Source File Basics

### File Encoding

Source files must be encoded in **UTF-8**.

### Whitespace

- Use ASCII horizontal space (0x20) as the only whitespace character
- Use special escape sequences (`\'`, `\"`, `\\`, `\n`, `\r`, `\t`, etc.) instead of numeric escapes
- For non-printable characters, use hex/Unicode escapes with explanatory comments

```typescript
// Good: clear unicode character
const units = 'μs';

// Good: escape with comment
const output = '\ufeff' + content;  // byte order mark
```

### File Structure

Files must contain sections in this order (separated by exactly one blank line):

1. Copyright information (if present)
2. `@fileoverview` JSDoc (if present)
3. Imports
4. Implementation

```typescript
/**
 * @fileoverview Description of file. Lorem ipsum dolor sit amet, consectetur
 * adipiscing elit, sed do eiusmod tempor incididunt.
 */

import * as foo from './foo';
import {Bar} from './bar';

export class MyClass { }
```

## Imports and Exports

### Import Styles

Use appropriate import styles:

- **Module imports**: `import * as foo from '...';` - for namespacing
- **Named imports**: `import {SomeThing} from '...';` - for frequently used symbols
- **Default imports**: `import SomeThing from '...';` - only when required by external code
- **Side-effect imports**: `import '...';` - only for side-effects

```typescript
// Good: module import for namespace
import * as ng from '@angular/core';

// Good: named import for clear symbols
import {describe, it, expect} from './testing';

// Only when needed
import Button from 'Button';
```

### Named Exports Only

Always use named exports. Never use default exports.

```typescript
// Good: named export
export class Foo { }
export const BAR = 42;
```

```typescript
// Bad: default export
export default class Foo { }
```

**Why?** Default exports provide no canonical name, making refactoring difficult and allowing inconsistent import names.

### Import Paths

- Use relative paths (`./foo`) for files within the same project
- Use paths from root for cross-project imports
- Limit parent steps (`../../../`) to maintain clarity

```typescript
import {Symbol1} from 'path/from/root';
import {Symbol2} from '../parent/file';
import {Symbol3} from './sibling';
```

## Variables and Constants

### Use const and let

Always use `const` or `let`. Never use `var`.

```typescript
const foo = otherValue;  // Use const by default
let bar = someValue;     // Use let when reassigning
```

```typescript
var foo = someValue;     // Never use var
```

**Why?** `const` and `let` are block-scoped like most languages. `var` is function-scoped and causes bugs.

### One Variable Per Declaration

Declare only one variable per statement:

```typescript
// Good
let a = 1;
let b = 2;
```

```typescript
// Bad
let a = 1, b = 2;
```

## Arrays and Objects

### Array Literals

Do not use the `Array` constructor. Use bracket notation:

```typescript
// Good
const a = [2];
const b = [2, 3];
const c = Array.from<number>({length: 5}).fill(0);
```

```typescript
// Bad: confusing behavior
const a = new Array(2); // [undefined, undefined]
const b = new Array(2, 3); // [2, 3]
```

### Object Literals

Do not use the `Object` constructor. Use object literals:

```typescript
// Good
const obj = {};
const obj2 = {a: 0, b: 1};
```

```typescript
// Bad
const obj = new Object();
```

### Spread Syntax

Use spread for shallow copying and concatenating:

```typescript
// Good: array spread
const foo = [1, 2];
const foo2 = [...foo, 6, 7];

// Good: object spread
const foo = {num: 1};
const foo2 = {...foo, num: 5};
```

**Rules**:
- Only spread iterables into arrays
- Only spread objects into objects
- Later values override earlier values

### Destructuring

Use destructuring for unpacking values:

```typescript
// Good: array destructuring
const [a, b, c, ...rest] = generateResults();
let [, b, , d] = someArray;

// Good: object destructuring
const {num, str = 'default'} = options;
```

For function parameters, keep destructuring simple (single level, shorthand properties only):

```typescript
// Good
function destructured({num, str = 'default'}: Options = {}) { }
```

```typescript
// Bad: too deeply nested
function nestedTooDeeply({x: {num, str}}: {x: Options}) { }
```

## Classes

### Class Declarations

Class declarations must not end with semicolons:

```typescript
// Good
class Foo {
}
```

```typescript
// Bad
class Foo {
};
```

### Class Members

#### Use readonly

Mark properties never reassigned outside constructor with `readonly`:

```typescript
class Foo {
  private readonly bar = 5;
}
```

#### Parameter Properties

Use parameter properties instead of obvious initializers:

```typescript
// Good
class Foo {
  constructor(private readonly barService: BarService) {}
}
```

```typescript
// Bad: unnecessary boilerplate
class Foo {
  private readonly barService: BarService;
  
  constructor(barService: BarService) {
    this.barService = barService;
  }
}
```

#### Field Initializers

Initialize fields where declared when possible:

```typescript
// Good
class Foo {
  private readonly userList: string[] = [];
}
```

```typescript
// Bad: unnecessary constructor
class Foo {
  private readonly userList: string[];
  
  constructor() {
    this.userList = [];
  }
}
```

### Visibility

- Limit visibility as much as possible
- Never use `public` modifier except for non-readonly parameter properties
- TypeScript symbols are public by default

```typescript
// Good
class Foo {
  bar = new Bar();  // public by default
  
  constructor(public baz: Baz) {}  // public modifier allowed
}
```

```typescript
// Bad
class Foo {
  public bar = new Bar();  // unnecessary
}
```

### No Private Fields (#)

Do not use private fields (`#ident`). Use TypeScript's `private` modifier instead:

```typescript
// Good
class Clazz {
  private ident = 1;
}
```

```typescript
// Bad
class Clazz {
  #ident = 1;
}
```

**Why?** Private identifiers cause size/performance regressions when downleveled and don't offer benefits over TypeScript's visibility.

## Functions

### Prefer Function Declarations

For named functions, prefer function declarations over arrow functions:

```typescript
// Good
function foo() {
  return 42;
}
```

```typescript
// Bad
const foo = () => 42;
```

### Arrow Functions

Use arrow functions for:
- Callbacks and nested functions
- When explicit type annotation required
- When you need to preserve `this` context

```typescript
// Good: callback
bar(() => { this.doSomething(); });

// Good: nested function with this
class Foo {
  method() {
    setTimeout(() => {
      this.doWork();
    }, 100);
  }
}
```

### Arrow Function Bodies

Use concise bodies when return value is used, block bodies otherwise:

```typescript
// Good: return value used
const numbers = [1, 2, 3].map(v => v * 2);

// Good: no return value
myPromise.then(v => {
  console.log(v);
});

// Good: explicit void
myPromise.then(v => void console.log(v));
```

### No Rebinding this

Do not use `this` in function expressions/declarations unless rebinding is needed (which is discouraged):

```typescript
// Bad
function clickHandler() {
  this.textContent = 'Hello';
}
document.body.onclick = clickHandler;
```

```typescript
// Good: use arrow function
document.body.onclick = () => {
  document.body.textContent = 'hello';
};
```

## Type Annotations

### Inference

Rely on type inference where possible. Do not annotate when the type is obvious:

```typescript
// Good: type is obvious
const x = 5;
const y = new Foo();

// Bad: redundant annotation
const x: number = 5;
```

### Return Types

Annotate return types on exported functions and public methods:

```typescript
// Good
export function foo(): string {
  return 'bar';
}
```

### Type vs Interface

- Use `interface` for object shapes and class contracts
- Use `type` for unions, intersections, and mapped types
- Prefer `interface` when either would work

```typescript
// Good: interface for object shape
interface User {
  name: string;
  age: number;
}

// Good: type for union
type Status = 'success' | 'error' | 'pending';
```

## Naming Conventions

### Identifiers

Use these naming conventions:

- **Classes/Interfaces/Types/Enums**: `UpperCamelCase`
- **Functions/Methods/Properties**: `lowerCamelCase`
- **Constants**: `CONSTANT_CASE`
- **Private properties**: prefix with `private`
- **Type parameters**: single uppercase letter or `UpperCamelCase`

```typescript
class MyClass {}
interface UserData {}
type Status = 'active' | 'inactive';
enum Color { RED, GREEN, BLUE }

function doSomething() {}
const userName = 'Alice';
const MAX_COUNT = 100;

class Foo {
  private readonly internalState = 5;
}
```

### File Names

- Use lowercase with dashes: `file-name.ts`
- Match exported symbol when exporting single symbol
- Use `.d.ts` for declaration files

## String Literals

### Use Single Quotes

Use single quotes for ordinary strings:

```typescript
// Good
const message = 'Hello world';
```

```typescript
// Bad
const message = "Hello world";
```

### Template Literals

Use template literals for:
- String interpolation
- Multi-line strings
- Complex concatenation

```typescript
// Good
const greeting = `Hello ${name}`;
const multiline = `Line 1
Line 2`;
```

## Type Coercion

### Explicit Coercion

Use `String()`, `Boolean()`, `Number()` for type coercion:

```typescript
// Good
const bool = Boolean(value);
const str = String(num);
const num = Number(str);
```

### No Implicit Enum Coercion

Never convert enums to booleans implicitly. Compare explicitly:

```typescript
enum SupportLevel { NONE, BASIC, ADVANCED }

// Bad
if (level) { }

// Good
if (level !== SupportLevel.NONE) { }
```

## Quick Reference

### DO

- Use `const` and `let`, never `var`
- Use named exports only
- Use `readonly` for immutable properties
- Use parameter properties
- Initialize fields where declared
- Use single quotes for strings
- Use template literals for interpolation
- Annotate return types on public functions
- Prefer `interface` over `type` for objects

### DON'T

- Use default exports
- Use `var` for variables
- Use `Array()` or `Object()` constructors
- Use private fields (`#`)
- Rebind `this` unnecessarily
- Use function expressions (use arrows instead)
- Mix quoted and unquoted object keys
- Coerce enums to booleans

## Additional Resources

### Reference Files

For detailed specifications:
- **`references/language-features.md`** - Detailed coverage of TypeScript language features
- **`references/type-system.md`** - Type annotations, generics, utility types
- **`references/naming-conventions.md`** - Complete naming rules and examples

### Example Files

Working examples in `examples/`:
- **`examples/class-example.ts`** - Well-structured class with best practices
- **`examples/function-example.ts`** - Function declarations and arrow functions
- **`examples/types-example.ts`** - Type definitions and interfaces
