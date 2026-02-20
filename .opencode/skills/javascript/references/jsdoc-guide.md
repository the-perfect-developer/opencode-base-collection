# JSDoc Guide

Complete guide to JSDoc annotations for JavaScript code based on Google JavaScript Style Guide.

## Table of Contents

- [Basic JSDoc Structure](#basic-jsdoc-structure)
- [Type Annotations](#type-annotations)
- [Function Documentation](#function-documentation)
- [Class Documentation](#class-documentation)
- [Property Documentation](#property-documentation)
- [Type Definitions](#type-definitions)
- [Advanced Annotations](#advanced-annotations)
- [Best Practices](#best-practices)

## Basic JSDoc Structure

### Standard Comment Format

```javascript
/**
 * Brief description of the function/class/method.
 * Can span multiple lines if needed.
 *
 * @param {type} paramName Description of parameter
 * @return {type} Description of return value
 */
```

### Rules

- Use `/** */` for JSDoc (not `/* */`)
- First line is brief description
- Blank line before tags
- Tags start with `@`
- Align tag descriptions

## Type Annotations

### Primitive Types

```javascript
/** @type {boolean} */
let flag;

/** @type {number} */
let count;

/** @type {string} */
let message;

/** @type {null} */
let empty;

/** @type {undefined} */
let notSet;
```

### Non-Nullable Types

Use `!` to indicate non-nullable:

```javascript
/** @type {!Object} */
let obj;  // Cannot be null

/** @type {!Array<string>} */
let names;  // Non-null array

/** @type {!MyClass} */
let instance;  // Non-null instance
```

### Nullable Types

Use `?` to allow null:

```javascript
/** @type {?string} */
let maybeString;  // Can be string or null

/** @type {?Array<number>} */
let maybeArray;  // Can be array or null
```

### Union Types

```javascript
/** @type {string|number} */
let id;  // Can be string or number

/** @type {!Array<string|number>} */
let mixed;  // Array of strings or numbers
```

### Arrays

```javascript
/** @type {Array<string>} */
let names;

/** @type {!Array<number>} */
let numbers;

/** @type {Array<!Object>} */
let objects;

// Alternative syntax
/** @type {string[]} */
let names2;

/** @type {number[]} */
let numbers2;
```

### Objects

```javascript
/** @type {Object} */
let anyObject;

/** @type {!Object} */
let nonNullObject;

/** @type {Object<string, number>} */
let stringToNumber;  // Keys are strings, values are numbers

// Specific structure
/** @type {{name: string, age: number}} */
let person;

/** @type {{name: string, age: number, email: (string|undefined)}} */
let user;  // email is optional
```

### Function Types

```javascript
/** @type {function(string): number} */
let converter;

/** @type {function(number, number): boolean} */
let comparator;

/** @type {function(): void} */
let callback;

/** @type {function(...number): number} */
let sum;  // Variadic function
```

### Generic Types

```javascript
/** @type {!Promise<string>} */
let asyncString;

/** @type {!Map<string, number>} */
let stringToNum;

/** @type {!Set<!Object>} */
let objectSet;
```

### Record Types

```javascript
// Inline record type
/** @type {{name: string, id: number}} */
let record;

// With optional properties
/** @type {{name: string, id: number, email: (string|undefined)}} */
let optionalRecord;

// Nested records
/**
 * @type {{
 *   user: {name: string, age: number},
 *   metadata: {created: number, updated: number}
 * }}
 */
let complex;
```

## Function Documentation

### Basic Function

```javascript
/**
 * Adds two numbers together.
 *
 * @param {number} a The first number
 * @param {number} b The second number
 * @return {number} The sum of a and b
 */
function add(a, b) {
  return a + b;
}
```

### Optional Parameters

```javascript
/**
 * Greets a user.
 *
 * @param {string} name The user's name
 * @param {string=} greeting Optional greeting (defaults to "Hello")
 * @return {string} The greeting message
 */
function greet(name, greeting = 'Hello') {
  return `${greeting}, ${name}`;
}
```

### Rest Parameters

```javascript
/**
 * Sums all provided numbers.
 *
 * @param {...number} numbers Numbers to sum
 * @return {number} The sum
 */
function sum(...numbers) {
  return numbers.reduce((a, b) => a + b, 0);
}
```

### Functions with Callbacks

```javascript
/**
 * Processes each item in an array.
 *
 * @param {!Array<T>} items The items to process
 * @param {function(T): void} callback Function to call for each item
 * @template T
 */
function forEach(items, callback) {
  for (const item of items) {
    callback(item);
  }
}
```

### Async Functions

```javascript
/**
 * Fetches user data from the server.
 *
 * @param {string} userId The user ID
 * @return {!Promise<!Object>} Promise resolving to user data
 * @throws {NetworkError} If the network request fails
 */
async function fetchUser(userId) {
  const response = await fetch(`/users/${userId}`);
  if (!response.ok) {
    throw new NetworkError('Failed to fetch user');
  }
  return await response.json();
}
```

### Function Overloads

```javascript
/**
 * Gets value by key or index.
 *
 * @param {string} key The property key
 * @return {*} The value
 */
/**
 * @param {number} index The array index
 * @return {*} The value
 */
function get(keyOrIndex) {
  // Implementation
}
```

## Class Documentation

### Basic Class

```javascript
/**
 * Represents a point in 2D space.
 */
class Point {
  /**
   * Creates a new Point.
   *
   * @param {number} x The x coordinate
   * @param {number} y The y coordinate
   */
  constructor(x, y) {
    /** @private @const {number} */
    this.x_ = x;
    
    /** @private @const {number} */
    this.y_ = y;
  }

  /**
   * Calculates distance from origin.
   *
   * @return {number} The distance
   */
  distanceFromOrigin() {
    return Math.sqrt(this.x_ * this.x_ + this.y_ * this.y_);
  }
}
```

### Inheritance

```javascript
/**
 * Base class for animals.
 */
class Animal {
  /**
   * @param {string} name The animal's name
   */
  constructor(name) {
    /** @protected {string} */
    this.name = name;
  }

  /**
   * Makes the animal speak.
   *
   * @return {string} The sound the animal makes
   */
  speak() {
    return '';
  }
}

/**
 * Represents a dog.
 *
 * @extends {Animal}
 */
class Dog extends Animal {
  /**
   * @param {string} name The dog's name
   * @param {string} breed The dog's breed
   */
  constructor(name, breed) {
    super(name);
    
    /** @private @const {string} */
    this.breed_ = breed;
  }

  /**
   * Makes the dog bark.
   *
   * @override
   * @return {string} The barking sound
   */
  speak() {
    return 'Woof!';
  }
}
```

### Generic Classes

```javascript
/**
 * A container for a value.
 *
 * @template T
 */
class Container {
  /**
   * @param {T} value The initial value
   */
  constructor(value) {
    /** @private {T} */
    this.value_ = value;
  }

  /**
   * Gets the contained value.
   *
   * @return {T} The value
   */
  getValue() {
    return this.value_;
  }

  /**
   * Sets a new value.
   *
   * @param {T} value The new value
   */
  setValue(value) {
    this.value_ = value;
  }
}

// Usage with type
/** @type {!Container<string>} */
const stringContainer = new Container('hello');
```

### Interfaces

```javascript
/**
 * Interface for objects that can be serialized.
 *
 * @interface
 */
class Serializable {
  /**
   * Converts to JSON.
   *
   * @return {string} JSON representation
   */
  toJSON() {}

  /**
   * Loads from JSON.
   *
   * @param {string} json JSON string
   */
  fromJSON(json) {}
}

/**
 * Implements Serializable.
 *
 * @implements {Serializable}
 */
class User {
  /** @override */
  toJSON() {
    return JSON.stringify(this);
  }

  /** @override */
  fromJSON(json) {
    Object.assign(this, JSON.parse(json));
  }
}
```

## Property Documentation

### Instance Properties

```javascript
class User {
  constructor(name, email) {
    /** @private @const {string} */
    this.name_ = name;
    
    /** @private {string} */
    this.email_ = email;
    
    /** @private {!Array<string>} */
    this.roles_ = [];
  }
}
```

### Static Properties

```javascript
class Config {
  /** @const {number} */
  static VERSION = 1;
  
  /** @const {string} */
  static API_URL = 'https://api.example.com';
}
```

### Getters and Setters

```javascript
class Temperature {
  constructor() {
    /** @private {number} */
    this.celsius_ = 0;
  }

  /**
   * Gets temperature in Celsius.
   *
   * @return {number} Temperature in Celsius
   */
  get celsius() {
    return this.celsius_;
  }

  /**
   * Sets temperature in Celsius.
   *
   * @param {number} value Temperature in Celsius
   */
  set celsius(value) {
    this.celsius_ = value;
  }

  /**
   * Gets temperature in Fahrenheit.
   *
   * @return {number} Temperature in Fahrenheit
   */
  get fahrenheit() {
    return this.celsius_ * 9/5 + 32;
  }

  /**
   * Sets temperature in Fahrenheit.
   *
   * @param {number} value Temperature in Fahrenheit
   */
  set fahrenheit(value) {
    this.celsius_ = (value - 32) * 5/9;
  }
}
```

## Type Definitions

### typedef

```javascript
/**
 * A user object.
 *
 * @typedef {{
 *   id: number,
 *   name: string,
 *   email: string,
 *   role: string,
 *   metadata: (!Object|undefined)
 * }}
 */
let UserType;

/**
 * Processes a user.
 *
 * @param {UserType} user The user to process
 */
function processUser(user) {
  // Implementation
}
```

### enum

```javascript
/**
 * Supported colors.
 *
 * @enum {string}
 */
const Color = {
  RED: 'red',
  GREEN: 'green',
  BLUE: 'blue',
};

/**
 * Sets the color.
 *
 * @param {Color} color The color to set
 */
function setColor(color) {
  // Implementation
}
```

### Complex Type Definitions

```javascript
/**
 * Configuration options.
 *
 * @typedef {{
 *   timeout: (number|undefined),
 *   retries: (number|undefined),
 *   headers: (!Object<string, string>|undefined),
 *   onSuccess: (function(!Object): void|undefined),
 *   onError: (function(!Error): void|undefined)
 * }}
 */
let RequestConfig;

/**
 * Makes an HTTP request.
 *
 * @param {string} url The URL
 * @param {RequestConfig=} config Optional configuration
 * @return {!Promise<!Object>} The response data
 */
async function request(url, config = {}) {
  // Implementation
}
```

## Advanced Annotations

### @template - Generics

```javascript
/**
 * Returns the first element of an array.
 *
 * @template T
 * @param {!Array<T>} array The array
 * @return {T|undefined} The first element or undefined
 */
function first(array) {
  return array[0];
}

/**
 * Maps an array to a new type.
 *
 * @template T, R
 * @param {!Array<T>} array The input array
 * @param {function(T): R} mapper The mapping function
 * @return {!Array<R>} The mapped array
 */
function map(array, mapper) {
  return array.map(mapper);
}
```

### @this - Context

```javascript
/**
 * Logs the object's name.
 *
 * @this {{name: string}}
 */
function logName() {
  console.log(this.name);
}
```

### @throws - Exceptions

```javascript
/**
 * Divides two numbers.
 *
 * @param {number} a The dividend
 * @param {number} b The divisor
 * @return {number} The quotient
 * @throws {Error} If b is zero
 */
function divide(a, b) {
  if (b === 0) {
    throw new Error('Division by zero');
  }
  return a / b;
}
```

### @deprecated

```javascript
/**
 * Old function that should not be used.
 *
 * @deprecated Use newFunction instead
 * @param {string} value The value
 */
function oldFunction(value) {
  // Legacy implementation
}
```

### @see - References

```javascript
/**
 * Processes user data.
 *
 * @param {UserType} user The user
 * @see fetchUser for retrieving user data
 * @see saveUser for persisting user data
 */
function processUser(user) {
  // Implementation
}
```

### @example

```javascript
/**
 * Formats a date string.
 *
 * @param {!Date} date The date to format
 * @param {string=} format The format string (default: 'YYYY-MM-DD')
 * @return {string} The formatted date
 * @example
 * formatDate(new Date('2024-01-15'))
 * // returns '2024-01-15'
 * @example
 * formatDate(new Date('2024-01-15'), 'MM/DD/YYYY')
 * // returns '01/15/2024'
 */
function formatDate(date, format = 'YYYY-MM-DD') {
  // Implementation
}
```

### Visibility Annotations

```javascript
/**
 * @private - Only accessible within the class
 * @protected - Accessible in class and subclasses
 * @package - Accessible within the same package/module
 * @public - Accessible everywhere (default)
 */

class Example {
  constructor() {
    /** @private {number} */
    this.privateField_ = 0;
    
    /** @protected {string} */
    this.protectedField = '';
    
    /** @public {boolean} */
    this.publicField = true;
  }

  /**
   * Private method.
   * @private
   */
  privateMethod_() {}

  /**
   * Protected method.
   * @protected
   */
  protectedMethod() {}

  /**
   * Public method.
   * @public
   */
  publicMethod() {}
}
```

### @const

```javascript
class Constants {
  constructor() {
    /** @const {number} */
    this.MAX_SIZE = 100;
    
    /** @private @const {string} */
    this.API_KEY_ = 'secret';
  }
}

/** @const {!Array<string>} */
const COLORS = ['red', 'green', 'blue'];
```

### @final

```javascript
/**
 * Base class that cannot be extended.
 *
 * @final
 */
class FinalClass {
  /**
   * Method that cannot be overridden.
   *
   * @final
   */
  finalMethod() {}
}
```

## Best Practices

### Do Document

**All public APIs**:
```javascript
/**
 * Public function that others will use.
 *
 * @param {string} input The input
 * @return {string} The output
 */
export function publicAPI(input) {
  return privateHelper(input);
}
```

**Complex private functions**:
```javascript
/**
 * Complex internal logic.
 *
 * @private
 * @param {!Array<number>} data The data
 * @return {number} The result
 */
function complexPrivateLogic_(data) {
  // Complex implementation
}
```

**All classes and methods**:
```javascript
/**
 * User management service.
 */
class UserService {
  /**
   * Fetches user by ID.
   *
   * @param {string} id User ID
   * @return {!Promise<!Object>} User data
   */
  async getUser(id) {}
}
```

### Don't Over-Document

**Obvious code**:
```javascript
// Bad - too obvious
/**
 * Sets the name.
 * @param {string} name The name
 */
setName(name) {
  this.name = name;
}

// Good - document only if not obvious
setName(name) {
  this.name = name;
}
```

**Implementation details** that may change:
```javascript
// Bad - documents how, not what
/**
 * Uses SHA-256 hashing algorithm to hash the password.
 */

// Good - documents what, not how
/**
 * Securely hashes a password.
 *
 * @param {string} password The password to hash
 * @return {string} The hashed password
 */
function hashPassword(password) {
  // Implementation may change
}
```

### Type Annotation Best Practices

**Be specific**:
```javascript
// Bad - too generic
/** @type {Object} */
let user;

// Good - specific structure
/** @type {{name: string, email: string}} */
let user;
```

**Use non-nullable when appropriate**:
```javascript
// Document that it cannot be null
/** @type {!Array<string>} */
let names;

/** @type {!Promise<!Object>} */
let userData;
```

**Template types need annotation**:
```javascript
// Bad - compiler infers unknown
const map = new Map();

// Good - explicit template types
/** @type {!Map<string, number>} */
const map = new Map();
```

### Ordering Tags

Standard order for JSDoc tags:
1. Description
2. `@template`
3. `@param`
4. `@return`
5. `@throws`
6. `@deprecated`
7. `@see`
8. `@example`

```javascript
/**
 * Description of the function.
 *
 * @template T
 * @param {T} input The input
 * @return {!Promise<T>} The result
 * @throws {ValidationError} If input is invalid
 * @deprecated Use newFunction instead
 * @see relatedFunction
 * @example
 * doSomething('test')
 */
```
