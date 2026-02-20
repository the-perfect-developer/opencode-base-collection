---
name: python
description: Apply Python style guide conventions to code
license: CC-BY-3.0
compatibility: opencode
metadata:
  language: python
  source: https://google.github.io/styleguide/pyguide.html
  audience: developers
---

## What I do

I help you write Python code that follows professional style guide conventions. This includes:

- Enforcing naming conventions (snake_case, PascalCase, UPPER_CASE)
- Applying proper docstring formatting (module, class, function, method docstrings)
- Managing imports correctly (full package paths, proper ordering)
- Implementing type annotations following best practices
- Following line length and indentation rules
- Using proper exception handling patterns
- Writing clean, readable code that matches professional standards

## When to use me

Use this skill when:
- Writing new Python code that should follow style guide conventions
- Refactoring existing Python code to match best practices
- Reviewing Python code for style compliance
- Adding documentation to Python modules, classes, or functions
- Setting up type hints for Python code
- Organizing imports in Python files

## Key style rules I enforce

### Naming Conventions

- **Modules**: `module_name.py` (lowercase with underscores)
- **Packages**: `package_name` (lowercase, no underscores preferred)
- **Classes**: `ClassName` (PascalCase)
- **Functions**: `function_name()` (lowercase with underscores)
- **Variables**: `variable_name` (lowercase with underscores)
- **Constants**: `CONSTANT_NAME` (uppercase with underscores)
- **Private attributes**: `_private_var` (leading underscore)
- **Internal globals**: `_internal_global` (leading underscore)
- **Strongly private attributes**: `__secret_var` (double leading underscore for name mangling)

**Important**: For strongly private attributes that should be protected via name mangling, always use double underscore prefix:

```python
class MyClass:
    def __init__(self):
        # Public attribute
        self.public_var: str = "visible"
        
        # Protected attribute (convention only)
        self._protected_var: str = "use with care"
        
        # Private attribute (name mangled to _MyClass__secret)
        self.__secret: str = "truly private"
```

### Imports

Use full package paths:
```python
# Good
from absl import flags
from doctor.who import jodie

# Bad
import jodie  # Ambiguous
```

Import order:
1. Standard library imports
2. Third-party imports
3. Local application imports

### Docstrings

Always use triple-quoted strings `"""` format.

**Function docstring template**:
```python
def fetch_smalltable_rows(
    table_handle: smalltable.Table,
    keys: Sequence[bytes | str],
    require_all_keys: bool = False,
) -> Mapping[bytes, tuple[str, ...]]:
    """Fetches rows from a Smalltable.

    Retrieves rows pertaining to the given keys from the Table instance
    represented by table_handle. String keys will be UTF-8 encoded.

    Args:
        table_handle: An open smalltable.Table instance.
        keys: A sequence of strings representing the key of each table
            row to fetch. String keys will be UTF-8 encoded.
        require_all_keys: If True only rows with values set for all keys will be
            returned.

    Returns:
        A dict mapping keys to the corresponding table row data
        fetched. Each row is represented as a tuple of strings. For
        example:

        {b'Serak': ('Rigel VII', 'Preparer'),
         b'Zim': ('Irk', 'Invader'),
         b'Lrrr': ('Omicron Persei 8', 'Emperor')}

        Returned keys are always bytes. If a key from the keys argument is
        missing from the dictionary, then that row was not found in the
        table (and require_all_keys must have been False).

    Raises:
        IOError: An error occurred accessing the smalltable.
    """
```

**Class docstring template**:
```python
class SampleClass:
    """Summary of class here.

    Longer class information...
    Longer class information...

    Attributes:
        likes_spam: A boolean indicating if we like SPAM or not.
        eggs: An integer count of the eggs we have laid.
    """

    def __init__(self, likes_spam: bool = False):
        """Initializes the instance based on spam preference.

        Args:
          likes_spam: Defines if instance exhibits this preference.
        """
        self.likes_spam = likes_spam
        self.eggs = 0
```

**Module docstring template**:
```python
"""A one-line summary of the module or program, terminated by a period.

Leave one blank line. The rest of this docstring should contain an
overall description of the module or program. Optionally, it may also
contain a brief description of exported classes and functions and/or usage
examples.

Typical usage example:

  foo = ClassFoo()
  bar = foo.function_bar()
"""
```

### Type Annotations

Always add type hints to function signatures:
```python
def func(a: int) -> list[int]:
    return [a * 2]

# For variables when type isn't obvious
a: SomeType = some_func()

# Use modern syntax (Python 3.10+)
def process(data: str | None = None) -> dict[str, int]:
    pass
```

**Important**: Use capitalized type hints from `typing` module instead of built-in lowercase types:

```python
from typing import Dict, List, Set, Tuple, Optional

# Good - using typing module
def process_users(users: List[str]) -> Dict[str, int]:
    return {user: len(user) for user in users}

def get_config() -> Dict[str, List[int]]:
    return {"ports": [8080, 8081]}

# Good - with Optional
def find_user(user_id: int) -> Optional[str]:
    return None

# Bad - using built-in lowercase types (avoid)
def process_users(users: list[str]) -> dict[str, int]:
    return {user: len(user) for user in users}
```

