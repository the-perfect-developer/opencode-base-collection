/**
 * Type System Examples - Google TypeScript Style Guide
 * 
 * Demonstrates interfaces, types, generics, utility types,
 * and proper type annotations.
 */

// ✅ GOOD: Interface for object shapes
interface User {
  id: string;
  name: string;
  email: string;
  role?: 'admin' | 'user' | 'guest';
}

// ✅ GOOD: Type alias for unions
type Status = 'pending' | 'active' | 'completed' | 'failed';

// ✅ GOOD: Type alias for complex types
type RequestHandler = (req: Request, res: Response) => Promise<void>;

// ✅ GOOD: Extending interfaces
interface AdminUser extends User {
  permissions: string[];
  lastLogin: Date;
}

// ✅ GOOD: Interface for function signatures
interface Validator {
  (value: string): boolean;
}

// ✅ GOOD: Generic interface
interface ApiResponse<T> {
  data: T;
  status: number;
  message: string;
}

// ✅ GOOD: Generic type with constraints
type Identifiable<T extends {id: string}> = T & {
  createdAt: Date;
  updatedAt: Date;
};

// ✅ GOOD: Utility types
type PartialUser = Partial<User>;
type RequiredUser = Required<User>;
type ReadonlyUser = Readonly<User>;
type UserWithoutEmail = Omit<User, 'email'>;
type UserIdAndName = Pick<User, 'id' | 'name'>;

// ✅ GOOD: Mapped types
type Optional<T> = {
  [P in keyof T]?: T[P];
};

type Nullable<T> = {
  [P in keyof T]: T[P] | null;
};

// ✅ GOOD: Conditional types
type NonNullable<T> = T extends null | undefined ? never : T;

type ArrayElement<T> = T extends (infer U)[] ? U : never;

// ✅ GOOD: Index signatures
interface StringMap {
  [key: string]: string;
}

interface NumberDictionary {
  [index: string]: number;
  length: number; // Specific properties can be mixed in
}

// ✅ GOOD: Tuple types
type Point = [number, number];
type NamedPoint = [x: number, y: number];
type RGB = [red: number, green: number, blue: number];

// ✅ GOOD: Discriminated unions
interface SuccessResult {
  success: true;
  data: object;
}

interface ErrorResult {
  success: false;
  error: string;
}

type Result = SuccessResult | ErrorResult;

// ✅ GOOD: Using the discriminated union
function handleResult(result: Result): void {
  if (result.success) {
    console.log(result.data);
  } else {
    console.error(result.error);
  }
}

// ✅ GOOD: Intersection types
type Timestamped = {
  createdAt: Date;
  updatedAt: Date;
};

type AuditedUser = User & Timestamped;

// ✅ GOOD: Type guards
function isUser(value: unknown): value is User {
  return (
    typeof value === 'object' &&
    value !== null &&
    'id' in value &&
    'name' in value &&
    'email' in value
  );
}

// ✅ GOOD: Generic constraints
interface HasLength {
  length: number;
}

function logLength<T extends HasLength>(item: T): void {
  console.log(item.length);
}

// ✅ GOOD: Template literal types
type EventName = 'click' | 'focus' | 'blur';
type EventHandler = `on${Capitalize<EventName>}`;
// Results in: 'onClick' | 'onFocus' | 'onBlur'

// ✅ GOOD: Const assertions for literal types
const config = {
  apiUrl: 'https://api.example.com',
  timeout: 5000,
  retries: 3,
} as const;

// ❌ BAD: Using 'any' unnecessarily
// let data: any;

// ❌ BAD: Using 'Object' or 'object' as a type
// function process(obj: Object): void { }

// ✅ GOOD: Use specific object shape instead
function process(obj: Record<string, unknown>): void {
  // Implementation
}

// ✅ GOOD: Enum alternatives (prefer union types)
type Direction = 'north' | 'south' | 'east' | 'west';

// ✅ GOOD: Const enum (if enum is needed)
const enum LogLevel {
  ERROR = 0,
  WARN = 1,
  INFO = 2,
  DEBUG = 3,
}

export type {
  User,
  Status,
  RequestHandler,
  AdminUser,
  Validator,
  ApiResponse,
  Identifiable,
  Result,
  AuditedUser,
  Direction,
  EventHandler,
};

export {
  isUser,
  logLength,
  handleResult,
  process,
  LogLevel,
};
