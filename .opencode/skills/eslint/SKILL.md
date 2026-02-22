---
name: eslint
description: This skill should be used when the user asks to "set up ESLint", "configure ESLint rules", "fix ESLint errors", "migrate to flat config", or needs guidance on JavaScript/TypeScript linting best practices.
---

# ESLint Best Practices

Provides guidance for configuring ESLint using the modern flat config format (`eslint.config.js`), selecting and tuning rules, managing plugins, and integrating linting into CI/CD workflows.

## Core Concepts

- **Flat config** (`eslint.config.js`) is the current standard. The legacy `.eslintrc.*` format is deprecated as of ESLint v9.
- **Configuration objects** are merged in order — later objects override earlier ones for the same rule.
- **Rule severities**: `"off"` (0) | `"warn"` (1) | `"error"` (2).
- **Plugins** extend ESLint with additional rules, processors, and languages. Reference as `pluginName/ruleName`.

## Setup

### Quick initialization (recommended)

```bash
npm init @eslint/config@latest
```

This generates `eslint.config.js` interactively. Requires Node.js `^20.19.0`, `^22.13.0`, or `>=24`.

### Manual setup

```bash
npm install --save-dev eslint@latest @eslint/js@latest
```

Create `eslint.config.js`:

```js
import { defineConfig } from "eslint/config";
import js from "@eslint/js";

export default defineConfig([
  {
    files: ["**/*.js"],
    plugins: { js },
    extends: ["js/recommended"],
    rules: {
      "no-unused-vars": "warn",
      "no-undef": "error",
    },
  },
]);
```

Run linting:

```bash
npx eslint src/
```

## Flat Config Structure

Every configuration object accepts these keys:

| Key | Purpose |
|---|---|
| `name` | Label for debugging (use `plugin/scope` convention) |
| `files` | Glob patterns this object applies to |
| `ignores` | Glob patterns to exclude (global if no other keys present) |
| `extends` | Inherit from plugin configs, shareable configs, or objects |
| `plugins` | Register plugins by namespace |
| `rules` | Rule names mapped to severity or `[severity, ...options]` |
| `languageOptions` | `ecmaVersion`, `sourceType`, `globals`, `parser`, `parserOptions` |
| `linterOptions` | `noInlineConfig`, `reportUnusedDisableDirectives`, `reportUnusedInlineConfigs` |
| `settings` | Shared data available to all rules |
| `processor` | Extracts JS from non-JS files (e.g., Markdown) |

### File targeting

```js
// Apply rules only to source files
{ files: ["src/**/*.{js,ts}"], rules: { ... } }

// Apply rules to all except tests
{ files: ["**/*.js"], ignores: ["**/*.test.js"], rules: { ... } }
```

### Global ignores (use `globalIgnores`)

```js
import { defineConfig, globalIgnores } from "eslint/config";

export default defineConfig([
  globalIgnores(["dist/", "coverage/", "*.min.js"]),
  // other config objects...
]);
```

Use `globalIgnores()` — not bare `ignores` keys — for project-wide exclusions. This is the clearest and least error-prone pattern.

### Import `.gitignore` patterns

```js
import { includeIgnoreFile } from "@eslint/compat";
import { fileURLToPath } from "node:url";

const gitignorePath = fileURLToPath(new URL(".gitignore", import.meta.url));

export default defineConfig([
  includeIgnoreFile(gitignorePath),
  // ...
]);
```

## Rule Configuration Best Practices

### Prefer `"error"` for enforced standards

Use `"error"` for rules that block bad code from merging. Reserve `"warn"` for violations that require human judgment or incremental adoption.

```js
rules: {
  "no-var": "error",          // always use const/let
  "prefer-const": "error",    // enforce immutability where possible
  "eqeqeq": ["error", "always"], // ban == in favor of ===
  "no-console": "warn",       // flag but don't block during development
}
```

### Disable inline comments sparingly

Use `// eslint-disable-next-line rule-name -- reason` with a mandatory reason. Never disable wholesale with `/* eslint-disable */` without scoping and justification.

```js
// eslint-disable-next-line no-console -- CLI entrypoint needs output
console.log("Starting server...");
```

Enable detection of stale disable comments:

```js
linterOptions: {
  reportUnusedDisableDirectives: "error",
}
```

### File-pattern overrides instead of inline disables

Disable rules for test files via configuration, not inline comments:

```js
{
  files: ["**/*.test.{js,ts}", "**/*.spec.{js,ts}"],
  rules: {
    "no-unused-expressions": "off", // chai/jest assertions
  },
}
```

## Plugin Usage

### Register and use a plugin

```js
import jsdoc from "eslint-plugin-jsdoc";
import { defineConfig } from "eslint/config";

export default defineConfig([
  {
    files: ["**/*.js"],
    plugins: { jsdoc },
    rules: {
      "jsdoc/require-description": "error",
      "jsdoc/check-values": "error",
    },
  },
]);
```

The plugin namespace is the property name in `plugins`. Convention: strip the `eslint-plugin-` prefix.

### Extend a plugin's recommended config

```js
import react from "eslint-plugin-react";
import { defineConfig } from "eslint/config";

export default defineConfig([
  {
    files: ["**/*.{jsx,tsx}"],
    plugins: { react },
    extends: ["react/recommended"],
    languageOptions: {
      parserOptions: { ecmaFeatures: { jsx: true } },
    },
  },
]);
```

## TypeScript Support

Install the TypeScript parser and plugin:

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
      "@typescript-eslint/no-explicit-any": "warn",
      "@typescript-eslint/explicit-function-return-type": "off",
    },
  },
]);
```

## Linter Options

```js
{
  linterOptions: {
    noInlineConfig: false,                    // allow inline eslint comments
    reportUnusedDisableDirectives: "error",   // fail on stale disables
    reportUnusedInlineConfigs: "warn",        // warn on redundant inline configs
  },
}
```

## Debugging Configuration

Inspect which config objects apply to a file:

```bash
npx eslint --inspect-config        # Opens config inspector UI
npx eslint --print-config file.js  # Prints merged config for a file
```

## CI/CD Integration

Add to `package.json`:

```json
{
  "scripts": {
    "lint": "eslint src/",
    "lint:fix": "eslint src/ --fix"
  }
}
```

Run `npm run lint` in CI. ESLint exits with code `1` when any `"error"`-severity rule triggers, blocking merges.

## Quick Reference: Rule Severity

| Value | Meaning |
|---|---|
| `"off"` / `0` | Disabled |
| `"warn"` / `1` | Warning (exit code 0) |
| `"error"` / `2` | Error (exit code 1) |

## Additional Resources

### Reference Files

- **`references/configuration-guide.md`** — Detailed flat config patterns, cascading, TypeScript config files, monorepo setup
- **`references/rules-and-plugins.md`** — Commonly used rules reference and popular plugin ecosystem

### Example Files

- **`examples/eslint.config.js`** — Production-ready config for a TypeScript project with React
