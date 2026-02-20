---
name: go
description: Apply Go style guide conventions to code
license: CC-BY-4.0
compatibility: opencode
metadata:
  language: go
  source: https://google.github.io/styleguide/go/
  audience: developers
---

## What I do

I help you write Go code that follows professional style guide conventions based on Google's Go Style Guide. This includes:

- Enforcing naming conventions (MixedCaps, mixedCaps)
- Applying proper documentation and commentary
- Managing imports correctly (grouping, ordering, renaming)
- Following formatting rules (gofmt compliant)
- Implementing error handling patterns
- Writing clear, simple, and maintainable code
- Applying concurrency best practices
- Structuring packages effectively

## When to use me

Use this skill when:
- Writing new Go code that should follow style guide conventions
- Refactoring existing Go code to match best practices
- Reviewing Go code for style compliance
- Adding documentation to Go packages, functions, or types
- Organizing imports in Go files
- Designing APIs and interfaces
- Handling errors appropriately

## Style Principles

Go style follows these core principles in order of importance:

1. **Clarity** - The code's purpose and rationale is clear to the reader
2. **Simplicity** - The code accomplishes its goal in the simplest way possible
3. **Concision** - The code has a high signal-to-noise ratio
4. **Maintainability** - The code can be easily maintained
5. **Consistency** - The code is consistent with the broader codebase

## Key style rules I enforce

### Formatting

All Go source files **must** conform to `gofmt` output:
```bash
gofmt -w .
```

- No fixed line length (prefer refactoring over splitting)
- Use `MixedCaps` or `mixedCaps` (never snake_case)
- Let the code speak for itself when possible

### Naming Conventions

**Packages**:
```go
// Good
package creditcard
package tabwriter
package oauth2

// Bad
package credit_card
package tabWriter
package oAuth2
```

**Functions and Methods**:
```go
// Good - avoid repetition with package name
package yamlconfig
func Parse(input string) (*Config, error)

// Bad - repetitive
func ParseYAMLConfig(input string) (*Config, error)
```

**Variables**:
- Short names in small scopes: `i`, `c`, `db`
- Longer names in larger scopes: `userCount`, `databaseConnection`
- Avoid type in name: `users` not `userSlice`

**Constants**:
```go
// Good
const MaxPacketSize = 512
const ExecuteBit = 1 << iota

// Bad
const MAX_PACKET_SIZE = 512
const kMaxBufferSize = 1024
```

**Initialisms**:
Keep same case throughout:
```go
// Good
func ServeHTTP(w http.ResponseWriter, r *http.Request)
func ProcessXMLAPI() error
var userID string

// Bad
func ServeHttp()
func ProcessXmlApi()
var userId string
```

**Receiver Names**:
- Short (1-2 letters)
- Abbreviation of type
- Consistent across methods

```go
// Good
func (c *Client) Get(url string) (*Response, error)
func (c *Client) Post(url string, body io.Reader) (*Response, error)

// Bad
func (client *Client) Get(url string) (*Response, error)
func (this *Client) Post(url string, body io.Reader) (*Response, error)
```

### Documentation

**Package Comments**:
```go
// Package math provides basic constants and mathematical functions.
//
// This package does not guarantee bit-identical results across architectures.
package math
```

**Function Comments**:
```go
// Good - complete sentence starting with function name
// Join concatenates the elements of its first argument to create a single string.
// The separator string sep is placed between elements in the resulting string.
func Join(elems []string, sep string) string

// Bad
// This function joins strings
func Join(elems []string, sep string) string
```

**Comment Sentences**:
- Complete sentences for doc comments
- Capitalize and punctuate properly
- Start with the name being described

### Imports

**Import Grouping** (separated by blank lines):
1. Standard library packages
2. Other (project and vendored) packages
3. Protocol Buffer imports
4. Side-effect imports

```go
// Good
package main

import (
    "fmt"
    "hash/adler32"
    "os"

    "github.com/dsnet/compress/flate"
    "golang.org/x/text/encoding"

    foopb "myproj/foo/proto/proto"

    _ "myproj/rpc/protocols/dial"
)
```

**Import Renaming**:
```go
// Good - clear and descriptive
import (
    foogrpc "path/to/package/foo_service_go_grpc"
    foopb "path/to/package/foo_service_go_proto"
)

// Avoid - unless necessary
import (
    foo "some/really/long/package/path"
)
```

**Never use import dot** (except in tests):
```go
// Bad
import . "foo"

// Good
import "foo"
```

### Error Handling

**Return errors, don't panic**:
```go
// Good
func Open(path string) (*File, error) {
    f, err := os.Open(path)
    if err != nil {
        return nil, fmt.Errorf("open %s: %w", path, err)
    }
    return f, nil
}

// Bad - don't panic on errors
func Open(path string) *File {
    f, err := os.Open(path)
    if err != nil {
        panic(err)
    }
    return f
}
```

**Error strings**:
```go
// Good - lowercase, no punctuation
err := fmt.Errorf("something bad happened")

// Bad
err := fmt.Errorf("Something bad happened.")
```

**Handle errors**:
```go
// Good
if err := doSomething(); err != nil {
    return fmt.Errorf("failed to do something: %w", err)
}

// Bad - ignoring errors
_ = doSomething()
```

**Indent error flow**:
```go
// Good
if err != nil {
    // error handling
    return err
}
// normal code

// Bad - avoid else after error
if err != nil {
    // error handling
} else {
    // normal code
}
```

**Error wrapping**:
```go
// Good - use %w to wrap errors for errors.Is/As
return fmt.Errorf("process failed: %w", err)

// Good - use %v when you don't want wrapping
return fmt.Errorf("process failed: %v", err)
```

### Function Design

