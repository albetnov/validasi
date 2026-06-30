# Standalone (Dart-only)

You don't need Flutter to use code generation. This page shows how to set up and use
`validasi_gen` in a pure Dart project — CLI tools, servers, or backend applications.

## Project setup

```bash
dart pub add validasi validasi_annotation
dart pub add dev:build_runner dev:validasi_gen
```

No `flutter` dependency — just Dart.

## Model definition

```dart
// lib/models/user.dart
import 'package:validasi/validasi.dart';
import 'package:validasi_annotation/validasi_annotation.dart';

part 'user.g.dart';

@ValidateClass()
class User {
  @Validate<String>([Required(), MinLength(2), MaxLength(50)])
  final String username;

  @Validate<String>([MinLength(6)])
  final String password;

  @Validate<int>([MinLength(18)])
  final int age;

  const User({required this.username, required this.password, required this.age});
}
```

Run the generator:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Validating objects

```dart
import 'models/user.dart';

void handleRequest() {
  final user = User(username: 'alice', password: 'secret', age: 25);

  final result = user.validate();

  if (!result.isValid) {
    for (final error in result.errors) {
      // error.rule   = 'MinLength'
      // error.message = 'Password must be at least 6 characters'
      // error.path    = ['password']
    }
    throw ValidationException(result.errors);
  }

  // Use result.data (the validated User instance)
  final valid = result.requireValue();
  saveUser(valid);
}
```

## Validating single fields

When you only need to check one field at a time:

```dart
// Check just the username
final usernameResult = user.validateField(UserFields.username);
if (!usernameResult.isValid) {
  print(usernameResult.errors.first.message);
}

// Check just the age
final ageResult = user.validateField(UserFields.age);
```

## Async validation (Dart-only)

```dart
import 'package:validasi_annotation/validasi_annotation.dart';

Future<bool> _usernameAvailable(String? username) async {
  if (username == null) return false;
  final taken = await database.lookup(username);
  return !taken;
}

@ValidateClass()
class User {
  @Validate<String>([Required(), MinLength(3), AsyncInline(_usernameAvailable)])
  final String username;

  const User({required this.username});
}
```

```dart
final result = await user.validateAsync();
```

## Continuous generation

During development, use `build_runner watch` to regenerate on every file change:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Integration with Dart backends

| Framework | Pattern |
|-----------|---------|
| **Shelf** | Validate in middleware or handler body; return errors as JSON |
| **Serverpod** | Annotate model classes; call `validate()` before `insertRow()` |
| **Dart Frog** | Validate in route handler; return `response.json(errors)` on failure |
| **Custom** | Validate at API boundary; map `ValidationError` → your error schema |

No special framework setup needed — just call `validate()` and handle the result.
