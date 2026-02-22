---
name: pydantic
description: This skill should be used when the user asks to "validate data with pydantic", "create a pydantic model", "use pydantic best practices", "write pydantic validators", or needs guidance on pydantic v2 patterns, serialization, configuration, or performance optimization.
---

# Pydantic v2 Best Practices

Pydantic is the most widely used data validation library for Python. This skill covers idiomatic patterns, common pitfalls, and performance guidance for Pydantic v2 (the current major version).

## Models

### Define models by inheriting from `BaseModel`

```python
from pydantic import BaseModel, ConfigDict

class User(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True, extra='forbid')

    id: int
    name: str
    email: str | None = None
```

Key rules:
- Use `model_config = ConfigDict(...)` — never the deprecated V1 `class Config`.
- Set `extra='forbid'` to reject unexpected fields in strict APIs; use `extra='ignore'` (default) or `extra='allow'` when appropriate.
- Avoid naming a field the same as its type annotation (`int: int` breaks validation).

### Validate data correctly

```python
# From dict / Python objects
user = User.model_validate({'id': 1, 'name': 'Alice'})

# From JSON bytes/str — faster than model_validate(json.loads(...))
user = User.model_validate_json('{"id": 1, "name": "Alice"}')

# From ORM / arbitrary objects
class UserORM: ...
user = User.model_validate(orm_obj, from_attributes=True)
```

Always prefer `model_validate_json()` over `model_validate(json.loads(...))` for JSON input — the former validates internally without an extra Python-side parse step.

### Use `model_post_init` instead of a custom `__init__`

```python
from typing import Any
from pydantic import BaseModel

class MyModel(BaseModel):
    value: int

    def model_post_init(self, context: Any) -> None:
        # Runs after all field validators succeed
        self._cache: dict = {}
```

Defining a custom `__init__` bypasses validation parameters (strictness, extra, context). Use `model_post_init` for side effects after initialization.

### Copy models with `model_copy`

```python
updated = user.model_copy(update={'name': 'Bob'})
deep_copy = user.model_copy(deep=True)
```

---

## Fields

### Use the `Annotated` pattern for reusable constraints

```python
from typing import Annotated
from pydantic import BaseModel, Field

PositivePrice = Annotated[float, Field(gt=0, description='Price in USD')]
ShortString = Annotated[str, Field(max_length=100)]

class Product(BaseModel):
    name: ShortString
    price: PositivePrice
    quantity: Annotated[int, Field(ge=0)] = 0
```

The annotated pattern makes constraints composable and reusable across models, unlike `field: type = Field(...)` which ties the constraint to one model.

### Provide field metadata for JSON Schema

```python
from pydantic import BaseModel, Field

class Article(BaseModel):
    title: str = Field(
        min_length=1,
        max_length=200,
        title='Article Title',
        description='The main headline',
        examples=['Pydantic v2 released'],
    )
```

### Use `default_factory` for mutable defaults

```python
from pydantic import BaseModel, Field

class Order(BaseModel):
    # Correct — factory called per instance
    items: list[str] = Field(default_factory=list)
    tags: set[str] = Field(default_factory=set)
```

Pydantic handles non-hashable defaults (like `[]`, `{}`) safely by deep-copying them, but `default_factory` is the explicit, recommended approach.

### Use aliases to decouple field names from wire formats

```python
from pydantic import BaseModel, Field, ConfigDict

class Response(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    user_id: int = Field(alias='userId')          # validation + serialization
    created_at: str = Field(serialization_alias='createdAt')  # serialization only
```

---

## Validators

### Choose the right validator mode

| Mode | When to use |
|------|-------------|
| `after` | Post-type-coercion checks; input is already the correct type |
| `before` | Pre-coercion transformations; input may be raw/arbitrary |
| `plain` | Full replacement of Pydantic's logic for a field |
| `wrap` | Need to intercept errors or run code both before and after |

Prefer `after` validators — they receive the already-coerced value and are easier to type correctly.

### Write reusable validators with the annotated pattern

```python
from typing import Annotated
from pydantic import AfterValidator, BaseModel

def must_be_even(v: int) -> int:
    if v % 2 != 0:
        raise ValueError(f'{v} is not even')
    return v

EvenInt = Annotated[int, AfterValidator(must_be_even)]

class Config(BaseModel):
    batch_size: EvenInt
    worker_count: EvenInt
```

### Use `field_validator` to apply one function to multiple fields

```python
from pydantic import BaseModel, field_validator

class User(BaseModel):
    first_name: str
    last_name: str

    @field_validator('first_name', 'last_name', mode='before')
    @classmethod
    def strip_whitespace(cls, v: str) -> str:
        return v.strip()
```

### Use `model_validator` for cross-field checks

```python
from typing_extensions import Self
from pydantic import BaseModel, model_validator

class DateRange(BaseModel):
    start: int
    end: int

    @model_validator(mode='after')
    def check_range(self) -> Self:
        if self.end <= self.start:
            raise ValueError('end must be greater than start')
        return self
```

### Raise the right exception type in validators

- `ValueError` — standard choice for most validation failures.
- `AssertionError` — works but is skipped under Python's `-O` flag; avoid in production validators.
- `PydanticCustomError` — use when custom error types and structured error metadata are needed.

```python
from pydantic_core import PydanticCustomError

raise PydanticCustomError(
    'invalid_format',
    'Value {value!r} does not match the expected format',
    {'value': v},
)
```

### Pass context to validators when needed

```python
from pydantic import BaseModel, ValidationInfo, field_validator

class Document(BaseModel):
    text: str

    @field_validator('text', mode='after')
    @classmethod
    def filter_words(cls, v: str, info: ValidationInfo) -> str:
        if isinstance(info.context, dict):
            banned = info.context.get('banned_words', set())
            v = ' '.join(w for w in v.split() if w not in banned)
        return v

doc = Document.model_validate(
    {'text': 'hello world'},
    context={'banned_words': {'hello'}},
)
```

---

## Error Handling

Catch `ValidationError` and inspect `.errors()` for structured detail:

```python
from pydantic import BaseModel, ValidationError

class Item(BaseModel):
    price: float
    quantity: int

try:
    Item(price='bad', quantity=-1)
except ValidationError as exc:
    for error in exc.errors():
        print(error['loc'], error['msg'], error['type'])
```

One `ValidationError` aggregates all field errors — never raised per-field individually.

---

## Quick Reference

| Task | Recommended API |
|------|-----------------|
| Validate from dict | `Model.model_validate(data)` |
| Validate from JSON | `Model.model_validate_json(json_str)` |
| Validate from ORM | `Model.model_validate(obj, from_attributes=True)` |
| Dump to dict | `model.model_dump()` |
| Dump to JSON | `model.model_dump_json()` |
| Dump only set fields | `model.model_dump(exclude_unset=True)` |
| Copy with changes | `model.model_copy(update={...})` |
| Skip validation | `Model.model_construct(...)` — only for pre-validated data |
| Rebuild after forward refs | `Model.model_rebuild()` |

---

## Additional Resources

- **`references/validators-and-fields.md`** — Detailed validator modes, field constraints, discriminated unions, and computed fields.
- **`references/serialization-and-config.md`** — Serializers, `model_dump` options, `ConfigDict` reference, and ORM integration.
- **`references/performance.md`** — Performance tips: `TypeAdapter` reuse, tagged unions, `TypedDict` vs nested models, `FailFast`, and more.