**Keep signatures simple**:
```go
// Good - signature on one line
func (r *Reader) Read(p []byte) (n int, err error)

// Good - named results when helpful
func WithTimeout(parent Context, d time.Duration) (ctx Context, cancel func())

// Bad - naked returns in long functions
func Process() (result int, err error) {
    // ... many lines ...
    result = 42
    return // unclear what's being returned
}
```

**Avoid repetition**:
```go
// Good
func (c *Config) WriteTo(w io.Writer) (int64, error)

// Bad - repetitive
func (c *Config) WriteConfigTo(w io.Writer) (int64, error)
```

### Nil Slices

Prefer nil slices over empty slices:
```go
// Good
var s []int // nil slice, len=0, cap=0

// Acceptable in most cases
s := []int{} // non-nil empty slice

// Don't force distinction between nil and empty
if len(s) == 0 { // works for both nil and empty
    // ...
}

// Bad
if s == nil { // usually not what you want
    // ...
}
```

### Interfaces

**Small interfaces**:
```go
// Good - single method interface
type Reader interface {
    Read(p []byte) (n int, err error)
}

// Good - composed interfaces
type ReadWriter interface {
    Reader
    Writer
}
```

**Accept interfaces, return structs**:
```go
// Good
func Process(r io.Reader) (*Result, error)

// Avoid unless necessary
func Process(r *os.File) (*Result, error)
```

### Concurrency

**Document concurrency**:
```go
// Good - document when NOT safe
// Cache stores expensive computation results.
//
// Methods are not safe for concurrent use.
type Cache struct { ... }

// Good - document when safe
// Client is safe for concurrent use by multiple goroutines.
type Client struct { ... }
```

**Context usage**:
```go
// Good - context as first parameter
func Process(ctx context.Context, data []byte) error

// Document if context behavior is special
// Run executes the worker's run loop.
//
// If the context is cancelled, Run returns a nil error.
func (w *Worker) Run(ctx context.Context) error
```

### Testing

**Table-driven tests**:
```go
// Good
func TestParse(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        want    int
        wantErr bool
    }{
        {name: "valid", input: "123", want: 123},
        {name: "invalid", input: "abc", wantErr: true},
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := Parse(tt.input)
            if (err != nil) != tt.wantErr {
                t.Errorf("Parse() error = %v, wantErr %v", err, tt.wantErr)
                return
            }
            if got != tt.want {
                t.Errorf("Parse() = %v, want %v", got, tt.want)
            }
        })
    }
}
```

**Test names**:
```go
// Good
func TestParse(t *testing.T)
func TestParse_InvalidInput(t *testing.T)
func TestClient_Get_Success(t *testing.T)

// Bad
func TestParseFunction(t *testing.T)
func Test_Parse(t *testing.T)
```

### Literal Formatting

**Field names in structs**:
```go
// Good - specify field names for external types
r := csv.Reader{
    Comma: ',',
    Comment: '#',
    FieldsPerRecord: 4,
}

// Good - field names optional for package-local types
okay := LocalType{42, "hello"}
```

**Matching braces**:
```go
// Good
items := []*Item{
    {Name: "foo"},
    {Name: "bar"},
}

// Bad - misaligned braces
items := []*Item{
    {Name: "foo"},
    {Name: "bar"}}
```

### Package Design

**Package size**:
- Not too large (thousands of lines in one package)
- Not too small (one type per package)
- Group related functionality
- Standard library is a good example

**Avoid utility packages**:
```go
// Bad - vague package names
package util
package common
package helper

// Good - specific, focused packages
package cache
package auth
package stringutil
```

## Common Patterns

### Options Pattern

```go
// Good - for optional configuration
type Options struct {
    Timeout time.Duration
    Retries int
}

func NewServer(addr string, opts Options) *Server

// Or using functional options
type Option func(*Server)

func WithTimeout(d time.Duration) Option {
    return func(s *Server) {
        s.timeout = d
    }
}

func NewServer(addr string, opts ...Option) *Server
```

### Constructor Pattern

```go
// Good - New for single type in package
package widget
func New() *Widget

// Good - NewX for multiple types
package widget
func NewWidget() *Widget
func NewGizmo() *Gizmo
```

### Cleanup Pattern

```go
// Good - document cleanup requirements
// Open opens a file for reading.
// The caller must call Close when done.
func Open(name string) (*File, error)

// Good - defer for cleanup
f, err := os.Open(filename)
if err != nil {
    return err
}
defer f.Close()
```

## Least Mechanism

Prefer simpler constructs:

1. Use core language features first (channels, slices, maps, loops)
2. Then standard library (http.Client, template engine)
3. Finally, external dependencies (only if necessary)

```go
// Good - use built-in
users := make(map[string]*User)

// Avoid - unless set operations are complex
import "github.com/deckarep/golang-set"
users := mapset.NewSet()
```

## How I work

When you ask me to help with Go code, I will:

1. **Analyze** the code for style violations and clarity issues
2. **Suggest** specific improvements citing relevant style principles
3. **Rewrite** code sections to match professional Go style
4. **Add** proper documentation following godoc conventions
5. **Format** imports, grouping, and structure correctly
6. **Simplify** complex code while maintaining correctness
7. **Apply** idiomatic Go patterns and best practices

I prioritize clarity, simplicity, and maintainability. The goal is code that is easy to read, understand, and maintain.

## References

- **Style Guide**: https://google.github.io/styleguide/go/guide
- **Style Decisions**: https://google.github.io/styleguide/go/decisions
- **Best Practices**: https://google.github.io/styleguide/go/best-practices
- **Effective Go**: https://go.dev/doc/effective_go
- **Code Review Comments**: https://github.com/golang/go/wiki/CodeReviewComments
- **Go Proverbs**: https://go-proverbs.github.io/
