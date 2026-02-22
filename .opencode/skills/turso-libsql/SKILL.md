---
name: turso-libsql
description: This skill should be used when the user asks to "connect to Turso", "use libSQL", "set up a Turso database", "query Turso with TypeScript", or needs guidance on Turso Cloud, embedded replicas, or vector search with libSQL.
---

# Turso & libSQL

Turso is a SQLite-compatible managed database platform built on libSQL — a production-ready, open-contribution fork of SQLite. libSQL adds native vector search, extensions, and async I/O while remaining fully backward-compatible with SQLite.

**libSQL vs. Turso Database**: libSQL is the battle-tested fork used by Turso Cloud today. Turso Database is a ground-up rewrite optimized for extreme density and concurrent writes (currently in beta). For new projects with stable workloads, use libSQL via Turso Cloud. For new projects targeting agents, on-device, or high-density use cases, consider Turso Database.

## Key Concepts

| Term | Meaning |
|---|---|
| **Database** | A single libSQL database instance hosted on Turso Cloud |
| **Group** | A collection of databases sharing a region and auth tokens |
| **Embedded Replica** | A local SQLite file that syncs with a remote Turso database |
| **Auth Token** | JWT used to authenticate SDK connections |
| **libsql://** | The native Turso protocol (WebSocket-based, best for persistent connections) |
| **https://** | HTTP-based access, better for single-shot serverless queries |

## Installation

```bash
# TypeScript / JavaScript
npm install @libsql/client

# Python
pip install libsql-client

# Rust (Cargo.toml)
# libsql = "0.6"

# Go
# go get github.com/tursodatabase/go-libsql
```

## Connecting to Turso

Always load credentials from environment variables. Never hardcode tokens.

```ts
import { createClient } from "@libsql/client";

const client = createClient({
  url: process.env.TURSO_DATABASE_URL!,    // libsql://[DB]-[ORG].turso.io
  authToken: process.env.TURSO_AUTH_TOKEN!, // JWT from Turso CLI or Platform API
});
```

**Protocol selection**:
- Use `libsql://` for persistent connections (WebSockets) — best for servers and long-lived processes
- Use `https://` for single serverless invocations — fewer round-trips per cold start
- Use `file:path/to/db.db` for local SQLite files (no `authToken` needed)
- Use `:memory:` for in-memory databases in tests

## Executing Queries

Always use parameterized queries. Never interpolate user input into SQL strings.

```ts
// Simple query
const result = await client.execute("SELECT * FROM users");

// Positional placeholders (preferred for brevity)
const user = await client.execute({
  sql: "SELECT * FROM users WHERE id = ?",
  args: [userId],
});

// Named placeholders
const inserted = await client.execute({
  sql: "INSERT INTO users (name, email) VALUES (:name, :email)",
  args: { name: "Iku", email: "iku@example.com" },
});
```

**ResultSet fields**:
- `rows` — array of row objects
- `columns` — column names in order
- `rowsAffected` — for write operations
- `lastInsertRowid` — `bigint | undefined` for INSERT

## Transactions

### Batch Transactions (preferred for multi-statement writes)

All statements execute atomically. Any failure rolls back the entire batch.

```ts
await client.batch(
  [
    { sql: "INSERT INTO orders (user_id) VALUES (?)", args: [userId] },
    { sql: "UPDATE inventory SET stock = stock - 1 WHERE id = ?", args: [itemId] },
  ],
  "write",
);
```

### Interactive Transactions (for conditional logic)

Use when write decisions depend on reads within the same transaction. Note: interactive transactions lock the database for up to 5 seconds — prefer batch transactions where possible.

```ts
const tx = await client.transaction("write");
try {
  const { rows } = await tx.execute({
    sql: "SELECT balance FROM accounts WHERE id = ?",
    args: [accountId],
  });
  if ((rows[0].balance as number) >= amount) {
    await tx.execute({
      sql: "UPDATE accounts SET balance = balance - ? WHERE id = ?",
      args: [amount, accountId],
    });
    await tx.commit();
  } else {
    await tx.rollback();
  }
} catch (e) {
  await tx.rollback();
  throw e;
}
```

