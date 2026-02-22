# Pydantic v2 Performance Reference

This reference covers techniques for reducing validation overhead in hot paths. Profile before optimizing — most applications do not need these patterns.

---

## JSON Parsing: Prefer `model_validate_json`

```python
import json
from pydantic import BaseModel

class User(BaseModel):
    id: int
    name: str

# Slow — Python parses JSON to a dict, then Pydantic validates the dict
user = User.model_validate(json.loads(raw_json))

# Fast — Pydantic-core parses and validates in one Rust pass
user = User.model_validate_json(raw_json)
```

`model_validate_json` avoids the intermediate Python dict entirely. For large payloads or high request rates, this is typically the single biggest win.

---

## `TypeAdapter`: Instantiate Once at Module Level

`TypeAdapter` compiles a validation schema at construction time. Creating it inside a function or per-request is expensive.

```python
from pydantic import TypeAdapter
from typing import Annotated
from pydantic import Field

# Bad — schema compiled on every call
def validate_price(v: float) -> float:
    adapter = TypeAdapter(Annotated[float, Field(gt=0)])
    return adapter.validate_python(v)

# Good — compiled once at import time
PriceAdapter = TypeAdapter(Annotated[float, Field(gt=0)])

def validate_price(v: float) -> float:
    return PriceAdapter.validate_python(v)
```

`TypeAdapter` supports the same validate/serialize methods as `BaseModel` but works with any type — primitives, `TypedDict`, `dataclass`, or complex annotated types.

---

## `TypedDict` Over Nested `BaseModel` for Hot Paths

`TypedDict` models validate roughly 2.5x faster than equivalent nested `BaseModel` structures because they do not carry instance overhead (no `__init__`, no `model_fields`, no `__pydantic_validator__` per instance).

```python
from typing import TypedDict
from pydantic import TypeAdapter

class AddressDict(TypedDict):
    street: str
    city: str
    zip_code: str

class UserDict(TypedDict):
    id: int
    name: str
    address: AddressDict

UserDictAdapter = TypeAdapter(UserDict)

# Faster than using nested BaseModel classes
user = UserDictAdapter.validate_python(raw_data)
```

Use `TypedDict` for internal data that is validated and immediately consumed rather than passed around as rich objects.

---

## Discriminated Unions: Tag Variants for O(1) Dispatch

Plain unions require Pydantic to attempt each member in order until one succeeds. Tagged/discriminated unions use a literal field to select the correct schema in constant time.

```python
from typing import Annotated, Literal, Union
from pydantic import BaseModel, Field

class Cat(BaseModel):
    pet_type: Literal['cat']
    meow_volume: int

class Dog(BaseModel):
    pet_type: Literal['dog']
    bark_loudness: str

# Slow for large unions — tries Cat first, then Dog
Pet = Union[Cat, Dog]

# Fast — jumps directly to the right schema via pet_type
TaggedPet = Annotated[Union[Cat, Dog], Field(discriminator='pet_type')]
```

Always use discriminated unions when union members can be identified by a single literal field. This is especially important for unions with many members.

---

## Avoiding Validation: `model_construct` for Pre-Validated Data

When data is known to be valid (e.g., loaded from an internal database with a strict schema), `model_construct` skips all validation.

```python
from pydantic import BaseModel

class User(BaseModel):
    id: int
    name: str

# Bypasses all field validators and type coercion
user = User.model_construct(id=1, name='Alice')
```

**Use with caution.** `model_construct` provides no safety guarantees — invalid data will propagate silently. Reserve it for paths where the data source is trusted and immutable.

---

## `FailFast`: Skip Remaining Items on First Error

For large sequence validations, `FailFast` stops processing after the first failure instead of collecting all errors.

```python
from typing import Annotated
from pydantic import BaseModel
from pydantic.functional_validators import FailFast

class Batch(BaseModel):
    # Stops after the first invalid item
    items: Annotated[list[int], FailFast()]
```

Available since Pydantic v2.8. Useful when sequences may be very long and the full error list is not needed.

---

## Avoid Unnecessary Wrap Validators

Wrap validators carry the cost of a Python callback that intercepts every validation call. Use them only when the use-case genuinely requires intercepting both the handler and the result:

```python
from typing import Any
from pydantic import BaseModel
from pydantic.functional_validators import WrapValidator

# Justified — catching and transforming validation errors
def coerce_or_none(v: Any, handler):
    try:
        return handler(v)
    except Exception:
        return None

# Unjustified — use AfterValidator instead
def upper(v: str, handler):
    return handler(v).upper()
```

If the validator only needs to inspect or transform the result after coercion, use `AfterValidator`. If it only needs to transform the input before coercion, use `BeforeValidator`. Reserve `WrapValidator` for cases where error interception is required.

---

## Avoid Subclassing Primitive Types

Pydantic validates subclasses of `int`, `str`, `float`, etc. by calling the subclass constructor — which is slower than validating the base type.

```python
# Slower — Pydantic calls MyStr(v) for every value
class MyStr(str): ...

class Model(BaseModel):
    value: MyStr

# Faster — use Annotated constraints on str directly
from typing import Annotated
from pydantic import Field

class Model(BaseModel):
    value: Annotated[str, Field(max_length=100)]
```

---

## Prefer `list` and `tuple` Over `Sequence`

`Sequence` is a generic abstract type. Pydantic validates `Sequence[X]` by iterating and validating each element then converting to a list. Using `list[X]` or `tuple[X, ...]` directly is faster because Pydantic can dispatch to the concrete validator without the abstract-type overhead.

```python
from pydantic import BaseModel

# Slower
class A(BaseModel):
    items: Sequence[int]

# Faster
class B(BaseModel):
    items: list[int]
```

---

## Use `Any` to Skip Validation for Trusted Fields

Fields typed as `Any` receive no validation. Use this when a field contains arbitrary trusted data that must be preserved exactly.

```python
from typing import Any
from pydantic import BaseModel

class Event(BaseModel):
    name: str
    metadata: Any  # not validated — stored as-is
```

Avoid this pattern in public-facing APIs where input is untrusted.

---

## Summary Table

| Technique | When to Apply |
|-----------|---------------|
| `model_validate_json` over `json.loads` + `model_validate` | Any JSON input |
| Module-level `TypeAdapter` | Validating non-`BaseModel` types in hot paths |
| `TypedDict` over nested `BaseModel` | Internal data structures not used as rich objects |
| Discriminated unions | Unions with a literal discriminator field |
| `model_construct` | Internal paths with pre-validated, trusted data |
| `FailFast` | Very long sequence validation where first error suffices |
| `AfterValidator` over `WrapValidator` | Post-coercion checks without error interception |
| `list[X]` over `Sequence[X]` | Any list-typed field |
| `Any` typing | Opaque, trusted, arbitrary data fields |
