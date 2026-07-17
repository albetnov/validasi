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

  @Validate<int>([Positive()])
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
custom error messages. **This page shows a representative subset** — there are around 50 rule
annotations in total, mirroring almost every `Rules.*` factory from the core `validasi` package.
For the full, current catalog, check `package:validasi_annotation/validasi_annotation.dart`'s
exports or the generated API docs on pub.dev; a rule not listed here likely still exists.

### Generic rules

| Annotation | Parameters | Description |
|------------|------------|-------------|
| `Required<T>` | `{String? message}` | Value must be non-null |
| `Nullable<T>` | _(none)_ | Marks a field as nullable (no Required check) |
| `Inline<T>` | `validator`, `{String? name, String? message, bool runOnNull}` | Inline sync validation function, body will be inlined in generated code. `validator` must be a `static` or top-level function — the generator emits a qualified reference to it. |
| `AsyncInline<T>` | `validator`, `{String? name, String? message}` | Inline async validation function (e.g. database lookup). Same `static`/top-level requirement as `Inline`. |
| `CustomRule<T>` | `{required String name, String? message, bool runOnNull}` | Base class — subclass it and add a `static bool check(T?)` |

### String / Iterable rules

| Annotation | Parameters | Context | Description |
|------------|------------|---------|-------------|
| `MinLength<T>` | `int length`, `{String? message}` | `string`, `iterable` | Min chars / min items |
| `MaxLength<T>` | `int length`, `{String? message}` | `string`, `iterable` | Max chars / max items |
| `OneOf<T>` | `List<T> options`, `{String? message}` | `string`, `generic` | Value must be one of the options |
| `Email<T>` | `{String? message}` | `string` | Value must be a valid email address |
| `Regex<T>` | `Pattern pattern`, `{String? message}` | `string` | Value must match the pattern |
| `Alphanumeric<T>` / `Alpha<T>` | `{String? message}` | `string` | Character-class checks |
| `Uuid<T>` / `Ulid<T>` / `Url<T>` | `{String? message}` | `string` | Format checks |

Applying `MinLength`/`MaxLength` (or any handler that checks context) to an unsupported context —
e.g. a bare `int` field — fails the build with `InvalidGenerationSourceError`, not a silent no-op.

### Numeric rules

| Annotation | Parameters | Description |
|------------|------------|-------------|
| `MoreThan<T extends num>` / `MoreThanEqual<T extends num>` | `T value`, `{String? message}` | Value must be greater than (or equal to) `value` |
| `LessThan<T extends num>` / `LessThanEqual<T extends num>` | `T value`, `{String? message}` | Value must be less than (or equal to) `value` |
| `Between<T extends num>` | `T min, T max`, `{String? message}` | Value must fall within the range |
| `Positive<T extends num>` / `Negative<T extends num>` | `{String? message}` | Sign checks |

> **Context-dependent rules:** `MinLength` and `MaxLength` behave differently depending
> on the `T` in `@Validate<T>`. With `@Validate<String>` they check character length;
> with `@Validate<List<T>>` they check item count.

### Cross-field sugar

`@RequiredAny`, `@RequiredOneOf`, `@RequiredAll`, `@DependsOn`, `@MutuallyExclusive`, and
`@MatchesField` cover common multi-field shapes (confirm-password, at-least-one-of, mutually
exclusive fields) without hand-writing a `@RefineFn`. See
[Cross-field & Async](/companion/generator/cross-field#cross-field-sugar-annotations) for the
full list with signatures and a worked example.

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
  static void emailsMatch(FailFn fail, {String? email, String? confirmEmail}) {
    if (email != null && confirmEmail != null && email != confirmEmail) {
      fail(message: 'Emails do not match', path: ['confirmEmail']);
    }
  }
}
```

- **The method must be `static`** — an instance method throws `InvalidGenerationSourceError` at
  build time, since the generator emits a qualified `ClassName.methodName(...)` call.
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
