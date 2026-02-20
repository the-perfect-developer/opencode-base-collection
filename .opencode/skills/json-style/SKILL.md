---
name: json-style
description: This skill should be used when the user asks to "format JSON", "design JSON API", "write JSON response", "structure JSON data", or needs guidance on JSON naming conventions and best practices based on Google's JSON Style Guide.
license: CC-BY-3.0
compatibility: opencode
---

# JSON Style Guide

Apply Google's JSON Style Guide conventions for consistent, well-structured JSON APIs and data formats.

## Overview

This skill provides guidelines for creating JSON APIs and data structures following Google's JSON Style Guide. The guide clarifies naming conventions, property structures, reserved property names, and standard patterns for JSON requests and responses in both RPC-based and REST-based APIs.

## Core Principles

### Use Double Quotes

All property names must be surrounded by double quotes. String values must use double quotes. Other value types (boolean, number, null, arrays, objects) should not be quoted.

```json
{
  "propertyName": "string value",
  "count": 42,
  "isActive": true,
  "data": null
}
```

### No Comments

Do not include comments in JSON objects. JSON does not support comments in the specification.

### Flatten Data Appropriately

Data should be flattened unless there is a clear semantic reason for structured hierarchy. Group properties only when they represent a single logical structure.

**Structured (preferred for related data)**:
```json
{
  "company": "Google",
  "address": {
    "line1": "111 8th Ave",
    "city": "New York",
    "state": "NY",
    "zip": "10011"
  }
}
```

## Property Naming

### Naming Format

Property names must:
- Be meaningful with defined semantics
- Use camelCase (not snake_case or PascalCase)
- Start with a letter, underscore (_), or dollar sign ($)
- Contain only letters, digits, underscores, or dollar signs
- Avoid JavaScript reserved keywords

```json
{
  "firstName": "John",
  "lastName": "Doe",
  "accountBalance": 1000.50,
  "isVerified": true
}
```

### Singular vs Plural

Use plural names for arrays. Use singular names for all other properties.

```json
{
  "author": "lisa",
  "siblings": ["bart", "maggie"],
  "totalItems": 10,
  "itemCount": 10
}
```

### JSON Maps vs Objects

When using a JSON object as a map (associative array), keys can use any Unicode characters. Map keys do not need to follow property naming guidelines.

```json
{
  "address": {
    "addressLine1": "123 Anystreet",
    "city": "Anytown"
  },
  "thumbnails": {
    "72": "https://url.to.72px.thumbnail",
    "144": "https://url.to.144px.thumbnail"
  }
}
```

## Property Values

### Valid Value Types

Property values must be:
- Boolean: `true` or `false`
- Number: integers or floating-point
- String: Unicode strings in double quotes
- Object: `{}`
- Array: `[]`
- Null: `null`

JavaScript expressions and functions are not allowed.

### Empty or Null Values

Consider removing properties with empty or null values unless there is a strong semantic reason. A property with value `0`, `false`, or `""` may have semantic meaning and should be kept.

```json
{
  "volume": 10,
  "balance": 0,
  "currentlyPlaying": null
}
```

Better:
```json
{
  "volume": 10,
  "balance": 0
}
```

### Enum Values

Represent enums as strings (not numbers) to handle graceful changes as APIs evolve.

```json
{
  "color": "WHITE",
  "status": "ACTIVE"
}
```

## Standard Data Types

### Dates

Format dates according to RFC 3339:

```json
{
  "lastUpdate": "2007-11-06T16:34:41.000Z",
  "createdAt": "2024-02-19T10:30:00.000Z"
}
```

### Time Durations

Format durations according to ISO 8601:

```json
{
  "duration": "P3Y6M4DT12H30M5S"
}
```

### Latitude/Longitude

Format coordinates according to ISO 6709 using ±DD.DDDD±DDD.DDDD degrees format:

```json
{
  "location": "+40.6894-074.0447"
}
```

## Standard JSON Structure

### Top-Level Properties

A JSON response should have these optional top-level properties:

