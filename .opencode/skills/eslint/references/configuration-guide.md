# ESLint Configuration Guide

## Table of Contents

1. [Flat Config Deep Dive](#flat-config-deep-dive)
2. [Cascading and Merging Rules](#cascading-and-merging-rules)
3. [Language Options](#language-options)
4. [TypeScript Configuration Files](#typescript-configuration-files)
5. [Monorepo Setup](#monorepo-setup)
6. [Shared Settings](#shared-settings)
7. [Processors for Non-JS Files](#processors-for-non-js-files)
8. [Extends vs Cascading Decision Guide](#extends-vs-cascading-decision-guide)
9. [Debugging Techniques](#debugging-techniques)
10. [Migration from Legacy .eslintrc](#migration-from-legacy-eslintrc)

---

## Flat Config Deep Dive

The flat config format uses `eslint.config.js` (or `.mjs`, `.cjs`, `.ts`) at the project root. ESLint searches upward from each linted file to find the nearest config, enabling monorepo subdirectory configs.

### `defineConfig` helper

Always wrap the export array in `defineConfig()`. It provides type inference in editors and validates the structure:

```js
import { defineConfig } from "eslint/config";

export default defineConfig([
  // ...configuration objects
]);
```

### Configuration object anatomy

```js
{
  name: "myproject/source",          // optional, but recommended for debugging
  files: ["src/**/*.{js,ts}"],       // which files this object targets
  ignores: ["src/**/*.generated.*"], // exclude specific files within scope
  extends: ["js/recommended"],       // inherit from configs/plugins
  plugins: { pluginName: plugin },   // register plugin under a namespace
  languageOptions: { ... },          // parser, ecmaVersion, globals, etc.
  linterOptions: { ... },            // linting process options
  rules: { ... },                    // rule ID → severity or [severity, options]
  settings: { ... },                 // shared data passed to every rule
}
```

### Config file formats

| Filename | Format | When to use |
|---|---|---|
| `eslint.config.js` | ESM or CJS (auto-detected via `package.json`) | Default choice |
| `eslint.config.mjs` | ESM only | Force ESM in CJS packages |
| `eslint.config.cjs` | CJS only | Force CJS in ESM packages |
| `eslint.config.ts` | TypeScript | Requires `jiti` on Node.js |

File precedence (highest first): `.js` → `.mjs` → `.cjs` → `.ts` → `.mts` → `.cts`

---

## Cascading and Merging Rules

When multiple configuration objects match the same file, ESLint merges them in order. Later objects take precedence over earlier ones.

### Rule merging behavior

```js
export default defineConfig([
  // Object 1 — sets semi to error with "never"
  { rules: { semi: ["error", "never"] } },

  // Object 2 — overrides severity only, keeps "never" option
  { rules: { semi: "warn" } },

  // Final result: ["warn", "never"]
]);
```

Override only what differs. Avoid repeating shared options in downstream overrides.

### Object scope determines merge

```js
export default defineConfig([
  // Applies to ALL JS files
  {
    files: ["**/*.js"],
    rules: { "no-var": "error" },
  },

  // Adds globals only for test files; still inherits no-var from above
  {
    files: ["**/*.test.js"],
    languageOptions: {
      globals: { describe: "readonly", it: "readonly", expect: "readonly" },
    },
    rules: { "no-unused-expressions": "off" },
  },
]);
```

### Using `basePath` for subdirectory scoping

```js
export default defineConfig([
  {
    basePath: "packages/api",
    extends: [
      { rules: { "no-process-env": "error" } },
      { files: ["**/*.test.ts"], rules: { "no-process-env": "off" } },
    ],
  },
]);
```

---

## Language Options

### ECMAScript version and module type

```js
{
  languageOptions: {
    ecmaVersion: "latest",     // or 2024, 2022, etc.
    sourceType: "module",      // "module" | "script" | "commonjs"
  },
}
```

### Globals

Use the `globals` package for environment-specific globals:

```bash
npm install --save-dev globals
```

```js
import globals from "globals";

{
  languageOptions: {
    globals: {
      ...globals.browser,   // window, document, fetch, etc.
      ...globals.node,      // process, __dirname, etc.
      MY_GLOBAL: "readonly",
    },
  },
}
```

### Parser options

```js
{
  languageOptions: {
    parserOptions: {
      ecmaFeatures: {
        jsx: true,   // enable JSX parsing
      },
    },
  },
}
```

---

## TypeScript Configuration Files

For Node.js, install `jiti` to use TypeScript config files:

```bash
npm install --save-dev jiti
```

Create `eslint.config.ts`:

```ts
import { defineConfig } from "eslint/config";
import js from "@eslint/js";
import type { Linter } from "eslint";

const config: Linter.Config[] = [
  {
    files: ["**/*.ts"],
    plugins: { js },
    extends: ["js/recommended"],
  },
];

export default defineConfig(config);
```

Force ESLint to use the `.ts` config:

```bash
npx eslint --config eslint.config.ts src/
```

On Node.js >= 22.13.0 with experimental strips-types support, skip `jiti`:

```bash
npx --node-options='--experimental-strip-types' eslint --flag unstable_native_nodejs_ts_config
```

---

## Monorepo Setup

Each package can have its own `eslint.config.js`. ESLint resolves configs by walking up directories from the target file.

### Root config + package overrides pattern

```
my-monorepo/
├── eslint.config.js          ← shared base rules
├── packages/
│   ├── api/
│   │   └── eslint.config.js  ← API-specific rules
│   └── ui/
│       └── eslint.config.js  ← React/JSX rules
```

Root `eslint.config.js`:

```js
import { defineConfig } from "eslint/config";
import js from "@eslint/js";

export default defineConfig([
  {
    files: ["**/*.{js,ts}"],
    plugins: { js },
    extends: ["js/recommended"],
    rules: {
      "no-var": "error",
      "prefer-const": "error",
      "eqeqeq": ["error", "always"],
    },
  },
]);
```

Package `packages/ui/eslint.config.js`:

```js
import rootConfig from "../../eslint.config.js";
import { defineConfig } from "eslint/config";
import react from "eslint-plugin-react";

export default defineConfig([
  ...rootConfig,
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

---

## Shared Settings

The `settings` key is supplied to every rule in its configuration object. Plugins namespace their settings to avoid collisions:

```js
{
  settings: {
    react: { version: "detect" },   // used by eslint-plugin-react
    "import/resolver": {
      typescript: { alwaysTryTypes: true },
    },
  },
}
```

---

## Processors for Non-JS Files

### Lint code blocks inside Markdown

```bash
npm install --save-dev @eslint/markdown
```

```js
import markdown from "@eslint/markdown";
import { defineConfig } from "eslint/config";

export default defineConfig([
  {
    files: ["**/*.md"],
    plugins: { markdown },
    processor: "markdown/markdown",
  },
  // Relax certain rules for code samples inside Markdown
  {
    files: ["**/*.md/*.js"],
    rules: {
      "no-undef": "off",
      "no-unused-vars": "off",
    },
  },
]);
```

### Lint JSON files

```bash
npm install --save-dev @eslint/json
```

```js
import json from "@eslint/json";
import { defineConfig } from "eslint/config";

export default defineConfig([
  {
    files: ["**/*.json"],
    plugins: { json },
    language: "json/jsonc",
  },
]);
```

---

## Extends vs Cascading Decision Guide

| Scenario | Use |
|---|---|
| Inherit plugin's recommended rules | `extends: ["plugin/recommended"]` |
| Apply different rules to test files | Cascading (new config object with `files`) |
| Compose multiple plugin configs in one object | `extends: [config1, config2]` |
| Override rules for a subdirectory | Cascading with `basePath` |
| Shareable npm config package | `extends: [importedConfig]` |

**Key rule**: Use `extends` to inherit; use cascading (new array entries) to override by file pattern.

---

## Debugging Techniques

### Config inspector UI

```bash
npx eslint --inspect-config
```

Opens a browser UI showing every config object, what files it matches, and the merged result for any file.

### Print merged config for a single file

```bash
npx eslint --print-config src/app.ts
```

Outputs the complete merged JSON config (rules, language options, etc.) that applies to the given file.

### Verbose output

```bash
npx eslint --debug src/ 2>&1 | head -100
```

Traces config file resolution and rule loading.

### Identify stale disable comments

```js
{
  linterOptions: {
    reportUnusedDisableDirectives: "error",
    reportUnusedInlineConfigs: "warn",
  },
}
```

---

## Migration from Legacy `.eslintrc`

ESLint v9 deprecated `.eslintrc.*`. Use the official migration guide:

```bash
# Auto-migrate with the config migrator (may need manual fixes)
npx @eslint/migrate-config .eslintrc.json
```

Key changes:

| Legacy (`.eslintrc`) | Flat Config (`eslint.config.js`) |
|---|---|
| `extends: ["plugin:react/recommended"]` | `extends: ["react/recommended"]` in object with `plugins: { react }` |
| `env: { browser: true }` | `languageOptions: { globals: globals.browser }` |
| `parser: "@typescript-eslint/parser"` | `languageOptions: { parser: tsParser }` |
| `overrides: [{ files, rules }]` | Separate config object with `files` key |
| `.eslintignore` | `globalIgnores(["..."])` in config |

After migration, validate with `--inspect-config` and check that all rules still apply to the correct files.
