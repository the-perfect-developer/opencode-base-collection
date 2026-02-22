# env.py Configuration Reference

This file covers advanced `env.py` customization patterns for Alembic.

## Table of Contents

- [Reading Database URL from Environment Variables](#reading-database-url-from-environment-variables)
- [Async DBAPI Support](#async-dbapi-support)
- [Filtering Tables with include_name](#filtering-tables-with-include_name)
- [Fine-grained Object Filtering with include_object](#fine-grained-object-filtering-with-include_object)
- [Multiple MetaData Collections](#multiple-metadata-collections)
- [Offline (SQL Script) Mode](#offline-sql-script-mode)
- [Enabling compare_type and compare_server_default](#enabling-compare_type-and-compare_server_default)
- [pyproject.toml Configuration](#pyprojecttoml-configuration)

---

## Reading Database URL from Environment Variables

Never store production credentials in `alembic.ini`. Override the URL in `env.py`:

```python
# env.py
import os
from alembic import context

config = context.config

# Override sqlalchemy.url from environment
database_url = os.environ.get("DATABASE_URL")
if database_url:
    config.set_main_option("sqlalchemy.url", database_url)
```

For 12-factor apps, this is the standard approach and allows the same codebase to work across dev/staging/prod without config changes.

---

## Async DBAPI Support

Use the `async` template (`alembic init --template async alembic`), which generates an `env.py` using `AsyncEngine`. The key difference is wrapping migration calls in `async_engine_from_config` and `run_sync`:

```python
# env.py (async template excerpt)
import asyncio
from sqlalchemy.ext.asyncio import async_engine_from_config

async def run_async_migrations():
    connectable = async_engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )
    async with connectable.connect() as connection:
        await connection.run_sync(do_run_migrations)
    await connectable.dispose()

def run_migrations_online():
    asyncio.run(run_async_migrations())
```

`NullPool` is required for migration scripts to prevent connection pooling issues during short-lived processes.

---

## Filtering Tables with include_name

When the database contains tables outside the application's `MetaData` (e.g., third-party extensions, legacy tables), autogenerate will generate spurious `drop_table` operations. Prevent this with `include_name`:

### Filter by table name

```python
# env.py
target_metadata = MyModel.metadata

def include_name(name, type_, parent_names):
    if type_ == "table":
        return name in target_metadata.tables
    return True

def run_migrations_online():
    with engine.connect() as connection:
        context.configure(
            connection=connection,
            target_metadata=target_metadata,
            include_name=include_name,
        )
        with context.begin_transaction():
            context.run_migrations()
```

### Filter by schema (multi-schema setups)

```python
def include_name(name, type_, parent_names):
    if type_ == "schema":
        # None = default schema; include it plus specific named schemas
        return name in [None, "app_schema", "audit_schema"]
    elif type_ == "table":
        return (
            parent_names["schema_qualified_table_name"] in target_metadata.tables
        )
    return True

context.configure(
    connection=connection,
    target_metadata=target_metadata,
    include_schemas=True,
    include_name=include_name,
)
```

`include_name` applies only to reflected (database-side) objects. Objects present in `MetaData` but absent from the database will still be detected for creation.

---

## Fine-grained Object Filtering with include_object

`include_object` provides column/constraint-level control and applies to both `MetaData` and reflected objects:

```python
def include_object(object, name, type_, reflected, compare_to):
    # Skip columns tagged to be ignored by autogenerate
    if (
        type_ == "column"
        and not reflected
        and object.info.get("skip_autogenerate", False)
    ):
        return False
    # Skip audit tables managed by a trigger system
    if type_ == "table" and name.startswith("audit_"):
        return False
    return True

context.configure(
    connection=connection,
    target_metadata=target_metadata,
    include_object=include_object,
)
```

Use `include_name` for name-based filtering (cheaper; avoids full reflection). Use `include_object` when you need access to the actual SQLAlchemy object (e.g., inspecting `Column.info`).

---

## Multiple MetaData Collections

Pass a list to `target_metadata` when an application uses multiple declarative bases:

```python
from myapp.models.core import CoreBase
from myapp.models.audit import AuditBase

target_metadata = [CoreBase.metadata, AuditBase.metadata]
```

Each `MetaData` must contain unique table keys (no duplicate `schema.tablename` across collections). The collections are consulted in order during autogenerate.

---

## Offline (SQL Script) Mode

Offline mode generates SQL DDL scripts without a live database connection. Useful for DBAs reviewing migrations before applying:

```bash
alembic upgrade head --sql > migration.sql
alembic upgrade ae1027a6acf:head --sql > partial.sql
```

In `env.py`, the `run_migrations_offline()` function handles this path — it uses `url` instead of a live `connection`:

```python
def run_migrations_offline():
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )
    with context.begin_transaction():
        context.run_migrations()
```

---

## Enabling compare_type and compare_server_default

By default (since Alembic 1.12), `compare_type=True` is the default. If needed, configure explicitly in `env.py`:

```python
context.configure(
    connection=connection,
    target_metadata=target_metadata,
    compare_type=True,           # detect column type changes
    compare_server_default=True, # detect server default changes (use with caution)
)
```

`compare_server_default=True` can produce false positives. Test on the target schema before enabling in production autogenerate workflows. PostgreSQL has the best support (it evaluates the defaults against the database).

### Custom Type Comparator

```python
def my_compare_type(context, inspected_column, metadata_column,
                    inspected_type, metadata_type):
    # Return False = types match, True = types differ, None = use default logic
    if isinstance(metadata_type, MyCustomType):
        return str(inspected_type) != str(metadata_type)
    return None  # fall back to default comparison

context.configure(
    connection=connection,
    target_metadata=target_metadata,
    compare_type=my_compare_type,
)
```

---

## pyproject.toml Configuration

The `pyproject` template splits configuration into two files:

**`pyproject.toml`** — source/code config:

```toml
[tool.alembic]
script_location = "%(here)s/alembic"
prepend_sys_path = ["."]

# Optional: organize migrations by date
# file_template = "%%(year)d/%%(month).2d/%%(day).2d_%%(hour).2d%%(minute).2d_%%(rev)s_%%(slug)s"
# recursive_version_locations = true
```

**`alembic.ini`** — deployment config (database URL, logging):

```ini
[alembic]
sqlalchemy.url = postgresql+psycopg2://user:pass@localhost/mydb
```

When all connectivity is managed by `env.py` (e.g., via environment variables), `alembic.ini` can be omitted entirely. Alembic runs successfully with only `pyproject.toml` present.

### Percent-sign escaping in pyproject.toml

Alembic applies `%(here)s`-style interpolation to `pyproject.toml` values just as it does for `alembic.ini`. The `file_template` value must double `%` signs:

```toml
# Correct — doubled %% for alembic's interpolation
file_template = "%%(year)d_%%(month).2d_%%(rev)s_%%(slug)s"
```
