# Quick Start

Validasi keeps validation simple: define a schema, validate data, and inspect the result.

## 1. Validate a String

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

final nameSchema = Validasi.string([
  Rules.string.minLength(2),
  Rules.string.maxLength(50),
]);

final result = nameSchema.validate('John Doe');
print(result.isValid);
```

## 2. Validate a Map

```dart
final userSchema = Validasi.map<dynamic>([
  Rules.map.hasFields({
    'name': FieldRules<String>([
      Rules.string.minLength(2),
    ]),
    'email': FieldRules<String>([
      Rules.string.email(),
    ]),
  }),
]);

final result = userSchema.validate({
  'name': 'Alice',
  'email': 'alice@example.com',
});

print(result.isValid);
```

## 3. Handle Optional Values

```dart
final optionalEmail = Validasi.string([
  Rules.nullable<String>(),
  Rules.string.email(),
]);

print(optionalEmail.validate(null).isValid);
print(optionalEmail.validate('test@example.com').isValid);
```
