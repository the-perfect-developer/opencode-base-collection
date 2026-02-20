# Naming Conventions

Comprehensive naming rules for all JavaScript identifier types based on Google JavaScript Style Guide.

## Table of Contents

- [General Rules](#general-rules)
- [Package Names](#package-names)
- [Class Names](#class-names)
- [Method Names](#method-names)
- [Enum Names](#enum-names)
- [Constant Names](#constant-names)
- [Non-Constant Field Names](#non-constant-field-names)
- [Parameter Names](#parameter-names)
- [Local Variable Names](#local-variable-names)
- [Template Parameter Names](#template-parameter-names)
- [Module-Local Names](#module-local-names)
- [Special Cases](#special-cases)

## General Rules

### Character Set

Use ASCII letters, digits, and in limited cases, underscores and dollar signs.

### Descriptive Names

Choose names that clearly convey intent:

```javascript
// Good
const userCount = 10;
function calculateTotalPrice() {}

// Bad - unclear, too short
const n = 10;
function calc() {}
```

### Avoid Abbreviations

```javascript
// Good
const errorMessage = 'Invalid input';
const customerList = [];

// Bad - unclear abbreviations
const errMsg = 'Invalid input';
const custList = [];

// Exception: well-known abbreviations are OK
const htmlParser = new Parser();
const maxId = 100;
const userId = '123';
```

### No Hungarian Notation

Do not encode type information in names:

```javascript
// Bad
const strName = 'Alice';
const arrItems = [1, 2, 3];
const objUser = {name: 'Alice'};

// Good
const name = 'Alice';
const items = [1, 2, 3];
const user = {name: 'Alice'};
```

## Package Names

Package/module names use `lowerCamelCase`:

```javascript
// Good
goog.module('myProject.myPackage');
goog.module('search.urlHistory');
goog.module('analytics.eventTracker');

// Bad
goog.module('MyProject.MyPackage');
goog.module('my_project.my_package');
```

## Class Names

Use `UpperCamelCase` (also called `PascalCase`):

```javascript
// Good
class User {}
class PaymentProcessor {}
class HttpClient {}
class XMLParser {}

// Bad
class user {}
class paymentProcessor {}
class httpClient {}
```

### Interface Names

Interfaces also use `UpperCamelCase` (no `I` prefix):

```javascript
// Good
/** @interface */
class Serializable {}

/** @interface */
class EventHandler {}

// Bad
/** @interface */
class ISerializable {}  // Don't use I prefix
```

### Type Definition Names

```javascript
// Good
/** @typedef {{name: string, age: number}} */
let UserRecord;

/** @typedef {string|number} */
let Identifier;

// Bad
/** @typedef {{name: string, age: number}} */
let userRecord;
```

## Method Names

Use `lowerCamelCase`:

```javascript
class UserService {
  // Good
  getUser() {}
  createUser() {}
  validateEmail() {}
  
  // Bad
  GetUser() {}
  create_user() {}
}
```

### Private Methods

May optionally end with underscore:

```javascript
class DataProcessor {
  processData() {
    return this.validateData_();
  }
  
  /** @private */
  validateData_() {
    // Private implementation
  }
}
```

### Verb Prefixes

Use clear verb prefixes:

```javascript
class UserRepository {
  // Retrieval - use get/find/fetch
  getUser(id) {}
  findUserByEmail(email) {}
  fetchActiveUsers() {}
  
  // Boolean checks - use is/has/can/should
  isValid() {}
  hasPermission() {}
  canEdit() {}
  shouldUpdate() {}
  
  // Creation - use create/build/make
  createUser(data) {}
  buildQuery() {}
  makeRequest() {}
  
  // Updates - use update/set/change
  updateUser(id, data) {}
  setStatus(status) {}
  changePassword(password) {}
  
  // Deletion - use delete/remove/clear
  deleteUser(id) {}
  removeFromCache() {}
  clearData() {}
  
  // Computation - use calculate/compute/process
  calculateTotal() {}
  computeHash() {}
  processResults() {}
}
```

## Enum Names

Enum types use `UpperCamelCase`. Enum values use `CONSTANT_CASE`:

```javascript
// Good
/**
 * @enum {string}
 */
const UserRole = {
  ADMIN: 'admin',
  EDITOR: 'editor',
  VIEWER: 'viewer',
};

/**
 * @enum {number}
 */
const HttpStatus = {
  OK: 200,
  NOT_FOUND: 404,
  INTERNAL_ERROR: 500,
};

// Bad
/**
 * @enum {string}
 */
const userRole = {
  admin: 'admin',
  Editor: 'editor',
};
```

## Constant Names

Use `CONSTANT_CASE` (all uppercase with underscores):

```javascript
// Module-level constants
const MAX_COUNT = 100;
const API_BASE_URL = 'https://api.example.com';
const DEFAULT_TIMEOUT_MS = 5000;

// Class constants
class Config {
  static DEFAULT_PORT = 8080;
  static MAX_RETRIES = 3;
}
```

### What Qualifies as a Constant

Must be deeply immutable:

```javascript
// These are constants
const NUMBER = 5;
const NAMES = Object.freeze(['Alice', 'Bob']);
const MAPPING = Object.freeze({a: 1, b: 2});

// These are NOT constants (mutable)
const names = ['Alice', 'Bob'];  // Array is mutable
const config = {port: 8080};  // Object is mutable
const user = Object.freeze({name: 'Alice'});  // Not constant (not global/static)
```

Use `lowerCamelCase` for non-constants:

```javascript
// Good - not truly constant
const defaultConfig = {port: 8080, host: 'localhost'};
const importantValues = [1, 2, 3];

// Bad - using CONSTANT_CASE for mutable values
const DEFAULT_CONFIG = {port: 8080};
const IMPORTANT_VALUES = [1, 2, 3];
```

## Non-Constant Field Names

Use `lowerCamelCase`:

```javascript
class User {
  constructor() {
    this.firstName = '';
    this.lastName = '';
    this.emailAddress = '';
  }
}
```

### Private Fields

May optionally end with underscore:

```javascript
class User {
  constructor() {
    /** @private */
    this.firstName_ = '';
    
    /** @private */
    this.internalId_ = 0;
  }
}
```

### Constant Fields

Use `CONSTANT_CASE` for deeply immutable static fields:

```javascript
class Timeouts {
  static DEFAULT_MS = 1000;
  static MAX_MS = 5000;
}
```

## Parameter Names

Use `lowerCamelCase`:

```javascript
// Good
function createUser(firstName, lastName, emailAddress) {}

function processData(inputArray, shouldValidate, maxRetries) {}

// Bad
function CreateUser(FirstName, last_name, EMAIL_ADDRESS) {}
```

### Unused Parameters

Prefix with underscore or use clear name:

```javascript
// Good - underscore prefix
function onClick(_event) {
  console.log('clicked');
}

// Good - descriptive unused name
function map(array, _index, callback) {
  return array.map(callback);
}

// Good - omit if trailing
function process(data) {
  // originalIndex parameter removed
}
```

### Destructured Parameters

```javascript
// Good - clear names
function updateUser({userId, firstName, lastName, email}) {}

function configure({timeout = 5000, retries = 3, debug = false}) {}

// Still use lowerCamelCase
function processData({inputData, shouldValidate, maxItems}) {}
```

## Local Variable Names

Use `lowerCamelCase`:

```javascript
function processUsers() {
  const activeUsers = getActiveUsers();
  const userCount = activeUsers.length;
  let processedCount = 0;
  
  for (const currentUser of activeUsers) {
    const isValid = validate(currentUser);
    if (isValid) {
      processedCount++;
    }
  }
  
  return processedCount;
}
```

### Loop Variables

```javascript
// Good - descriptive
for (const user of users) {}
for (const item of items) {}
for (const [key, value] of Object.entries(obj)) {}

// Acceptable for simple numeric loops
for (let i = 0; i < array.length; i++) {}
for (let j = 0; j < matrix[i].length; j++) {}

// Good - index variables
for (const [index, item] of items.entries()) {}
```

### Temporary Variables

Even temporary variables should be descriptive:

```javascript
// Good
const temp = array[i];
array[i] = array[j];
array[j] = temp;

const previousValue = this.value;
this.value = newValue;
return previousValue;

// Bad - unclear
const x = array[i];
array[i] = array[j];
array[j] = x;
```

## Template Parameter Names

Use single uppercase letter or `UpperCamelCase`:

```javascript
// Single letter (most common)
/**
 * @template T
 * @param {T} value
 * @return {T}
 */
function identity(value) {
  return value;
}

/**
 * @template K, V
 */
class HashMap {}

// UpperCamelCase for clarity
/**
 * @template Key, Value
 */
class TypedMap {}

/**
 * @template RequestType, ResponseType
 * @param {RequestType} request
 * @return {ResponseType}
 */
function process(request) {}

// Common conventions
/**
 * @template T - Type
 * @template K - Key
 * @template V - Value
 * @template E - Element
 * @template R - Result/Return
 */
```

## Module-Local Names

Private module-level names may end with underscore:

```javascript
// Module: user-service.js

// Private helper (underscore optional but allowed)
function validateEmail_(email) {
  return /\S+@\S+\.\S+/.test(email);
}

// Private constant
const API_KEY_ = 'secret';

// Public exports (no underscore)
export function createUser(data) {
  if (!validateEmail_(data.email)) {
    throw new Error('Invalid email');
  }
  // ...
}
```

## Special Cases

### Acronyms in Names

Treat acronyms as words:

```javascript
// Good
class XmlHttpRequest {}
class HtmlParser {}
class UrlBuilder {}
const userId = '123';
const apiKey = 'secret';

// Bad
class XMLHTTPRequest {}
class HTMLParser {}
class URLBuilder {}
const userID = '123';
const APIKey = 'secret';

// Exception: When acronym is at start of CONSTANT_CASE
const URL_PATTERN = /^https?:\/\//;
const API_BASE_URL = 'https://api.example.com';
```

### Dollar Sign

Avoid `$` except for specific cases:

```javascript
// Acceptable - popular library convention
import $ from 'jquery';
const $element = $('.my-class');

// Acceptable - generated code
const name$0 = 'value';

// Avoid otherwise
const my$Variable = 'bad';  // Bad
```

### Numbers in Names

Allowed but use sparingly:

```javascript
// Good - when number is meaningful
const base64Encoder = new Encoder();
const md5Hash = computeHash();
const ipv4Address = '192.168.1.1';

// Avoid - unclear meaning
const value2 = compute();
const temp3 = process();

// Exception: generated code
const value$1 = 'ok';
```

### Boolean Variables

Prefix with question words:

```javascript
// Good
const isValid = true;
const hasPermission = false;
const canEdit = true;
const shouldUpdate = false;
const willRetry = true;

// Bad
const valid = true;
const permission = false;
const editable = true;
```

### Collections

Use plural or collective nouns:

```javascript
// Good
const users = [];
const itemList = [];
const nameSet = new Set();
const userMap = new Map();
const fileCollection = [];

// Bad
const user = [];  // Misleading - plural expected
const item_array = [];
```

### Callbacks and Handlers

Use clear prefixes:

```javascript
// Event handlers - use 'handle' or 'on'
function handleClick(event) {}
function onClick(event) {}
function handleSubmit(event) {}

// Callbacks - use descriptive name or 'callback'
function processAsync(data, onComplete) {}
function fetchUser(id, callback) {}
function load(successCallback, errorCallback) {}
```

### Factory Functions

```javascript
// Use 'create' or 'make' prefix
function createUser(data) {
  return new User(data);
}

function makeRequest(config) {
  return new Request(config);
}

// Or describe what's created
function userFromJson(json) {
  return new User(JSON.parse(json));
}
```

### Predicates

Functions returning boolean use question prefixes:

```javascript
// Good
function isValid(value) {}
function hasPermission(user, resource) {}
function canAccess(user, resource) {}
function shouldRetry(attempt) {}

// Bad
function valid(value) {}  // Unclear if boolean
function checkPermission(user) {}  // Sounds like void function
```

## Common Patterns

### Getters and Setters

```javascript
class User {
  constructor() {
    this.name_ = '';
  }
  
  // Getter - use 'get' prefix or property name
  getName() {
    return this.name_;
  }
  
  // Or ES6 getter
  get name() {
    return this.name_;
  }
  
  // Setter - use 'set' prefix
  setName(name) {
    this.name_ = name;
  }
  
  // Or ES6 setter
  set name(name) {
    this.name_ = name;
  }
}
```

### Builder Pattern

```javascript
class RequestBuilder {
  constructor() {
    this.config_ = {};
  }
  
  // Methods return 'this' for chaining
  withTimeout(timeout) {
    this.config_.timeout = timeout;
    return this;
  }
  
  withRetries(retries) {
    this.config_.retries = retries;
    return this;
  }
  
  build() {
    return new Request(this.config_);
  }
}

// Usage
const request = new RequestBuilder()
  .withTimeout(5000)
  .withRetries(3)
  .build();
```

### Async Function Names

No special prefix needed:

```javascript
// Good - no 'async' in name
async function fetchUser(id) {}
async function saveData(data) {}

// Bad - redundant
async function asyncFetchUser(id) {}
async function getUserAsync(id) {}
```

## Quick Reference

| Type | Convention | Example |
|------|-----------|---------|
| Package/Module | lowerCamelCase | `myPackage`, `userService` |
| Class | UpperCamelCase | `UserService`, `HttpClient` |
| Interface | UpperCamelCase | `Serializable`, `EventHandler` |
| Method | lowerCamelCase | `getValue`, `processData` |
| Enum type | UpperCamelCase | `UserRole`, `HttpStatus` |
| Enum value | CONSTANT_CASE | `ADMIN`, `NOT_FOUND` |
| Constant | CONSTANT_CASE | `MAX_COUNT`, `API_URL` |
| Field | lowerCamelCase | `firstName`, `emailAddress` |
| Private field | lowerCamelCase_ | `firstName_`, `userId_` |
| Parameter | lowerCamelCase | `userId`, `maxRetries` |
| Local variable | lowerCamelCase | `userCount`, `isValid` |
| Template param | T or UpperCamelCase | `T`, `K`, `V`, `ResponseType` |

### Prefix Conventions

| Prefix | Use | Example |
|--------|-----|---------|
| get/find/fetch | Retrieval | `getUser`, `findById`, `fetchData` |
| is/has/can/should | Boolean check | `isValid`, `hasPermission`, `canEdit` |
| create/make/build | Creation | `createUser`, `makeRequest`, `buildQuery` |
| update/set/change | Mutation | `updateUser`, `setStatus`, `changePassword` |
| delete/remove/clear | Deletion | `deleteUser`, `removeItem`, `clearCache` |
| calculate/compute | Calculation | `calculateTotal`, `computeHash` |
| handle/on | Event handler | `handleClick`, `onClick`, `onSubmit` |
