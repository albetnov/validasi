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