### Transaction Modes

| Mode | SQLite Command | Use When |
|---|---|---|
| `write` | `BEGIN IMMEDIATE` | Mix of reads and writes |
| `read` | `BEGIN TRANSACTION READONLY` | Read-only; can parallelize on replicas |
| `deferred` | `BEGIN DEFERRED` | Unknown upfront; may fail if a write is in flight |

## Local Development

Use environment variables to switch between local and remote transparently:

```ts
// .env.local
TURSO_DATABASE_URL=file:local.db
// No TURSO_AUTH_TOKEN needed for local files

// .env.production
TURSO_DATABASE_URL=libsql://my-db-myorg.turso.io
TURSO_AUTH_TOKEN=eyJ...
```

Run a local libSQL server with libSQL-specific features (extensions, etc.):

```bash
turso dev --db-file local.db
# Connects at http://127.0.0.1:8080
```

## Embedded Replicas

Embedded replicas sync a remote Turso database into a local file. Reads are microsecond-speed (local). Writes go to the remote primary and are reflected locally immediately (read-your-writes semantics).

```ts
const client = createClient({
  url: "file:replica.db",         // local file path
  syncUrl: process.env.TURSO_DATABASE_URL!,
  authToken: process.env.TURSO_AUTH_TOKEN!,
  syncInterval: 60,               // auto-sync every 60 seconds (optional)
});

// Manually trigger sync
await client.sync();
```

**When to use embedded replicas**:
- VMs / VPS deployments where the process is long-lived
- Mobile apps needing offline-capable local data
- Edge deployments with filesystem access

**Do not use embedded replicas in**:
- Serverless environments without a persistent filesystem (use `https://` instead)
- Multiple concurrent processes writing to the same local file (risk of corruption)

See `references/embedded-replicas.md` for sync patterns and deployment guides.

## Vector Search

libSQL includes native vector search — no extension required. Use `F32_BLOB` for embeddings (best balance of precision and storage).

```sql
-- Schema
CREATE TABLE documents (
  id    INTEGER PRIMARY KEY,
  text  TEXT,
  embedding F32_BLOB(1536)  -- match your embedding model's dimensions
);

-- Create vector index (DiskANN-based ANN search)
CREATE INDEX documents_idx ON documents (libsql_vector_idx(embedding));

-- Insert with embedding
INSERT INTO documents (text, embedding)
VALUES ('Hello world', vector32('[0.1, 0.2, ...]'));

-- Query top-K nearest neighbors
SELECT d.id, d.text
FROM vector_top_k('documents_idx', vector32('[0.1, 0.2, ...]'), 5)
JOIN documents d ON d.rowid = id;
```

See `references/vector-search.md` for index settings, distance functions, and RAG patterns.

## Authentication & Security

- Generate scoped auth tokens via the CLI: `turso db tokens create <db-name>`
- For group-level tokens: `turso group tokens create <group-name>`
- Rotate tokens with: `turso db tokens invalidate <db-name>`
- Use JWKS integration to let your auth provider (Clerk, Auth0) issue tokens directly
- Apply fine-grained permissions to restrict tokens to specific tables or operations

See `references/connection-and-auth.md` for token scoping, JWKS setup, and security checklist.

## CLI Quick Reference

```bash
turso auth login                          # authenticate
turso db create my-db                    # create database
turso db show my-db                      # show URL and metadata
turso db tokens create my-db             # create auth token
turso db shell my-db                     # interactive SQL shell
turso db inspect my-db                   # storage stats and top queries
turso dev --db-file local.db             # local libSQL server
```

## Additional Resources

- **`references/connection-and-auth.md`** — Auth tokens, JWKS, fine-grained permissions, security checklist
- **`references/vector-search.md`** — Vector types, index settings, distance functions, RAG query patterns
- **`references/embedded-replicas.md`** — Sync strategies, encryption at rest, deployment guides
