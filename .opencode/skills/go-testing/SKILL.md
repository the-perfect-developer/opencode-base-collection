---
name: go-testing
description: This skill should be used when the user asks to "write Go unit tests", "add tests to a Go package", "use the testing package", "write table-driven tests in Go", or needs guidance on Go test patterns, subtests, benchmarks, and test helpers.
---

# Go Testing

The `testing` package provides support for automated testing of Go packages. Tests are run with `go test` and require no external libraries — the standard library covers unit tests, benchmarks, fuzz tests, and example functions.

## File and Function Conventions

Test files must end in `_test.go`. They are excluded from normal builds but included by `go test`.

Test functions must match the signature `func TestXxx(*testing.T)` where `Xxx` does not start with a lowercase letter:

```go
package mypackage

import "testing"

func TestAdd(t *testing.T) {
    got := Add(2, 3)
    if got != 5 {
        t.Errorf("Add(2, 3) = %d; want 5", got)
    }
}
```

### White-box vs Black-box Tests

- **Same package** (`package mypackage`) — accesses unexported identifiers
- **`_test` suffix package** (`package mypackage_test`) — tests only the exported API; this is "black-box" testing

Both styles can coexist in the same directory.

## Reporting Failures

| Method | Behaviour |
|---|---|
| `t.Errorf(format, args...)` | Marks failed, continues execution |
| `t.Error(args...)` | Marks failed, continues execution |
| `t.Fatalf(format, args...)` | Marks failed, stops test immediately |
| `t.Fatal(args...)` | Marks failed, stops test immediately |
| `t.Fail()` | Marks failed without logging, continues |
| `t.FailNow()` | Marks failed without logging, stops immediately |

Use `Errorf`/`Error` when checking multiple independent conditions so all failures are reported. Use `Fatalf`/`Fatal` when a failure makes further checks meaningless (e.g., a nil pointer).

Prefer `t.Errorf` over `t.Fatalf` unless subsequent assertions depend on a prior one succeeding.

## Table-Driven Tests

Table-driven tests are the idiomatic Go pattern for testing a function against many inputs:

```go
func TestDivide(t *testing.T) {
    tests := []struct {
        name    string
        a, b    float64
        want    float64
        wantErr bool
    }{
        {name: "positive", a: 10, b: 2, want: 5},
        {name: "negative divisor", a: 10, b: -2, want: -5},
        {name: "divide by zero", a: 10, b: 0, wantErr: true},
    }

    for _, tc := range tests {
        t.Run(tc.name, func(t *testing.T) {
            got, err := Divide(tc.a, tc.b)
            if (err != nil) != tc.wantErr {
                t.Fatalf("Divide(%v, %v) error = %v, wantErr %v", tc.a, tc.b, err, tc.wantErr)
            }
            if !tc.wantErr && got != tc.want {
                t.Errorf("Divide(%v, %v) = %v; want %v", tc.a, tc.b, got, tc.want)
            }
        })
    }
}
```

Name each case descriptively. Use `t.Run` so each case appears as a named subtest in output and can be run individually.

## Subtests

`t.Run(name, func(t *testing.T))` creates a named subtest. Subtests:

- Appear in output as `TestParent/SubName`
- Can be run individually: `go test -run TestParent/SubName`
- Share setup/teardown with the parent
- Can be run in parallel independently of other top-level tests

```go
func TestAPI(t *testing.T) {
    server := startTestServer(t) // shared setup

    t.Run("GET /users", func(t *testing.T) {
        // ...
    })
    t.Run("POST /users", func(t *testing.T) {
        // ...
    })
    // server is cleaned up after all subtests finish
}
```

## Parallel Tests

Call `t.Parallel()` at the start of a test function to allow it to run concurrently with other parallel tests:

```go
func TestExpensive(t *testing.T) {
    t.Parallel()
    // ...
}
```

For parallel subtests in a table-driven test, capture the loop variable:

```go
for _, tc := range tests {
    tc := tc // capture range variable (required before Go 1.22)
    t.Run(tc.name, func(t *testing.T) {
        t.Parallel()
        // use tc safely
    })
}
```

From Go 1.22 onward, loop variable capture is automatic and the `tc := tc` line is no longer needed.

## Cleanup

`t.Cleanup(f func())` registers a function to run after the test (and all its subtests) complete. Cleanup functions run in LIFO order.

```go
func TestWithDB(t *testing.T) {
    db := openTestDB(t)
    t.Cleanup(func() { db.Close() })
    // test body — db.Close is called automatically when test ends
}
```

Prefer `t.Cleanup` over `defer` inside test helpers because it runs after all subtests complete, not just when the helper function returns.

