---
name: sqlmodel
description: This skill should be used when the user asks to "use SQLModel", "define SQLModel models", "connect SQLModel with FastAPI", "set up a database with SQLModel", or needs guidance on SQLModel best practices, relationships, or session management.
---

# SQLModel

SQLModel is a Python library for SQL databases built on top of SQLAlchemy and Pydantic. It uses Python type annotations to define both database table schemas and API data schemas in a single class hierarchy.

## Installation

```bash
pip install sqlmodel
```

For PostgreSQL or MySQL, install the appropriate driver alongside SQLModel:

```bash
pip install sqlmodel psycopg2-binary   # PostgreSQL
pip install sqlmodel pymysql           # MySQL
```

## Core Concepts

### Table Models vs Data Models

SQLModel has two distinct model kinds:

- **Table models** — `SQLModel` subclasses with `table=True`. Map to real database tables. Are also SQLAlchemy models and Pydantic models.
- **Data models** — `SQLModel` subclasses without `table=True`. Pydantic models only. Used for API schemas, input validation, and response shaping. Never create tables.

```python
from sqlmodel import Field, SQLModel

# Data model only — no table created
class HeroBase(SQLModel):
    name: str = Field(index=True)
    secret_name: str
    age: int | None = Field(default=None, index=True)

# Table model — creates the `hero` table
class Hero(HeroBase, table=True):
    id: int | None = Field(default=None, primary_key=True)
```

### Nullable Fields and Primary Keys

- Declare nullable fields with `int | None` (Python 3.10+) or `Optional[int]`.
- Primary keys must be `int | None = Field(default=None, primary_key=True)` — the database generates the value; code holds `None` until the row is saved.

```python
class Article(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    title: str
    body: str
    views: int | None = None  # nullable column, default NULL
```

### Engine — One Per Application

Create a **single engine** for the whole application and reuse it everywhere. Do not recreate it per request.

```python
from sqlmodel import SQLModel, create_engine

DATABASE_URL = "sqlite:///database.db"
engine = create_engine(DATABASE_URL)

# PostgreSQL example:
# engine = create_engine("postgresql+psycopg2://user:pass@host/db")
```

Use `echo=True` during development to log generated SQL, but remove it in production.

### Table Creation

Call `SQLModel.metadata.create_all(engine)` **after** all table model classes have been imported. The order matters — classes must be registered in `SQLModel.metadata` first.

```python
# db.py
from sqlmodel import SQLModel, create_engine
from . import models  # import models before create_all

engine = create_engine("sqlite:///database.db")

def create_db_and_tables() -> None:
    SQLModel.metadata.create_all(engine)
```

For production, use Alembic for schema migrations instead of `create_all`.

## Session Management

### Use `with` Blocks — Never Manual `.close()`

Always open sessions in a `with` block. This guarantees cleanup even on exceptions.

```python
from sqlmodel import Session

with Session(engine) as session:
    hero = Hero(name="Deadpond", secret_name="Dive Wilson")
    session.add(hero)
    session.commit()
    session.refresh(hero)  # populates auto-generated fields like id
    print(hero.id)         # now has the DB-assigned value
```

### One Session Per Request (FastAPI)

Create a **new session per request** using a FastAPI dependency with `yield`. The engine is shared; sessions are per-request.

```python
from fastapi import Depends
from sqlmodel import Session

def get_session():
    with Session(engine) as session:
        yield session

@app.post("/heroes/", response_model=HeroPublic)
def create_hero(
    *,
    session: Session = Depends(get_session),
    hero: HeroCreate,
) -> HeroPublic:
    db_hero = Hero.model_validate(hero)
    session.add(db_hero)
    session.commit()
    session.refresh(db_hero)
    return db_hero
```

The `yield` dependency ensures the session's `with` block finalizes after the response is sent.

## Multiple Models Pattern (Best Practice)

Avoid exposing the table model directly in API routes. Use a model hierarchy:

| Model | Purpose | `table=True` |
|---|---|---|
| `HeroBase` | Shared fields (base data model) | No |
| `Hero` | DB table model | Yes |
| `HeroCreate` | API input — no `id` | No |
| `HeroPublic` | API output — required `id: int` | No |
| `HeroUpdate` | Partial update — all fields optional | No |

```python
class HeroBase(SQLModel):
    name: str = Field(index=True)
    secret_name: str
    age: int | None = Field(default=None, index=True)

class Hero(HeroBase, table=True):
    id: int | None = Field(default=None, primary_key=True)

class HeroCreate(HeroBase):
    pass  # same fields as HeroBase, named explicitly for clarity

class HeroPublic(HeroBase):
    id: int  # required in responses (always present after DB save)

class HeroUpdate(SQLModel):
    name: str | None = None
    secret_name: str | None = None
    age: int | None = None
```

