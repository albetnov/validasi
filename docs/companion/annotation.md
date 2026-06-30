# Annotations (`validasi_annotation`) <Badge type="warning" text="experimental" />

The `validasi_annotation` package provides annotations that drive `validasi_gen`'s
compile-time code generation. Every annotation is a zero-cost marker — none of them
add runtime overhead. The generator reads them at build time and emits plain Dart code.

## Setup

```bash
dart pub add validasi_annotation
dart pub add dev:validasi_gen dev:build_runner
```

## Class-level: `@ValidateClass`

Place `@ValidateClass` on any class you want the generator to process:

```dart
@ValidateClass()
class User {
  @Validate<String>([MinLength(3), MaxLength(100)])
  final String name;

  const User({required this.name});
}
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `generateFields` | `bool?` | `true` | Emit the `XFields<V>` sealed class hierarchy with per-field leaf types |
| `generateSchema` | `bool?` | `true` | Emit a `ValidasiSchema<T>` implementation for form allocation |
| `generateIndexedFields` | `bool?` | `false` | Emit `indexedFields`, `reconstructItem`, `reconstructAll` (requires `validasi_ui`) |

All parameters are optional and nullable — when unset they inherit from the global
build options in `build.yaml`. Per-class annotations take precedence.

## Field-level: `@Validate<T>`

Annotate each validated field with `@Validate<T>([...rules...])`:

```dart
@ValidateClass()
class User {
  @Validate<String>([Required(), MinLength(3)])
  final String name;

  @Validate<int>([MinLength(1)])
  final int age;
}
```

- **`T`** is the field's value type — used by the generator to determine the
  `FieldContext` (`string`, `iterable`, `generic`) for each rule handler.
- **`rules`** is required. Passing an empty list `[]` means "no rules to check" (the
  generator still emits the field class so form libraries can discover it).
- Rules are checked in order. The first failing rule's error is emitted.

## Rule annotations

All rule annotations extend `Rule<T>` and carry an optional `message` parameter for
custom error messages.

### Generic rules

| Annotation | Parameters | Description |
|------------|------------|-------------|
| `Required<T>` | `{String? message}` | Value must be non-null |
| `Nullable<T>` | _(none)_ | Marks a field as nullable (no Required check) |
| `Inline<T>` | `validator`, `{String? name, String? message, bool runOnNull}` | Inline sync validation function, body will be inlined in generated code |
| `AsyncInline<T>` | `validator`, `{String? name, String? message}` | Inline async validation function (e.g. database lookup) |
| `CustomRule<T>` | `{required String name, String? message, bool runOnNull}` | Base class — subclass it and add a `static bool check(T?)` |

### String / Iterable rules

| Annotation | Parameters | Context | Description |
|------------|------------|---------|-------------|
| `MinLength<T>` | `int length`, `{String? message}` | `string`, `iterable` | Min chars / min items |
| `MaxLength<T>` | `int length`, `{String? message}` | `string`, `iterable` | Max chars / max items |
| `OneOf<T>` | `List<T> options`, `{String? message}` | `string`, `generic` | Value must be one of the options |

> **Context-dependent rules:** `MinLength` and `MaxLength` behave differently depending
> on the `T` in `@Validate<T>`. With `@Validate<String>` they check character length;
> with `@Validate<List<T>>` they check item count.

## Custom rule: `CustomRule<T>` and `AsyncCustomRule<T>`

For rules that can't be expressed with the built-in annotations, subclass `CustomRule`:

```dart
class NoSpaces extends CustomRule<String> {
  const NoSpaces({String? message, super.runOnNull})
      : super(name: 'noSpaces', message: message);

  static bool check(String? value) => value == null || !value.contains(' ');
}
```

Then use it in a `@Validate<T>` annotation:

```dart
@Validate<String>([MinLength(3), NoSpaces()])
final String username;
```

The generator detects subclasses of `CustomRule<T>` and emits a call to the `static bool check(T?)` method. For async variants, use `AsyncCustomRule<T>`.

## Cross-field: `@RefineFn`

Place `@RefineFn` on a method to define validation rules that span multiple fields:

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

- The first parameter is always `FailFn` — call `fail(...)` to register an error.
- Named parameters match the field names in `dependsOn`.
- The generator detects `Future<void>` return types and inserts `await`.

## What the generator produces

For a class annotated with `@ValidateClass(generateSchema: true)`:

```
User
  ├── sealed class UserFields<V> extends ValidasiKey<User>
  │     └── implements ValidasiField<User, V>
  │     ├── static const UserFields<String> name
  │     ├── static const UserFields<int>  age
  │     └── static const ValidasiSchema<User> schema
  │
  └── extension $UserValidasi on User
        ├── ValidasiResult<User> validate()
        ├── Future<ValidasiResult<User>> validateAsync()
        ├── ValidasiResult<V> validateField<V>(UserFields<V>)
        └── Future<ValidasiResult<V>> validateFieldAsync<V>(UserFields<V>)
```

See [Code Generation](/companion/generator/overview) for details.