Note: While Python 3.9+ supports lowercase `list`, `dict`, etc., using the `typing` module variants (`List`, `Dict`) is preferred for consistency and broader compatibility.

### Line Length and Formatting

- Maximum line length: **80 characters**
- Use implicit line continuation with parentheses (not backslashes)
- Indent with **4 spaces** (never tabs)
- Two blank lines between top-level definitions
- One blank line between method definitions

```python
# Good
foo_bar(
    self, width, height, color='black', design=None, x='foo',
    emphasis=None, highlight=0
)

# Good
if (width == 0 and height == 0 and
    color == 'red' and emphasis == 'strong'):
    pass

# Bad - backslash continuation
if width == 0 and height == 0 and \
    color == 'red' and emphasis == 'strong':
    pass
```

### Exception Handling

```python
# Good
def connect_to_next_port(self, minimum: int) -> int:
    """Connects to the next available port.

    Args:
        minimum: A port value greater or equal to 1024.

    Returns:
        The new minimum port.

    Raises:
        ConnectionError: If no available port is found.
    """
    if minimum < 1024:
        raise ValueError(f'Min. port must be at least 1024, not {minimum}.')
    
    port = self._find_next_port(minimum)
    if port is None:
        raise ConnectionError(
            f'Could not connect to service on port {minimum} or higher.')
    return port
```

### Default Arguments

Never use mutable objects as default values:
```python
# Good
def foo(a, b: list[int] | None = None):
    if b is None:
        b = []

# Bad
def foo(a, b: list[int] = []):
    pass
```

### Boolean Evaluations

Use implicit false when possible:
```python
# Good
if not users:
    print('no users')

if foo:
    bar()

# Check for None explicitly
if x is None:
    pass

# Bad
if len(users) == 0:
    print('no users')

if foo != []:
    bar()
```

### Comprehensions

Keep them simple - optimize for readability:
```python
# Good
result = [mapping_expr for value in iterable if filter_expr]

# Good
result = [
    is_valid(metric={'key': value})
    for value in interesting_iterable
    if a_longer_filter_expression(value)
]

# Bad - multiple for clauses
result = [(x, y) for x in range(10) for y in range(5) if x * y > 10]
```

### Loop Variables

**Important**: Always use underscore prefix for loop variables when you don't use the variable itself:

```python
# Good - using underscore when variable is not used
for _user in users:
    print("Processing a user")
    send_notification()

for _item in items:
    count += 1

# Good - using the variable
for user in users:
    print(f"Processing {user.name}")
    user.process()

# Bad - not using underscore when variable is unused
for user in users:  # 'user' is never referenced
    print("Processing a user")
```

This convention makes it immediately clear that the loop variable is intentionally unused.

### Linting

- Run `pylint` on all code
- Suppress warnings with inline comments when appropriate:
```python
def do_PUT(self):  # WSGI name, so pylint: disable=invalid-name
    pass
```

## The Zen of Python

Follow these fundamental principles from PEP 20 (The Zen of Python):

1. **Beautiful is better than ugly** - Write elegant, readable code
2. **Explicit is better than implicit** - Be clear about what your code does
3. **Simple is better than complex** - Favor straightforward solutions
4. **Complex is better than complicated** - When complexity is needed, keep it organized
5. **Flat is better than nested** - Avoid deep nesting when possible
6. **Sparse is better than dense** - Use whitespace for readability
7. **Readability counts** - Code is read more often than written
8. **Special cases aren't special enough to break the rules** - Consistency matters
9. **Although practicality beats purity** - Pragmatism over dogmatism when needed
10. **Errors should never pass silently** - Handle exceptions explicitly
11. **In the face of ambiguity, refuse the temptation to guess** - Be explicit
12. **There should be one-- and preferably only one --obvious way to do it** - Favor the idiomatic approach
13. **Now is better than never** - Don't overthink, start coding
14. **Although never is often better than *right* now** - But plan before rushing
15. **If the implementation is hard to explain, it's a bad idea** - Simplicity test
16. **If the implementation is easy to explain, it may be a good idea** - Clarity indicator
17. **Namespaces are one honking great idea** - Use them to organize code

Access these at any time by running:
```python
import this
```

**Key principles to remember**:
- Explicit > Implicit
- Simple > Complex  
- Readability counts
- One obvious way to do things

## How I work

When you ask me to help with Python code, I will:

1. **Analyze** the code for style violations
2. **Suggest** specific improvements citing relevant style rules
3. **Rewrite** code sections to match professional style
4. **Add** proper docstrings following standard format
5. **Format** imports, line lengths, and indentation correctly
6. **Apply** type annotations where missing or incorrect

I prioritize readability and maintainability over brevity. When there's ambiguity, I'll ask clarifying questions about your specific use case.

## References

- Full style guide: https://google.github.io/styleguide/pyguide.html
- PEP 8 (Python's general style guide): https://peps.python.org/pep-0008/
- PEP 257 (Docstring conventions): https://peps.python.org/pep-0257/
- Type hints (PEP 484): https://peps.python.org/pep-0484/
