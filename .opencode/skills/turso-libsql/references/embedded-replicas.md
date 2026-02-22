# Embedded Replicas Reference

Detailed guide to using Turso embedded replicas — local SQLite files that sync with a remote Turso Cloud database.

## Table of Contents

- [How Embedded Replicas Work](#how-embedded-replicas-work)
- [Setup by Language](#setup-by-language)
- [Sync Strategies](#sync-strategies)
- [Read-Your-Writes Semantics](#read-your-writes-semantics)
- [Offline Mode](#offline-mode)
- [Encryption at Rest](#encryption-at-rest)
- [When to Use / Avoid](#when-to-use--avoid)
- [Operational Considerations](#operational-considerations)
- [Deployment Guides](#deployment-guides)

---

## How Embedded Replicas Work

1. **Local file** (`url`) — the replica lives on-disk beside your application
2. **Remote primary** (`syncUrl`) — the authoritative Turso Cloud database

**Reads** are always served from the local file — microsecond latency, no network round-trip.

**Writes** are forwarded to the remote primary by default. After a successful write, the local replica reflects the change immediately (read-your-writes). Other replicas see the change on their next sync.

**Sync** pulls frames from the remote WAL log into the local file. One frame = 4 KB (one SQLite page).

---

## Setup by Language

### TypeScript / JavaScript

```ts
import { createClient } from "@libsql/client";

const client = createClient({
  url: "file:replica.db",                           // local file path
  syncUrl: process.env.TURSO_DATABASE_URL!,         // libsql://...turso.io
  authToken: process.env.TURSO_AUTH_TOKEN!,
  syncInterval: 60,                                  // auto-sync every 60s (optional)
  offline: false,                                    // default; writes go to remote
});

// Manual sync
await client.sync();
```

### Go

```go
import (
  "os"
  "path/filepath"
  "github.com/tursodatabase/go-libsql"
)

dir, _ := os.MkdirTemp("", "libsql-*")
defer os.RemoveAll(dir)

connector, err := libsql.NewEmbeddedReplicaConnector(
  filepath.Join(dir, "replica.db"),
  os.Getenv("TURSO_DATABASE_URL"),
  libsql.WithAuthToken(os.Getenv("TURSO_AUTH_TOKEN")),
  libsql.WithSyncInterval(60 * time.Second),
)
defer connector.Close()

// Trigger sync
if err := connector.Sync(); err != nil {
  log.Printf("sync error: %v", err)
}

db := sql.OpenDB(connector)
defer db.Close()
```

### Rust

```rust
use libsql::Builder;

let db = Builder::new_remote_replica("file:replica.db", "libsql://...turso.io", "token")
    .sync_interval(std::time::Duration::from_secs(60))
    .build()
    .await?;

let conn = db.connect()?;

// Manual sync
db.sync().await?;
```

### PHP (Laravel)

```php
// config/database.php
"libsql" => [
    "driver"        => "libsql",
    "database"      => database_path("replica.db"),
    "url"           => env("TURSO_DATABASE_URL"),
    "password"      => env("TURSO_AUTH_TOKEN"),
    "sync_interval" => env("TURSO_SYNC_INTERVAL", 300),
],
```

---

## Sync Strategies

### Manual Sync (explicit control)

Call `sync()` at defined moments: application startup, after a user action, or on a schedule.

```ts
// Sync on app startup
await client.sync();

// Sync before a critical read
await client.sync();
const result = await client.execute("SELECT * FROM config");
```

**Use when**: the application can tolerate slightly stale reads and wants full control over network usage.

### Periodic Sync (background interval)

Set `syncInterval` (seconds) to sync automatically in the background. The application does not need to call `sync()` explicitly.

```ts
const client = createClient({
  url: "file:replica.db",
  syncUrl: process.env.TURSO_DATABASE_URL!,
  authToken: process.env.TURSO_AUTH_TOKEN!,
  syncInterval: 300,  // every 5 minutes
});
```

**Use when**: the application can tolerate eventual consistency within the sync window and prefers simpler code.

### Hybrid (startup + periodic)

```ts
const client = createClient({
  url: "file:replica.db",
  syncUrl: process.env.TURSO_DATABASE_URL!,
  authToken: process.env.TURSO_AUTH_TOKEN!,
  syncInterval: 120,
});

// Ensure fresh state at startup
await client.sync();
```

**Use when**: best-effort freshness on startup with background updates thereafter.

---

## Read-Your-Writes Semantics

After a write returns successfully, the replica that performed the write will immediately see the updated data — even without calling `sync()`. This is guaranteed per-connection.

Other replicas (separate processes, different machines) will see the write only after their next sync.

```ts
// Write
await client.execute({
  sql: "INSERT INTO events (name) VALUES (?)",
  args: ["purchase"],
});

// Read immediately — guaranteed to reflect the write above
const { rows } = await client.execute("SELECT * FROM events ORDER BY rowid DESC LIMIT 1");
// rows[0].name === "purchase" ✓
```

---

## Offline Mode

Enable `offline: true` to route writes to the local file instead of the remote primary. Useful for mobile apps or edge deployments with intermittent connectivity.

```ts
const client = createClient({
  url: "file:replica.db",
  syncUrl: process.env.TURSO_DATABASE_URL!,
  authToken: process.env.TURSO_AUTH_TOKEN!,
  offline: true,
});

// All writes go to local file
await client.execute("INSERT INTO events (name) VALUES ('offline_action')");

// Sync when connectivity is restored
await client.sync();
```

**Conflict resolution**: Turso uses last-write-wins at the frame level for offline sync. Design your schema to avoid conflicts (e.g., append-only tables, UUIDs for primary keys, `updated_at` timestamps).

---

## Encryption at Rest

Embedded replicas support encryption. The local file is stored as raw encrypted data — unreadable without the key.

```ts
const client = createClient({
  url: "file:replica.db",
  syncUrl: process.env.TURSO_DATABASE_URL!,
  authToken: process.env.TURSO_AUTH_TOKEN!,
  encryptionKey: process.env.DB_ENCRYPTION_KEY!,  // your securely managed key
});
```

```rust
let db = Builder::new_remote_replica("file:replica.db", "libsql://...", "token")
    .encryption_key("your-32-byte-key".into())
    .build()
    .await?;
```

**Key management**:
- Generate the key outside the application (e.g., via your secrets manager)
- Store it in environment variables or a vault (AWS Secrets Manager, HashiCorp Vault, etc.)
- Do not derive the key from user passwords without a proper KDF (e.g., Argon2)
- Losing the key means permanent data loss — back it up securely
- Rotating the key requires re-encrypting the local file

---

## When to Use / Avoid

### Use embedded replicas when:

- Deploying to **VMs or VPS** (Fly.io, Railway, Render, Koyeb) — persistent filesystem available
- Building **mobile apps** — offline-capable, local reads are critical
- Building **desktop apps** — same pattern; local speed, remote sync
- Running **long-lived server processes** that need sub-millisecond reads

### Do NOT use embedded replicas when:

| Scenario | Reason | Alternative |
|---|---|---|
| Serverless (AWS Lambda, Vercel Functions, Cloudflare Workers) | No persistent filesystem between invocations | Use `https://` or `libsql://` direct connection |
| Multiple concurrent processes sharing the same local file | Concurrent writes corrupt the local replica | Give each process its own replica file or use direct connection |
| Read-only serverless consumers | No sync benefit without a filesystem | Use `https://` with a read-only token |

---

## Operational Considerations

### Storage usage

One frame = 4 KB. Writing a 1-byte row still creates a 4 KB frame. Large btree splits can generate many frames. Monitor local file size and disk usage.

### WAL compaction (Checkpoint)

The local WAL grows over time. Compact it periodically to bound disk usage:

```ts
// Turso Sync checkpoint (not standard SQLite PRAGMA)
await client.execute("PRAGMA wal_checkpoint(TRUNCATE)");
```

Refer to `https://docs.turso.tech/sync/checkpoint` for details on automatic checkpointing behavior.

### Re-syncing from scratch

Deleting the local replica file forces a full re-sync from the remote on the next connection. This is safe but can transfer significant data for large databases.

### Do not open the local file while syncing

Avoid opening the local `.db` file with an external tool (SQLite browser, sqlite3 CLI) while the application is syncing. This can cause data corruption.

### Frame over-sync scenarios

Expect more frames to sync than a raw write count would suggest in these cases:
- Btree node splits during writes
- Server restart leaving the WAL in dirty state
- Local file deletion (full re-sync from scratch)

---

## Deployment Guides

Official guides for deploying embedded replicas to hosted platforms:

| Platform | Notes |
|---|---|
| **Fly.io** | Persistent volumes available; map the volume to the replica file path |
| **Railway** | Persistent disk available; configure the replica path to the mounted volume |
| **Koyeb** | Persistent storage available for stateful deployments |
| **Render** | Persistent disk available; attach to the service |
| **Linode / Akamai** | Standard VM — full filesystem access |

Common pattern for containerized deployments:

```dockerfile
# Mount a persistent volume at /data
VOLUME ["/data"]

# Set replica path to the mounted volume
ENV REPLICA_PATH=/data/replica.db
```

```ts
const client = createClient({
  url: `file:${process.env.REPLICA_PATH ?? "replica.db"}`,
  syncUrl: process.env.TURSO_DATABASE_URL!,
  authToken: process.env.TURSO_AUTH_TOKEN!,
  syncInterval: 60,
});
```

Ensure the volume persists across deployments/restarts. If the volume is ephemeral, the replica will re-sync from scratch on each restart.
