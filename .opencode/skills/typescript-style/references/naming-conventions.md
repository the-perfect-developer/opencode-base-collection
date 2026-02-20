# Naming Conventions

Complete naming rules and conventions for TypeScript code following Google's style guide.

## Table of Contents

- [General Rules](#general-rules)
- [Identifiers](#identifiers)
- [File Names](#file-names)
- [Type Parameters](#type-parameters)
- [Abbreviations](#abbreviations)
- [Dollar Sign](#dollar-sign)

## General Rules

### Use Descriptive Names

Choose clear, descriptive names that communicate intent:

```typescript
// Good: clear names
const userCount = users.length;
function calculateTotalPrice(items: Item[]): number { }
class UserRepository { }

// Bad: unclear abbreviations
const uc = users.length;
function calc(i: Item[]): number { }
class UR { }
```

### Avoid Meaningless Names

Don't use generic names that don't add information:

```typescript
// Bad
let data: any;
function process(info: any) { }
class Manager { }

// Good
let userData: User[];
function processUserRegistration(user: User) { }
class UserService { }
```

## Identifiers

### Classes, Interfaces, Types, Enums

Use `UpperCamelCase` (also called PascalCase):

```typescript
// Good
class HttpClient { }
interface UserData { }
type ResponseStatus = 'success' | 'error';
enum Color { RED, GREEN, BLUE }

// Bad
class httpClient { }
interface user_data { }
type response_status = 'success' | 'error';
enum color { red, green, blue }
```

### Methods and Functions

Use `lowerCamelCase`:

```typescript
// Good
function getUserById(id: string): User { }
function calculateTotalPrice(): number { }

class MyClass {
  getValue(): string { }
  processData(): void { }
}

// Bad
function GetUserById(id: string): User { }
function calculate_total_price(): number { }

class MyClass {
  GetValue(): string { }
  process_data(): void { }
}
```

### Properties and Variables

Use `lowerCamelCase`:

```typescript
// Good
const userName = 'Alice';
let itemCount = 0;

class User {
  firstName: string;
  emailAddress: string;
}

// Bad
const UserName = 'Alice';
let item_count = 0;

class User {
  FirstName: string;
  email_address: string;
}
```

### Constants

Use `CONSTANT_CASE` for true constants (values known at compile time):

```typescript
// Good: compile-time constants
const MAX_COUNT = 100;
const API_BASE_URL = 'https://api.example.com';
const DEFAULT_TIMEOUT_MS = 5000;

enum Status {
  ACTIVE = 'active',
  INACTIVE = 'inactive',
}

// Bad: runtime values
const userId = getUserId();  // Should be const userId
const MAX_VALUE = Math.random() * 100;  // Should be const maxValue
```

**Important**: Only use `CONSTANT_CASE` for truly immutable compile-time constants. Don't use it for:
- Function return values
- Objects that could be mutated
- Values computed at runtime

```typescript
// Good: lowerCamelCase for runtime values
const config = loadConfig();
const timestamp = Date.now();
const defaultOptions = {timeout: 1000};

// Bad: CONSTANT_CASE for runtime values
const CONFIG = loadConfig();
const TIMESTAMP = Date.now();
```

### Private Properties

Use `private` modifier and regular `lowerCamelCase`. Do not use underscore prefixes:

```typescript
// Good
class MyClass {
  private internalState = 0;
  private helperMethod() { }
}

// Bad: underscore prefix
class MyClass {
  private _internalState = 0;
  private _helperMethod() { }
}
```

**Note**: This differs from some other style guides that use underscores. Google's TypeScript style relies on the `private` keyword.

### Protected Properties

Use `protected` modifier with regular `lowerCamelCase`:

```typescript
// Good
class BaseClass {
  protected sharedState = 0;
  protected helperMethod() { }
}
```

## File Names

### Use Lowercase with Dashes

Name files in lowercase with dashes separating words:

```typescript
// Good
user-service.ts
http-client.ts
data-utils.ts

// Bad
UserService.ts
httpClient.ts
data_utils.ts
```

### Match Primary Export

When a file exports a single class/interface/function, match the file name:

```typescript
// user-service.ts
export class UserService { }

// http-client.ts
export class HttpClient { }

// parse-json.ts
export function parseJson(input: string) { }
```

### Declaration Files

Use `.d.ts` extension for declaration files:

```typescript
// Good
types.d.ts
globals.d.ts
```

### Test Files

Suffix test files with `.test.ts` or `.spec.ts`:

```typescript
// Good
user-service.test.ts
http-client.spec.ts

// Bad
user-service-test.ts
test-http-client.ts
```

## Type Parameters

### Single Letter

Use single uppercase letters for simple generic type parameters:

```typescript
// Good: single letter generics
function identity<T>(arg: T): T {
  return arg;
}

function map<T, U>(items: T[], fn: (item: T) => U): U[] {
  return items.map(fn);
}

interface KeyValuePair<K, V> {
  key: K;
  value: V;
}
```

Common conventions:
- `T` - Type
- `K` - Key
- `V` - Value
- `E` - Element
- `R` - Result/Return

### UpperCamelCase for Complex Types

Use `UpperCamelCase` when the type parameter needs to be more descriptive:

```typescript
// Good: descriptive type parameter
function merge<BaseType, ExtensionType>(
  base: BaseType,
  extension: ExtensionType
): BaseType & ExtensionType {
  return {...base, ...extension};
}

interface Repository<EntityType> {
  get(id: string): EntityType;
  save(entity: EntityType): void;
}
```

### Constraints in Name

When heavily constrained, consider descriptive names:

```typescript
// Good: descriptive constrained type
interface Serializable {
  serialize(): string;
}

function save<SerializableType extends Serializable>(
  item: SerializableType
): void {
  const data = item.serialize();
  // Save data
}
```

## Abbreviations

### Treat Abbreviations as Words

When using abbreviations in camelCase, treat them as words:

```typescript
// Good: abbreviations as words
class XmlHttpRequest { }
function loadHtmlContent(): string { }
const userId = '123';
const apiKey = 'abc';

// Bad: all caps abbreviations
class XMLHTTPRequest { }
function loadHTMLContent(): string { }
const userID = '123';
const APIKey = 'abc';
```

**Exception**: When the abbreviation is the entire name, use all caps:

```typescript
// Good: abbreviation is entire name
const URL = 'https://example.com';
const ID = '123';
const API = createApi();
```

### Common Abbreviations

Treat these as single words:

- `Html` not `HTML`
- `Url` not `URL`
- `Api` not `API`
- `Json` not `JSON`
- `Xml` not `XML`
- `Http` not `HTTP`
- `Id` not `ID`

```typescript
// Good
parseJsonData();
fetchApiResponse();
const xmlParser = new XmlParser();
const httpClient = new HttpClient();
const userId = user.id;

// Bad
parseJSONData();
fetchAPIResponse();
const XMLParser = new XMLParser();
const HTTPClient = new HTTPClient();
const userID = user.id;
```

## Dollar Sign

### Avoid Dollar Sign

Do not use `$` in names except for specific framework requirements (like Angular observables):

```typescript
// Bad: unnecessary dollar sign
const user$ = getUser();
function $parse(input: string) { }

// Acceptable: Angular observable convention
import {Observable} from 'rxjs';
const user$: Observable<User> = this.http.get('/user');
```

### jQuery/RxJS Exceptions

If using jQuery or RxJS, `$` may be used following those conventions:

```typescript
// Acceptable: jQuery convention
const $element = $('.my-class');

// Acceptable: RxJS observable convention  
const clicks$: Observable<MouseEvent> = fromEvent(button, 'click');
```

## Naming by Category

### Services/Managers/Controllers

Suffix with descriptive noun:

```typescript
// Good
class UserService { }
class AuthenticationManager { }
class PaymentController { }

// Bad: generic suffixes
class UserHelper { }
class UserUtil { }
class UserClass { }
```

### Interfaces for Behavior

Use adjective or `-able` suffix for behavior interfaces:

```typescript
// Good
interface Drawable {
  draw(): void;
}

interface Serializable {
  serialize(): string;
}

interface Comparable<T> {
  compareTo(other: T): number;
}

// Bad: no context
interface Draw { }
interface Serialize { }
```

### Interfaces for Data

Use noun for data interfaces:

```typescript
// Good
interface User {
  name: string;
  email: string;
}

interface Configuration {
  host: string;
  port: number;
}
```

### Factory Functions

Use `create` prefix:

```typescript
// Good
function createUser(name: string): User { }
function createHttpClient(config: Config): HttpClient { }

// Bad
function makeUser(name: string): User { }
function newHttpClient(config: Config): HttpClient { }
```

### Boolean Properties/Methods

Use `is`, `has`, `can`, or `should` prefix:

```typescript
// Good
interface User {
  isActive: boolean;
  hasPermission: boolean;
}

class Validator {
  canValidate(): boolean { }
  shouldSkip(): boolean { }
}

// Bad: unclear
interface User {
  active: boolean;
  permission: boolean;
}
```

### Getter Methods

Don't use `get` prefix unless needed for clarity:

```typescript
// Good: property name is clear
class User {
  get fullName(): string {
    return `${this.firstName} ${this.lastName}`;
  }
}

// Acceptable: get prefix for clarity
class Cache {
  getValue(key: string): string | undefined { }
}

// Bad: redundant get prefix
class User {
  getName(): string {
    return this.name;
  }
}
```

## Anti-Patterns

### Hungarian Notation

Don't use Hungarian notation (type prefixes):

```typescript
// Bad: Hungarian notation
let strName: string;
let arrUsers: User[];
let objConfig: Config;

// Good
let name: string;
let users: User[];
let config: Config;
```

### Redundant Context

Don't repeat context in names:

```typescript
// Bad: redundant context
class User {
  userName: string;
  userEmail: string;
  userAge: number;
}

// Good
class User {
  name: string;
  email: string;
  age: number;
}
```

### Noise Words

Avoid noise words that don't add meaning:

```typescript
// Bad: noise words
class UserData { }
class UserInfo { }
interface IUser { }

// Good
class User { }
interface User { }
```

## Best Practices Summary

### DO

- Use `UpperCamelCase` for classes, interfaces, types, enums
- Use `lowerCamelCase` for functions, methods, properties, variables
- Use `CONSTANT_CASE` for compile-time constants only
- Use lowercase with dashes for file names
- Use single letters (T, K, V) for simple generics
- Treat abbreviations as words in camelCase
- Use descriptive, meaningful names
- Use `is`, `has`, `can` prefixes for booleans

### DON'T

- Use `snake_case` or `kebab-case` for identifiers
- Use underscore prefixes for private members
- Use Hungarian notation
- Use `I` prefix for interfaces
- Use abbreviations when full words are clearer
- Use all-caps abbreviations in camelCase
- Use `$` except for specific frameworks
- Repeat context in property names
- Use generic names like `data`, `info`, `manager`
