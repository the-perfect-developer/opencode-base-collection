# Relationships and Queries

## Table of Contents

1. [Relationship Fundamentals](#relationship-fundamentals)
2. [One-to-Many Relationships](#one-to-many-relationships)
3. [Many-to-Many Relationships](#many-to-many-relationships)
4. [Relationship Loading Behavior](#relationship-loading-behavior)
5. [Advanced Query Patterns](#advanced-query-patterns)
6. [Cascade Delete](#cascade-delete)

---

## Relationship Fundamentals

Relationships in SQLModel are defined via two complementary mechanisms:

1. **Foreign key field** — a plain column field with `Field(foreign_key="table.column")`. This is what lives in the database.
2. **`Relationship` attribute** — a virtual attribute that provides ORM-level access to the related object(s). It does **not** create a column.

```python
from sqlmodel import Field, Relationship, SQLModel

class Team(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    name: str

    # Relationship attribute — not a DB column
    heroes: list["Hero"] = Relationship(back_populates="team")

class Hero(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    name: str
    team_id: int | None = Field(default=None, foreign_key="team.id")  # real column

    # Relationship attribute — not a DB column
    team: "Team | None" = Relationship(back_populates="heroes")
```

### `back_populates`

`back_populates` keeps both sides of the in-memory relationship object in sync. If you assign `hero.team = some_team`, SQLModel will also add `hero` to `some_team.heroes` in the same session.

Always use matching string names:
- `Team.heroes` has `back_populates="team"` → refers to `Hero.team`
- `Hero.team` has `back_populates="heroes"` → refers to `Team.heroes`

### Forward References with String Annotations

When two model classes reference each other, at least one must use a string annotation to avoid `NameError`:

```python
class Team(SQLModel, table=True):
    heroes: list["Hero"] = Relationship(back_populates="team")  # string ref

class Hero(SQLModel, table=True):
    team: Team | None = Relationship(back_populates="heroes")   # direct ref OK here
```

Alternatively, annotate all relationship fields as strings and rely on Python's deferred evaluation. From Python 3.10+ with `from __future__ import annotations`, all annotations are strings by default.

---

## One-to-Many Relationships

The "many" side holds the foreign key. The "one" side holds the list relationship.

```python
# One Team has many Heroes
class Team(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    name: str = Field(index=True)
    headquarters: str
    heroes: list["Hero"] = Relationship(back_populates="team")

# Many Heroes belong to one Team
class Hero(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    name: str = Field(index=True)
    secret_name: str
    age: int | None = Field(default=None, index=True)
    team_id: int | None = Field(default=None, foreign_key="team.id")
    team: Team | None = Relationship(back_populates="heroes")
```

### Creating Related Objects

Assign objects directly to relationship attributes — SQLModel resolves the foreign key automatically:

```python
with Session(engine) as session:
    team = Team(name="Preventers", headquarters="Sharp Tower")
    hero = Hero(name="Rusty-Man", secret_name="Tommy Sharp", age=48, team=team)
    session.add(hero)  # adding hero also adds team (cascade add)
    session.commit()
```

### Reading Related Objects

Access relationship attributes within the same session scope:

```python
with Session(engine) as session:
    hero = session.get(Hero, hero_id)
    # Access within session — SQLModel lazy-loads the relationship
    print(hero.team.name if hero.team else "No team")
```

### Updating Relationships

Reassign the relationship attribute and commit:

```python
with Session(engine) as session:
    hero = session.get(Hero, hero_id)
    new_team = session.get(Team, new_team_id)
    hero.team = new_team
    session.add(hero)
    session.commit()
```

### Removing Relationships

Set to `None` and commit:

```python
with Session(engine) as session:
    hero = session.get(Hero, hero_id)
    hero.team = None
    session.add(hero)
    session.commit()
```

---

## Many-to-Many Relationships

Use an explicit **link model** (junction table) with `table=True`. This approach is recommended because it allows adding extra fields to the link.

### Basic Many-to-Many

```python
class HeroTeamLink(SQLModel, table=True):
    hero_id: int | None = Field(default=None, foreign_key="hero.id", primary_key=True)
    team_id: int | None = Field(default=None, foreign_key="team.id", primary_key=True)

class Team(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    name: str
    heroes: list["Hero"] = Relationship(back_populates="teams", link_model=HeroTeamLink)

class Hero(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    name: str
    teams: list[Team] = Relationship(back_populates="heroes", link_model=HeroTeamLink)
```

### Many-to-Many with Extra Fields on the Link

Add extra columns to the link model (e.g., `is_training`, `joined_at`). When accessing extra fields, query the link model directly instead of using the relationship shortcut:

```python
class HeroTeamLink(SQLModel, table=True):
    hero_id: int | None = Field(default=None, foreign_key="hero.id", primary_key=True)
    team_id: int | None = Field(default=None, foreign_key="team.id", primary_key=True)
    is_training: bool = False

    # Inverse relationships back to parent models
    hero: "Hero | None" = Relationship(back_populates="team_links")
    team: "Team | None" = Relationship(back_populates="hero_links")

class Team(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    name: str
    hero_links: list[HeroTeamLink] = Relationship(back_populates="team")

class Hero(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    name: str
    team_links: list[HeroTeamLink] = Relationship(back_populates="hero")
```

Accessing link data:

```python
with Session(engine) as session:
    hero = session.get(Hero, hero_id)
    for link in hero.team_links:
        print(link.team.name, "training:", link.is_training)
```

---

## Relationship Loading Behavior

SQLModel (via SQLAlchemy) uses **lazy loading** by default. Relationship attributes are fetched from the database on first access. This means:

- Accessing `hero.team` inside a session works fine.
- Accessing `hero.team` **after the session closes** raises `DetachedInstanceError`.

### Accessing Relationships After Session Close

Load the data before the session closes:

```python
with Session(engine) as session:
    hero = session.get(Hero, hero_id)
    # Access within session to trigger load
    team_name = hero.team.name if hero.team else None

# Use the variable after session
print(team_name)
```

Alternatively, use `session.refresh(hero)` to re-attach and reload all data from the database.

### Eager Loading (SQLAlchemy selectinload)

For cases where related data is always needed, use SQLAlchemy's `selectinload` to avoid N+1 queries:

```python
from sqlalchemy.orm import selectinload

with Session(engine) as session:
    statement = select(Hero).options(selectinload(Hero.team))
    heroes = session.exec(statement).all()
    # hero.team is now pre-loaded for all heroes
```

---

## Advanced Query Patterns

### Filtering on Related Table Columns (JOIN)

```python
from sqlmodel import select

with Session(engine) as session:
    statement = (
        select(Hero, Team)
        .join(Team, Hero.team_id == Team.id)
        .where(Team.name == "Preventers")
    )
    results = session.exec(statement).all()
    for hero, team in results:
        print(hero.name, team.name)
```

### Pagination

Always apply `offset` and `limit` for list endpoints:

```python
def read_heroes(offset: int = 0, limit: int = 100) -> list[Hero]:
    with Session(engine) as session:
        return session.exec(
            select(Hero).offset(offset).limit(limit)
        ).all()
```

### Checking for Existence (`.first()` vs `.one()`)

- `.first()` — returns `None` if no result; use for optional lookups.
- `.one()` — raises `NoResultFound` if zero results, `MultipleResultsFound` if more than one; use when exactly one result is required.
- `session.get(Model, pk)` — returns `None` if not found; the preferred way to fetch by primary key.

```python
# Safe — returns None if not found
hero = session.exec(select(Hero).where(Hero.name == "Unknown")).first()

# Raises if not found or if duplicates exist
hero = session.exec(select(Hero).where(Hero.id == 1)).one()

# Best for primary key lookups
hero = session.get(Hero, 1)
```

### Counting Rows

```python
from sqlmodel import func

with Session(engine) as session:
    count = session.exec(select(func.count()).select_from(Hero)).one()
```

---

## Cascade Delete

To automatically delete related rows when the parent is deleted, configure `cascade` on the relationship:

```python
from sqlmodel import Relationship

class Team(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    name: str
    heroes: list["Hero"] = Relationship(
        back_populates="team",
        sa_relationship_kwargs={"cascade": "all, delete-orphan"},
    )
```

With this configuration, deleting a `Team` will also delete all its `Hero` rows.

Without cascade, deleting a parent with children raises a `ForeignKeyViolation` error (or sets children's FK to NULL depending on DB config).

### Explicit Delete (No Cascade)

Manually handle children before deleting the parent:

```python
with Session(engine) as session:
    team = session.get(Team, team_id)
    for hero in team.heroes:
        hero.team_id = None
        session.add(hero)
    session.delete(team)
    session.commit()
```
