# Type System

Comprehensive guide to TypeScript's type system and best practices for type annotations.

## Table of Contents

- [Type Inference](#type-inference)
- [Type Annotations](#type-annotations)
- [Interfaces vs Types](#interfaces-vs-types)
- [Generics](#generics)
- [Utility Types](#utility-types)
- [Type Guards](#type-guards)
- [Mapped Types](#mapped-types)

## Type Inference

### When to Rely on Inference

TypeScript's type inference is powerful. Avoid redundant type annotations:

```typescript
// Good: types are inferred
const x = 5;  // number
const y = 'hello';  // string
const z = [1, 2, 3];  // number[]
const user = {name: 'Alice', age: 30};  // {name: string; age: number}

// Bad: redundant annotations
const x: number = 5;
const y: string = 'hello';
```

### When to Annotate

Provide explicit type annotations when:

1. **Exported functions/methods** - Always annotate return types
2. **Complex expressions** - When inference isn't obvious
3. **API boundaries** - Public interfaces, parameters
4. **Empty arrays/objects** - When initial value doesn't indicate type

```typescript
// Good: annotate return type on exports
export function getUser(id: string): User {
  return users.get(id);
}

// Good: annotate when not obvious
const cache: Map<string, User> = new Map();
const items: Item[] = [];

// Good: annotate complex types
const config: AppConfig = loadConfig();
```

## Type Annotations

### Function Return Types

Always annotate return types for exported functions and public methods:

```typescript
// Good
export function calculate(x: number, y: number): number {
  return x + y;
}

// Good: async function
export async function fetchUser(id: string): Promise<User> {
  return await api.get(`/users/${id}`);
}

// Bad: missing return type on export
export function calculate(x: number, y: number) {
  return x + y;
}
```

### Function Parameters

Annotate parameter types (inference doesn't work for parameters):

```typescript
// Good
function greet(name: string, age: number): void {
  console.log(`Hello ${name}, age ${age}`);
}

// Bad: parameters need types
function greet(name, age) {
  console.log(`Hello ${name}, age ${age}`);
}
```

### Optional Parameters

Use `?` for optional parameters. Place them after required parameters:

```typescript
// Good
function createUser(name: string, email?: string): User {
  return {name, email: email ?? ''};
}

// Good: with default value
function greet(name: string, prefix = 'Hello'): string {
  return `${prefix}, ${name}`;
}

// Bad: optional before required
function bad(email?: string, name: string) { }
```

### Rest Parameters

Type rest parameters as arrays:

```typescript
// Good
function sum(...numbers: number[]): number {
  return numbers.reduce((a, b) => a + b, 0);
}

// Good: specific tuple types
function process(...args: [string, number, boolean]): void {
  const [name, age, active] = args;
}
```

## Interfaces vs Types

### When to Use Interface

Use `interface` for:
- Object shapes
- Class contracts
- API boundaries
- When you might extend later

```typescript
// Good: interface for object shape
interface User {
  id: string;
  name: string;
  email: string;
}

// Good: interface for class contract
interface Drawable {
  draw(): void;
}

class Circle implements Drawable {
  draw(): void {
    // Implementation
  }
}
```

### When to Use Type

Use `type` for:
- Unions
- Intersections
- Mapped types
- Tuple types
- Function types

```typescript
// Good: type for union
type Status = 'pending' | 'active' | 'completed';

// Good: type for intersection
type TimestampedUser = User & {createdAt: Date};

// Good: type for function
type Callback = (data: string) => void;

// Good: type for tuple
type Coordinate = [number, number];
```

### Prefer Interface

When either would work, prefer `interface`:

```typescript
// Good: prefer interface
interface Point {
  x: number;
  y: number;
}

// Less preferred but acceptable
type Point = {
  x: number;
  y: number;
};
```

### Extending Interfaces vs Types

Interfaces can be extended and merged:

```typescript
// Good: extending interface
interface Animal {
  name: string;
}

interface Dog extends Animal {
  breed: string;
}

// Good: interface merging (declaration merging)
interface User {
  name: string;
}

interface User {
  email: string;
}
// User now has both name and email
```

Types use intersections:

```typescript
// Good: type intersection
type Animal = {
  name: string;
};

type Dog = Animal & {
  breed: string;
};
```

## Generics

### Generic Functions

Use generics for reusable, type-safe functions:

```typescript
// Good: generic function
function first<T>(arr: T[]): T | undefined {
  return arr[0];
}

const num = first([1, 2, 3]);  // number | undefined
const str = first(['a', 'b']);  // string | undefined
```

### Generic Constraints

Constrain generics with `extends`:

```typescript
// Good: generic with constraint
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}

const user = {name: 'Alice', age: 30};
const name = getProperty(user, 'name');  // string
```

### Generic Interfaces

Create reusable interface structures:

```typescript
// Good: generic interface
interface Repository<T> {
  get(id: string): T | undefined;
  save(item: T): void;
  delete(id: string): boolean;
}

class UserRepository implements Repository<User> {
  get(id: string): User | undefined {
    // Implementation
  }
  save(user: User): void {
    // Implementation
  }
  delete(id: string): boolean {
    // Implementation
  }
}
```

### Generic Classes

```typescript
// Good: generic class
class Cache<T> {
  private data = new Map<string, T>();

  set(key: string, value: T): void {
    this.data.set(key, value);
  }

  get(key: string): T | undefined {
    return this.data.get(key);
  }
}

const userCache = new Cache<User>();
```

### Default Generic Types

Provide default types for generics:

```typescript
// Good: default generic type
interface Response<T = unknown> {
  data: T;
  status: number;
}

const response1: Response = {data: {}, status: 200};  // T is unknown
const response2: Response<User> = {data: user, status: 200};  // T is User
```

## Utility Types

TypeScript provides built-in utility types for common transformations.

### Partial<T>

Makes all properties optional:

```typescript
interface User {
  name: string;
  email: string;
  age: number;
}

// Good: partial for updates
function updateUser(id: string, updates: Partial<User>): void {
  // Can pass any subset of User properties
}

updateUser('123', {name: 'Alice'});
updateUser('456', {email: 'bob@example.com', age: 30});
```

### Required<T>

Makes all properties required:

```typescript
interface Config {
  host?: string;
  port?: number;
}

// Good: ensure all properties present
function validateConfig(config: Required<Config>): boolean {
  // config.host and config.port are definitely defined
  return config.host.length > 0 && config.port > 0;
}
```

### Readonly<T>

Makes all properties readonly:

```typescript
interface MutableUser {
  name: string;
  email: string;
}

// Good: prevent modifications
function displayUser(user: Readonly<MutableUser>): void {
  console.log(user.name);
  // user.name = 'new'; // Error: cannot assign to readonly property
}
```

### Pick<T, K>

Creates type with subset of properties:

```typescript
interface User {
  id: string;
  name: string;
  email: string;
  age: number;
}

// Good: pick specific properties
type UserPreview = Pick<User, 'id' | 'name'>;
// {id: string; name: string}
```

### Omit<T, K>

Creates type excluding specific properties:

```typescript
// Good: omit specific properties
type UserWithoutId = Omit<User, 'id'>;
// {name: string; email: string; age: number}

type PublicUser = Omit<User, 'email' | 'age'>;
// {id: string; name: string}
```

### Record<K, T>

Creates object type with specific keys and value type:

```typescript
// Good: record type
type UserRoles = Record<string, 'admin' | 'user' | 'guest'>;

const roles: UserRoles = {
  'user1': 'admin',
  'user2': 'user',
  'user3': 'guest',
};
```

### ReturnType<T>

Extracts return type of function:

```typescript
function createUser(name: string) {
  return {id: '123', name, createdAt: new Date()};
}

// Good: infer return type
type User = ReturnType<typeof createUser>;
// {id: string; name: string; createdAt: Date}
```

### Parameters<T>

Extracts parameter types as tuple:

```typescript
function greet(name: string, age: number) {
  return `Hello ${name}, age ${age}`;
}

// Good: extract parameters
type GreetParams = Parameters<typeof greet>;
// [string, number]
```

## Type Guards

### User-Defined Type Guards

Create custom type guards with `is`:

```typescript
// Good: type guard function
function isUser(value: unknown): value is User {
  return (
    typeof value === 'object' &&
    value !== null &&
    'name' in value &&
    'email' in value
  );
}

function processValue(value: unknown) {
  if (isUser(value)) {
    // value is User here
    console.log(value.name);
  }
}
```

### instanceof

Use `instanceof` for class instances:

```typescript
// Good: instanceof type guard
if (error instanceof Error) {
  console.log(error.message);
}
```

### typeof

Use `typeof` for primitive types:

```typescript
// Good: typeof type guard
function double(value: string | number): string | number {
  if (typeof value === 'string') {
    return value + value;
  }
  return value * 2;
}
```

### in Operator

Use `in` to check for properties:

```typescript
// Good: in operator type guard
interface Dog {
  bark(): void;
}

interface Cat {
  meow(): void;
}

function makeSound(animal: Dog | Cat) {
  if ('bark' in animal) {
    animal.bark();
  } else {
    animal.meow();
  }
}
```

## Mapped Types

### Basic Mapped Types

Transform existing types:

```typescript
// Good: mapped type
type Nullable<T> = {
  [P in keyof T]: T[P] | null;
};

interface User {
  name: string;
  age: number;
}

type NullableUser = Nullable<User>;
// {name: string | null; age: number | null}
```

### Conditional Mapped Types

Apply conditions during mapping:

```typescript
// Good: conditional mapped type
type StringKeys<T> = {
  [K in keyof T]: T[K] extends string ? K : never;
}[keyof T];

interface User {
  id: string;
  name: string;
  age: number;
}

type UserStringKeys = StringKeys<User>;
// 'id' | 'name'
```

## Best Practices Summary

### DO

- Rely on type inference for local variables
- Annotate return types on exported functions
- Use `interface` for object shapes
- Use `type` for unions and intersections
- Use generics for reusable code
- Leverage utility types (`Partial`, `Pick`, `Omit`, etc.)
- Create type guards for runtime checking
- Use mapped types for transformations

### DON'T

- Over-annotate when types are obvious
- Use `any` (use `unknown` instead)
- Use `type` when `interface` would work
- Create redundant type aliases
- Use type assertions unnecessarily
- Ignore TypeScript errors with `@ts-ignore`
- Use overly complex generic constraints

## Common Patterns

### API Response Type

```typescript
interface ApiResponse<T> {
  data: T;
  status: number;
  error?: string;
}

async function fetchUser(id: string): Promise<ApiResponse<User>> {
  // Implementation
}
```

### Builder Pattern

```typescript
class UserBuilder {
  private user: Partial<User> = {};

  setName(name: string): this {
    this.user.name = name;
    return this;
  }

  setEmail(email: string): this {
    this.user.email = email;
    return this;
  }

  build(): User {
    if (!this.user.name || !this.user.email) {
      throw new Error('Missing required fields');
    }
    return this.user as User;
  }
}
```

### Branded Types

```typescript
// Good: branded type for type safety
type UserId = string & {__brand: 'UserId'};
type ProductId = string & {__brand: 'ProductId'};

function getUserId(id: string): UserId {
  return id as UserId;
}

function getUser(id: UserId): User {
  // Can't accidentally pass ProductId
}
```
