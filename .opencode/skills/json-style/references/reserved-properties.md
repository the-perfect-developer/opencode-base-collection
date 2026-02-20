# Reserved Property Names

Complete reference for reserved property names in Google's JSON Style Guide, including semantics and usage examples.

## Table of Contents

- [Overview](#overview)
- [Top-Level Properties](#top-level-properties)
- [Data Object Properties](#data-object-properties)
- [Pagination Properties](#pagination-properties)
- [Link Properties](#link-properties)
- [Error Object Properties](#error-object-properties)

## Overview

Reserved property names provide consistency across JSON APIs. These properties have standardized meanings and should only be used for their intended purposes. Services can add custom properties alongside reserved ones.

### Usage Rules

- Reserved properties are **optional** (may appear zero or one time)
- Use reserved properties **only** for their defined semantics
- Services should **avoid** using these names for other purposes
- New reserved properties may be added in future versions

## Top-Level Properties

Properties that appear at the root level of JSON requests and responses.

### apiVersion

**Type**: `string`  
**Parent**: Root level  
**Required**: Recommended for all responses

Represents the version of the service API. Should always be present in responses.

**Purpose**:
- Indicates which API version is being used
- Helps clients handle version-specific behavior
- Not related to data versioning (use etags for that)

**Example**:
```json
{
  "apiVersion": "2.1",
  "data": {}
}
```

### context

**Type**: `string`  
**Parent**: Root level  
**Required**: No

Client-specified value that the server echoes in the response. Useful for correlating requests with responses, especially in JSON-P and batch situations.

**Purpose**:
- Correlate responses with requests
- Different from `id` (which is server-assigned)
- Present regardless of success or error

**Example request**:
```json
{
  "context": "user-profile-widget",
  "method": "users.get",
  "params": {"userId": "123"}
}
```

**Example response**:
```json
{
  "context": "user-profile-widget",
  "data": {
    "name": "John Doe"
  }
}
```

### id

**Type**: `string`  
**Parent**: Root level  
**Required**: No

Server-supplied identifier for the response. Useful for correlating server logs with client-side responses.

**Purpose**:
- Track individual responses in logs
- Debug issues across client-server boundary
- Server-assigned (vs `context` which is client-assigned)

**Example**:
```json
{
  "id": "response-12345",
  "apiVersion": "2.1",
  "data": {}
}
```

### method

**Type**: `string`  
**Parent**: Root level  
**Required**: No

Represents the operation to perform (in requests) or that was performed (in responses).

**Purpose**:
- Indicate RPC operation in JSON-RPC style APIs
- Document what operation was executed

**Example**:
```json
{
  "method": "people.get",
  "params": {
    "userId": "@me",
    "groupId": "@self"
  }
}
```

### params

**Type**: `object`  
**Parent**: Root level  
**Required**: No

Map of input parameters for RPC requests. Used with the `method` property.

**Purpose**:
- Pass parameters to RPC functions
- Can be omitted if method needs no parameters

**Example**:
```json
{
  "method": "calendar.events.create",
  "params": {
    "calendarId": "primary",
    "event": {
      "title": "Team Meeting",
      "start": "2024-02-20T10:00:00.000Z"
    }
  }
}
```

### data

**Type**: `object`  
**Parent**: Root level  
**Required**: No (but use for successful responses)

Container for all response data. Contains many reserved property names (see Data Object Properties section).

**Purpose**:
- Hold successful response data
- Mutually exclusive with `error` object
- If both `data` and `error` present, `error` takes precedence

**Example**:
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

### error

**Type**: `object`  
**Parent**: Root level  
**Required**: No (but use for error responses)

Indicates an error occurred with details about the error. Supports single or multiple errors.

**Purpose**:
- Communicate failures to clients
- Provide actionable error information
- Mutually exclusive with `data` object

**Example**:
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

## Data Object Properties

Properties that appear within the `data` object.

### data.kind

**Type**: `string`  
**Parent**: `data`  
**Required**: No  
**Ordering**: Should be first property

Indicates the type of object. Helps parsers determine how to process the object.

**Purpose**:
- Distinguish between different object types
- Guide parser to instantiate appropriate object
- Should be first property for parsing efficiency

**Example**:
```json
{
  "data": {
    "kind": "album",
    "title": "Vacation Photos"
  }
}
```

### data.fields

**Type**: `string`  
**Parent**: `data`  
**Required**: No (only for partial responses)

Comma-separated list of fields present in partial GET response or partial PATCH request.

**Purpose**:
- Document which fields are included in partial response
- Should only exist during partial GET/PATCH
- Should not be empty

**Example**:
```json
{
  "data": {
    "kind": "user",
    "fields": "id,name,email",
    "id": "12345",
    "name": "John Doe",
    "email": "john@example.com"
  }
}
```

### data.etag

**Type**: `string`  
**Parent**: `data`  
**Required**: No

Entity tag for resource versioning. Used for optimistic concurrency control.

**Purpose**:
- Track resource versions
- Enable conditional requests
- Prevent lost updates

**Example**:
```json
{
  "data": {
    "etag": "W/\"C0QBRXcycSp7ImA9WxRVFUk.\"",
    "id": "12345",
    "name": "John Doe"
  }
}
```

### data.id

**Type**: `string`  
**Parent**: `data`  
**Required**: No

Globally unique identifier for the resource.

**Purpose**:
- Uniquely identify the object
- Enable resource lookups
- Format is service-specific

**Example**:
```json
{
  "data": {
    "id": "abc123def456",
    "name": "My Resource"
  }
}
```

### data.lang

**Type**: `string` (BCP 47 format)  
**Parent**: `data` or any child element  
**Required**: No

Language code for the object's content. Mimics HTML's `lang` and XML's `xml:lang`.

**Purpose**:
- Indicate content language
- Support internationalization
- Format per BCP 47

**Example**:
```json
{
  "data": {
    "items": [
      {
        "lang": "en",
        "title": "Hello world!"
      },
      {
        "lang": "fr",
        "title": "Bonjour monde!"
      }
    ]
  }
}
```

### data.updated

**Type**: `string` (RFC 3339 format)  
**Parent**: `data`  
**Required**: No

Last update timestamp for the resource.

**Purpose**:
- Track when resource was modified
- Enable caching decisions
- Format per RFC 3339

**Example**:
```json
{
  "data": {
    "id": "12345",
    "updated": "2024-02-19T10:30:00.000Z",
    "title": "My Document"
  }
}
```

### data.deleted

**Type**: `boolean`  
**Parent**: `data` or any child element  
**Required**: No

Marker indicating the resource has been deleted. When present, value must be `true`.

**Purpose**:
- Mark deleted resources in listings
- Avoid using `false` value (causes confusion)
- Typically used in sync/feed scenarios

**Example**:
```json
{
  "data": {
    "items": [
      {
        "id": "123",
        "title": "Active Item"
      },
      {
        "id": "456",
        "title": "Deleted Item",
        "deleted": true
      }
    ]
  }
}
```

### data.items

**Type**: `array`  
**Parent**: `data`  
**Required**: No  
**Ordering**: Should be last property in `data`

Array of items in a collection (photos, videos, users, etc.).

**Purpose**:
- Standard location for collection items
- Enable generic pagination systems
- Should be last property for parsing efficiency

**Example**:
```json
{
  "data": {
    "kind": "photoList",
    "totalItems": 2,
    "items": [
      {"id": "1", "title": "Photo 1"},
      {"id": "2", "title": "Photo 2"}
    ]
  }
}
```

## Pagination Properties

Properties within `data` object for paging through collections. Based on OpenSearch specification concepts.

### data.currentItemCount

**Type**: `integer`  
**Parent**: `data`  
**Required**: No

Number of items in the current result set. Equals `items.length`.

**Purpose**:
- Convenience property for item count
- May differ from `itemsPerPage` on last page

**Example**:
```json
{
  "data": {
    "itemsPerPage": 10,
    "currentItemCount": 7,
    "items": []
  }
}
```

### data.itemsPerPage

**Type**: `integer`  
**Parent**: `data`  
**Required**: No

Maximum number of items per page. May not match actual items on last page.

**Purpose**:
- Document requested page size
- Help calculate total pages

**Example**:
```json
{
  "data": {
    "itemsPerPage": 10,
    "currentItemCount": 10,
    "items": []
  }
}
```

### data.startIndex

**Type**: `integer`  
**Parent**: `data`  
**Required**: No

Index of first item in `data.items`. 1-based indexing.

**Purpose**:
- Indicate position in total result set
- Enable index-based pagination
- First item has `startIndex` of 1

**Example**:
```json
{
  "data": {
    "startIndex": 11,
    "itemsPerPage": 10,
    "items": []
  }
}
```

### data.totalItems

**Type**: `integer`  
**Parent**: `data`  
**Required**: No

Total number of items available across all pages.

**Purpose**:
- Show complete result set size
- Enable UI to show "X of Y results"
- Help calculate total pages

**Example**:
```json
{
  "data": {
    "totalItems": 100,
    "currentItemCount": 10,
    "items": []
  }
}
```

### data.pageIndex

**Type**: `integer`  
**Parent**: `data`  
**Required**: No

Current page number. 1-based indexing.

**Purpose**:
- Enable page-based pagination
- Can be calculated: `floor(startIndex / itemsPerPage) + 1`

**Example**:
```json
{
  "data": {
    "pageIndex": 2,
    "totalPages": 10,
    "items": []
  }
}
```

### data.totalPages

**Type**: `integer`  
**Parent**: `data`  
**Required**: No

Total number of pages in result set.

**Purpose**:
- Enable page-based navigation
- Can be calculated: `ceiling(totalItems / itemsPerPage)`

**Example**:
```json
{
  "data": {
    "pageIndex": 1,
    "totalPages": 10,
    "items": []
  }
}
```

### data.pagingLinkTemplate

**Type**: `string` (URI template)  
**Parent**: `data`  
**Required**: No

URI template for constructing pagination links. Variables: `{index}` for item number, `{pageIndex}` for page number.

**Purpose**:
- Enable clients to build pagination URLs
- Avoid hardcoding URL structure in clients

**Example**:
```json
{
  "data": {
    "pagingLinkTemplate": "https://api.example.com/items?start={index}&count=10",
    "items": []
  }
}
```

## Link Properties

Properties within `data` object representing links to related resources. Come in two forms: objects and URI strings (suffixed with "Link").

### data.self / data.selfLink

**Type**: `object` / `string`  
**Parent**: `data`  
**Required**: No

Link to retrieve the current resource.

**Purpose**:
- Provide canonical URL for resource
- Enable resource reloading
- Support HATEOAS principles

**Example**:
```json
{
  "data": {
    "self": {},
    "selfLink": "https://api.example.com/albums/1234",
    "title": "My Album"
  }
}
```

### data.edit / data.editLink

**Type**: `object` / `string`  
**Parent**: `data`  
**Required**: No

Link to update or delete the resource. Only present if user has permission.

**Purpose**:
- Indicate update/delete endpoint
- Support REST-based APIs
- Only include if user can modify resource

**Example**:
```json
{
  "data": {
    "edit": {},
    "editLink": "https://api.example.com/albums/1234/edit",
    "title": "My Album"
  }
}
```

### data.next / data.nextLink

**Type**: `object` / `string`  
**Parent**: `data`  
**Required**: No

Link to the next page of results.

**Purpose**:
- Enable forward pagination
- Works with pagination properties
- Only present if more items available

**Example**:
```json
{
  "data": {
    "next": {},
    "nextLink": "https://api.example.com/items?start=20&count=10",
    "items": []
  }
}
```

### data.previous / data.previousLink

**Type**: `object` / `string`  
**Parent**: `data`  
**Required**: No

Link to the previous page of results.

**Purpose**:
- Enable backward pagination
- Works with pagination properties
- Only present if previous page exists

**Example**:
```json
{
  "data": {
    "previous": {},
    "previousLink": "https://api.example.com/items?start=0&count=10",
    "items": []
  }
}
```

## Error Object Properties

Properties within the `error` object for communicating failures.

### error.code

**Type**: `integer`  
**Parent**: `error`  
**Required**: Recommended

HTTP status code or error code. If multiple errors, represents first error's code.

**Purpose**:
- Indicate error category (404, 500, etc.)
- Match HTTP response code
- Enable programmatic error handling

**Example**:
```json
{
  "error": {
    "code": 404,
    "message": "File Not Found"
  }
}
```

### error.message

**Type**: `string`  
**Parent**: `error`  
**Required**: Recommended

Human-readable error message. If multiple errors, represents first error's message.

**Purpose**:
- Provide user-friendly error description
- Enable error display in UI
- Summarize what went wrong

**Example**:
```json
{
  "error": {
    "code": 400,
    "message": "Invalid request parameters"
  }
}
```

### error.errors

**Type**: `array`  
**Parent**: `error`  
**Required**: No

Array of detailed error objects. Each element represents a different error.

**Purpose**:
- Support multiple simultaneous errors
- Provide detailed error information
- Enable field-level validation errors

**Example**:
```json
{
  "error": {
    "code": 400,
    "message": "Validation failed",
    "errors": [
      {
        "domain": "global",
        "reason": "invalidParameter",
        "message": "Invalid email format",
        "location": "email",
        "locationType": "parameter"
      }
    ]
  }
}
```

### error.errors[].domain

**Type**: `string`  
**Parent**: `error.errors`  
**Required**: No

Service or domain that raised the error.

**Purpose**:
- Distinguish service-specific errors from protocol errors
- Enable targeted error handling
- Helpful in microservices

**Example**:
```json
{
  "error": {
    "errors": [{
      "domain": "Calendar",
      "message": "Event conflict detected"
    }]
  }
}
```

### error.errors[].reason

**Type**: `string`  
**Parent**: `error.errors`  
**Required**: No

Unique identifier for the error type. Different from HTTP status code.

**Purpose**:
- Programmatic error identification
- Enable specific error handling
- Machine-readable error type

**Example**:
```json
{
  "error": {
    "errors": [{
      "reason": "ResourceNotFoundException",
      "message": "User not found"
    }]
  }
}
```

### error.errors[].message

**Type**: `string`  
**Parent**: `error.errors`  
**Required**: No

Detailed error message. Should match `error.message` if only one error.

**Purpose**:
- Provide error-specific details
- Enable field-level error messages
- User-friendly description

**Example**:
```json
{
  "error": {
    "errors": [{
      "message": "Email address is required"
    }]
  }
}
```

### error.errors[].location

**Type**: `string`  
**Parent**: `error.errors`  
**Required**: No

Where the error occurred. Interpretation depends on `locationType`.

**Purpose**:
- Pinpoint error location
- Enable field highlighting in forms
- Works with `locationType`

**Example**:
```json
{
  "error": {
    "errors": [{
      "location": "email",
      "locationType": "parameter",
      "message": "Invalid email format"
    }]
  }
}
```

### error.errors[].locationType

**Type**: `string`  
**Parent**: `error.errors`  
**Required**: No

How to interpret the `location` property (e.g., "parameter", "header", "body").

**Purpose**:
- Clarify location context
- Enable precise error localization
- Works with `location`

**Example**:
```json
{
  "error": {
    "errors": [{
      "location": "Authorization",
      "locationType": "header",
      "message": "Missing authorization header"
    }]
  }
}
```

### error.errors[].extendedHelp

**Type**: `string` (URI)  
**Parent**: `error.errors`  
**Required**: No

URI to help documentation for this error.

**Purpose**:
- Link to detailed error information
- Help users resolve the issue
- Reduce support burden

**Example**:
```json
{
  "error": {
    "errors": [{
      "reason": "quotaExceeded",
      "message": "API quota exceeded",
      "extendedHelp": "https://docs.example.com/errors/quota-exceeded"
    }]
  }
}
```

### error.errors[].sendReport

**Type**: `string` (URI)  
**Parent**: `error.errors`  
**Required**: No

URI to error report form, preloaded with request details.

**Purpose**:
- Enable error reporting
- Collect data about error conditions
- Improve service quality

**Example**:
```json
{
  "error": {
    "errors": [{
      "message": "Internal server error",
      "sendReport": "https://report.example.com/submit?error=500&request=abc123"
    }]
  }
}
```

## Reserved Property Summary

### Quick Reference Table

| Property | Parent | Type | Purpose |
|----------|--------|------|---------|
| `apiVersion` | root | string | API version |
| `context` | root | string | Client-set correlation value |
| `id` | root | string | Response identifier |
| `method` | root | string | RPC operation |
| `params` | root | object | RPC parameters |
| `data` | root | object | Success response container |
| `error` | root | object | Error response container |
| `kind` | data | string | Object type identifier |
| `fields` | data | string | Partial response fields |
| `etag` | data | string | Resource version tag |
| `id` | data | string | Resource identifier |
| `lang` | data | string | Language code |
| `updated` | data | string | Last update timestamp |
| `deleted` | data | boolean | Deletion marker |
| `items` | data | array | Collection items |
| `currentItemCount` | data | integer | Current page item count |
| `itemsPerPage` | data | integer | Page size |
| `startIndex` | data | integer | First item index |
| `totalItems` | data | integer | Total available items |
| `pageIndex` | data | integer | Current page number |
| `totalPages` | data | integer | Total page count |
| `pagingLinkTemplate` | data | string | Pagination URI template |
| `self` / `selfLink` | data | object/string | Self link |
| `edit` / `editLink` | data | object/string | Edit link |
| `next` / `nextLink` | data | object/string | Next page link |
| `previous` / `previousLink` | data | object/string | Previous page link |
| `code` | error | integer | Error code |
| `message` | error | string | Error message |
| `errors` | error | array | Detailed errors |
| `domain` | error.errors | string | Error domain |
| `reason` | error.errors | string | Error reason code |
| `message` | error.errors | string | Detailed error message |
| `location` | error.errors | string | Error location |
| `locationType` | error.errors | string | Location interpretation |
| `extendedHelp` | error.errors | string | Help documentation URI |
| `sendReport` | error.errors | string | Error report URI |
