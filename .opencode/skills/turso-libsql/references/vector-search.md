# Vector Search Reference

Complete guide to native vector search in libSQL — types, indexes, distance functions, and RAG query patterns.

## Table of Contents

- [Overview](#overview)
- [Vector Types](#vector-types)
- [Vector Functions](#vector-functions)
- [Creating Tables with Vectors](#creating-tables-with-vectors)
- [Inserting Embeddings](#inserting-embeddings)
- [Vector Index (ANN Search)](#vector-index-ann-search)
- [Index Settings](#index-settings)
- [Querying](#querying)
- [RAG Pattern](#rag-pattern)
- [Limitations](#limitations)
- [Choosing the Right Type](#choosing-the-right-type)

---

## Overview

libSQL includes vector search natively — no extension required, no separate service to manage. The implementation is based on the [DiskANN](https://turso.tech/blog/approximate-nearest-neighbor-search-with-diskann-in-libsql) algorithm for approximate nearest neighbor (ANN) search. Vectors are stored as SQLite BLOBs with metadata encoded inside the blob itself.

Vector search integrates with standard SQL: join `vector_top_k()` results with any table, apply WHERE clauses, and combine with full-text or structured filters.

---

## Vector Types

| Type | Bytes per dimension | Use Case |
|---|---|---|
| `FLOAT64` / `F64_BLOB` | 8 | Maximum precision, large storage |
| `FLOAT32` / `F32_BLOB` | 4 | **Recommended default** — best precision/storage balance |
| `FLOAT16` / `F16_BLOB` | 2 | Compact, moderate precision |
| `FLOATB16` / `FB16_BLOB` | 2 | Compact, faster ops than FLOAT16 but less precise |
| `FLOAT8` / `F8_BLOB` | 1 | Very compact, lossy |
| `FLOAT1BIT` / `F1BIT_BLOB` | 1 bit | Extreme compression, binary vectors only |

Library authors: prefer the `_BLOB` suffix variants to align with SQLite affinity rules.

**Storage estimate**: for N rows with D-dimensional `FLOAT32` vectors: `N × 4D` bytes.

---

## Vector Functions

| Function | Description |
|---|---|
| `vector32(text)` | Convert JSON array string to `FLOAT32` binary |
| `vector64(text)` | Convert JSON array string to `FLOAT64` binary |
| `vector16(text)` | Convert JSON array string to `FLOAT16` binary |
| `vectorb16(text)` | Convert JSON array string to `FLOATB16` binary |
| `vector8(text)` | Convert JSON array string to `FLOAT8` binary |
| `vector1bit(text)` | Convert JSON array string to `FLOAT1BIT` binary |
| `vector(text)` | Alias for `vector32` |
| `vector_extract(blob)` | Extract JSON text representation from binary vector |
| `vector_distance_cos(a, b)` | Cosine distance (0=identical, 1=orthogonal, 2=opposite) |
| `vector_distance_l2(a, b)` | Euclidean (L2) distance |

Both vectors in a distance function must have **the same type and same dimensionality**.

---

## Creating Tables with Vectors

```sql
-- Recommended: use F32_BLOB with explicit dimensionality
CREATE TABLE documents (
  id        INTEGER PRIMARY KEY,
  content   TEXT NOT NULL,
  source    TEXT,
  embedding F32_BLOB(1536)  -- 1536 = OpenAI text-embedding-3-small dimensions
);

-- Multi-vector table (e.g., question + answer embeddings)
CREATE TABLE qa_pairs (
  id               INTEGER PRIMARY KEY,
  question         TEXT,
  answer           TEXT,
  question_emb     F32_BLOB(768),
  answer_emb       F32_BLOB(768)
);
```

The number in parentheses (e.g., `1536`) enforces dimensionality — all vectors in the column must have exactly that many components.

---

## Inserting Embeddings

Pass embeddings as JSON array strings using the conversion function:

```sql
-- Single row
INSERT INTO documents (content, source, embedding)
VALUES (
  'Turso is a SQLite-compatible database platform',
  'docs',
  vector32('[0.1, 0.02, -0.4, ...]')  -- full 1536-dim vector
);
```

From TypeScript with a real embedding API:

```ts
import { createClient } from "@libsql/client";
import OpenAI from "openai";

const client = createClient({
  url: process.env.TURSO_DATABASE_URL!,
  authToken: process.env.TURSO_AUTH_TOKEN!,
});
const openai = new OpenAI();

async function insertDocument(content: string, source: string) {
  const { data } = await openai.embeddings.create({
    model: "text-embedding-3-small",
    input: content,
  });
  const embedding = data[0].embedding; // number[]

  await client.execute({
    sql: "INSERT INTO documents (content, source, embedding) VALUES (?, ?, vector32(?))",
    args: [content, source, JSON.stringify(embedding)],
  });
}
```

For bulk inserts, use batch transactions:

```ts
async function bulkInsert(docs: Array<{ content: string; embedding: number[] }>) {
  await client.batch(
    docs.map((doc) => ({
      sql: "INSERT INTO documents (content, embedding) VALUES (?, vector32(?))",
      args: [doc.content, JSON.stringify(doc.embedding)],
    })),
    "write",
  );
}
```

---

## Vector Index (ANN Search)

Create an index using `libsql_vector_idx` to enable fast approximate nearest neighbor queries. Without the index, similarity search requires a full table scan.

```sql
-- Basic cosine index (default metric)
CREATE INDEX documents_idx ON documents (libsql_vector_idx(embedding));

-- L2 (Euclidean) distance index
CREATE INDEX documents_l2_idx ON documents (libsql_vector_idx(embedding, 'metric=l2'));

-- Partial index (only index documents from a specific source)
CREATE INDEX docs_idx ON documents (libsql_vector_idx(embedding))
WHERE source = 'docs';
```

Index management:

```sql
-- Rebuild index from scratch
REINDEX documents_idx;

-- Remove index
DROP INDEX documents_idx;
```

---

## Index Settings

Pass settings as variadic string arguments to `libsql_vector_idx`:

```sql
CREATE INDEX documents_idx ON documents (
  libsql_vector_idx(
    embedding,
    'metric=cosine',
    'max_neighbors=48',
    'compress_neighbors=float8',
    'alpha=1.2',
    'search_l=200',
    'insert_l=70'
  )
);
```

| Setting | Default | Effect |
|---|---|---|
| `metric` | `cosine` | Distance function: `cosine` or `l2` |
| `max_neighbors` | `3√D` | Neighbors stored per node; lower = less storage, less precision |
| `compress_neighbors` | same as column type | Type used to store graph neighbors; more compact = less storage |
| `alpha` | `1.2` | Graph density; lower = sparser graph, faster search, less precise |
| `search_l` | `200` | Neighbors visited per query; lower = faster search, less precise |
| `insert_l` | `70` | Neighbors visited per insert; lower = faster inserts, less precise |

**Tuning guidance**:
- Reduce `max_neighbors` and `compress_neighbors` first to save storage
- Reduce `search_l` to improve query latency at the cost of recall
- Keep `alpha` at `1.2` unless testing precision/recall tradeoffs at scale

---

## Querying

### Without Index (exact, full-scan — small tables only)

```sql
SELECT id, content,
       vector_distance_cos(embedding, vector32('[0.1, 0.02, ...]')) AS distance
FROM documents
ORDER BY distance ASC
LIMIT 5;
```

### With Index (ANN — preferred for production)

Use `vector_top_k(index_name, query_vector, k)` as a table-valued function. It returns `rowid` (or primary key for WITHOUT ROWID tables).

```sql
SELECT d.id, d.content, d.source
FROM vector_top_k('documents_idx', vector32('[0.1, 0.02, ...]'), 10)
JOIN documents d ON d.rowid = id
WHERE d.source = 'docs'  -- additional filter after ANN retrieval
LIMIT 5;
```

From TypeScript:

```ts
async function similaritySearch(queryEmbedding: number[], topK = 5) {
  const result = await client.execute({
    sql: `
      SELECT d.id, d.content, d.source
      FROM vector_top_k('documents_idx', vector32(?), ?)
      JOIN documents d ON d.rowid = id
    `,
    args: [JSON.stringify(queryEmbedding), topK],
  });
  return result.rows;
}
```

### Distance Interpretation

`vector_distance_cos` returns cosine distance (not similarity):
- `0` — vectors are identical
- `1` — vectors are orthogonal (unrelated)
- `2` — vectors point in opposite directions

Very small negative values near zero (e.g., `-2e-14`) are floating-point artifacts — treat as `0` (exact match).

---

## RAG Pattern

A complete retrieval-augmented generation (RAG) implementation:

```ts
import { createClient } from "@libsql/client";
import OpenAI from "openai";

const db = createClient({
  url: process.env.TURSO_DATABASE_URL!,
  authToken: process.env.TURSO_AUTH_TOKEN!,
});
const openai = new OpenAI();

// 1. Initialize schema
await db.execute(`
  CREATE TABLE IF NOT EXISTS knowledge (
    id        INTEGER PRIMARY KEY,
    content   TEXT NOT NULL,
    metadata  TEXT,
    embedding F32_BLOB(1536)
  )
`);
await db.execute(
  "CREATE INDEX IF NOT EXISTS knowledge_idx ON knowledge (libsql_vector_idx(embedding))"
);

// 2. Ingest documents
async function ingest(documents: Array<{ content: string; metadata?: string }>) {
  const embeddings = await Promise.all(
    documents.map(async (doc) => {
      const { data } = await openai.embeddings.create({
        model: "text-embedding-3-small",
        input: doc.content,
      });
      return { ...doc, embedding: data[0].embedding };
    })
  );

  await db.batch(
    embeddings.map((doc) => ({
      sql: "INSERT INTO knowledge (content, metadata, embedding) VALUES (?, ?, vector32(?))",
      args: [doc.content, doc.metadata ?? null, JSON.stringify(doc.embedding)],
    })),
    "write"
  );
}

// 3. Retrieve and generate
async function query(question: string): Promise<string> {
  // Embed the question
  const { data } = await openai.embeddings.create({
    model: "text-embedding-3-small",
    input: question,
  });
  const queryEmb = data[0].embedding;

  // Retrieve top-5 relevant chunks
  const { rows } = await db.execute({
    sql: `
      SELECT k.content
      FROM vector_top_k('knowledge_idx', vector32(?), 5)
      JOIN knowledge k ON k.rowid = id
    `,
    args: [JSON.stringify(queryEmb)],
  });

  const context = rows.map((r) => r.content).join("\n\n");

  // Generate answer
  const completion = await openai.chat.completions.create({
    model: "gpt-4o-mini",
    messages: [
      { role: "system", content: "Answer using only the provided context." },
      { role: "user", content: `Context:\n${context}\n\nQuestion: ${question}` },
    ],
  });

  return completion.choices[0].message.content ?? "";
}
```

---

## Limitations

- Vector index requires tables **with** `ROWID` or a **singular** `PRIMARY KEY` — composite primary keys without ROWID are not supported
- Euclidean distance (`vector_distance_l2`) is **not supported** for `FLOAT1BIT` vectors
- Maximum dimensionality: **65,536 dimensions**
- `vector_top_k` returns approximate neighbors (DiskANN trades accuracy for speed); use exact full-scan for critical precision requirements on small tables

---

## Choosing the Right Type

| Scenario | Recommended Type |
|---|---|
| OpenAI / Cohere / most models | `F32_BLOB` |
| Storage-constrained, moderate precision needed | `F16_BLOB` or `FB16_BLOB` |
| Extreme compression, binary search (e.g., locality-sensitive hashing) | `F1BIT_BLOB` |
| Library code needing generic compatibility | `F32_BLOB` with `_BLOB` suffix |

Always match the vector type and dimensionality between the table column, the index, and the query vector.
