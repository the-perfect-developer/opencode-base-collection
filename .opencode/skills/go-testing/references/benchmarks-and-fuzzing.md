# Go Testing: Benchmarks, Fuzz Tests & Advanced Patterns

Reference for `testing.B`, `testing.F`, custom metrics, parallel benchmarks, fuzz testing, and advanced test organisation.

## Table of Contents

- [Benchmarks](#benchmarks)
- [Benchmark Timer Control](#benchmark-timer-control)
- [Parallel Benchmarks](#parallel-benchmarks)
- [Custom Metrics](#custom-metrics)
- [Fuzz Testing](#fuzz-testing)
- [AllocsPerRun](#allocsperrun)
- [TestMain Patterns](#testmain-patterns)
- [Context in Tests](#context-in-tests)
- [Subtest Teardown Pattern](#subtest-teardown-pattern)

---

## Benchmarks

Benchmark functions have the signature `func BenchmarkXxx(*testing.B)` and run only when `-bench` is passed to `go test`.

### `b.Loop()` Style (Go 1.24+, Preferred)

```go
func BenchmarkEncode(b *testing.B) {
    data := generateTestData() // setup outside loop — not measured
    for b.Loop() {
        _ = encode(data)
    }
    // cleanup after loop — not measured
}
```

`b.Loop()` handles timer management automatically:
- Resets the timer on the first call
- Stops the timer when it returns `false`
- Setup and cleanup around the loop are excluded from measurement

### `b.N` Style (Pre-Go 1.24, Still Valid)

```go
func BenchmarkEncode(b *testing.B) {
    data := generateTestData()
    b.ResetTimer() // exclude setup from measurement
    for range b.N {
        _ = encode(data)
    }
}
```

The benchmark framework calls the function multiple times, adjusting `b.N` until the benchmark runs long enough to be statistically reliable. Any setup before the loop is re-run each iteration, so `b.ResetTimer()` is essential.

Prefer `b.Loop()` for new benchmarks — it is simpler and more efficient.

### Running Benchmarks

```bash
# Run all benchmarks
go test -bench=. ./...

# Run benchmarks matching a pattern
go test -bench=BenchmarkEncode ./...

# Run with memory stats
go test -bench=. -benchmem ./...

# Run with multiple CPU counts
go test -bench=. -cpu=1,2,4,8 ./...

# Run with a fixed number of iterations
go test -bench=. -benchtime=1000x ./...

# Run for a fixed duration
go test -bench=. -benchtime=5s ./...
```

### Reading Benchmark Output

```
BenchmarkEncode-8   1234567   987 ns/op   256 B/op   4 allocs/op
```

| Field | Meaning |
|---|---|
| `-8` | `GOMAXPROCS` value during benchmark |
| `1234567` | Number of iterations (`b.N` or loop count) |
| `987 ns/op` | Nanoseconds per iteration |
| `256 B/op` | Bytes allocated per iteration (with `-benchmem`) |
| `4 allocs/op` | Heap allocations per iteration (with `-benchmem`) |

---

## Benchmark Timer Control

For `b.N`-style benchmarks that need fine-grained timer control:

```go
func BenchmarkWithDB(b *testing.B) {
    db := openDB()
    defer db.Close()

    b.ResetTimer() // exclude DB setup

    for range b.N {
        b.StopTimer()
        tx := db.Begin() // setup per-iteration, not measured
        b.StartTimer()

        runOperation(tx)

        b.StopTimer()
        tx.Rollback() // teardown per-iteration, not measured
        b.StartTimer()
    }
}
```

| Method | Purpose |
|---|---|
| `b.ResetTimer()` | Reset elapsed time and memory stats |
| `b.StartTimer()` | Resume timing (called automatically) |
| `b.StopTimer()` | Pause timing |
| `b.Elapsed()` | Return measured duration so far |

With `b.Loop()`, timer control is automatic — `ResetTimer`/`StartTimer`/`StopTimer` are not needed.

---

## Parallel Benchmarks

`b.RunParallel` runs a benchmark body across multiple goroutines, controlled by `-cpu`:

```go
func BenchmarkConcurrentLookup(b *testing.B) {
    cache := NewCache()
    b.RunParallel(func(pb *testing.PB) {
        for pb.Next() {
            cache.Get("key")
        }
    })
}
```

`pb.Next()` returns `true` while the benchmark should continue iterating. Each goroutine calls `pb.Next()` independently.

Set the number of goroutines per CPU with `b.SetParallelism(p)` (default: `GOMAXPROCS`).

---

## Custom Metrics

`b.ReportMetric` reports custom measurements alongside standard ns/op:

```go
func BenchmarkSort(b *testing.B) {
    data := generateData(1000)
    b.ResetTimer()
    var comparisons int64
    for range b.N {
        comparisons += sortWithCount(data)
    }
    b.ReportMetric(float64(comparisons)/float64(b.N), "comparisons/op")
}
```

`b.SetBytes(n)` reports throughput in MB/s:

```go
func BenchmarkRead(b *testing.B) {
    data := make([]byte, 4096)
    b.SetBytes(int64(len(data)))
    for b.Loop() {
        processBytes(data)
    }
    // output: 4096 B/op, X MB/s
}
```

`b.ReportAllocs()` enables per-allocation reporting without requiring `-benchmem`:

```go
func BenchmarkAlloc(b *testing.B) {
    b.ReportAllocs()
    for b.Loop() {
        _ = make([]byte, 64)
    }
}
```

---

## Fuzz Testing

Fuzz test functions have the signature `func FuzzXxx(*testing.F)`.

### Structure

```go
func FuzzParseURL(f *testing.F) {
    // Seed corpus — known-good inputs
    f.Add("https://example.com")
    f.Add("http://localhost:8080/path?query=value")
    f.Add("")

    // Fuzz target — called with each generated input
    f.Fuzz(func(t *testing.T, input string) {
        u, err := url.Parse(input)
        if err != nil {
            t.Skip() // invalid input is fine, not a bug
        }
        // Invariant: re-encoding must round-trip
        if u.String() != input {
            // Only fail if the invariant is violated, not for all differences
        }
    })
}
```

### Running Fuzz Tests

```bash
# Run fuzz tests with seed corpus only (like normal tests)
go test -run FuzzParseURL ./...

# Actually fuzz (generate random inputs)
go test -fuzz=FuzzParseURL ./...

# Fuzz with a time limit
go test -fuzz=FuzzParseURL -fuzztime=60s ./...

# Reproduce a specific failure from the corpus
go test -run=FuzzParseURL/testdata/fuzz/FuzzParseURL/abc123 ./...
```

### Seed Corpus Files

Store seed inputs in `testdata/fuzz/<FuzzName>/` as text files. Each file contains the input values as a Go syntax literal:

```
go test fuzz v1
string("https://example.com/path")
```

The fuzzing engine saves failing inputs to `testdata/fuzz/<FuzzName>/` automatically so they become regression tests.

### Fuzz Target Rules

- The fuzz target receives `*testing.T` plus one or more parameters matching the types passed to `f.Add`
- Supported seed types: `string`, `[]byte`, `int`, `int8`–`int64`, `uint`, `uint8`–`uint64`, `float32`, `float64`, `bool`
- Use `t.Skip()` for inputs that are structurally invalid (not a bug)
- Use `t.Fatal`/`t.Error` for actual invariant violations

---

## AllocsPerRun

`testing.AllocsPerRun` measures average heap allocations per call outside a benchmark:

```go
func TestZeroAllocations(t *testing.T) {
    result := testing.AllocsPerRun(100, func() {
        _ = fastPath("input")
    })
    if result != 0 {
        t.Errorf("fastPath allocated %v times; want 0", result)
    }
}
```

Useful for documenting zero-allocation guarantees in unit tests.

---

## TestMain Patterns

### Database Integration Tests

```go
var testDB *sql.DB

func TestMain(m *testing.M) {
    var err error
    testDB, err = sql.Open("postgres", os.Getenv("TEST_DATABASE_URL"))
    if err != nil {
        fmt.Fprintf(os.Stderr, "failed to open test DB: %v\n", err)
        os.Exit(1)
    }
    if err = testDB.Ping(); err != nil {
        fmt.Fprintf(os.Stderr, "failed to ping test DB: %v\n", err)
        os.Exit(1)
    }

    code := m.Run()

    testDB.Close()
    os.Exit(code)
}
```

### Conditional Skip

```go
func TestMain(m *testing.M) {
    if os.Getenv("INTEGRATION") == "" {
        fmt.Println("Skipping integration tests (set INTEGRATION=1 to run)")
        os.Exit(0)
    }
    os.Exit(m.Run())
}
```

### Flag Parsing

`flag.Parse` is not called before `TestMain`. Call it explicitly if the setup depends on flags:

```go
var verbose = flag.Bool("mytest.verbose", false, "enable verbose test output")

func TestMain(m *testing.M) {
    flag.Parse()
    if *verbose {
        log.SetFlags(log.LstdFlags | log.Lshortfile)
    }
    os.Exit(m.Run())
}
```

---

## Context in Tests

`t.Context()` (Go 1.24+) returns a context that is canceled just before cleanup functions run:

```go
func TestWithContext(t *testing.T) {
    ctx := t.Context()
    result, err := client.Fetch(ctx, "https://example.com")
    if err != nil {
        t.Fatalf("Fetch failed: %v", err)
    }
    _ = result
}
```

Useful for canceling goroutines or HTTP requests when a test ends. Combined with `t.Cleanup`:

```go
func TestGoroutineLeak(t *testing.T) {
    ctx := t.Context()
    done := make(chan struct{})

    go func() {
        defer close(done)
        select {
        case <-ctx.Done():
        case <-time.After(10 * time.Second):
        }
    }()

    t.Cleanup(func() {
        <-done // wait for goroutine to exit
    })

    // test body
}
```

---

## Subtest Teardown Pattern

Run teardown after a group of parallel subtests completes:

```go
func TestSuite(t *testing.T) {
    db := setupDB(t)

    // This inner Run does not return until all parallel subtests finish
    t.Run("group", func(t *testing.T) {
        t.Run("read", func(t *testing.T) {
            t.Parallel()
            testRead(t, db)
        })
        t.Run("write", func(t *testing.T) {
            t.Parallel()
            testWrite(t, db)
        })
        t.Run("delete", func(t *testing.T) {
            t.Parallel()
            testDelete(t, db)
        })
    })

    // Teardown runs here — after all parallel subtests complete
    db.DropAll()
}
```

---

## `testing.B` Quick Reference

| Method | Purpose |
|---|---|
| `b.Loop()` | Preferred loop control (Go 1.24+) |
| `b.N` | Iteration count for `b.N`-style benchmarks |
| `b.ResetTimer()` | Exclude setup from measurement |
| `b.StartTimer()` | Resume timing |
| `b.StopTimer()` | Pause timing |
| `b.Elapsed()` | Measured elapsed time so far |
| `b.ReportAllocs()` | Enable allocation reporting |
| `b.ReportMetric(n, unit)` | Report custom metric |
| `b.SetBytes(n)` | Report throughput |
| `b.RunParallel(f)` | Run parallel benchmark |
| `b.SetParallelism(p)` | Set goroutines per CPU |
| `b.Run(name, f)` | Create sub-benchmark |

## `testing.F` Quick Reference

| Method | Purpose |
|---|---|
| `f.Add(args...)` | Add seed corpus entry |
| `f.Fuzz(func(t *T, ...))` | Register fuzz target |
| `f.Skip(...)` | Skip entire fuzz test |
| `f.Fatal(...)` | Fail fuzz test |
