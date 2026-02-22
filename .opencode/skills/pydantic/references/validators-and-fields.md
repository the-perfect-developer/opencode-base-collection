# Validators and Fields — Pydantic v2 Reference

## Table of Contents
1. [Field Constraints Quick Reference](#field-constraints-quick-reference)
2. [The Annotated Pattern in Depth](#the-annotated-pattern-in-depth)
3. [Validator Modes Explained](#validator-modes-explained)
4. [Validator Ordering](#validator-ordering)
5. [Model Validators](#model-validators)
6. [Validation Context and Info](#validation-context-and-info)
7. [Special Validator Utilities](#special-validator-utilities)
8. [Discriminated Unions](#discriminated-unions)
9. [Computed Fields](#computed-fields)
10. [Field Aliases In Depth](#field-aliases-in-depth)

---

## Field Constraints Quick Reference

| Constraint | Types | Example |
|---|---|---|
| `gt`, `ge`, `lt`, `le` | `int`, `float`, `Decimal` | `Field(gt=0)` |
| `min_length`, `max_length` | `str`, `list`, `set` | `Field(max_length=255)` |
| `pattern` | `str` | `Field(pattern=r'^\w+$')` |
| `max_digits`, `decimal_places` | `Decimal` | `Field(max_digits=10, decimal_places=2)` |
| `multiple_of` | `int`, `float` | `Field(multiple_of=5)` |
| `strict` | any | `Field(strict=True)` |
| `frozen` | any | `Field(frozen=True)` |
| `exclude` | any | `Field(exclude=True)` |
| `deprecated` | any | `Field(deprecated='Use X instead')` |

---

## The Annotated Pattern in Depth

The annotated pattern decouples type metadata from any single field, enabling reuse:

```python
from typing import Annotated
from pydantic import BaseModel, Field, AfterValidator

# Create reusable type aliases
NonEmptyStr = Annotated[str, Field(min_length=1)]
PositiveFloat = Annotated[float, Field(gt=0)]

def normalize_email(v: str) -> str:
    return v.strip().lower()

Email = Annotated[str, Field(pattern=r'.+@.+\..+'), AfterValidator(normalize_email)]

class User(BaseModel):
    name: NonEmptyStr
    price: PositiveFloat
    email: Email

# Compose: annotated types can be further annotated
AdminEmail = Annotated[Email, Field(description='Must be a company email')]
```

Key benefit: constraints live on the type, not spread across model classes. A change to `NonEmptyStr` propagates everywhere it is used.

### Annotating specific collection items

```python
from typing import Annotated
from pydantic import BaseModel, Field

class Order(BaseModel):
    # Constraint applies to each item, not the list itself
    quantities: list[Annotated[int, Field(gt=0)]]
    # Constraint applies to the list itself
    tags: Annotated[list[str], Field(max_length=10)]
```

---

## Validator Modes Explained

### `after` — Post-coercion validation (recommended default)

Receives the already-coerced value. Type-safe and straightforward.

```python
from typing import Annotated
from pydantic import AfterValidator, BaseModel

def ensure_https(url: str) -> str:
    if not url.startswith('https://'):
        raise ValueError('URL must use HTTPS')
    return url

class Config(BaseModel):
    webhook_url: Annotated[str, AfterValidator(ensure_https)]
```

### `before` — Pre-coercion transformation

Receives raw input. Use for normalization or accepting multiple input shapes.

```python
from typing import Annotated, Any
from pydantic import BaseModel, BeforeValidator

def coerce_to_list(v: Any) -> Any:
    if isinstance(v, str):
        return v.split(',')
    return v

class Params(BaseModel):
    tags: Annotated[list[str], BeforeValidator(coerce_to_list)]

# Both work:
Params(tags='a,b,c')   # -> tags=['a', 'b', 'c']
Params(tags=['a', 'b'])
```

### `plain` — Replace Pydantic's built-in validation entirely

No further Pydantic validation runs after a `plain` validator. Use sparingly — the field type annotation becomes documentation-only.

```python
from typing import Annotated, Any
from pydantic import BaseModel, PlainValidator

def parse_color(v: Any) -> tuple[int, int, int]:
    if isinstance(v, str) and v.startswith('#'):
        h = v.lstrip('#')
        return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))
    if isinstance(v, (list, tuple)) and len(v) == 3:
        return tuple(v)
    raise ValueError(f'Cannot parse color: {v!r}')

class Theme(BaseModel):
    primary: Annotated[tuple[int, int, int], PlainValidator(parse_color)]
```

### `wrap` — Intercept before and after, handle errors

```python
from typing import Any, Annotated
from pydantic import BaseModel, Field, ValidationError, ValidatorFunctionWrapHandler, WrapValidator

def truncate_on_overflow(v: Any, handler: ValidatorFunctionWrapHandler) -> str:
    try:
        return handler(v)
    except ValidationError as exc:
        if any(e['type'] == 'string_too_long' for e in exc.errors()):
            return str(v)[:50]
        raise

class Post(BaseModel):
    summary: Annotated[str, Field(max_length=50), WrapValidator(truncate_on_overflow)]
```

---

## Validator Ordering

When combining multiple annotated validators, `before`/`wrap` run **right-to-left**; `after` runs **left-to-right**.

```python
from typing import Annotated
from pydantic import BaseModel, AfterValidator, BeforeValidator, WrapValidator

class Model(BaseModel):
    name: Annotated[
        str,
        AfterValidator(runs_3rd),
        AfterValidator(runs_4th),
        BeforeValidator(runs_2nd),
        WrapValidator(runs_1st),
    ]
```

`field_validator` decorators are converted to annotated validators and appended after existing metadata, so they run after inline annotated validators in the same mode.

---

## Model Validators

### `mode='after'` — Cross-field validation on a fully instantiated model

```python
from typing_extensions import Self
from pydantic import BaseModel, model_validator

class BookingRequest(BaseModel):
    check_in: int   # epoch days
    check_out: int

    @model_validator(mode='after')
    def validate_dates(self) -> Self:
        if self.check_out <= self.check_in:
            raise ValueError('check_out must be after check_in')
        return self  # always return self
```

### `mode='before'` — Strip or transform raw input before any field validation

```python
from typing import Any
from pydantic import BaseModel, model_validator

class StrictPayload(BaseModel):
    amount: float

    @model_validator(mode='before')
    @classmethod
    def reject_sensitive_keys(cls, data: Any) -> Any:
        if isinstance(data, dict) and 'card_number' in data:
            raise ValueError('card_number must not be present')
        return data
```

### `mode='wrap'` — Logging, metrics, fallback handling

```python
import logging
from typing import Any
from typing_extensions import Self
from pydantic import BaseModel, ModelWrapValidatorHandler, ValidationError, model_validator

class ApiRequest(BaseModel):
    endpoint: str

    @model_validator(mode='wrap')
    @classmethod
    def log_on_failure(cls, data: Any, handler: ModelWrapValidatorHandler[Self]) -> Self:
        try:
            return handler(data)
        except ValidationError:
            logging.warning('Validation failed for %s with %r', cls.__name__, data)
            raise
```

### Inheritance behavior

A `model_validator` defined on a base class runs for all subclasses. Overriding in a subclass replaces the base class validator entirely — only the subclass version runs.

---

## Validation Context and Info

Pass runtime context (e.g., current user, feature flags) without coupling it to the model:

```python
from pydantic import BaseModel, ValidationInfo, field_validator

class FileUpload(BaseModel):
    filename: str
    size_bytes: int

    @field_validator('size_bytes', mode='after')
    @classmethod
    def check_size_limit(cls, v: int, info: ValidationInfo) -> int:
        ctx = info.context or {}
        limit = ctx.get('max_bytes', 10 * 1024 * 1024)  # 10 MB default
        if v > limit:
            raise ValueError(f'File too large: {v} > {limit}')
        return v

upload = FileUpload.model_validate(
    {'filename': 'photo.jpg', 'size_bytes': 5_000_000},
    context={'max_bytes': 20 * 1024 * 1024},
)
```

`info.data` (in field validators) holds already-validated fields that come before the current field in definition order. Do not access fields defined after the current field.

---

## Special Validator Utilities

### `InstanceOf` — Validate class membership without type coercion

```python
from pydantic import BaseModel, InstanceOf

class Animal: ...
class Dog(Animal): ...

class Kennel(BaseModel):
    residents: list[InstanceOf[Animal]]
```

### `SkipValidation` — Pass a value through untouched

```python
from pydantic import BaseModel, SkipValidation

class InternalModel(BaseModel):
    # Already-validated data from trusted source
    raw_payload: SkipValidation[dict]
```

### `PydanticUseDefault` — Signal that a field's default should be used

```python
from typing import Annotated, Any
from pydantic_core import PydanticUseDefault
from pydantic import BaseModel, BeforeValidator

def use_default_if_none(v: Any) -> Any:
    if v is None:
        raise PydanticUseDefault()
    return v

class Config(BaseModel):
    timeout: Annotated[int, BeforeValidator(use_default_if_none)] = 30
```

---

## Discriminated Unions

Tagged (discriminated) unions resolve the correct type via a literal field, avoiding costly try-all-branches resolution.

```python
from typing import Annotated, Literal
from pydantic import BaseModel, Field

class TextBlock(BaseModel):
    type: Literal['text']
    content: str

class ImageBlock(BaseModel):
    type: Literal['image']
    url: str
    alt: str = ''

class VideoBlock(BaseModel):
    type: Literal['video']
    url: str
    duration: int

class Page(BaseModel):
    blocks: list[Annotated[
        TextBlock | ImageBlock | VideoBlock,
        Field(discriminator='type'),
    ]]
```

For union members with different discriminator field names, use a `Discriminator` callable:

```python
from pydantic import Discriminator, Tag

def get_kind(v):
    if isinstance(v, dict):
        return v.get('type') or v.get('kind')
    return getattr(v, 'type', getattr(v, 'kind', None))

class Container(BaseModel):
    item: Annotated[
        Annotated[TypeA, Tag('a')] | Annotated[TypeB, Tag('b')],
        Discriminator(get_kind),
    ]
```

Prefer discriminated unions over bare `X | Y | Z` unions when possible — they are both faster and produce clearer validation errors.

---

## Computed Fields

Use `@computed_field` to expose derived values in serialization and JSON Schema:

```python
from pydantic import BaseModel, computed_field

class Rectangle(BaseModel):
    width: float
    height: float

    @computed_field
    @property
    def area(self) -> float:
        return self.width * self.height

    @computed_field
    @property
    def perimeter(self) -> float:
        return 2 * (self.width + self.height)

r = Rectangle(width=3.0, height=4.0)
print(r.model_dump())  # includes 'area' and 'perimeter'
```

Use `@cached_property` when the computation is expensive:

```python
from functools import cached_property
from pydantic import computed_field

class HeavyModel(BaseModel):
    data: list[int]

    @computed_field
    @cached_property
    def statistics(self) -> dict:
        return {'mean': sum(self.data) / len(self.data), 'count': len(self.data)}
```

---

## Field Aliases In Depth

Three alias types serve different purposes:

| Parameter | Validation | Serialization |
|---|---|---|
| `alias` | ✓ (overrides field name) | ✓ (when `by_alias=True`) |
| `validation_alias` | ✓ | ✗ |
| `serialization_alias` | ✗ | ✓ |

Enable accepting both field name and alias during validation:

```python
from pydantic import BaseModel, ConfigDict, Field

class User(BaseModel):
    model_config = ConfigDict(populate_by_name=True)
    name: str = Field(alias='username')

# Both work:
User(username='alice')
User(name='alice')
```

Use `alias_generator` to apply a consistent naming convention across all fields:

```python
from pydantic import BaseModel, ConfigDict
from pydantic.alias_generators import to_camel

class ApiResponse(BaseModel):
    model_config = ConfigDict(
        alias_generator=to_camel,
        populate_by_name=True,
    )
    user_id: int
    created_at: str

# Validates: {'userId': 1, 'createdAt': '2024-01-01'}
# Dumps with by_alias=True: {'userId': 1, 'createdAt': '2024-01-01'}
```
