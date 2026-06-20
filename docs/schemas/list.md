# List Schema

Use `Validasi.list<T>()` to validate lists.

The schema is generic, so you choose the item type with `T`.

- `Validasi.list<String>(...)` for list of strings
- `Validasi.list<int>(...)` for list of integers
- `Validasi.list<MyType>(...)` for custom types

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

final tagsSchema = Validasi.list<String>([
 Rules.iterable.minLength(1),
]);
```

## Available Rules

### Rules.iterable.minLength

Ensures the list has at least the given number of items.

```dart
final atLeastTwoTags = Validasi.list<String>([
 Rules.iterable.minLength(2),
]);

print(atLeastTwoTags.validate(['dart']).isValid); // false
print(atLeastTwoTags.validate(['dart', 'flutter']).isValid); // true
```

### Rules.iterable.maxLength

Ensures the list has at most the given number of items.

```dart
final maxThreeItems = Validasi.list<String>([
 Rules.iterable.maxLength(3),
]);

print(maxThreeItems.validate(['a', 'b']).isValid); // true
print(maxThreeItems.validate(['a', 'b', 'c', 'd']).isValid); // false
```

### Rules.iterable.exactLength

Ensures the list has exactly the given number of items.

```dart
final pairSchema = Validasi.list<int>([
 Rules.iterable.exactLength(2),
]);

print(pairSchema.validate([1, 2]).isValid); // true
print(pairSchema.validate([1, 2, 3]).isValid); // false
```

### Rules.iterable.isEmpty

Ensures the list is empty.

```dart
final emptySchema = Validasi.list<String>([
 Rules.iterable.isEmpty(),
]);

print(emptySchema.validate([]).isValid); // true
print(emptySchema.validate(['a']).isValid); // false
```

### Rules.iterable.isNotEmpty

Ensures the list is not empty.

```dart
final nonEmptySchema = Validasi.list<String>([
 Rules.iterable.isNotEmpty(),
]);

print(nonEmptySchema.validate(['a']).isValid); // true
print(nonEmptySchema.validate([]).isValid); // false
```

### Rules.iterable.contains

Ensures the list contains a specific element.

```dart
final mustContainAdmin = Validasi.list<String>([
 Rules.iterable.contains('admin'),
]);

print(mustContainAdmin.validate(['user', 'admin']).isValid); // true
print(mustContainAdmin.validate(['user', 'guest']).isValid); // false
```

With a key selector for object properties:

```dart
final mustContainId = Validasi.list<Map<String, dynamic>>([
 Rules.iterable.contains(
  {'id': 1},
  keySelector: (m) => m['id'],
 ),
]);
```

The `keySelector` function extracts a comparable key from each element, enabling
O(k) lookups without needing a custom equality function.

### Rules.iterable.notContains

Ensures the list does not contain a specific element.

```dart
final noBanned = Validasi.list<String>([
 Rules.iterable.notContains('banned'),
]);

print(noBanned.validate(['user', 'admin']).isValid); // true
print(noBanned.validate(['user', 'banned']).isValid); // false
```

### Rules.iterable.unique

Ensures all elements in the list are unique.

```dart
final uniqueIds = Validasi.list<int>([
 Rules.iterable.unique(),
]);

print(uniqueIds.validate([1, 2, 3]).isValid); // true
print(uniqueIds.validate([1, 2, 2]).isValid); // false
```

With a key selector for object properties (O(N) Set-based):

```dart
final uniqueByField = Validasi.list<Map<String, dynamic>>([
 Rules.iterable.unique(keySelector: (m) => m['id']),
]);
```

For custom equality with optimal performance, provide both `equals` and `hasher`:

```dart
import 'dart:collection';

final uniqueByField = Validasi.list<Map<String, dynamic>>([
 Rules.iterable.unique(
  equals: (a, b) => a['id'] == b['id'],
  hasher: (m) => m['id']?.hashCode ?? 0,
 ),
]);
```

> **Note**: When providing `equals` without `hasher`, the rule falls back to an O(N²)
> comparison. Always provide `hasher` alongside `equals` for O(N) performance.

### Rules.iterable.containsAll

Ensures the list contains all specified elements.

```dart
final requiredRoles = Validasi.list<String>([
 Rules.iterable.containsAll(['read', 'write']),
]);

print(requiredRoles.validate(['read', 'write', 'admin']).isValid); // true
print(requiredRoles.validate(['read']).isValid); // false
```

### Rules.iterable.forEach

Validates each item using another schema.

```dart
 final emailListSchema = Validasi.list<String>([
 Rules.iterable.forEach<String>([
  Rules.string.minLength(5),
 ]),
]);

print(emailListSchema.validate(['a@b.c', 'test@example.com']).isValid); // true
print(emailListSchema.validate(['x', 'test@example.com']).isValid); // false
```

## Nested List Validation

`Rules.iterable.forEach` can validate nested structures by composing list schemas.

```dart
 final matrixSchema = Validasi.list<List<int>>([
 Rules.iterable.minLength(1),
 Rules.iterable.forEach<List<int>>([
  Rules.iterable.minLength(2),
  Rules.iterable.forEach<int>([
   Rules.number.moreThanEqual(0),
  ]),
 ]),
]);

print(matrixSchema.validate([
 [1, 2],
 [3, 4],
]).isValid); // true

print(matrixSchema.validate([
 [1],
 [3, -1],
]).isValid); // false
```

This approach makes list validation composable: each nesting level has its own list rules.

## Combining List Rules

Use both list-specific rules together for shape and item validation.

```dart
 final usernamesSchema = Validasi.list<String>([
 Rules.iterable.minLength(1),
 Rules.iterable.forEach<String>([
  Rules.string.minLength(3),
  Rules.string.maxLength(20),
 ]),
]);

final result = usernamesSchema.validate(['alice', 'bob']);
print(result.isValid); // true
```
