# Serialization and Configuration — Pydantic v2 Reference

## Table of Contents
1. [Serialization Methods](#serialization-methods)
2. [Field Inclusion and Exclusion](#field-inclusion-and-exclusion)
3. [Custom Field Serializers](#custom-field-serializers)
4. [Custom Model Serializers](#custom-model-serializers)
5. [Serialization Context](#serialization-context)
6. [Subclass Serialization](#subclass-serialization)
7. [ConfigDict Reference](#configdict-reference)
8. [Configuration Propagation](#configuration-propagation)
9. [ORM and Arbitrary Object Integration](#orm-and-arbitrary-object-integration)
10. [Generic Models](#generic-models)

---

## Serialization Methods

### `model_dump()` — Python dict

```python
from pydantic import BaseModel, Field

class Order(BaseModel):
    order_id: int
    customer: str
    amount: float = Field(serialization_alias='totalAmount')
    internal_note: str = Field(exclude=True)

o = Order(order_id=1, customer='Alice', amount=99.9, internal_note='VIP')

o.model_dump()
# {'order_id': 1, 'customer': 'Alice', 'amount': 99.9}

o.model_dump(by_alias=True)
# {'order_id': 1, 'customer': 'Alice', 'totalAmount': 99.9}

o.model_dump(mode='json')
# Forces JSON-compatible types (e.g. tuples become lists, datetimes become strings)
```

### `model_dump_json()` — JSON string

```python
o.model_dump_json()           # compact
o.model_dump_json(indent=2)   # pretty-printed
```

Prefer `model_dump_json()` over `json.dumps(model.model_dump())` — Pydantic's Rust core serializes directly to JSON without building an intermediate Python dict.

### Serialization parameters

| Parameter | Description |
|---|---|
| `include` | Set or dict of fields to include |
| `exclude` | Set or dict of fields to exclude |
| `by_alias` | Use field aliases instead of names |
| `exclude_unset` | Omit fields not explicitly provided at instantiation |
| `exclude_defaults` | Omit fields whose value equals their default |
| `exclude_none` | Omit fields with `None` values |
| `mode` | `'python'` (default) or `'json'` for JSON-compatible output |
| `serialize_as_any` | Serialize subclass instances with all their fields (duck typing) |
| `context` | Passed to serializer functions |

### `exclude_unset` for PATCH semantics

```python
from pydantic import BaseModel

class UserUpdate(BaseModel):
    name: str = 'default'
    email: str = 'default@example.com'
    age: int = 0

patch = UserUpdate(name='Alice')
patch.model_dump(exclude_unset=True)
# {'name': 'Alice'}  — only the explicitly set field
```

This is the idiomatic pattern for building partial-update payloads (HTTP PATCH).

---

## Field Inclusion and Exclusion

### Nested exclusion with dicts

```python
from pydantic import BaseModel, SecretStr

class User(BaseModel):
    id: int
    username: str
    password: SecretStr

class Transaction(BaseModel):
    id: str
    user: User
    value: float

t = Transaction(id='tx1', user=User(id=1, username='alice', password='secret'), value=42.0)

# Exclude nested fields:
t.model_dump(exclude={'user': {'password', 'username'}})
# {'id': 'tx1', 'user': {'id': 1}, 'value': 42.0}

# Include only specific fields:
t.model_dump(include={'id': True, 'user': {'id'}})
# {'id': 'tx1', 'user': {'id': 1}}
```

### Excluding all matching items in a collection

```python
class Order(BaseModel):
    items: list[dict]

o = Order(items=[{'name': 'a', 'secret': 'x'}, {'name': 'b', 'secret': 'y'}])
o.model_dump(exclude={'items': {'__all__': {'secret'}}})
# {'items': [{'name': 'a'}, {'name': 'b'}]}
```

### `exclude_if` — Conditional exclusion at the field level

```python
from pydantic import BaseModel, Field

class Event(BaseModel):
    id: int
    payload: dict = Field(exclude_if=lambda v: not v)  # exclude empty payloads
```

---

## Custom Field Serializers

### Plain serializer — replaces Pydantic's default

```python
from typing import Annotated
from pydantic import BaseModel, PlainSerializer
import datetime

# Reusable via Annotated
EpochInt = Annotated[
    datetime.datetime,
    PlainSerializer(lambda dt: int(dt.timestamp()), return_type=int),
]

class Event(BaseModel):
    occurred_at: EpochInt

Event(occurred_at=datetime.datetime(2024, 1, 1)).model_dump()
# {'occurred_at': 1704067200}
```

### Wrap serializer — augments Pydantic's default

```python
from pydantic import BaseModel, SerializerFunctionWrapHandler, field_serializer

class Metrics(BaseModel):
    values: list[float]

    @field_serializer('values', mode='wrap')
    def round_values(self, v: list[float], handler: SerializerFunctionWrapHandler) -> list[float]:
        serialized = handler(v)
        return [round(x, 2) for x in serialized]
```

### Decorator on multiple fields

```python
from pydantic import BaseModel, field_serializer

class Document(BaseModel):
    title: str
    body: str

    @field_serializer('title', 'body', mode='plain')
    def strip_html(self, v: str) -> str:
        import re
        return re.sub(r'<[^>]+>', '', v)
```

---

## Custom Model Serializers

### Plain — full control over output structure

```python
from pydantic import BaseModel, model_serializer

class ApiResponse(BaseModel):
    status: str
    data: dict

    @model_serializer(mode='plain')
    def to_envelope(self) -> dict:
        return {'ok': self.status == 'success', 'payload': self.data}
```

### Wrap — augment default dict output

```python
from pydantic import BaseModel, SerializerFunctionWrapHandler, model_serializer

class AuditModel(BaseModel):
    name: str

    @model_serializer(mode='wrap')
    def add_metadata(self, handler: SerializerFunctionWrapHandler) -> dict:
        result = handler(self)
        result['_version'] = 2
        return result
```

---

## Serialization Context

Pass runtime information (locale, user permissions, output format) into serializers:

```python
from pydantic import BaseModel, FieldSerializationInfo, field_serializer

class Price(BaseModel):
    amount: float
    currency: str = 'USD'

    @field_serializer('amount', mode='plain')
    def format_amount(self, v: float, info: FieldSerializationInfo) -> str | float:
        if isinstance(info.context, dict) and info.context.get('human_readable'):
            return f'{v:,.2f} {self.currency}'
        return v

p = Price(amount=1234567.89)
p.model_dump()
# {'amount': 1234567.89, 'currency': 'USD'}
p.model_dump(context={'human_readable': True})
# {'amount': '1,234,567.89 USD', 'currency': 'USD'}
```

---

## Subclass Serialization

By default (V2 behavior), serializing a `User`-typed field that holds a `UserLogin` subclass will only include `User` fields — not the subclass-added fields. This prevents accidental secret leakage.

```python
from pydantic import BaseModel

class User(BaseModel):
    name: str

class UserLogin(User):
    password: str  # will NOT appear in serialization of User-typed fields
```

To opt into duck-typing serialization (include all subclass fields):

```python
from pydantic import BaseModel, SerializeAsAny

class OuterModel(BaseModel):
    user: SerializeAsAny[User]  # serialize whatever fields exist at runtime

# Or at call time:
outer.model_dump(serialize_as_any=True)
```

---

## ConfigDict Reference

Set model-wide behavior via `model_config = ConfigDict(...)`.

### Validation behavior

| Key | Default | Effect |
|---|---|---|
| `extra` | `'ignore'` | `'forbid'` rejects unknown fields; `'allow'` stores them |
| `strict` | `False` | Disables all type coercion globally |
| `validate_default` | `False` | Runs validators on default values too |
| `validate_assignment` | `False` | Re-validates on attribute assignment |
| `revalidate_instances` | `'never'` | `'always'` re-validates model instances passed as values |
| `coerce_numbers_to_str` | `False` | Converts numeric types to strings |

### String handling

| Key | Default | Effect |
|---|---|---|
| `str_strip_whitespace` | `False` | Strips leading/trailing whitespace from strings |
| `str_to_lower` | `False` | Lowercases all strings |
| `str_to_upper` | `False` | Uppercases all strings |
| `str_min_length` | `0` | Minimum string length for all string fields |
| `str_max_length` | `None` | Maximum string length for all string fields |

### Serialization behavior

| Key | Default | Effect |
|---|---|---|
| `populate_by_name` | `False` | Allows using field name when an alias is set |
| `serialize_by_alias` | `False` | Always serialize using aliases |
| `from_attributes` | `False` | Enable ORM mode (read attributes, not keys) |

### Common production patterns

```python
from pydantic import BaseModel, ConfigDict

class StrictApiModel(BaseModel):
    """Strict model for external API input."""
    model_config = ConfigDict(
        extra='forbid',          # reject unknown fields
        str_strip_whitespace=True,
        validate_default=True,
    )

class OrmModel(BaseModel):
    """For reading from SQLAlchemy / Django ORM."""
    model_config = ConfigDict(
        from_attributes=True,
    )

class ImmutableModel(BaseModel):
    """Immutable value object."""
    model_config = ConfigDict(frozen=True)
```

### Global base class pattern

```python
from pydantic import BaseModel, ConfigDict

class AppBase(BaseModel):
    """Project-wide base with shared defaults."""
    model_config = ConfigDict(
        extra='forbid',
        str_strip_whitespace=True,
        validate_default=True,
    )

class User(AppBase):
    id: int
    name: str
    # Inherits all AppBase config; can override specific keys
```

---

## Configuration Propagation

Pydantic model configuration does **not** propagate to nested Pydantic models — each model has its own config boundary:

```python
from pydantic import BaseModel, ConfigDict

class Address(BaseModel):
    street: str  # 'str_to_lower' from Parent will NOT apply here

class Person(BaseModel):
    model_config = ConfigDict(str_to_lower=True)
    name: str      # lowercased ✓
    address: Address  # Address has its own config, not lowercased ✗
```

`TypedDict` and stdlib dataclasses **do** inherit configuration from the containing model, unless they define their own.

---

## ORM and Arbitrary Object Integration

```python
from pydantic import BaseModel, ConfigDict

class UserOrm:  # could be SQLAlchemy mapped class
    def __init__(self, id: int, name: str, email: str):
        self.id = id
        self.name = name
        self.email = email

class UserSchema(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    email: str

orm_obj = UserOrm(id=1, name='Alice', email='alice@example.com')
user = UserSchema.model_validate(orm_obj)
```

For one-off validation without setting `from_attributes` globally:

```python
user = UserSchema.model_validate(orm_obj, from_attributes=True)
```

### Nested ORM attributes

With `from_attributes=True` set on all relevant models, Pydantic traverses nested object attributes recursively:

```python
class AddressSchema(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    city: str

class PersonSchema(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    name: str
    address: AddressSchema  # Pydantic reads person.address.city automatically
```

---

## Generic Models

Generic models enable reusable response wrappers and typed containers:

```python
from typing import Generic, TypeVar
from pydantic import BaseModel

T = TypeVar('T')

class Paginated(BaseModel, Generic[T]):
    items: list[T]
    total: int
    page: int
    page_size: int

class UserItem(BaseModel):
    id: int
    name: str

# Parametrize at call site:
response = Paginated[UserItem](
    items=[UserItem(id=1, name='Alice')],
    total=1, page=1, page_size=20,
)
response.model_dump()
# {'items': [{'id': 1, 'name': 'Alice'}], 'total': 1, 'page': 1, 'page_size': 20}
```

Pydantic caches parametrized generic classes internally — there is no significant overhead from using generics.

For models that inherit from a generic base and remain generic, subclasses must also inherit from `Generic[T]`:

```python
class SortedPaginated(Paginated[T], Generic[T]):
    sort_field: str
    sort_direction: str
```
