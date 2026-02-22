# FastAPI Integration Patterns

## Table of Contents

1. [Application Setup](#application-setup)
2. [Session Dependency](#session-dependency)
3. [Full CRUD Example](#full-crud-example)
4. [Response Model Patterns](#response-model-patterns)
5. [Error Handling](#error-handling)
6. [Testing with SQLModel](#testing-with-sqlmodel)
7. [Lifespan (Modern Startup)](#lifespan-modern-startup)

---

## Application Setup

### Project Layout

```
app/
├── __init__.py
├── main.py           # FastAPI app, lifespan
├── database.py       # engine, get_session
├── models.py         # table models (Hero, Team, …)
└── routers/
    ├── __init__.py
    ├── heroes.py
    └── teams.py
```

### database.py

```python
from sqlmodel import Session, SQLModel, create_engine

DATABASE_URL = "sqlite:///database.db"
# For SQLite in FastAPI (multi-threaded), set check_same_thread=False
connect_args = {"check_same_thread": False}
engine = create_engine(DATABASE_URL, connect_args=connect_args)

def create_db_and_tables() -> None:
    SQLModel.metadata.create_all(engine)

def get_session():
    with Session(engine) as session:
        yield session
```

For PostgreSQL, the `connect_args` override is not needed:

```python
engine = create_engine("postgresql+psycopg2://user:pass@localhost/mydb")
```

---

## Session Dependency

Use `Annotated` (Python 3.9+) to avoid repeating `Depends(get_session)` across every route:

```python
from typing import Annotated
from fastapi import Depends
from sqlmodel import Session
from app.database import get_session

SessionDep = Annotated[Session, Depends(get_session)]
```

Then use `SessionDep` directly in route signatures:

```python
@app.get("/heroes/{hero_id}")
def read_hero(hero_id: int, session: SessionDep) -> HeroPublic:
    hero = session.get(Hero, hero_id)
    if not hero:
        raise HTTPException(status_code=404, detail="Hero not found")
    return hero
```

---

## Full CRUD Example

```python
from fastapi import APIRouter, HTTPException, Query
from sqlmodel import select
from app.database import SessionDep
from app.models import Hero
from app.schemas import HeroCreate, HeroPublic, HeroUpdate

router = APIRouter(prefix="/heroes", tags=["heroes"])

@router.post("/", response_model=HeroPublic, status_code=201)
def create_hero(hero: HeroCreate, session: SessionDep) -> HeroPublic:
    db_hero = Hero.model_validate(hero)
    session.add(db_hero)
    session.commit()
    session.refresh(db_hero)
    return db_hero

@router.get("/", response_model=list[HeroPublic])
def read_heroes(
    session: SessionDep,
    offset: int = 0,
    limit: int = Query(default=100, le=100),
) -> list[HeroPublic]:
    heroes = session.exec(select(Hero).offset(offset).limit(limit)).all()
    return heroes

@router.get("/{hero_id}", response_model=HeroPublic)
def read_hero(hero_id: int, session: SessionDep) -> HeroPublic:
    hero = session.get(Hero, hero_id)
    if not hero:
        raise HTTPException(status_code=404, detail="Hero not found")
    return hero

@router.patch("/{hero_id}", response_model=HeroPublic)
def update_hero(
    hero_id: int,
    hero: HeroUpdate,
    session: SessionDep,
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

@router.delete("/{hero_id}")
def delete_hero(hero_id: int, session: SessionDep) -> dict:
    hero = session.get(Hero, hero_id)
    if not hero:
        raise HTTPException(status_code=404, detail="Hero not found")
    session.delete(hero)
    session.commit()
    return {"ok": True}
```

---

## Response Model Patterns

### The Four-Model Pattern

For each entity, maintain these separate schemas to preserve type safety and avoid leaking internal data:

```python
# schemas.py
from sqlmodel import SQLModel, Field

class HeroBase(SQLModel):
    name: str = Field(index=True)
    secret_name: str
    age: int | None = Field(default=None, index=True)

class Hero(HeroBase, table=True):
    """DB table model — not used directly in routes."""
    id: int | None = Field(default=None, primary_key=True)

class HeroCreate(HeroBase):
    """Request body for POST /heroes/. Excludes id."""
    pass

class HeroPublic(HeroBase):
    """Response body. id is always present after DB save."""
    id: int

class HeroUpdate(SQLModel):
    """Request body for PATCH /heroes/{id}. All fields optional."""
    name: str | None = None
    secret_name: str | None = None
    age: int | None = None
```

### Including Related Data in Responses

To include related data (e.g., a hero's team) in an API response, create a specialized public schema:

```python
class TeamPublic(SQLModel):
    id: int
    name: str

class HeroPublicWithTeam(HeroPublic):
    team: TeamPublic | None = None
```

Then use `model_config` to allow attribute access from SQLModel instances:

```python
# This is handled automatically by SQLModel/Pydantic
@router.get("/{hero_id}/with-team", response_model=HeroPublicWithTeam)
def read_hero_with_team(hero_id: int, session: SessionDep) -> HeroPublicWithTeam:
    hero = session.get(Hero, hero_id)
    if not hero:
        raise HTTPException(status_code=404, detail="Hero not found")
    return hero  # FastAPI serializes team via response_model
```

Access `hero.team` within the session before returning — the response_model will serialize it correctly.

---

## Error Handling

### 404 Not Found

```python
hero = session.get(Hero, hero_id)
if not hero:
    raise HTTPException(status_code=404, detail="Hero not found")
```

### Validation Errors

FastAPI automatically returns 422 for invalid request bodies via Pydantic validation. No extra code needed.

### Integrity Errors (Unique Constraints)

Catch SQLAlchemy `IntegrityError` for database-level constraint violations:

```python
from sqlalchemy.exc import IntegrityError

try:
    session.commit()
except IntegrityError:
    session.rollback()
    raise HTTPException(status_code=409, detail="Duplicate entry")
```

---

## Testing with SQLModel

### Override the Session Dependency

Replace the real database with an in-memory SQLite database in tests. Use `app.dependency_overrides` to inject the test session:

```python
# tests/conftest.py
import pytest
from fastapi.testclient import TestClient
from sqlmodel import Session, SQLModel, create_engine
from sqlmodel.pool import StaticPool

from app.main import app
from app.database import get_session

@pytest.fixture(name="session")
def session_fixture():
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,  # share connection across threads
    )
    SQLModel.metadata.create_all(engine)
    with Session(engine) as session:
        yield session

@pytest.fixture(name="client")
def client_fixture(session: Session):
    def get_session_override():
        return session

    app.dependency_overrides[get_session] = get_session_override
    client = TestClient(app)
    yield client
    app.dependency_overrides.clear()
```

### Writing Tests

```python
# tests/test_heroes.py
from fastapi.testclient import TestClient
from sqlmodel import Session
from app.models import Hero

def test_create_hero(client: TestClient):
    response = client.post(
        "/heroes/",
        json={"name": "Deadpond", "secret_name": "Dive Wilson"},
    )
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Deadpond"
    assert data["id"] is not None

def test_read_hero(client: TestClient, session: Session):
    hero = Hero(name="Spider-Boy", secret_name="Pedro Parqueador")
    session.add(hero)
    session.commit()

    response = client.get(f"/heroes/{hero.id}")
    assert response.status_code == 200
    assert response.json()["name"] == "Spider-Boy"

def test_read_hero_not_found(client: TestClient):
    response = client.get("/heroes/99999")
    assert response.status_code == 404
```

Key points:
- `StaticPool` ensures the in-memory SQLite database is shared across the test connection.
- Import all table models before `SQLModel.metadata.create_all(engine)` runs in tests.
- Clear `dependency_overrides` after each test to prevent state leakage.

---

## Lifespan (Modern Startup)

The `@app.on_event("startup")` decorator is deprecated. Use `lifespan` instead (FastAPI 0.93+):

```python
from contextlib import asynccontextmanager
from fastapi import FastAPI
from app.database import create_db_and_tables
from app import models  # ensures table models are registered

@asynccontextmanager
async def lifespan(app: FastAPI):
    create_db_and_tables()
    yield
    # Teardown code here if needed

app = FastAPI(lifespan=lifespan)
```

The `import app.models` line before `create_db_and_tables()` is critical — it registers all `SQLModel` subclasses with `SQLModel.metadata` so `create_all` picks them up.
