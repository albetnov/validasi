# Quick Start

Validasi keeps validation simple: define a schema, validate data, and inspect the result.

## 1. Validate a String

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

## 2. Validate a Map

```dart
final userSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'name': FieldRules<String>([
      StringRules.minLength(2),
    ]),
    'email': FieldRules<String>([
      StringRules.email(),
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
  Nullable(),
  StringRules.email(),
]);

print(optionalEmail.validate(null).isValid);
print(optionalEmail.validate('test@example.com').isValid);
```