## Test Helpers

Mark a function as a test helper with `t.Helper()` so error output points to the call site, not inside the helper:

```go
func assertEqualInts(t *testing.T, got, want int) {
    t.Helper() // makes error line point to the caller
    if got != want {
        t.Errorf("got %d; want %d", got, want)
    }
}
```

Always call `t.Helper()` as the first statement in helper functions.

## Temporary Directories

`t.TempDir()` creates a temporary directory that is automatically removed when the test completes:

```go
func TestWriteFile(t *testing.T) {
    dir := t.TempDir()
    path := filepath.Join(dir, "output.txt")
    // write to path — dir is cleaned up automatically
}
```

## Environment Variables

`t.Setenv(key, value)` sets an environment variable and restores the original value after the test. Cannot be used in parallel tests.

```go
func TestWithEnv(t *testing.T) {
    t.Setenv("MY_CONFIG", "test-value")
    // original value restored after test
}
```

## Skipping Tests

Skip a test conditionally using `t.Skip`, `t.Skipf`, or `t.SkipNow`:

```go
func TestIntegration(t *testing.T) {
    if testing.Short() {
        t.Skip("skipping integration test in short mode")
    }
    // ...
}

func TestRequiresDocker(t *testing.T) {
    if os.Getenv("DOCKER_HOST") == "" {
        t.Skip("DOCKER_HOST not set")
    }
    // ...
}
```

## Example Functions

Example functions serve as documentation and are verified by `go test`:

```go
func ExampleAdd() {
    fmt.Println(Add(1, 2))
    // Output: 3
}
```

The `// Output:` comment is compared against stdout. Examples without an output comment are compiled but not executed. Use `// Unordered output:` when output order is non-deterministic.

Naming conventions:

```go
func Example() { ... }           // package example
func ExampleAdd() { ... }        // function Add
func ExampleCalc() { ... }       // type Calc
func ExampleCalc_Add() { ... }   // method Calc.Add
func ExampleAdd_second() { ... } // second example for Add (suffix starts lowercase)
```

## TestMain

`TestMain` controls global test setup and teardown. Define it in any `_test.go` file in the package:

```go
func TestMain(m *testing.M) {
    // setup
    code := m.Run()
    // teardown
    os.Exit(code)
}
```

Use `TestMain` for package-level resources (database connections, server processes). It is not necessary for per-test resources — use `t.Cleanup` instead.

## Running Tests

```bash
# Run all tests in the current module
go test ./...

# Run with verbose output
go test -v ./...

# Run tests matching a pattern (regexp)
go test -run TestAdd ./...

# Run a specific subtest
go test -run TestDivide/divide_by_zero ./...

# Run with race detector
go test -race ./...

# Run with coverage
go test -cover ./...

# Generate HTML coverage report
go test -coverprofile=coverage.out ./... && go tool cover -html=coverage.out

# Skip slow tests
go test -short ./...

# Set test timeout
go test -timeout 30s ./...

# Run benchmarks
go test -bench=. ./...

# Run benchmarks with memory allocation stats
go test -bench=. -benchmem ./...
```

## Quick Reference: `testing.T` Methods

| Method | Purpose |
|---|---|
| `t.Run(name, f)` | Create named subtest |
| `t.Parallel()` | Mark test as parallel |
| `t.Helper()` | Mark as helper function |
| `t.Cleanup(f)` | Register teardown function |
| `t.TempDir()` | Create auto-cleaned temp directory |
| `t.Setenv(k, v)` | Set env var, auto-restored after test |
| `t.Chdir(dir)` | Change working dir, auto-restored |
| `t.Context()` | Context canceled before cleanup runs |
| `t.Log(args...)` | Log (shown on failure or with `-v`) |
| `t.Logf(format, args...)` | Log formatted |
| `t.Error(args...)` | Fail + log, continue |
| `t.Errorf(format, args...)` | Fail + log formatted, continue |
| `t.Fatal(args...)` | Fail + log, stop |
| `t.Fatalf(format, args...)` | Fail + log formatted, stop |
| `t.Skip(args...)` | Skip + log, stop |
| `t.Skipf(format, args...)` | Skip + log formatted, stop |
| `t.Name()` | Return full test name |
| `t.Failed()` | Reports whether test has failed |
| `t.Deadline()` | Returns test deadline from `-timeout` flag |

## Additional Resources

For benchmarks, fuzz testing, and advanced patterns:

- **`references/benchmarks-and-fuzzing.md`** — `testing.B` API, `b.Loop()` style, parallel benchmarks, `testing.F` fuzz tests, `TestMain` patterns, and `AllocsPerRun`
