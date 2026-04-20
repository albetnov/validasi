# Validation Schemas

Schemas define what kind of data you expect and which rules should run on it. The main idea is simple: pick a schema type, attach rules, and validate the value.

## Schema Types

### String Schema

Use `Validasi.string()` for text values.

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

final nameSchema = Validasi.string([
  StringRules.minLength(2),
  StringRules.maxLength(50),
]);

final result = nameSchema.validate('John Doe');
print(result.isValid);
```

### Number Schema

Use `Validasi.number<T>()` for numeric values.

```dart
final ageSchema = Validasi.number<int>([
  NumberRules.moreThanEqual(0),
  NumberRules.lessThan(150),
]);

print(ageSchema.validate(25).isValid);
```

### List Schema

Use `Validasi.list<T>()` for lists and other iterables.

```dart
final tagsSchema = Validasi.list<String>([
  IterableRules.minLength(1),
  IterableRules.forEach(
    Validasi.string([
      StringRules.minLength(2),
      StringRules.maxLength(20),
    ]),
  ),
]);

print(tagsSchema.validate(['flutter', 'dart']).isValid);
```

### Map Schema

Use `Validasi.map<T>()` for objects and structured data.

```dart
final userSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'name': Validasi.string([
      StringRules.minLength(1),
    ]),
    'age': Validasi.number<int>([
      NumberRules.moreThanEqual(18),
    ]),
  }),
]);

print(userSchema.validate({
  'name': 'Alice',
  'age': 25,
}).isValid);
```

### Any Schema

Use `Validasi.any<T>()` when you want to validate a value with custom rules.

```dart
final termsSchema = Validasi.any<bool>([
  InlineRule<bool>((value) {
    return value == true ? null : 'You must accept the terms';
  }),
]);

print(termsSchema.validate(true).isValid);
```

## Schema Composition

Schemas are easy to extend because the API lets you reuse existing schemas as building blocks. Define small schemas once, then combine them into larger ones with `MapRules`, `IterableRules`, or additional inline rules.

```dart
final emailSchema = Validasi.string([
  Transform((value) => value?.trim().toLowerCase()),
  StringRules.minLength(5),
  InlineRule<String>((value) {
    return value.contains('@') ? null : 'Invalid email format';
  }),
]);

final passwordSchema = Validasi.string([
  StringRules.minLength(8),
]);

final registrationSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'email': emailSchema,
    'password': passwordSchema,
    'confirmPassword': passwordSchema,
  }),
  InlineRule<Map<String, dynamic>>((value) {
    return value['password'] == value['confirmPassword']
        ? null
        : 'Passwords do not match';
  }),
]);
```

This pattern keeps schemas small and reusable while still letting you build stricter validation at the top level.

## Validation Results

`validate()` returns a `ValidasiResult` with the final data and any errors.

```dart
final result = userSchema.validate(data);

if (result.isValid) {
  print(result.data);
} else {
  for (final error in result.errors) {
    print('${error.path?.join('.')}: ${error.message}');
  }
}
```

- `isValid` tells you whether validation passed.
- `data` contains the validated value, including any transformations.
- `errors` contains the validation failures.
- `error.message` is the human-readable message.
- `error.path` points to the field that failed in nested structures.

## Best Practices

- Keep schemas small and reusable.
- Use explicit type parameters for better type safety.
- Put transforms before validation rules when both are needed.
- Prefer clear, user-friendly error messages.