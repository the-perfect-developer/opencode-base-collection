/**
 * Function Examples - Google TypeScript Style Guide
 * 
 * Demonstrates proper function declarations, arrow functions,
 * parameter handling, and return types.
 */

// ✅ GOOD: Prefer function declarations for named functions
function calculateTotal(price: number, tax: number): number {
  return price + (price * tax);
}

// ✅ GOOD: Arrow functions for callbacks and short expressions
const items = [1, 2, 3, 4, 5];
const doubled = items.map(item => item * 2);
const filtered = items.filter(item => item > 2);

// ✅ GOOD: Explicit return type for clarity
function getUserName(userId: string): string | null {
  // Implementation
  return null;
}

// ✅ GOOD: Optional parameters
function greet(name: string, title?: string): string {
  if (title) {
    return `Hello, ${title} ${name}`;
  }
  return `Hello, ${name}`;
}

// ✅ GOOD: Default parameters
function createUser(name: string, role: string = 'user'): object {
  return { name, role };
}

// ✅ GOOD: Rest parameters
function sum(...numbers: number[]): number {
  return numbers.reduce((total, n) => total + n, 0);
}

// ✅ GOOD: Async functions with proper typing
async function fetchUserData(userId: string): Promise<object> {
  const response = await fetch(`/api/users/${userId}`);
  return response.json();
}

// ✅ GOOD: Arrow function with explicit return type
const multiply = (a: number, b: number): number => a * b;

// ✅ GOOD: Higher-order function
function createMultiplier(factor: number): (value: number) => number {
  return (value: number) => value * factor;
}

// ✅ GOOD: Function overloads
function format(value: string): string;
function format(value: number): string;
function format(value: boolean): string;
function format(value: string | number | boolean): string {
  return String(value);
}

// ❌ BAD: Using 'var' instead of 'const' or 'let'
// var badFunction = function() { };

// ❌ BAD: Missing return type
// function noReturnType(x: number) {
//   return x * 2;
// }

// ❌ BAD: Using 'any' without good reason
// function processData(data: any): any {
//   return data;
// }

// ✅ GOOD: Generic function with constraints
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}

// ✅ GOOD: Function with object destructuring
function displayUser({name, email}: {name: string; email: string}): void {
  console.log(`${name} - ${email}`);
}

// ✅ GOOD: Arrow function in class property
class EventHandler {
  // Arrow functions preserve 'this' context
  handleClick = (event: MouseEvent): void => {
    console.log('Clicked', event);
  };
}

export {
  calculateTotal,
  getUserName,
  greet,
  createUser,
  sum,
  fetchUserData,
  multiply,
  createMultiplier,
  format,
  getProperty,
  displayUser,
  EventHandler,
};
