# Code Generation (`validasi_gen`) <Badge type="warning" text="experimental" />

The `validasi_gen` package works with `validasi_annotation` to produce typed,
zero-overhead validators at compile time via `build_runner`. Instead of calling
`Validasi.string().validate(value)` at runtime, the generator emits plain Dart
code with the same checks inlined — no reflection, no codegen runtime overhead.

## Setup

```bash
dart pub add validasi validasi_annotation
dart pub add dev:build_runner dev:validasi_gen
```

## Quick start

Annotate a model:

```dart
// user.dart
import 'package:validasi/validasi.dart';
import 'package:validasi_annotation/validasi_annotation.dart';

part 'user.g.dart';

@ValidateClass()
class User {
  @Validate<String>([Required(), MinLength(3), MaxLength(100)])
  final String name;

  @Validate<String>([MinLength(5)])
  final String email;

  @Validate<int>([Positive()])
  final int age;

  const User({required this.name, required this.email, required this.age});
}
```

Run the generator:

```bash
dart run build_runner build
```

This produces `user.g.dart` containing a sealed field class hierarchy and validation
extension methods on `User`.

## Annotation rules vs `Rules.*`

The annotation rule classes mirror the same rules from the core `Rules` factory.
Every rule you'd write at runtime has a corresponding annotation class.

```dart
// Runtime (core validasi)
Rules.string.minLength(3)
Rules.string.maxLength(100)
Rules.iterable.minLength(2)

// Annotation (validasi_gen) — same checks, no namespace prefix
MinLength(3)     // in @Validate<String>  → checks character length
MinLength(2)     // in @Validate<List<T>> → checks item count
MaxLength(100)
```

**Key differences:**

| Runtime (`Rules.*`) | Annotation | Notes |
|---|---|---|
| `Rules.string.minLength(n)` | `MinLength(n)` in `@Validate<String>` | Context from `T` |
| `Rules.iterable.minLength(n)` | `MinLength(n)` in `@Validate<List<T>>` | Same class, different context |
| `Rules.string.required()` | `Required()` | — |
| `Rules.string.email()` | `Email()` | — |
| `Rules.number.moreThan(n)` | `MoreThan(n)` | Also `LessThan`, `Between`, `Positive`, `Negative`, and more |

- **No namespace prefix** — write `MinLength(3)` instead of `Rules.string.minLength(3)`.
- **Unified rules** — `MinLength`, `MaxLength`, etc. work across contexts. The `T` in
  `@Validate<T>` tells the generator which check to emit (string-length vs item-count) — but
  each annotation only supports specific contexts (e.g. `MinLength`/`MaxLength` support
  `string`/`iterable`, not a bare `int`/`num`). Using one in an unsupported context throws
  `InvalidGenerationSourceError` at build time, not a silent no-op.
- **Around 50 rule annotations exist** across string, numeric, and cross-field categories —
  this table only shows a few for contrast. See [Annotations](/companion/annotation) for the
  fuller catalog.

## Generated artifacts

| Artifact | Build option | Purpose |
|----------|:---:|---------|
| `sealed class XFields<V>` | `generateFields` | Type-safe field keys with per-field `validate()` |
| `static const XFields<V> field` | `generateFields` | One singleton const per annotated field |
| `extension $XValidasi on X` | _(always)_ | `validate()` / `validateAsync()` on model instances |
| `extension $XValidasi on X { validateField, validateFieldAsync }` | `generateFields` | Validate a single field by key |
| `static const ValidasiSchema<X> schema` | `generateSchema` | Schema for form allocation |
| `class _XSchema extends ValidasiSchema<X>` | `generateSchema` | Private implementation of `allocate()` |
| `validateForm_X(controller)` | `generateValidateForm` | Form-aware validation (requires `validasi_ui`) |

`generateSchema` and `generateValidateForm` only take effect while `generateFields` is also
`true` — it gates both of them. Setting `generateFields: false` silently drops the schema and
form-validator output too, even if those two flags are still `true`. See
[Configuration](/companion/generator/configuration) for the full flag reference, including which
flags can be overridden per-class.

## Basic usage

```dart
void main() {
  final user = User(name: 'Alice', email: 'alice@example.com', age: 30);

  // Whole-object validation
  final result = user.validate();
  if (result.isValid) {
    print('User is valid!');
  }

  // Single-field validation
  final fieldResult = user.validateField(UserFields.email);

  // Check errors
  for (final error in result.errors) {
    print('${error.rule}: ${error.message}');
  }
}
```

## Async validation

The generator automatically produces `validateAsync()` and `validateFieldAsync()` methods:

```dart
final result = await user.validateAsync();
```

Async rules run sequentially after sync rules. See [Cross-field & Async](/companion/generator/cross-field) for
details on `@AsyncInline` and `AsyncCustomRule`.
