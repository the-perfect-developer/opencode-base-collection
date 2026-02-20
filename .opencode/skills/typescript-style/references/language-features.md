# Language Features

Detailed coverage of TypeScript language features and their proper usage according to Google's style guide.

## Table of Contents

- [Control Structures](#control-structures)
- [Iterables and Iteration](#iterables-and-iteration)
- [Exception Handling](#exception-handling)
- [Switch Statements](#switch-statements)
- [Equality Checks](#equality-checks)
- [Type Assertions](#type-assertions)
- [Keep Try Blocks Focused](#keep-try-blocks-focused)

## Control Structures

### If Statements

Use block statements for all control structures, even single-line bodies:

```typescript
// Good
if (condition) {
  doSomething();
}

// Bad: missing braces
if (condition) doSomething();
```

### For Loops

Prefer `for-of` loops over traditional indexed `for` loops:

```typescript
// Good: for-of loop
for (const item of items) {
  console.log(item);
}

// Good: for-of with index
for (const [index, item] of items.entries()) {
  console.log(index, item);
}

// Acceptable: when you need fine control
for (let i = 0; i < items.length; i++) {
  console.log(items[i]);
}
```

### For-In Loops

Avoid `for-in` loops. Use `Object.keys()`, `Object.values()`, or `Object.entries()` instead:

```typescript
// Bad: unfiltered for-in
for (const key in obj) {
  console.log(key);
}

// Good: Object.keys
for (const key of Object.keys(obj)) {
  console.log(key);
}

// Good: Object.entries  
for (const [key, value] of Object.entries(obj)) {
  console.log(key, value);
}

// If you must use for-in, filter it
for (const key in obj) {
  if (!obj.hasOwnProperty(key)) continue;
  console.log(key);
}
```

## Iterables and Iteration

### Iterating Arrays

Use `for-of` to iterate arrays:

```typescript
const numbers = [1, 2, 3];

// Good
for (const num of numbers) {
  console.log(num);
}

// Good: with index
for (const [i, num] of numbers.entries()) {
  console.log(i, num);
}

// Bad: forEach prevents break/continue
numbers.forEach(num => console.log(num));
```

### Array Methods

Use array methods when appropriate:

```typescript
// Good: transforming arrays
const doubled = numbers.map(x => x * 2);
const evens = numbers.filter(x => x % 2 === 0);
const sum = numbers.reduce((a, b) => a + b, 0);

// Good: checking conditions
const hasEven = numbers.some(x => x % 2 === 0);
const allPositive = numbers.every(x => x > 0);
```

### Iterating Objects

Use `Object.keys()`, `Object.values()`, or `Object.entries()`:

```typescript
const obj = {a: 1, b: 2, c: 3};

// Good: iterate keys
for (const key of Object.keys(obj)) {
  console.log(key, obj[key]);
}

// Good: iterate values
for (const value of Object.values(obj)) {
  console.log(value);
}

// Good: iterate entries
for (const [key, value] of Object.entries(obj)) {
  console.log(key, value);
}
```

## Exception Handling

### Throwing Exceptions

Always throw `Error` objects, never strings or other primitives:

```typescript
// Good
throw new Error('Something went wrong');

// Bad
throw 'error message';
throw {message: 'error'};
```

### Catching Exceptions

Catch exceptions and handle them appropriately. Do not use empty catch blocks:

```typescript
// Good: handle the error
try {
  riskyOperation();
} catch (e) {
  logger.error('Operation failed', e);
  showUserError();
}

// Good: re-throw if can't handle
try {
  riskyOperation();
} catch (e) {
  // Add context and re-throw
  throw new Error(`Failed during operation: ${e}`);
}

// Bad: empty catch block
try {
  riskyOperation();
} catch (e) {
  // Silent failure
}
```

### Exception Type

The caught exception type is `unknown` in TypeScript. Check the type before using:

```typescript
try {
  riskyOperation();
} catch (e) {
  // e is unknown, must check type
  if (e instanceof Error) {
    console.error(e.message);
  } else {
    console.error('Unknown error', e);
  }
}
```

## Switch Statements

### Use Braces for Case Blocks

When a `case` contains statements, wrap them in braces:

```typescript
// Good
switch (value) {
  case 'a': {
    const x = getValue();
    doSomething(x);
    break;
  }
  case 'b': {
    doOtherThing();
    break;
  }
  default: {
    handleDefault();
  }
}

// Bad: no braces with multiple statements
switch (value) {
  case 'a':
    const x = getValue();
    doSomething(x);
    break;
}
```

### Fall-Through

Document intentional fall-through with a comment:

```typescript
switch (value) {
  case 'a':
    prepareA();
    // fall through
  case 'b':
    handleAOrB();
    break;
  case 'c':
    handleC();
    break;
}
```

### Default Case

Always include a `default` case, even if it does nothing:

```typescript
// Good
switch (value) {
  case 'a':
    handleA();
    break;
  default:
    // No default behavior needed
}
```

## Equality Checks

### Use Strict Equality

Always use `===` and `!==`, never `==` or `!=`:

```typescript
// Good
if (x === y) { }
if (x !== y) { }

// Bad
if (x == y) { }
if (x != y) { }
```

**Exception**: Comparing against `null` can use `== null` to check for both `null` and `undefined`:

```typescript
// Good: checks both null and undefined
if (value == null) { }

// Equivalent to
if (value === null || value === undefined) { }
```

### Comparing to Primitives

Be explicit when comparing to boolean, number, or string literals:

```typescript
// Good
if (value === true) { }
if (count === 0) { }
if (text === '') { }

// Bad: implicit coercion
if (value) { }  // Unless you want truthy check
```

## Type Assertions

### Use as, Not Angle Brackets

Use `as` syntax for type assertions, not angle brackets:

```typescript
// Good
const input = document.querySelector('.my-input') as HTMLInputElement;

// Bad
const input = <HTMLInputElement>document.querySelector('.my-input');
```

**Why?** Angle bracket syntax conflicts with JSX.

### Type Assertions vs Type Annotations

Prefer type annotations over type assertions:

```typescript
// Good: type annotation
const input: HTMLInputElement = getInput();

// Less preferred: type assertion
const input = getInput() as HTMLInputElement;
```

### Non-Null Assertions

Use non-null assertion `!` sparingly and only when certain:

```typescript
// Good: when you know it's not null
const value = map.get(key)!;

// Better: check explicitly
const value = map.get(key);
if (value === undefined) {
  throw new Error('Key not found');
}
```

### Type Assertion Restrictions

Never use double assertions. If needed, the code likely has a design issue:

```typescript
// Bad: double assertion
const foo = (value as unknown) as Foo;

// Better: fix the type hierarchy
```

## Keep Try Blocks Focused

Limit the code in `try` blocks to the minimum that can throw:

```typescript
// Good: focused try block
let result;
try {
  result = riskyOperation();
} catch (e) {
  handleError(e);
  return;
}
processResult(result);

// Bad: too much in try block
try {
  const input = getInput();
  const validated = validate(input);
  const result = riskyOperation(validated);
  processResult(result);
  displaySuccess();
} catch (e) {
  // Which operation failed?
  handleError(e);
}
```

## Comments

### Use JSDoc

Use JSDoc for all public APIs:

```typescript
/**
 * Processes user data and returns formatted output.
 * @param user The user object to process
 * @returns Formatted user string
 */
export function formatUser(user: User): string {
  return `${user.name} (${user.email})`;
}
```

### Parameter Property Comments

Document parameter properties with `@param`:

```typescript
class Service {
  /**
   * @param apiKey The API key for authentication
   */
  constructor(private readonly apiKey: string) {}
}
```

### Inline Comments

Use `//` for inline comments. Place on line before the code:

```typescript
// Good: comment before code
// This is necessary because of legacy API constraint
const value = legacyTransform(input);

// Bad: comment after code
const value = legacyTransform(input);  // legacy API
```

## Nullability

### Prefer Undefined

Prefer `undefined` over `null` for optional values:

```typescript
// Good
function find(id: string): User | undefined {
  return users.get(id);
}

// Less preferred
function find(id: string): User | null {
  return users.get(id) ?? null;
}
```

### Nullable Types

Use union types to represent nullable values:

```typescript
// Good
let name: string | undefined;
let count: number | null;

// Bad: optional properties for required fields
interface User {
  name?: string;  // Only if truly optional
}
```

### Optional Chaining

Use optional chaining for nested optional access:

```typescript
// Good
const city = user?.address?.city;

// Bad: manual checks
const city = user && user.address && user.address.city;
```

### Nullish Coalescing

Use nullish coalescing `??` for default values:

```typescript
// Good: only replaces null/undefined
const name = user.name ?? 'Anonymous';

// Bad: OR replaces falsy values
const name = user.name || 'Anonymous';  // '' becomes 'Anonymous'
```

## Enums

### Prefer Enums for Constants

Use `enum` for related constants:

```typescript
// Good
enum Status {
  PENDING,
  ACTIVE,
  COMPLETED,
}

// Less clear
const STATUS_PENDING = 0;
const STATUS_ACTIVE = 1;
const STATUS_COMPLETED = 2;
```

### Use const enum

Use `const enum` when values are only used as types:

```typescript
// Good: compiled away
const enum Color {
  RED,
  GREEN,
  BLUE,
}
```

### String Enums

Use string enums when values are serialized:

```typescript
enum Status {
  PENDING = 'pending',
  ACTIVE = 'active',
  COMPLETED = 'completed',
}
```

## Tuples

### Use Tuples for Fixed-Length Arrays

Use tuple types for fixed-length arrays with specific types:

```typescript
// Good: tuple for coordinate
type Coordinate = [number, number];
const point: Coordinate = [10, 20];

// Good: tuple for function return
function splitName(fullName: string): [string, string] {
  const parts = fullName.split(' ');
  return [parts[0], parts[1]];
}
```

### Label Tuple Elements

Label tuple elements for clarity (TypeScript 4.0+):

```typescript
// Good: labeled tuple
type Range = [min: number, max: number];

// Good: labeled optional elements
type Args = [name: string, age?: number];
```

## Best Practices Summary

### DO

- Use `for-of` over traditional `for` loops
- Throw `Error` objects, not primitives
- Handle caught exceptions appropriately
- Use `===` and `!==` for equality
- Use `as` for type assertions
- Keep try blocks focused
- Use JSDoc for public APIs
- Prefer `undefined` over `null`
- Use optional chaining and nullish coalescing
- Use enums for related constants

### DON'T

- Use `for-in` without filtering
- Use empty catch blocks
- Use `==` or `!=` for comparison
- Use angle brackets for type assertions
- Overuse non-null assertions
- Put too much code in try blocks
- Use `null` when `undefined` is more natural
- Use `||` when you mean `??`
