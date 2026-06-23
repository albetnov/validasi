# Code Generation (experimental)

> **Experimental** — API subject to change. Feedback and contributions are welcome!

The `validasi_gen` package, together with `validasi_annotation`, provides annotation-based code generation for Validasi. Decorate your model with `@ValidateClass()` and `@Validate(...)`, and the generator produces a typed `XFields<V>` hierarchy plus `validate()` / `validateAsync()` extension methods — all at build time via `build_runner`.

## Setup

Add the dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  validasi: ^1.0.0-rc.1
  validasi_annotation: ^0.1.0-dev.2

dev_dependencies:
  build_runner: ^2.4.0
  validasi_gen: ^0.1.0-dev.2
```

## Quick start

Define a model with validation annotations:

```dart
// user.dart
import 'package:validasi/validasi.dart';
import 'package:validasi_annotation/validasi_annotation.dart';

part 'user.g.dart';

@ValidateClass()
class User {
  @Validate.string([MinLength(3), MaxLength(100)])
  final String name;

  @Validate.string([MinLength(5)])
  final String email;

  @Validate([MinLength(1)])
  final int age;

  const User({required this.name, required this.email, required this.age});
}
```

Run the generator:

```bash
dart run build_runner build
```

This produces `user.g.dart` with:

- A `sealed class UserFields<V>` hierarchy — type-safe field keys
- Per-field leaves like `UserFields.name`, `UserFields.email`, `UserFields.age`
- Extension methods on `User`: `validate()`, `validateAsync()`, `validateField()`

## Usage

```dart
void main() {
  final user = User(name: 'Alice', email: 'alice@example.com', age: 30);

  // Validate the whole object
  final result = user.validate();
  if (result.isValid) {
    print('User is valid!');
  }

  // Validate a single field
  final fieldResult = user.validateField(UserFields.email);
}
```

## What gets generated

| Artifact | Always? | Purpose |
|---|---|---|
| `sealed class XFields<V>` | Yes | Type-safe field key hierarchy |
| `static const XFields<V> field = XFieldField()` | Per field | Singleton for every annotated field |
| `class XFieldField extends XFields<V>` | Per field | Leaf that runs the field's rules |
| `extension $XValidasi on X { validate(), validateAsync() }` | Yes | Whole-object validation |
| `extension $XValidasi on X { validateField<V>(f), validateFieldAsync<V>(f) }` | Configurable | Per-field validation |
| `X assemble_X(ValidasiFormController<X> ctrl)` | Configurable | Materialise a model from a form controller |
| `ValidasiResult<X> validateForm_X(ValidasiFormController<X> ctrl)` | Configurable | Form-aware validation |

## Build options

Configure the generator in your `build.yaml`:

```yaml
targets:
  $default:
    builders:
      validasi_gen:validasi:
        options:
          generateFields: true
          generateAssemble: true
          generateValidateForm: false
```

| Option | Default | Description |
|---|---|---|
| `generateFields` | `true` | Emit `XFields` hierarchy + `validateField()` |
| `generateAssemble` | `true` | Emit `assemble_X()` for form controller |
| `generateValidateForm` | `false` | Emit `validateForm_X()` (requires `validasi_ui`) |

Per-class overrides take precedence:

```dart
@ValidateClass(generateFields: false)
class Internal {
  // ...
}
```

## Cross-field validation (Refine)

Use `@RefineFn` on a method to define rules that span multiple fields:

```dart
@ValidateClass()
class User {
  final String email;
  final String confirmEmail;

  @RefineFn(dependsOn: ['email', 'confirmEmail'])
  void emailsMatch(FailFn fail, {String? email, String? confirmEmail}) {
    if (email != null && confirmEmail != null && email != confirmEmail) {
      fail(message: 'Emails do not match', path: ['confirmEmail']);
    }
  }
}
```

The method receives a `FailFn` as its first argument and named parameters matching the field names in `dependsOn`.

## Async validation

The generator automatically produces `validateAsync()` and `validateFieldAsync()` methods. They run all rules sequentially, including any async rules. There are two ways to define async validation:

### Async inline on a field (`AsyncInline`)

Place `AsyncInline` inside a `@Validate` annotation to run an async check on a specific field:

```dart
Future<bool> _checkUsernameAvailable(String? username) async {
  if (username == null) return false;
  final taken = await database.isTaken(username);
  return !taken;
}

@ValidateClass()
class User {
  @Validate.string([MinLength(3), AsyncInline(_checkUsernameAvailable)])
  final String username;

  const User({required this.username});
}
```

The generator wraps it in `try / catch` — a thrown exception or a `false` return produces a validation error.

`Rules.inlineAsync(...)` from the core library is the programmatic equivalent for use outside of codegen.

### Async refine (`@RefineFn` with `Future<void>`)

When a cross-field rule needs async (e.g. checking two fields against a database), return `Future<void>` instead of `void`:

```dart
@RefineFn(dependsOn: ['email', 'confirmEmail'])
Future<void> emailsMatch(FailFn fail, {String? email, String? confirmEmail}) async {
  if (email != null && confirmEmail != null && email != confirmEmail) {
    fail(message: 'Emails do not match', path: ['confirmEmail']);
  }
}
```

The generator detects the `Future` return type and inserts `await` before the call automatically.
