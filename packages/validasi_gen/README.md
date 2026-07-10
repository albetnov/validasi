# `validasi_gen` (experimental)

> **Experimental** — API subject to change. Feedback and contributions are welcome!

Code generator for [Validasi](https://pub.dev/packages/validasi). Turns `@ValidateClass()` and `@Validate(...)` annotations on a Dart model into a typed `XFields<V>` hierarchy, a `validate()` / `validateAsync()` extension, and (optionally) a form-aware `validateForm_X(ctrl)`.

## Quick start

`pubspec.yaml`:

```yaml
dependencies:
  validasi: ^1.0.0-rc.1
  validasi_annotation: ^0.1.0-dev.2

dev_dependencies:
  build_runner: ^2.4.0
  validasi_gen: ^0.1.0-dev.2
```

Source model:

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi_annotation/validasi_annotation.dart';

part 'user.g.dart';

@ValidateClass()
class User {
  @Validate.string([MinLength(3), MaxLength(100)])
  final String email;

  const User({required this.email});
}
```

Run the generator:

```bash
dart run build_runner build
```

You now have `UserFields<V>`, `UserNameField`, `UserEmailField`, and an `extension $UserValidasi on User` with `validate()` / `validateAsync()` / `validateField()`.

## What you get

For every class annotated with `@ValidateClass`, the generator emits (into `*.g.dart` as a `part of` file):

| Artifact | When | Purpose |
|---|---|---|
| `sealed class XFields<V> extends ValidasiKey<X> implements ValidasiField<X, V>` | always | The type-safe field key hierarchy. |
| `static const XFields<V> fieldName = XFieldNameField();` | per field | Singletons for every annotated field. |
| `class XFieldNameField extends XFields<String>` | per field | Leaf that runs the field's rules. |
| `extension $XValidasi on X { validate(), validateAsync() }` | always | Whole-object validation. |
| `extension $XValidasi on X { validateField<V>(field), validateFieldAsync<V>(field) }` | when `generateFields: true` | Per-field validation using a `XFields<V>` key. |
| `X assemble_X(ValidasiFormController<X> ctrl)` | when `generateAssemble: true` | Materialise a `X` from a form controller. |
| `ValidasiResult<X> validateForm_X(ValidasiFormController<X> ctrl)` | when `generateValidateForm: true` | Form-aware validation that reads per-field values and runs refines. |

A field named `name`, `extract`, `validate`, or `validateAsync` would collide with the identically-named instance member `XFields<V>` inherits from `FieldDescriptor`/`ValidasiField` — a class can't declare both a static and instance member sharing a name. For those field names only, the generator suffixes the static accessor with an underscore (e.g. `XFields.name_`) to dodge the collision; the field's runtime `.name` still reports its real, unmangled name.

## Build options

Set in the downstream package's `build.yaml`:

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

| Option | Default | What it controls |
|---|---|---|
| `generateFields` | `true` | Emit `XFields` sealed hierarchy + `validateField()` on the extension. |
| `generateAssemble` | `true` | Emit `X assemble_X(ValidasiFormController<X> ctrl)`. |
| `generateValidateForm` | `false` | Emit `ValidasiResult<X> validateForm_X(ValidasiFormController<X> ctrl)`. |

`generateValidateForm` is **off by default** because the emitted function references `ValidasiFormController`, which lives in the Flutter-dependent `validasi_ui` package. Flutter consumers opt in by setting it to `true` and importing `validasi_ui` in the source file. Pure-Dart packages leave it off.

Per-class overrides always win:

```dart
@ValidateClass(generateFields: false, generateAssemble: false)
class Internal { ... }
```

## Refine (cross-field validation)

For object- or form-level rules that span multiple fields, mark a `static` method with `@RefineFn(dependsOn: [...])`. The method receives a `FailFn` as its first positional argument and named parameters matching the field names in `dependsOn`:

```dart
class User {
  final String email;
  final String confirmEmail;

  @RefineFn(dependsOn: ['email', 'confirmEmail'])
  static void emailsMatch(
    FailFn fail, {
    String? email,
    String? confirmEmail,
  }) {
    if (email != null && confirmEmail != null && email != confirmEmail) {
      fail(message: 'Emails do not match', path: ['confirmEmail']);
    }
  }
}
```

The method must be `static` — the generator calls it via a fully-qualified static reference (`ClassName.methodName(...)`) from both `validate()`/`validateAsync()` and `validateForm_X(ctrl)`, passing field values as named arguments (`ctrl.getValue(...)` in the form case). Return `Future<void>` for async refines — the generator detects it and inserts `await`.

### Wiring `validateForm_X` into `ValidasiForm`

When both `generateSchema` (on by default) and `generateValidateForm` are `true`, the generated schema class implements `ValidasiFormValidatorSchema<X>` and `ValidasiFormController`/`ValidasiForm` auto-discover `validateForm_X` from `schema:` alone — no need to also pass `formValidator:`:

```dart
ValidasiForm<User>(
  schema: UserSchema(), // validateForm_User is picked up automatically
  builder: ...,
)
```

Pass `formValidator:` explicitly only if you hand-write your schema (`generateSchema: false`) or want to override the generated one.

## See also

- `ARCH.md` — full pipeline walkthrough, file-by-file map, and extension guide.
- `packages/validasi_annotation` — the annotation surface (`@ValidateClass`, `@Validate`, `@RefineFn`, built-in rules, `FailFn`).
- `packages/validasi` — the runtime engine (`ValidasiResult`, `ValidationError`, `ValidationState`).
- `packages/validasi_ui` — the Flutter-side form controller that consumes the generated `validateForm_X(ctrl)`.