**Never inherit data models from table models.** Only inherit from other data models to avoid confusion and accidental table creation.

### Creating from Input Model

Use `Hero.model_validate(hero_create_instance)` to convert a data model to a table model:

```python
db_hero = Hero.model_validate(hero)  # hero is HeroCreate
session.add(db_hero)
session.commit()
session.refresh(db_hero)
return db_hero  # FastAPI serializes via HeroPublic response_model
```

### Partial Update Pattern

Use `model_dump(exclude_unset=True)` and `sqlmodel_update()` for PATCH operations:

```python
@app.patch("/heroes/{hero_id}", response_model=HeroPublic)
def update_hero(
    *,
    session: Session = Depends(get_session),
    hero_id: int,
    hero: HeroUpdate,
) -> HeroPublic:
    db_hero = session.get(Hero, hero_id)
    if not db_hero:
        raise HTTPException(status_code=404, detail="Hero not found")
    hero_data = hero.model_dump(exclude_unset=True)
    db_hero.sqlmodel_update(hero_data)
    session.add(db_hero)
    session.commit()
    session.refresh(db_hero)
    return db_hero
```

## Querying

### SELECT with `select()`

```python
from sqlmodel import select

with Session(engine) as session:
    # All rows
    heroes = session.exec(select(Hero)).all()

    # Single result
    hero = session.exec(select(Hero).where(Hero.name == "Deadpond")).first()

    # By primary key (preferred for single-row lookup)
    hero = session.get(Hero, hero_id)

    # Filtering, ordering, pagination
    statement = (
        select(Hero)
        .where(Hero.age >= 18)
        .order_by(Hero.name)
        .offset(offset)
        .limit(limit)
    )
    heroes = session.exec(statement).all()
```

### Indexes

Declare indexes with `Field(index=True)` on frequently queried columns. Indexes speed up `WHERE`, `ORDER BY`, and `JOIN` operations at the cost of slightly slower writes.

```python
class Hero(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    name: str = Field(index=True)           # indexed
    age: int | None = Field(default=None, index=True)  # indexed
    secret_name: str                         # not indexed
```

## Relationships

### Foreign Keys and `Relationship`

Define foreign keys with `Field(foreign_key="table.column")` and use `Relationship` for ORM-level access to related objects.

```python
from sqlmodel import Relationship

class Team(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    name: str = Field(index=True)
    heroes: list["Hero"] = Relationship(back_populates="team")

class Hero(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    name: str
    team_id: int | None = Field(default=None, foreign_key="team.id")
    team: Team | None = Relationship(back_populates="heroes")
```

- `back_populates` keeps both sides of the relationship in sync in memory.
- Use string forward references (`"Hero"`) when the referenced class is defined after the current class.
- Relationship attributes are **not columns** — they do not appear in the table schema.

### Many-to-Many

Use an explicit link model with `table=True` as the association table:

```python
class HeroTeamLink(SQLModel, table=True):
    hero_id: int | None = Field(default=None, foreign_key="hero.id", primary_key=True)
    team_id: int | None = Field(default=None, foreign_key="team.id", primary_key=True)

class Hero(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    name: str
    teams: list["Team"] = Relationship(back_populates="heroes", link_model=HeroTeamLink)
```

## Code Structure

Organize multi-model projects across files to avoid circular imports and enforce `create_all` ordering:

```
app/
├── models.py        # all SQLModel table models
├── schemas.py       # data models (HeroCreate, HeroPublic, etc.)
├── database.py      # engine, get_session dependency
└── routers/
    └── heroes.py    # FastAPI router
```

Import models in `database.py` before calling `create_all`, or import them explicitly in the startup handler:

```python
# main.py
from app import models  # ensures registration before create_all
from app.database import engine, create_db_and_tables

@app.on_event("startup")
def on_startup() -> None:
    create_db_and_tables()
```

## Quick Reference

| Operation | Code |
|---|---|
| Create engine | `create_engine(url)` |
| Create tables | `SQLModel.metadata.create_all(engine)` |
| Open session | `with Session(engine) as session:` |
| Insert row | `session.add(obj); session.commit()` |
| Fetch by PK | `session.get(Model, pk)` |
| Query rows | `session.exec(select(Model).where(...)).all()` |
| Update row | `session.add(obj); session.commit()` |
| Delete row | `session.delete(obj); session.commit()` |
| Refresh from DB | `session.refresh(obj)` |
| Convert input→table | `Model.model_validate(input_obj)` |
| Partial update dict | `obj.model_dump(exclude_unset=True)` |

## Additional Resources

- **`references/relationships-and-queries.md`** — Relationship patterns, lazy loading, many-to-many with extra fields, advanced query techniques
- **`references/fastapi-patterns.md`** — Complete FastAPI integration: dependencies, lifespan, testing, response model patterns