- `apiVersion` - Version of the API (string)
- `context` - Client-set value echoed by server (string)
- `id` - Server-assigned response identifier (string)
- `method` - Operation performed (string)
- `params` - Input parameters for RPC requests (object)
- `data` - Container for successful response data (object)
- `error` - Error details if request failed (object)

A response should contain either `data` or `error`, but not both.

```json
{
  "apiVersion": "2.1",
  "data": {
    "kind": "user",
    "id": "12345",
    "name": "John Doe"
  }
}
```

### Data Object Properties

Common properties in the `data` object:

- `kind` - Type of object (should be first property)
- `fields` - Fields present in partial response
- `etag` - Entity tag for versioning
- `id` - Unique identifier
- `lang` - Language code (BCP 47)
- `updated` - Last update timestamp (RFC 3339)
- `deleted` - Boolean marker for deleted entries
- `items` - Array of items (should be last property)

### Pagination Properties

For paginated data in the `data` object:

- `currentItemCount` - Number of items in current response
- `itemsPerPage` - Requested page size
- `startIndex` - Index of first item (1-based)
- `totalItems` - Total available items
- `pageIndex` - Current page number (1-based)
- `totalPages` - Total number of pages
- `pagingLinkTemplate` - URI template for pagination

### Link Properties

Link properties in the `data` object:

- `self` / `selfLink` - Link to retrieve this resource
- `edit` / `editLink` - Link to update/delete this resource
- `next` / `nextLink` - Link to next page
- `previous` / `previousLink` - Link to previous page

### Error Object Properties

When an error occurs, use the `error` object:

- `code` - HTTP status code (integer)
- `message` - Human-readable error message (string)
- `errors` - Array of error details (array)

Each error in `errors` array can have:
- `domain` - Service identifier
- `reason` - Error type identifier
- `message` - Detailed error message
- `location` - Where error occurred
- `locationType` - How to interpret location
- `extendedHelp` - URI to help documentation
- `sendReport` - URI to error report form

```json
{
  "apiVersion": "2.0",
  "error": {
    "code": 404,
    "message": "File Not Found",
    "errors": [{
      "domain": "Calendar",
      "reason": "ResourceNotFoundException",
      "message": "File Not Found"
    }]
  }
}
```

## Property Ordering

While property order is not enforced by JSON, certain orderings improve parsing efficiency:

1. **`kind` should be first** - Helps parsers determine object type early
2. **`items` should be last in `data`** - Allows reading collection metadata before parsing items

```json
{
  "data": {
    "kind": "album",
    "title": "My Photo Album",
    "totalItems": 100,
    "items": [
      {
        "kind": "photo",
        "title": "My First Photo"
      }
    ]
  }
}
```

## Quick Reference

### Naming Checklist

- [ ] Use camelCase for property names
- [ ] Use plural names for arrays
- [ ] Use singular names for other properties
- [ ] Avoid JavaScript reserved keywords
- [ ] Choose meaningful, semantic names

### Value Type Checklist

- [ ] Use strings for enum values
- [ ] Format dates as RFC 3339
- [ ] Format durations as ISO 8601
- [ ] Remove null/empty values unless semantically meaningful
- [ ] Use appropriate types (boolean, number, string, object, array, null)

### Structure Checklist

- [ ] Include `apiVersion` in responses
- [ ] Use `data` for success, `error` for failures (not both)
- [ ] Place `kind` first in objects
- [ ] Place `items` last in `data` object
- [ ] Use reserved property names for standard semantics

## Additional Resources

### Reference Files

For detailed specifications:
- **`references/naming-conventions.md`** - Complete naming rules and reserved keywords
- **`references/reserved-properties.md`** - Full list of reserved property names and their semantics
- **`references/pagination-patterns.md`** - Detailed pagination implementation patterns

### Example Files

Working examples in `examples/`:
- **`examples/api-response.json`** - Standard API response structure
- **`examples/error-response.json`** - Error handling example
- **`examples/paginated-response.json`** - Pagination example with all properties
