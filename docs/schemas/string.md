# String Schema

Use `Validasi.string()` to validate string values.

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

final schema = Validasi.string([
	Rules.string.minLength(3),
]);
```

## Available Rules

### Rules.string.minLength

Ensures the string has at least the given number of characters.

```dart
final usernameSchema = Validasi.string([
	Rules.string.minLength(3),
]);

print(usernameSchema.validate('al').isValid); // false
print(usernameSchema.validate('alex').isValid); // true
```

### Rules.string.maxLength

Ensures the string does not exceed the given number of characters.

```dart
final titleSchema = Validasi.string([
	Rules.string.maxLength(10),
]);

print(titleSchema.validate('short').isValid); // true
print(titleSchema.validate('this title is too long').isValid); // false
```

### Rules.string.oneOf

Ensures the string matches one of the allowed values.

```dart
final statusSchema = Validasi.string([
	Rules.string.oneOf(['draft', 'published', 'archived']),
]);

print(statusSchema.validate('published').isValid); // true
print(statusSchema.validate('deleted').isValid); // false
```

## Combining String Rules

You can combine multiple rules in one schema.

```dart
final displayNameSchema = Validasi.string([
	Rules.string.minLength(2),
	Rules.string.maxLength(30),
	Rules.string.oneOf(['alice', 'bob', 'charlie']),
]);

final result = displayNameSchema.validate('bob');
print(result.isValid); // true
```
