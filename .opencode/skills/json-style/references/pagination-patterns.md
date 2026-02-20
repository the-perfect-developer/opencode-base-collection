# Pagination Patterns

Detailed guide to implementing pagination in JSON APIs using Google's JSON Style Guide conventions.

## Table of Contents

- [Overview](#overview)
- [Pagination Styles](#pagination-styles)
- [Index-Based Pagination](#index-based-pagination)
- [Page-Based Pagination](#page-based-pagination)
- [Link-Based Pagination](#link-based-pagination)
- [Complete Example](#complete-example)

## Overview

Pagination allows clients to retrieve large result sets in manageable chunks. The Google JSON Style Guide supports multiple pagination approaches using standardized property names.

### Core Pagination Properties

All pagination styles use these properties in the `data` object:

- `currentItemCount` - Items in current response
- `itemsPerPage` - Maximum items per page
- `startIndex` - Index of first item (1-based)
- `totalItems` - Total items across all pages
- `items` - Array of items in current page

### Optional Pagination Properties

Additional properties for enhanced pagination:

- `pageIndex` - Current page number (1-based)
- `totalPages` - Total number of pages
- `pagingLinkTemplate` - URI template for building links
- `nextLink` - Link to next page
- `previousLink` - Link to previous page

## Pagination Styles

### 1. Previous/Next Pagination

Navigate forward and backward one page at a time.

**When to use**:
- Simple navigation requirements
- Infinite scroll interfaces
- Feed-style applications

**Properties needed**:
- `nextLink` - Link to next page
- `previousLink` - Link to previous page
- `currentItemCount`
- `itemsPerPage`

**Example**:
```json
{
  "apiVersion": "2.1",
  "data": {
    "currentItemCount": 10,
    "itemsPerPage": 10,
    "nextLink": "https://api.example.com/items?page=2",
    "previousLink": "https://api.example.com/items?page=0",
    "items": [...]
  }
}
```

### 2. Index-Based Pagination

Jump to specific item positions in the result set.

**When to use**:
- Direct position access needed
- "Show items 100-110" scenarios
- Fine-grained control required

**Properties needed**:
- `startIndex` - First item index (1-based)
- `itemsPerPage` - Page size
- `totalItems` - Total available items
- `currentItemCount` - Items in response

**Example**:
```json
{
  "apiVersion": "2.1",
  "data": {
    "startIndex": 51,
    "itemsPerPage": 10,
    "currentItemCount": 10,
    "totalItems": 500,
    "items": [...]
  }
}
```

**Client calculation**:
```javascript
// To get page starting at item 200 with 10 items per page
const startIndex = 200;
const url = `https://api.example.com/items?startIndex=${startIndex}&count=10`;
```

### 3. Page-Based Pagination

Jump directly to specific page numbers.

**When to use**:
- Traditional page navigation UI
- "Page 5 of 20" displays
- User-friendly navigation

**Properties needed**:
- `pageIndex` - Current page (1-based)
- `totalPages` - Total pages
- `itemsPerPage` - Items per page
- `currentItemCount` - Items in response

**Example**:
```json
{
  "apiVersion": "2.1",
  "data": {
    "pageIndex": 3,
    "totalPages": 50,
    "itemsPerPage": 10,
    "currentItemCount": 10,
    "items": [...]
  }
}
```

**Client calculation**:
```javascript
// To get page 5 with 10 items per page
const page = 5;
const url = `https://api.example.com/items?page=${page}&count=10`;
```

**Relationship to index-based**:
```javascript
// Convert page to startIndex
const startIndex = (pageIndex - 1) * itemsPerPage + 1;

// Convert startIndex to pageIndex
const pageIndex = Math.floor((startIndex - 1) / itemsPerPage) + 1;

// Calculate totalPages
const totalPages = Math.ceil(totalItems / itemsPerPage);
```

## Index-Based Pagination

### Complete Implementation

**Request**:
```
GET /api/search?q=pizza&startIndex=11&count=10
```

**Response**:
```json
{
  "apiVersion": "2.1",
  "data": {
    "query": "pizza",
    "startIndex": 11,
    "itemsPerPage": 10,
    "currentItemCount": 10,
    "totalItems": 500,
    "items": [
      {"id": "11", "title": "Result 11"},
      {"id": "12", "title": "Result 12"},
      {"id": "20", "title": "Result 20"}
    ]
  }
}
```

### Navigation Logic

**First page**:
```
startIndex = 1
```

**Next page**:
```javascript
const nextStartIndex = currentStartIndex + itemsPerPage;
// If startIndex=11, itemsPerPage=10, next is 21
```

**Previous page**:
```javascript
const prevStartIndex = Math.max(1, currentStartIndex - itemsPerPage);
// If startIndex=11, itemsPerPage=10, prev is 1
```

**Last page**:
```javascript
const lastPageStartIndex = Math.floor((totalItems - 1) / itemsPerPage) * itemsPerPage + 1;
// If totalItems=500, itemsPerPage=10, last page starts at 491
```

**Has next page**:
```javascript
const hasNext = startIndex + currentItemCount <= totalItems;
```

**Has previous page**:
```javascript
const hasPrevious = startIndex > 1;
```

## Page-Based Pagination

### Complete Implementation

**Request**:
```
GET /api/search?q=pizza&page=3&count=10
```

**Response**:
```json
{
  "apiVersion": "2.1",
  "data": {
    "query": "pizza",
    "pageIndex": 3,
    "totalPages": 50,
    "itemsPerPage": 10,
    "currentItemCount": 10,
    "totalItems": 500,
    "items": [
      {"id": "21", "title": "Result 21"},
      {"id": "22", "title": "Result 22"},
      {"id": "30", "title": "Result 30"}
    ]
  }
}
```

### Navigation Logic

**First page**:
```
pageIndex = 1
```

**Next page**:
```javascript
const nextPage = currentPage + 1;
// If pageIndex=3, next is 4
```

**Previous page**:
```javascript
const prevPage = Math.max(1, currentPage - 1);
// If pageIndex=3, prev is 2
```

**Last page**:
```
pageIndex = totalPages
```

**Has next page**:
```javascript
const hasNext = pageIndex < totalPages;
```

**Has previous page**:
```javascript
const hasPrevious = pageIndex > 1;
```

## Link-Based Pagination

### Using nextLink and previousLink

Provide explicit URLs for next/previous pages.

**Response**:
```json
{
  "apiVersion": "2.1",
  "data": {
    "currentItemCount": 10,
    "itemsPerPage": 10,
    "startIndex": 11,
    "totalItems": 500,
    "nextLink": "https://api.example.com/search?q=pizza&startIndex=21&count=10",
    "previousLink": "https://api.example.com/search?q=pizza&startIndex=1&count=10",
    "items": [...]
  }
}
```

**Client usage**:
```javascript
// Simply follow the links
if (response.data.nextLink) {
  fetch(response.data.nextLink);
}
```

### Using pagingLinkTemplate

Provide URI template for clients to construct pagination links.

**Response**:
```json
{
  "apiVersion": "2.1",
  "data": {
    "pagingLinkTemplate": "https://api.example.com/search?q=pizza&startIndex={index}&count=10",
    "startIndex": 11,
    "itemsPerPage": 10,
    "totalItems": 500,
    "items": [...]
  }
}
```

**Client usage**:
```javascript
// Calculate desired index
const desiredIndex = 51; // Page 6: (6-1) * 10 + 1

// Substitute into template
const url = response.data.pagingLinkTemplate.replace('{index}', desiredIndex);
// Result: https://api.example.com/search?q=pizza&startIndex=51&count=10
```

**Template with pageIndex variable**:
```json
{
  "data": {
    "pagingLinkTemplate": "https://api.example.com/search?q=pizza&page={pageIndex}&count=10"
  }
}
```

## Complete Example

Real-world search results with full pagination support.

### Search Request

```
GET /api/search?q=chicago+style+pizza&startIndex=11&count=10
```

### Search Response

```json
{
  "apiVersion": "2.1",
  "id": "search-response-12345",
  "data": {
    "kind": "searchResults",
    "query": "chicago style pizza",
    "searchTime": "0.15",
    
    "currentItemCount": 10,
    "itemsPerPage": 10,
    "startIndex": 11,
    "totalItems": 2700000,
    
    "pageIndex": 2,
    "totalPages": 270000,
    
    "nextLink": "https://api.example.com/search?q=chicago+style+pizza&startIndex=21&count=10",
    "previousLink": "https://api.example.com/search?q=chicago+style+pizza&startIndex=1&count=10",
    "pagingLinkTemplate": "https://api.example.com/search?q=chicago+style+pizza&startIndex={index}&count=10",
    
    "items": [
      {
        "kind": "searchResult",
        "title": "Chicago Style Pizza Recipe",
        "url": "https://example.com/recipe",
        "snippet": "The best Chicago style pizza recipe..."
      },
      {
        "kind": "searchResult",
        "title": "History of Chicago Pizza",
        "url": "https://example.com/history",
        "snippet": "Learn about the origins..."
      }
    ]
  }
}
```

### UI Representation

This data represents: **"Results 11-20 of about 2,700,000"**

- **"Results"** - Generic label
- **"11"** - `startIndex` (11)
- **"20"** - `startIndex + currentItemCount - 1` (11 + 10 - 1 = 20)
- **"2,700,000"** - `totalItems` (2700000)

### Client-Side Navigation

**Previous/Next buttons**:
```javascript
// Check if buttons should be enabled
const showPrevious = response.data.previousLink !== undefined;
const showNext = response.data.nextLink !== undefined;

// Navigate on click
previousButton.onclick = () => fetch(response.data.previousLink);
nextButton.onclick = () => fetch(response.data.nextLink);
```

**Page number links (e.g., Google's "Gooooogle")**:
```javascript
const template = response.data.pagingLinkTemplate;
const itemsPerPage = response.data.itemsPerPage;

// Generate links for pages 1-10
for (let page = 1; page <= 10; page++) {
  const index = (page - 1) * itemsPerPage + 1;
  const url = template.replace('{index}', index);
  
  // Page 1: index = 1
  // Page 2: index = 11
  // Page 3: index = 21
  // ...
}
```

**Jump to page**:
```javascript
function jumpToPage(pageNumber) {
  const startIndex = (pageNumber - 1) * itemsPerPage + 1;
  const url = `https://api.example.com/search?q=pizza&startIndex=${startIndex}&count=10`;
  fetch(url);
}
```

## Edge Cases

### Last Page (Partial Results)

When on the last page, `currentItemCount` may be less than `itemsPerPage`:

**Request**:
```
GET /api/items?startIndex=491&count=10
```

**Response**:
```json
{
  "data": {
    "startIndex": 491,
    "itemsPerPage": 10,
    "currentItemCount": 7,
    "totalItems": 497,
    "items": [
      {"id": "491"},
      {"id": "497"}
    ]
  }
}
```

**No next link**:
```json
{
  "data": {
    "previousLink": "https://api.example.com/items?startIndex=481&count=10"
  }
}
```

### Empty Results

**Request**:
```
GET /api/search?q=nonexistent
```

**Response**:
```json
{
  "data": {
    "query": "nonexistent",
    "startIndex": 1,
    "itemsPerPage": 10,
    "currentItemCount": 0,
    "totalItems": 0,
    "items": []
  }
}
```

### Single Page

When all results fit on one page:

**Response**:
```json
{
  "data": {
    "startIndex": 1,
    "itemsPerPage": 10,
    "currentItemCount": 5,
    "totalItems": 5,
    "items": [
      {"id": "1"},
      {"id": "5"}
    ]
  }
}
```

**No pagination links** (no next/previous).

## Best Practices

### DO

- Use 1-based indexing for `startIndex` and `pageIndex`
- Always include `currentItemCount` and `itemsPerPage`
- Provide `totalItems` when available
- Include `nextLink` and `previousLink` for easy navigation
- Use consistent page sizes throughout pagination
- Handle last page gracefully (partial results)
- Validate that `startIndex` and `pageIndex` are positive
- Return empty `items` array (not null) when no results

### DON'T

- Use 0-based indexing for `startIndex` or `pageIndex`
- Include `nextLink` on last page
- Include `previousLink` on first page
- Return `currentItemCount` > `itemsPerPage`
- Change `itemsPerPage` between requests without client request
- Return null instead of empty array for `items`
- Provide `totalPages` without `pageIndex`

### Performance Considerations

**For large datasets**:
```json
{
  "data": {
    "currentItemCount": 10,
    "itemsPerPage": 10,
    "nextLink": "https://api.example.com/items?cursor=abc123",
    "items": [...]
  }
}
```

Omit `totalItems` and `totalPages` if:
- Computing total is expensive
- Using cursor-based pagination
- Total is approximate or unstable

**Cursor-based pagination** (not in standard spec):
```json
{
  "data": {
    "currentItemCount": 10,
    "nextCursor": "eyJpZCI6MTAwfQ==",
    "previousCursor": "eyJpZCI6OTB9",
    "items": [...]
  }
}
```

Use cursors for:
- Real-time data with frequent updates
- Preventing result set changes mid-pagination
- Large datasets where offset is expensive

## Summary

Choose pagination style based on your use case:

| Style | Best For | Properties |
|-------|----------|------------|
| Previous/Next | Simple navigation, feeds | `nextLink`, `previousLink` |
| Index-Based | Direct position access | `startIndex`, `itemsPerPage`, `totalItems` |
| Page-Based | Traditional page UI | `pageIndex`, `totalPages` |
| Template-Based | Client-built URLs | `pagingLinkTemplate` |

Combine multiple approaches for maximum flexibility:

```json
{
  "data": {
    "startIndex": 11,
    "itemsPerPage": 10,
    "currentItemCount": 10,
    "totalItems": 500,
    "pageIndex": 2,
    "totalPages": 50,
    "nextLink": "...",
    "previousLink": "...",
    "pagingLinkTemplate": "...",
    "items": [...]
  }
}
```
