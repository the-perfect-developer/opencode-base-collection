# Disallowed Features

Features to avoid in JavaScript and their recommended alternatives based on Google JavaScript Style Guide.

## Table of Contents

- [with Statement](#with-statement)
- [eval and Related](#eval-and-related)
- [Automatic Semicolon Insertion](#automatic-semicolon-insertion)
- [Wrapper Objects for Primitives](#wrapper-objects-for-primitives)
- [Modifying Built-in Prototypes](#modifying-built-in-prototypes)
- [for-in Loops](#for-in-loops)
- [== and != Operators](#-and--operators)
- [var Keyword](#var-keyword)
- [Default Exports](#default-exports)
- [Variadic Array Constructor](#variadic-array-constructor)
- [Object Constructor](#object-constructor)
- [Legacy Closure Features](#legacy-closure-features)
- [Other Deprecated Features](#other-deprecated-features)

## with Statement

### Don't Use

```javascript
// Bad - never use 'with'
with (object) {
  property = value;
  method();
}
```

### Use Instead

```javascript
// Good - be explicit
object.property = value;
object.method();

// Or use destructuring
const {property, method} = object;
property = value;
method();
```

**Why**: `with` makes code ambiguous and is forbidden in strict mode.

## eval and Related

### Don't Use

```javascript
// Bad - eval executes arbitrary code
eval('const x = 10');
eval('doSomething()');

// Bad - Function constructor
const fn = new Function('a', 'b', 'return a + b');

// Bad - setTimeout/setInterval with string
setTimeout('doSomething()', 1000);
setInterval('update()', 100);
```

### Use Instead

```javascript
// Good - direct code execution
const x = 10;
doSomething();

// Good - function declaration
function fn(a, b) {
  return a + b;
}

// Good - function references
setTimeout(doSomething, 1000);
setTimeout(() => doSomething(), 1000);
setInterval(update, 100);

// Exception: JSON parsing (use JSON.parse instead)
// Bad
const obj = eval('(' + jsonString + ')');

// Good
const obj = JSON.parse(jsonString);
```

**Why**: Security risks, performance issues, and prevents optimizations.

## Automatic Semicolon Insertion

### Don't Rely On

```javascript
// Bad - relying on ASI
function getValue() {
  return
    {
      value: 10
    }
}  // Returns undefined!

const x = y
[0].toString()  // Executes y[0].toString()

// Bad - missing semicolons
const a = 1
const b = 2
doSomething()
```

### Always Use Semicolons

```javascript
// Good - explicit semicolons
function getValue() {
  return {
    value: 10,
  };
}

const x = y;
[0].toString();

const a = 1;
const b = 2;
doSomething();
```

**Why**: ASI has subtle rules that can cause bugs.

## Wrapper Objects for Primitives

### Don't Use

```javascript
// Bad - primitive wrapper objects
const stringObject = new String('hello');
const numberObject = new Number(42);
const booleanObject = new Boolean(true);

// These behave unexpectedly
if (new Boolean(false)) {
  // This runs! Boolean object is truthy even if value is false
}

typeof new String('hello');  // 'object', not 'string'
```

### Use Instead

```javascript
// Good - use primitives directly
const string = 'hello';
const number = 42;
const boolean = true;

// Good - use for type conversion
const string = String(value);  // Without 'new'
const number = Number(value);
const boolean = Boolean(value);
```

**Why**: Wrapper objects are confusing and almost never needed.

## Modifying Built-in Prototypes

### Don't Modify

```javascript
// Bad - never modify built-in prototypes
Array.prototype.myMethod = function() {
  // Custom logic
};

String.prototype.capitalize = function() {
  return this.charAt(0).toUpperCase() + this.slice(1);
};

Object.prototype.customProp = 'value';
```

### Use Instead

```javascript
// Good - create utility functions
function myArrayMethod(array) {
  // Custom logic
}

function capitalize(string) {
  return string.charAt(0).toUpperCase() + string.slice(1);
}

// Good - extend in your own classes
class MyArray extends Array {
  myMethod() {
    // Custom logic
  }
}
```

**Why**: Pollutes global namespace, breaks other code, causes compatibility issues.

## for-in Loops

### Don't Use for Arrays

```javascript
// Bad - for-in on arrays
const array = [1, 2, 3];
for (const index in array) {
  console.log(array[index]);
}

// Problems:
// - Iterates over all enumerable properties, not just indices
// - Index is a string, not a number
// - Order is not guaranteed
```

### Use Instead

```javascript
// Good - for-of for iterating values
const array = [1, 2, 3];
for (const value of array) {
  console.log(value);
}

// Good - forEach
array.forEach((value, index) => {
  console.log(value, index);
});

// Good - traditional for loop when index needed
for (let i = 0; i < array.length; i++) {
  console.log(array[i], i);
}

// Good - for-of with entries
for (const [index, value] of array.entries()) {
  console.log(value, index);
}
```

### For Objects, Use with Care

```javascript
// Use for-in with hasOwnProperty check
const obj = {a: 1, b: 2, c: 3};

// Acceptable but check for own properties
for (const key in obj) {
  if (obj.hasOwnProperty(key)) {  // Or Object.hasOwn(obj, key)
    console.log(key, obj[key]);
  }
}

// Better - use Object methods
for (const key of Object.keys(obj)) {
  console.log(key, obj[key]);
}

for (const value of Object.values(obj)) {
  console.log(value);
}

for (const [key, value] of Object.entries(obj)) {
  console.log(key, value);
}
```

**Why**: for-in iterates over inherited properties and is error-prone with arrays.

## == and != Operators

### Don't Use

```javascript
// Bad - loose equality is confusing
if (value == null) {}
if (count != 0) {}
if (name == 'Alice') {}

// Unexpected behavior
0 == '';  // true
0 == '0';  // true
false == 'false';  // false
null == undefined;  // true
```

### Use Instead

```javascript
// Good - strict equality
if (value === null) {}
if (count !== 0) {}
if (name === 'Alice') {}

// Good - check for null or undefined
if (value == null) {}  // Exception: this is OK for null/undefined check
if (value != null) {}  // Exception: this is OK too

// Better - be explicit
if (value === null || value === undefined) {}
if (value !== null && value !== undefined) {}

// Modern - use nullish coalescing
const result = value ?? defaultValue;
```

**Why**: Loose equality has confusing type coercion rules.

## var Keyword

### Don't Use

```javascript
// Bad - var has confusing scoping
var count = 0;

for (var i = 0; i < 10; i++) {
  var temp = i * 2;
}
console.log(i);  // 10 - var leaks out of loop!
console.log(temp);  // 18 - var leaks out of loop!

// Bad - hoisting is confusing
console.log(x);  // undefined, not error
var x = 10;

// Bad - can redeclare
var name = 'Alice';
var name = 'Bob';  // No error
```

### Use Instead

```javascript
// Good - const by default
const count = 0;

// Good - let when reassignment needed
for (let i = 0; i < 10; i++) {
  const temp = i * 2;
}
// console.log(i);  // Error - i is not defined
// console.log(temp);  // Error - temp is not defined

// Good - const/let are not hoisted
// console.log(x);  // Error - cannot access before initialization
const x = 10;

// Good - cannot redeclare
const name = 'Alice';
// const name = 'Bob';  // Error - cannot redeclare
```

**Why**: `var` has function scope (not block scope), is hoisted, and allows redeclaration.

## Default Exports

### Don't Use

```javascript
// Bad - default export
export default class User {}

// Bad - default export of object
export default {
  name: 'MyModule',
  version: '1.0',
};

// Bad - default export of function
export default function process(data) {}
```

### Use Instead

```javascript
// Good - named exports
export class User {}

export const config = {
  name: 'MyModule',
  version: '1.0',
};

export function process(data) {}

// Or export together
class User {}
const config = {};
function process(data) {}

export {User, config, process};
```

**Why**: Named exports are more consistent, easier to refactor, and better for static analysis.

## Variadic Array Constructor

### Don't Use

```javascript
// Bad - Array constructor with arguments
const a1 = new Array(x1, x2, x3);
const a2 = new Array(x1, x2);
const a3 = new Array(x1);  // If x1 is number, creates array of that length!

// Confusing behavior
new Array(3);  // [empty × 3]
new Array(3.14);  // Error!
new Array('3');  // ['3']
```

### Use Instead

```javascript
// Good - array literal
const a1 = [x1, x2, x3];
const a2 = [x1, x2];
const a3 = [x1];

// Exception: preallocating array of specific length is OK
const empty = new Array(100);  // OK for preallocation
const filled = new Array(100).fill(0);  // OK
```

**Why**: Constructor behavior is confusing and error-prone.

## Object Constructor

### Don't Use

```javascript
// Bad - Object constructor
const obj = new Object();
obj.name = 'Alice';
obj.age = 30;

// Bad - with arguments (rarely used correctly)
const copy = new Object(original);
```

### Use Instead

```javascript
// Good - object literal
const obj = {
  name: 'Alice',
  age: 30,
};

// Good - for copying
const copy = {...original};
const copy2 = Object.assign({}, original);
```

**Why**: Object literal is clearer and more concise.

## Legacy Closure Features

### Don't Use goog.module.declareLegacyNamespace

```javascript
// Avoid when possible
goog.module('my.module');
goog.module.declareLegacyNamespace();
```

### Use Instead

```javascript
// Prefer standard goog.module
goog.module('my.module');

// Or migrate to ES modules
export class MyClass {}
```

### Don't Use goog.provide/goog.require

```javascript
// Old style - avoid
goog.provide('my.namespace.MyClass');
goog.require('other.namespace.Dependency');
```

### Use Instead

```javascript
// Modern - use goog.module
goog.module('my.namespace.MyClass');
const Dependency = goog.require('other.namespace.Dependency');

// Or use ES modules
import {Dependency} from './dependency.js';
```

## Other Deprecated Features

### arguments Object

```javascript
// Bad - arguments is array-like but not an array
function sum() {
  let total = 0;
  for (let i = 0; i < arguments.length; i++) {
    total += arguments[i];
  }
  return total;
}

// Bad - converting arguments to array
function process() {
  const args = Array.prototype.slice.call(arguments);
}
```

**Use rest parameters**:

```javascript
// Good - rest parameters
function sum(...numbers) {
  return numbers.reduce((a, b) => a + b, 0);
}

function process(...args) {
  // args is a real array
  args.forEach(arg => console.log(arg));
}
```

### Getters/Setters with Side Effects

```javascript
// Bad - getter with side effects
class User {
  get fullName() {
    this.nameAccessCount++;  // Side effect!
    return `${this.first} ${this.last}`;
  }
}

// Bad - getter that does expensive work
class Data {
  get processedData() {
    return this.expensiveProcessing();  // Computed every access!
  }
}
```

**Use methods instead**:

```javascript
// Good - method for side effects
class User {
  getFullName() {
    this.nameAccessCount++;
    return `${this.first} ${this.last}`;
  }
}

// Good - cache expensive computations
class Data {
  getProcessedData() {
    if (!this.cachedData_) {
      this.cachedData_ = this.expensiveProcessing();
    }
    return this.cachedData_;
  }
}
```

### Deleting Properties

```javascript
// Avoid - delete is slow
const obj = {a: 1, b: 2, c: 3};
delete obj.b;

// Better - set to undefined
obj.b = undefined;

// Best - restructure to avoid deletion
const {b, ...rest} = obj;  // rest is {a: 1, c: 3}

// Or use Map if properties change frequently
const map = new Map([['a', 1], ['b', 2], ['c', 3]]);
map.delete('b');  // Efficient
```

### Comparing with NaN

```javascript
// Bad - NaN comparisons always false
const value = 0 / 0;
if (value === NaN) {}  // Never true
if (value == NaN) {}  // Never true
```

**Use Number.isNaN**:

```javascript
// Good - proper NaN check
if (Number.isNaN(value)) {}

// Avoid - global isNaN coerces to number first
if (isNaN(value)) {}  // Also true for non-numbers
if (isNaN('hello')) {}  // true, but 'hello' is not NaN
```

### Sparse Arrays

```javascript
// Avoid - sparse arrays
const sparse = [1, , 3, , 5];  // Has holes
const sparse2 = new Array(10);  // All holes

// Problems
sparse.forEach(x => console.log(x));  // Skips holes
sparse.map(x => x * 2);  // [2, empty, 6, empty, 10]
```

**Use filled arrays**:

```javascript
// Good - no holes
const filled = [1, undefined, 3, undefined, 5];
const zeros = new Array(10).fill(0);
const range = Array.from({length: 10}, (_, i) => i);
```

### Type Coercion in Conditions

```javascript
// Avoid implicit coercion
if (array.length) {}  // Relies on 0 being falsy
if (string) {}  // Relies on '' being falsy
if (value) {}  // What exactly are you checking?
```

**Be explicit**:

```javascript
// Good - explicit checks
if (array.length > 0) {}
if (string !== '') {}
if (value !== null && value !== undefined) {}
if (value != null) {}  // OK for null/undefined check
```

### Constructor Without new

```javascript
// Bad - forgetting 'new'
function Person(name) {
  this.name = name;
}
const person = Person('Alice');  // Oops! Returns undefined

// Bad - relying on constructor check
function Person(name) {
  if (!(this instanceof Person)) {
    return new Person(name);
  }
  this.name = name;
}
```

**Use classes**:

```javascript
// Good - classes require 'new'
class Person {
  constructor(name) {
    this.name = name;
  }
}
const person = new Person('Alice');
// const person = Person('Alice');  // Error: Class constructor cannot be invoked without 'new'
```

## Quick Reference - Don't Use

| Feature | Instead Use |
|---------|-------------|
| `with` | Explicit property access or destructuring |
| `eval()` | Direct code, `JSON.parse()`, or functions |
| `new String/Number/Boolean` | Primitives, type conversion without `new` |
| Modifying prototypes | Utility functions or custom classes |
| `for-in` on arrays | `for-of`, `forEach`, or traditional `for` |
| `==` and `!=` | `===` and `!==` (except `== null`) |
| `var` | `const` and `let` |
| Default exports | Named exports |
| `new Array(x, y, z)` | Array literals `[x, y, z]` |
| `new Object()` | Object literals `{}` |
| `arguments` | Rest parameters `...args` |
| `delete obj.prop` | Set to `undefined` or restructure |
| `value === NaN` | `Number.isNaN(value)` |

## Migration Notes

When updating legacy code:

1. Replace `var` with `const`/`let`
2. Add semicolons explicitly
3. Replace `==` with `===`
4. Convert `for-in` loops to `for-of` or array methods
5. Remove `goog.provide` in favor of `goog.module` or ES modules
6. Replace default exports with named exports
7. Use rest parameters instead of `arguments`
8. Use `Number.isNaN()` instead of `=== NaN`
