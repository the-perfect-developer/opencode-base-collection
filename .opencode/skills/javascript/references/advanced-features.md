# Advanced JavaScript Features

This reference covers advanced JavaScript features and patterns from the Google JavaScript Style Guide.

## Table of Contents

- [Promises and Async Programming](#promises-and-async-programming)
- [Iterators and Generators](#iterators-and-generators)
- [Symbols](#symbols)
- [Proxies and Reflect](#proxies-and-reflect)
- [Advanced Array Features](#advanced-array-features)
- [Advanced Object Features](#advanced-object-features)
- [Error Handling Patterns](#error-handling-patterns)
- [Module Patterns](#module-patterns)

## Promises and Async Programming

### Promise Creation

```javascript
// Creating promises
function delay(ms) {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
}

// Promise with both resolve and reject
function fetchData(url) {
  return new Promise((resolve, reject) => {
    if (!url) {
      reject(new Error('URL is required'));
      return;
    }
    // ... fetch logic
    resolve(data);
  });
}
```

### Async/Await Best Practices

```javascript
// Prefer async/await over promise chains
async function processUser(userId) {
  try {
    const user = await fetchUser(userId);
    const posts = await fetchUserPosts(user.id);
    const comments = await fetchComments(posts);
    return {user, posts, comments};
  } catch (error) {
    console.error('Failed to process user:', error);
    throw error;
  }
}

// Parallel execution with Promise.all
async function loadDashboard() {
  const [user, stats, notifications] = await Promise.all([
    fetchUser(),
    fetchStats(),
    fetchNotifications(),
  ]);
  return {user, stats, notifications};
}

// Promise.allSettled for handling mixed success/failure
async function loadOptionalData() {
  const results = await Promise.allSettled([
    fetchCriticalData(),
    fetchOptionalData1(),
    fetchOptionalData2(),
  ]);
  
  const critical = results[0].status === 'fulfilled' 
    ? results[0].value 
    : null;
  
  return {critical, optional: results.slice(1)};
}

// Promise.race for timeout pattern
async function fetchWithTimeout(url, timeoutMs) {
  return Promise.race([
    fetch(url),
    new Promise((_, reject) => 
      setTimeout(() => reject(new Error('Timeout')), timeoutMs)
    ),
  ]);
}
```

### Error Handling in Async Code

```javascript
// Always handle promise rejections
async function safeOperation() {
  try {
    return await riskyOperation();
  } catch (error) {
    if (error instanceof NetworkError) {
      // Retry logic
      return await retryOperation();
    }
    throw error;  // Re-throw if can't handle
  }
}

// Top-level error handler
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});
```

## Iterators and Generators

### Iterators

```javascript
// Custom iterator
const range = {
  from: 1,
  to: 5,
  
  [Symbol.iterator]() {
    let current = this.from;
    const last = this.to;
    
    return {
      next() {
        if (current <= last) {
          return {value: current++, done: false};
        }
        return {done: true};
      },
    };
  },
};

for (const num of range) {
  console.log(num);  // 1, 2, 3, 4, 5
}
```

### Generators

```javascript
// Generator function
function* generateSequence(start, end) {
  for (let i = start; i <= end; i++) {
    yield i;
  }
}

const sequence = generateSequence(1, 5);
for (const num of sequence) {
  console.log(num);
}

// Generator composition
function* generateCombined() {
  yield* generateSequence(1, 3);
  yield* generateSequence(8, 10);
}

// Async generators
async function* fetchPages(url) {
  let page = 1;
  while (page <= 5) {
    const data = await fetch(`${url}?page=${page}`);
    yield await data.json();
    page++;
  }
}

// Using async generator
for await (const page of fetchPages('/api/items')) {
  console.log(page);
}
```

### Generator Patterns

```javascript
// Infinite sequence
function* fibonacci() {
  let [prev, curr] = [0, 1];
  while (true) {
    yield curr;
    [prev, curr] = [curr, prev + curr];
  }
}

const fib = fibonacci();
console.log(fib.next().value);  // 1
console.log(fib.next().value);  // 1
console.log(fib.next().value);  // 2

// Taking values from infinite generator
function* take(count, iterable) {
  let i = 0;
  for (const value of iterable) {
    if (i++ >= count) return;
    yield value;
  }
}

const first10Fib = [...take(10, fibonacci())];
```

## Symbols

### Creating and Using Symbols

```javascript
// Unique property keys
const uniqueId = Symbol('id');
const user = {
  name: 'Alice',
  [uniqueId]: 12345,
};

console.log(user[uniqueId]);  // 12345
console.log(Object.keys(user));  // ['name'] - symbol not enumerated

// Well-known symbols
class Collection {
  constructor(items) {
    this.items = items;
  }
  
  [Symbol.iterator]() {
    let index = 0;
    return {
      next: () => ({
        value: this.items[index++],
        done: index > this.items.length,
      }),
    };
  }
  
  [Symbol.toStringTag]() {
    return 'Collection';
  }
}

const col = new Collection([1, 2, 3]);
for (const item of col) {
  console.log(item);
}
console.log(col.toString());  // [object Collection]
```

### Symbol Registry

```javascript
// Global symbol registry
const sym1 = Symbol.for('shared');
const sym2 = Symbol.for('shared');
console.log(sym1 === sym2);  // true

// Get key for symbol
console.log(Symbol.keyFor(sym1));  // 'shared'
```

## Proxies and Reflect

### Proxy Basics

```javascript
// Validation proxy
function createValidatedObject(target, validators) {
  return new Proxy(target, {
    set(obj, prop, value) {
      if (validators[prop]) {
        if (!validators[prop](value)) {
          throw new Error(`Invalid value for ${prop}`);
        }
      }
      obj[prop] = value;
      return true;
    },
  });
}

const user = createValidatedObject({}, {
  age: (value) => typeof value === 'number' && value >= 0,
  email: (value) => /\S+@\S+\.\S+/.test(value),
});

user.age = 25;  // OK
user.age = -5;  // Error: Invalid value for age
```

### Common Proxy Traps

```javascript
// Logging proxy
function createLoggingProxy(target) {
  return new Proxy(target, {
    get(obj, prop) {
      console.log(`Getting ${prop}`);
      return Reflect.get(obj, prop);
    },
    
    set(obj, prop, value) {
      console.log(`Setting ${prop} to ${value}`);
      return Reflect.set(obj, prop, value);
    },
    
    deleteProperty(obj, prop) {
      console.log(`Deleting ${prop}`);
      return Reflect.deleteProperty(obj, prop);
    },
    
    has(obj, prop) {
      console.log(`Checking if ${prop} exists`);
      return Reflect.has(obj, prop);
    },
  });
}

// Negative array indices proxy
function createNegativeIndexArray(array) {
  return new Proxy(array, {
    get(target, prop) {
      const index = Number(prop);
      if (index < 0) {
        return target[target.length + index];
      }
      return target[prop];
    },
  });
}

const arr = createNegativeIndexArray([1, 2, 3, 4]);
console.log(arr[-1]);  // 4
console.log(arr[-2]);  // 3
```

### Reflect API

```javascript
// Reflect provides default behavior for proxy traps
const obj = {x: 1, y: 2};

// Same as: obj.x
Reflect.get(obj, 'x');  // 1

// Same as: obj.x = 3
Reflect.set(obj, 'x', 3);

// Same as: delete obj.x
Reflect.deleteProperty(obj, 'x');

// Same as: 'x' in obj
Reflect.has(obj, 'x');

// Same as: Object.keys(obj)
Reflect.ownKeys(obj);

// Function call with specific this
function greet(greeting) {
  return `${greeting}, ${this.name}`;
}
Reflect.apply(greet, {name: 'Alice'}, ['Hello']);  // "Hello, Alice"
```

## Advanced Array Features

### Array Methods

```javascript
// flatMap - map + flatten
const nested = [[1, 2], [3, 4], [5, 6]];
const doubled = nested.flatMap(arr => arr.map(x => x * 2));
// [2, 4, 6, 8, 10, 12]

// flat - flatten nested arrays
const deepNested = [1, [2, [3, [4]]]];
deepNested.flat(2);  // [1, 2, 3, [4]]
deepNested.flat(Infinity);  // [1, 2, 3, 4]

// Array.from with mapping function
const range = Array.from({length: 5}, (_, i) => i + 1);
// [1, 2, 3, 4, 5]

const chars = Array.from('hello');  // ['h', 'e', 'l', 'l', 'o']

// findLast and findLastIndex
const numbers = [1, 2, 3, 4, 5, 4, 3, 2, 1];
numbers.findLast(n => n > 3);  // 4 (last occurrence)
numbers.findLastIndex(n => n > 3);  // 5

// at - negative indexing
const arr = [1, 2, 3, 4, 5];
arr.at(-1);  // 5
arr.at(-2);  // 4
```

### Typed Arrays

```javascript
// Efficient binary data handling
const buffer = new ArrayBuffer(16);
const int32View = new Int32Array(buffer);
const uint8View = new Uint8Array(buffer);

int32View[0] = 42;
console.log(uint8View[0]);  // 42 (same bytes, different view)

// Common typed arrays
const int8 = new Int8Array([1, 2, 3]);
const uint8 = new Uint8Array([255, 254, 253]);
const float32 = new Float32Array([1.5, 2.5, 3.5]);
const float64 = new Float64Array([1.1, 2.2, 3.3]);

// Converting between typed arrays and regular arrays
const regular = [1, 2, 3, 4];
const typed = new Uint8Array(regular);
const back = Array.from(typed);
```

## Advanced Object Features

### Property Descriptors

```javascript
// Define properties with specific behavior
const obj = {};

Object.defineProperty(obj, 'readOnly', {
  value: 42,
  writable: false,
  enumerable: true,
  configurable: false,
});

obj.readOnly = 100;  // Silently fails (throws in strict mode)
console.log(obj.readOnly);  // 42

// Getters and setters
Object.defineProperty(obj, 'fullName', {
  get() {
    return `${this.firstName} ${this.lastName}`;
  },
  set(value) {
    [this.firstName, this.lastName] = value.split(' ');
  },
  enumerable: true,
});

// Get property descriptor
const descriptor = Object.getOwnPropertyDescriptor(obj, 'readOnly');
```

### Object Methods

```javascript
// Object.entries / Object.fromEntries
const obj = {a: 1, b: 2, c: 3};
const entries = Object.entries(obj);  // [['a', 1], ['b', 2], ['c', 3]]
const doubled = Object.fromEntries(
  entries.map(([key, val]) => [key, val * 2])
);  // {a: 2, b: 4, c: 6}

// Object.assign - shallow merge
const merged = Object.assign({}, obj1, obj2, obj3);

// Spread is preferred for shallow clone/merge
const clone = {...obj};
const merged2 = {...obj1, ...obj2};

// Object.freeze - prevent modifications
const frozen = Object.freeze({x: 1, y: 2});
frozen.x = 100;  // Silently fails
frozen.z = 3;  // Silently fails

// Object.seal - prevent adding/removing properties
const sealed = Object.seal({x: 1, y: 2});
sealed.x = 100;  // OK
sealed.z = 3;  // Silently fails

// Object.hasOwn - safer than hasOwnProperty
Object.hasOwn(obj, 'prop');  // Preferred
obj.hasOwnProperty('prop');  // Avoid (can be overridden)
```

## Error Handling Patterns

### Custom Errors

```javascript
// Extend Error class
class ValidationError extends Error {
  constructor(message, field) {
    super(message);
    this.name = 'ValidationError';
    this.field = field;
  }
}

class NetworkError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.name = 'NetworkError';
    this.statusCode = statusCode;
  }
}

// Usage
function validateUser(user) {
  if (!user.email) {
    throw new ValidationError('Email is required', 'email');
  }
  if (!user.age || user.age < 0) {
    throw new ValidationError('Valid age is required', 'age');
  }
}

// Catching specific errors
try {
  validateUser({email: ''});
} catch (error) {
  if (error instanceof ValidationError) {
    console.error(`Validation failed for ${error.field}: ${error.message}`);
  } else {
    throw error;
  }
}
```

### Error Wrapping

```javascript
// Wrap lower-level errors with context
async function processUser(userId) {
  try {
    const user = await fetchUser(userId);
    return await transformUser(user);
  } catch (error) {
    const wrapped = new Error(`Failed to process user ${userId}`);
    wrapped.cause = error;
    throw wrapped;
  }
}

// Using error cause (ES2022)
try {
  throw new Error('High-level error', {
    cause: new Error('Low-level cause'),
  });
} catch (error) {
  console.error(error.message);
  console.error(error.cause);
}
```

## Module Patterns

### Module Exports/Imports

```javascript
// Named exports (preferred)
export const PI = 3.14159;
export function square(x) {
  return x * x;
}
export class Calculator {}

// Or export together
const PI = 3.14159;
function square(x) { return x * x; }
class Calculator {}

export {PI, square, Calculator};

// Import specific items
import {PI, square} from './math.js';

// Import all as namespace
import * as math from './math.js';
math.square(5);

// Re-exporting
export {helper1, helper2} from './helpers.js';
export * from './utils.js';
```

### Dynamic Imports

```javascript
// Lazy loading modules
async function loadFeature() {
  const module = await import('./feature.js');
  module.initialize();
}

// Conditional loading
if (condition) {
  const {helper} = await import('./helper.js');
  helper();
}

// Dynamic import with error handling
try {
  const module = await import('./optional-feature.js');
  module.use();
} catch (error) {
  console.warn('Optional feature not available:', error);
}
```

### Module Patterns for Side Effects

```javascript
// Import for side effects only
import './polyfills.js';
import './global-styles.js';

// Initialize once pattern
let initialized = false;

export function initialize() {
  if (initialized) return;
  initialized = true;
  
  // Setup code
}

// Auto-initialize
initialize();
```

## Performance Considerations

### Avoid Unnecessary Computations

```javascript
// Memoization
function memoize(fn) {
  const cache = new Map();
  return function(...args) {
    const key = JSON.stringify(args);
    if (cache.has(key)) {
      return cache.get(key);
    }
    const result = fn.apply(this, args);
    cache.set(key, result);
    return result;
  };
}

const expensiveCalc = memoize((n) => {
  // Expensive computation
  return n * n;
});
```

### Debouncing and Throttling

```javascript
// Debounce - delay execution until quiet period
function debounce(func, wait) {
  let timeout;
  return function(...args) {
    clearTimeout(timeout);
    timeout = setTimeout(() => func.apply(this, args), wait);
  };
}

// Throttle - limit execution rate
function throttle(func, limit) {
  let inThrottle;
  return function(...args) {
    if (!inThrottle) {
      func.apply(this, args);
      inThrottle = true;
      setTimeout(() => inThrottle = false, limit);
    }
  };
}

// Usage
const debouncedSearch = debounce(searchFunction, 300);
const throttledScroll = throttle(handleScroll, 100);
```

## WeakMap and WeakSet

```javascript
// WeakMap - keys are weakly held (garbage collectable)
const privateData = new WeakMap();

class User {
  constructor(name) {
    privateData.set(this, {name});
  }
  
  getName() {
    return privateData.get(this).name;
  }
}

// WeakSet - values are weakly held
const visitedNodes = new WeakSet();

function processNode(node) {
  if (visitedNodes.has(node)) return;
  visitedNodes.add(node);
  // Process node
}
```
