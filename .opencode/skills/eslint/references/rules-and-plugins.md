# ESLint Rules & Plugin Ecosystem

## Table of Contents

1. [Essential Built-in Rules](#essential-built-in-rules)
2. [Recommended Rule Sets](#recommended-rule-sets)
3. [Popular Plugin Ecosystem](#popular-plugin-ecosystem)
4. [TypeScript Rules](#typescript-rules)
5. [React Rules](#react-rules)
6. [Import/Module Rules](#importmodule-rules)
7. [Accessibility Rules](#accessibility-rules)
8. [Node.js Rules](#nodejs-rules)
9. [Rule Severity Strategy](#rule-severity-strategy)

---

## Essential Built-in Rules

These rules should be enabled in most JavaScript/TypeScript projects. All are included in `js/recommended` unless noted.

### Error prevention

| Rule | Severity | Notes |
|---|---|---|
| `no-undef` | `error` | Catches undefined variables |
| `no-unused-vars` | `warn` | Flag but allow during development |
| `no-unreachable` | `error` | Dead code after `return`/`throw` |
| `no-constant-condition` | `error` | `if (true)` is always a bug |
| `no-duplicate-case` | `error` | Duplicate `switch` cases |
| `no-dupe-keys` | `error` | Duplicate object keys |
| `no-fallthrough` | `error` | Unintentional `switch` fallthrough |
| `use-isnan` | `error` | Use `Number.isNaN()` not `=== NaN` |
| `valid-typeof` | `error` | `typeof x === "strig"` typo guard |

### Code quality

| Rule | Recommended severity | Notes |
|---|---|---|
| `eqeqeq` | `["error", "always"]` | Enforce `===` / `!==` |
| `no-var` | `error` | Use `const`/`let` exclusively |
| `prefer-const` | `error` | Use `const` when never reassigned |
| `curly` | `["error", "all"]` | Always use braces on `if`/`else` |
| `no-eval` | `error` | `eval()` is a security risk |
| `no-implied-eval` | `error` | `setTimeout("code")` also runs eval |
| `no-new-func` | `error` | `new Function(...)` is eval |
| `no-alert` | `warn` | Remove before production |
| `no-console` | `warn` | Flag debug output |
| `no-debugger` | `error` | Never ship debugger statements |

### Modern JS patterns

| Rule | Severity | Notes |
|---|---|---|
| `prefer-arrow-callback` | `error` | Prefer arrow functions in callbacks |
| `object-shorthand` | `error` | `{ foo }` not `{ foo: foo }` |
| `prefer-template` | `error` | Template literals over concatenation |
| `prefer-destructuring` | `warn` | Destructure arrays/objects |
| `no-useless-constructor` | `error` | Remove empty constructors |
| `no-useless-rename` | `error` | `import { a as a }` |
| `prefer-rest-params` | `error` | `...args` not `arguments` |
| `prefer-spread` | `error` | `fn(...args)` not `fn.apply()` |

---

## Recommended Rule Sets

### `js/recommended` (built-in)

The baseline. Includes rules that catch clear errors with minimal false positives.

```js
import js from "@eslint/js";
import { defineConfig } from "eslint/config";

export default defineConfig([
  {
    files: ["**/*.js"],
    plugins: { js },
    extends: ["js/recommended"],
  },
]);
```

### `js/all` — avoid in production

Enables every built-in rule. Changes with every ESLint release, making upgrades risky. Use only in experimental configs.

---

## Popular Plugin Ecosystem

### Installation and usage pattern

```bash
npm install --save-dev eslint-plugin-<name>
```

```js
import pluginName from "eslint-plugin-<name>";

export default defineConfig([
  {
    plugins: { pluginName },
    extends: ["pluginName/recommended"],  // if available
    rules: {
      "pluginName/some-rule": "error",
    },
  },
]);
```

### Plugin overview

| Plugin | npm package | Use case |
|---|---|---|
| TypeScript ESLint | `typescript-eslint` | TypeScript-aware rules |
| React | `eslint-plugin-react` | React component rules |
| React Hooks | `eslint-plugin-react-hooks` | Hook rules (deps, call order) |
| JSX Accessibility | `eslint-plugin-jsx-a11y` | Accessibility for JSX |
| Import | `eslint-plugin-import` | Module import validation |
| N (Node.js) | `eslint-plugin-n` | Node.js-specific rules |
| JSDoc | `eslint-plugin-jsdoc` | JSDoc comment validation |
| Unicorn | `eslint-plugin-unicorn` | Opinionated code quality |
| Perfectionist | `eslint-plugin-perfectionist` | Sorting rules (imports, keys) |
| Prettier | `eslint-config-prettier` | Disable formatting rules when using Prettier |

---

## TypeScript Rules

### Setup

```bash
npm install --save-dev typescript-eslint
```

```js
import tseslint from "typescript-eslint";
import { defineConfig } from "eslint/config";

export default defineConfig([
  ...tseslint.configs.recommended,
  {
    files: ["**/*.ts", "**/*.tsx"],
    rules: {
      // Relax recommended rules for gradual adoption
      "@typescript-eslint/no-explicit-any": "warn",
      "@typescript-eslint/no-unused-vars": ["error", { argsIgnorePattern: "^_" }],
    },
  },
]);
```

### Typed linting (requires `project` option)

Enables rules that require the TypeScript type checker — much more powerful but slower:

```js
import tseslint from "typescript-eslint";
import { defineConfig } from "eslint/config";

export default defineConfig([
  ...tseslint.configs.recommendedTypeChecked,
  {
    files: ["**/*.ts"],
    languageOptions: {
      parserOptions: {
        project: true,          // use tsconfig.json in project root
        tsconfigRootDir: import.meta.dirname,
      },
    },
    rules: {
      "@typescript-eslint/await-thenable": "error",
      "@typescript-eslint/no-floating-promises": "error",
      "@typescript-eslint/no-misused-promises": "error",
      "@typescript-eslint/require-await": "error",
    },
  },
]);
```

### Key TypeScript rules

| Rule | Notes |
|---|---|
| `@typescript-eslint/no-explicit-any` | Discourage `any` usage |
| `@typescript-eslint/no-unused-vars` | Replaces built-in `no-unused-vars` for TS |
| `@typescript-eslint/consistent-type-imports` | Enforce `import type` for type-only imports |
| `@typescript-eslint/no-floating-promises` | Ensure promises are handled (requires types) |
| `@typescript-eslint/no-misused-promises` | Prevent passing async functions where sync expected |
| `@typescript-eslint/await-thenable` | Disallow `await` on non-promise values |
| `@typescript-eslint/strict-null-checks` | Requires `strictNullChecks` in tsconfig |

---

## React Rules

### Setup

```bash
npm install --save-dev eslint-plugin-react eslint-plugin-react-hooks
```

```js
import react from "eslint-plugin-react";
import reactHooks from "eslint-plugin-react-hooks";
import { defineConfig } from "eslint/config";

export default defineConfig([
  {
    files: ["**/*.{jsx,tsx}"],
    plugins: { react, "react-hooks": reactHooks },
    extends: ["react/recommended"],
    settings: {
      react: { version: "detect" },  // auto-detect React version
    },
    rules: {
      // React Hooks rules (not in react/recommended)
      "react-hooks/rules-of-hooks": "error",
      "react-hooks/exhaustive-deps": "warn",

      // Modern React (v17+) doesn't need React in scope
      "react/react-in-jsx-scope": "off",
      "react/prop-types": "off",  // use TypeScript instead
    },
  },
]);
```

### Key React rules

| Rule | Notes |
|---|---|
| `react-hooks/rules-of-hooks` | Hooks only in components/hooks, only at top level |
| `react-hooks/exhaustive-deps` | All `useEffect` dependencies must be listed |
| `react/no-array-index-key` | Avoid index as React key |
| `react/no-unstable-nested-components` | Prevent inline component definitions |
| `react/self-closing-comp` | `<Foo />` not `<Foo></Foo>` for empty elements |

---

## Import/Module Rules

```bash
npm install --save-dev eslint-plugin-import
```

```js
import importPlugin from "eslint-plugin-import";
import { defineConfig } from "eslint/config";

export default defineConfig([
  {
    plugins: { import: importPlugin },
    rules: {
      "import/no-unresolved": "error",          // catch missing modules
      "import/no-duplicates": "error",           // merge duplicate imports
      "import/no-cycle": "error",                // prevent circular deps
      "import/order": ["error", {               // enforce import grouping
        "groups": ["builtin", "external", "internal", "parent", "sibling"],
        "newlines-between": "always",
      }],
      "import/no-unused-modules": "warn",        // flag unused exports
    },
  },
]);
```

---

## Accessibility Rules

```bash
npm install --save-dev eslint-plugin-jsx-a11y
```

```js
import jsxA11y from "eslint-plugin-jsx-a11y";
import { defineConfig } from "eslint/config";

export default defineConfig([
  {
    files: ["**/*.{jsx,tsx}"],
    plugins: { "jsx-a11y": jsxA11y },
    extends: ["jsx-a11y/recommended"],
    rules: {
      "jsx-a11y/alt-text": "error",              // images need alt text
      "jsx-a11y/anchor-is-valid": "error",       // valid href on anchors
      "jsx-a11y/click-events-have-key-events": "warn",
    },
  },
]);
```

---

## Node.js Rules

```bash
npm install --save-dev eslint-plugin-n
```

```js
import n from "eslint-plugin-n";
import { defineConfig } from "eslint/config";

export default defineConfig([
  {
    files: ["**/*.{js,ts}"],
    plugins: { n },
    extends: ["n/recommended"],
    rules: {
      "n/no-missing-import": "error",       // validate import paths
      "n/no-process-exit": "error",         // use proper exit codes
      "n/prefer-global/buffer": "error",    // import Buffer don't use global
      "n/prefer-promises/fs": "error",      // fs.promises over callback API
    },
  },
]);
```

---

## Rule Severity Strategy

### Adopt incrementally

When introducing ESLint to an existing codebase, start with `"warn"` on all rules. Use bulk suppressions to silence existing violations, then progressively upgrade rules to `"error"` as violations are fixed:

```bash
# Generate bulk suppressions file for all current violations
npx eslint --suppress-all-output src/
```

This writes `eslint-suppressions.json` — existing violations are silenced without inline disables, allowing new violations to still be caught.

### Severity assignment guide

| Situation | Severity |
|---|---|
| Always a bug or security risk | `"error"` |
| Style preference enforced by team | `"error"` |
| Possibly unintentional, judgment needed | `"warn"` |
| New rule being phased in | `"warn"` → promote to `"error"` |
| Not applicable to this project | `"off"` |

### Avoid numeric values

Prefer string severities (`"error"`, `"warn"`, `"off"`) over numeric (`2`, `1`, `0`). Strings are self-documenting and searchable.
