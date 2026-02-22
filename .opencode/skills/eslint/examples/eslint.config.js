/**
 * Production-ready ESLint flat config for a TypeScript + React project.
 *
 * Covers:
 *  - Base JS recommended rules
 *  - TypeScript-aware rules (type-checked)
 *  - React + React Hooks rules
 *  - JSX Accessibility rules
 *  - Import order and cycle detection
 *  - Separate, relaxed config for test files
 *  - Global ignores for generated/build output
 *
 * Install dependencies:
 *   npm install --save-dev \
 *     eslint @eslint/js \
 *     typescript-eslint \
 *     eslint-plugin-react eslint-plugin-react-hooks \
 *     eslint-plugin-jsx-a11y \
 *     eslint-plugin-import \
 *     globals
 */

import js from "@eslint/js";
import tseslint from "typescript-eslint";
import react from "eslint-plugin-react";
import reactHooks from "eslint-plugin-react-hooks";
import jsxA11y from "eslint-plugin-jsx-a11y";
import importPlugin from "eslint-plugin-import";
import globals from "globals";
import { defineConfig, globalIgnores } from "eslint/config";

export default defineConfig([
  // ─── Global ignores ───────────────────────────────────────────────────────
  globalIgnores([
    "dist/",
    "build/",
    "coverage/",
    ".next/",
    "*.min.js",
    "**/*.generated.*",
  ]),

  // ─── Base JS rules (applies to all JS/TS files) ───────────────────────────
  {
    name: "base/js",
    files: ["**/*.{js,cjs,mjs,jsx,ts,tsx}"],
    plugins: { js },
    extends: ["js/recommended"],
    rules: {
      // Always a bug
      "no-var": "error",
      "eqeqeq": ["error", "always"],
      "no-eval": "error",
      "no-implied-eval": "error",
      "no-new-func": "error",
      "no-debugger": "error",

      // Code quality
      "prefer-const": "error",
      "prefer-arrow-callback": "error",
      "object-shorthand": "error",
      "prefer-template": "error",
      "prefer-rest-params": "error",
      "prefer-spread": "error",
      "no-useless-constructor": "error",
      "curly": ["error", "all"],

      // Flagged but not blocking — keep for CI awareness
      "no-console": "warn",
      "no-unused-vars": "off", // disabled in favor of TS-aware version below
    },
  },

  // ─── TypeScript rules (type-checked) ──────────────────────────────────────
  {
    name: "base/typescript",
    files: ["**/*.{ts,tsx}"],
    extends: [
      ...tseslint.configs.recommendedTypeChecked,
      ...tseslint.configs.stylisticTypeChecked,
    ],
    languageOptions: {
      parser: tseslint.parser,
      parserOptions: {
        project: true,
        tsconfigRootDir: import.meta.dirname,
      },
    },
    rules: {
      // Unused vars — track args starting with _ as intentionally ignored
      "@typescript-eslint/no-unused-vars": [
        "error",
        { argsIgnorePattern: "^_", varsIgnorePattern: "^_" },
      ],

      // Type safety
      "@typescript-eslint/no-explicit-any": "warn",
      "@typescript-eslint/no-floating-promises": "error",
      "@typescript-eslint/no-misused-promises": "error",
      "@typescript-eslint/await-thenable": "error",
      "@typescript-eslint/require-await": "error",

      // Import clarity
      "@typescript-eslint/consistent-type-imports": [
        "error",
        { prefer: "type-imports", fixStyle: "inline-type-imports" },
      ],

      // Prefer nullish coalescing and optional chaining
      "@typescript-eslint/prefer-nullish-coalescing": "error",
      "@typescript-eslint/prefer-optional-chain": "error",
    },
  },

  // ─── React rules ──────────────────────────────────────────────────────────
  {
    name: "base/react",
    files: ["**/*.{jsx,tsx}"],
    plugins: {
      react,
      "react-hooks": reactHooks,
    },
    extends: ["react/recommended"],
    settings: {
      react: { version: "detect" },
    },
    languageOptions: {
      globals: globals.browser,
      parserOptions: {
        ecmaFeatures: { jsx: true },
      },
    },
    rules: {
      // React Hooks
      "react-hooks/rules-of-hooks": "error",
      "react-hooks/exhaustive-deps": "warn",

      // Modern React (v17+) doesn't require React in scope for JSX
      "react/react-in-jsx-scope": "off",

      // TypeScript covers prop-types
      "react/prop-types": "off",

      // Quality
      "react/no-array-index-key": "warn",
      "react/no-unstable-nested-components": ["error", { allowAsProps: true }],
      "react/self-closing-comp": "error",
      "react/jsx-no-useless-fragment": "warn",
    },
  },

  // ─── Accessibility rules ──────────────────────────────────────────────────
  {
    name: "base/a11y",
    files: ["**/*.{jsx,tsx}"],
    plugins: { "jsx-a11y": jsxA11y },
    extends: ["jsx-a11y/recommended"],
  },

  // ─── Import rules ─────────────────────────────────────────────────────────
  {
    name: "base/imports",
    files: ["**/*.{js,ts,jsx,tsx}"],
    plugins: { import: importPlugin },
    rules: {
      "import/no-duplicates": "error",
      "import/no-cycle": "error",
      "import/order": [
        "error",
        {
          "groups": [
            "builtin",
            "external",
            "internal",
            "parent",
            "sibling",
            "index",
            "type",
          ],
          "newlines-between": "always",
          "alphabetize": { order: "asc", caseInsensitive: true },
        },
      ],
    },
  },

  // ─── Node.js environment (server-side files) ──────────────────────────────
  {
    name: "base/node",
    files: ["server/**/*.{js,ts}", "scripts/**/*.{js,ts}"],
    languageOptions: {
      globals: globals.node,
    },
    rules: {
      "no-console": "off", // console is fine server-side
    },
  },

  // ─── Test files — relaxed rules ───────────────────────────────────────────
  {
    name: "tests/overrides",
    files: [
      "**/*.test.{js,ts,jsx,tsx}",
      "**/*.spec.{js,ts,jsx,tsx}",
      "**/test/**/*.{js,ts}",
      "**/__tests__/**/*.{js,ts}",
    ],
    languageOptions: {
      globals: {
        ...globals.jest,
        describe: "readonly",
        it: "readonly",
        expect: "readonly",
        beforeEach: "readonly",
        afterEach: "readonly",
        beforeAll: "readonly",
        afterAll: "readonly",
      },
    },
    rules: {
      // Test assertions often appear "unused" to static analysis
      "no-unused-expressions": "off",

      // Type-checked rules are too strict for test mocks
      "@typescript-eslint/no-explicit-any": "off",
      "@typescript-eslint/no-floating-promises": "off",

      // Common test patterns
      "react/no-array-index-key": "off",
    },
  },

  // ─── Linter-level options ─────────────────────────────────────────────────
  {
    name: "linter/options",
    linterOptions: {
      reportUnusedDisableDirectives: "error",
      reportUnusedInlineConfigs: "warn",
    },
  },
]);
