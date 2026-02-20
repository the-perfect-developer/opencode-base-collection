# JSON Naming Conventions

Comprehensive naming rules and conventions for JSON property names based on Google's JSON Style Guide.

## Table of Contents

- [Property Name Rules](#property-name-rules)
- [CamelCase Convention](#camelcase-convention)
- [Singular vs Plural](#singular-vs-plural)
- [Reserved JavaScript Keywords](#reserved-javascript-keywords)
- [JSON Maps vs Objects](#json-maps-vs-objects)
- [Naming Conflicts](#naming-conflicts)

## Property Name Rules

Property names must conform to the following requirements:

### Character Requirements

1. **First character** must be:
   - A letter (a-z, A-Z)
   - An underscore (_)
   - A dollar sign ($)

2. **Subsequent characters** can be:
   - A letter (a-z, A-Z)
   - A digit (0-9)
   - An underscore (_)
   - A dollar sign ($)

### Semantic Requirements

1. **Meaningful names** - Choose names with clear, defined semantics
2. **CamelCase format** - Use camelCase, not snake_case or PascalCase
3. **Avoid reserved words** - Don't use JavaScript reserved keywords

### Why These Rules?

These guidelines mirror JavaScript identifier naming rules, allowing JavaScript clients to access properties using dot notation:

```javascript
// Works with proper naming
result.thisIsAnIdentifier

// Requires bracket notation with invalid identifiers
result["this-is-not-an-identifier"]
result["123startsWithNumber"]
```

## CamelCase Convention

### Correct CamelCase

Use camelCase where the first letter is lowercase and subsequent words start with uppercase:

```json
{
  "firstName": "John",
  "lastName": "Doe",
  "emailAddress": "john@example.com",
  "phoneNumber": "+1-555-0123",
  "dateOfBirth": "1990-01-15",
  "isActive": true,
  "accountBalance": 1000.50
}
```

### Incorrect Formats

**snake_case** (Python style) - Don't use:
```json
{
  "first_name": "John",
  "last_name": "Doe"
}
```

**PascalCase** (C# style) - Don't use:
```json
{
  "FirstName": "John",
  "LastName": "Doe"
}
```

**kebab-case** - Don't use:
```json
{
  "first-name": "John",
  "last-name": "Doe"
}
```

### Acronyms and Abbreviations

When using acronyms in camelCase:

**Recommended** - Treat acronym as a word:
```json
{
  "userId": "12345",
  "apiKey": "abc123",
  "htmlContent": "<p>Hello</p>",
  "httpStatus": 200,
  "urlPath": "/api/users"
}
```

**Acceptable but less preferred** - All caps for short acronyms:
```json
{
  "userID": "12345",
  "apiURL": "https://api.example.com"
}
```

Be consistent within your API - choose one approach and stick with it.

## Singular vs Plural

### Arrays Use Plural

Arrays should have plural property names since they contain multiple items:

```json
{
  "users": [
    {"name": "Alice"},
    {"name": "Bob"}
  ],
  "items": [
    {"id": 1},
    {"id": 2}
  ],
  "tags": ["javascript", "json", "api"]
}
```

### Other Properties Use Singular

All non-array properties should use singular names:

```json
{
  "user": {
    "name": "Alice",
    "role": "admin"
  },
  "count": 42,
  "title": "My Document",
  "author": "Jane Doe"
}
```

### Numeric Properties

For numeric properties representing totals or counts, use forms that sound natural:

**Good**:
```json
{
  "totalItems": 100,
  "itemCount": 100,
  "pageCount": 10,
  "userCount": 50
}
```

**Less natural** (but technically valid):
```json
{
  "totalItem": 100
}
```

Think of `totalItems` as `totalOfItems` where `total` is singular and `OfItems` qualifies it.

## Reserved JavaScript Keywords

Avoid using JavaScript reserved keywords as property names. While they work with bracket notation, they prevent using dot notation.

### Reserved Words to Avoid

From ECMAScript Language Specification 5th Edition:

```
abstract
boolean break byte
case catch char class const continue
debugger default delete do double
else enum export extends
false final finally float for function
goto
if implements import in instanceof int interface
let long
native new null
package private protected public
return
short static super switch synchronized
this throw throws transient true try typeof
var volatile void
while with
yield
```

### Working Around Reserved Words

If you need to represent a reserved concept, use an alternative:

**Instead of**:
```json
{
  "class": "premium",
  "new": true,
  "default": "value"
}
```

**Use**:
```json
{
  "className": "premium",
  "isNew": true,
  "defaultValue": "value"
}
```

## JSON Maps vs Objects

### Object Property Names (Strict Rules)

When a JSON object represents a structured data type, property names must follow all naming conventions:

```json
{
  "address": {
    "addressLine1": "123 Anystreet",
    "addressLine2": "Apt 4B",
    "city": "Anytown",
    "state": "XX",
    "zip": "00000"
  }
}
```

### Map Keys (Relaxed Rules)

When a JSON object is used as a map (associative array), keys can use any Unicode characters and don't need to follow property naming guidelines:

```json
{
  "translations": {
    "en-US": "Hello",
    "es-ES": "Hola",
    "fr-FR": "Bonjour",
    "日本語": "こんにちは"
  },
  "thumbnails": {
    "72": "https://url.to.72px.thumbnail",
    "144": "https://url.to.144px.thumbnail",
    "1080": "https://url.to.1080px.thumbnail"
  },
  "prices": {
    "USD": 10.00,
    "EUR": 8.50,
    "GBP": 7.25
  }
}
```

**Accessing map values**:
```javascript
// Must use bracket notation for non-identifier keys
result.thumbnails["72"]
result.translations["en-US"]
result.translations["日本語"]

// Can still use dot notation for the map property itself
result.thumbnails
result.translations
```

### Documenting Maps vs Objects

API documentation should clearly indicate when a JSON object is used as a map:

**Example documentation**:
> The `thumbnails` property is a map where keys are pixel sizes (as strings) and values are thumbnail URLs.

## Naming Conflicts

### With Future Reserved Names

New properties may be added to the reserved list in the future. If there's a naming conflict, resolve it by:

**Option 1: Choose a different name**
```json
{
  "apiVersion": "1.0",
  "data": {
    "recipeName": "pizza",
    "ingredientsData": "Some new property",
    "ingredients": ["tomatoes", "cheese", "sausage"]
  }
}
```

**Option 2: Rename on version boundary**
```json
{
  "apiVersion": "2.0",
  "data": {
    "recipeName": "pizza",
    "ingredients": "Some new property",
    "recipeIngredients": ["tomatoes", "cheese", "sausage"]
  }
}
```

### With JavaScript Reserved Words

If a property name conflicts with a JavaScript keyword, choose a more specific alternative:

```json
{
  "itemType": "book",
  "itemClass": "fiction",
  "packageContents": "...",
  "returnValue": 42
}
```

## Best Practices Summary

### DO

- Use camelCase for all property names
- Start property names with a letter
- Use meaningful, semantic names
- Use plural names for arrays
- Use singular names for non-arrays
- Be consistent with abbreviation capitalization
- Document when objects are used as maps

### DON'T

- Use snake_case, PascalCase, or kebab-case
- Use JavaScript reserved keywords
- Start property names with numbers
- Mix singular and plural arbitrarily
- Use cryptic abbreviations
- Use inconsistent capitalization for acronyms

## Examples

### Good Naming

```json
{
  "userId": "12345",
  "firstName": "Jane",
  "lastName": "Doe",
  "emailAddresses": [
    "jane@example.com",
    "jane.doe@work.com"
  ],
  "isVerified": true,
  "accountBalance": 1500.75,
  "createdAt": "2024-02-19T10:00:00.000Z",
  "preferences": {
    "theme": "dark",
    "language": "en-US",
    "notificationsEnabled": true
  },
  "tags": ["premium", "verified", "active"]
}
```

### Poor Naming

```json
{
  "user_id": "12345",
  "FirstName": "Jane",
  "last-name": "Doe",
  "email_address": [
    "jane@example.com"
  ],
  "verified": true,
  "balance": 1500.75,
  "created": "2024-02-19T10:00:00.000Z",
  "prefs": {
    "theme": "dark",
    "lang": "en-US",
    "notify": true
  },
  "tag": ["premium", "verified", "active"]
}
```

Issues in poor example:
- `user_id`: snake_case
- `FirstName`: PascalCase
- `last-name`: kebab-case
- `email_address`: snake_case and singular for array
- `verified`: less clear than `isVerified`
- `created`: abbreviation, less clear than `createdAt`
- `prefs`, `lang`, `notify`: unclear abbreviations
- `tag`: singular for array
