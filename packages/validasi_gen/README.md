# `validasi_gen` (experimental)

> **Experimental** — API subject to change. Feedback and contributions are welcome!

Code generator for [Validasi](https://pub.dev/packages/validasi). Turns `@ValidateClass()` and `@Validate<T>(...)` annotations on a Dart model into a typed `XFields<V>` hierarchy, a `validate()` / `validateAsync()` extension, and (optionally) a schema and a form-aware `validateForm_X(ctrl)`.

## Quick start

```bash
dart pub add validasi validasi_annotation
dart pub add --dev build_runner validasi_gen
```

Source model:

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi_annotation/validasi_annotation.dart';

part 'user.validasi.dart';

@ValidateClass()
class User {
  @Validate<String>([MinLength(3), MaxLength(100)])
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

For every class annotated with `@ValidateClass`, the generator emits (into `*.validasi.dart` as a `part of` file):

| Artifact | When | Purpose |
|---|---|---|
| `sealed class XFields<V> extends ValidasiKey<X> implements ValidasiField<X, V>` | always | The type-safe field key hierarchy. |
| `static const XFields<V> fieldName = XFieldNameField();` | per field | Singletons for every annotated field. |
| `class XFieldNameField extends XFields<String>` | per field | Leaf that runs the field's rules. |
| `extension $XValidasi on X { validate(), validateAsync() }` | always | Whole-object validation. |
| `extension $XValidasi on X { validateField<V>(field), validateFieldAsync<V>(field) }` | when `generateFields: true` | Per-field validation using a `XFields<V>` key. |
| `ValidasiSchema<X>`, exposed as `XFields.schema` | when `generateSchema: true` | A reusable schema for the class, consumed by `validasi_ui` form controllers. |
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
          generateSchema: true
          generateValidateForm: false
          generateIndexedFields: false
```

| Option | Default | What it controls |
|---|---|---|
| `generateFields` | `true` | Emit `XFields` sealed hierarchy + `validateField()` on the extension. |
| `generateSchema` | `true` | Emit `ValidasiSchema<X>`, exposed as `XFields.schema`. |
| `generateValidateForm` | `false` | Emit `ValidasiResult<X> validateForm_X(ValidasiFormController<X> ctrl)`. |
| `generateIndexedFields` | `false` | Emit `indexedFields`/`reconstructItem`/`reconstructAll` static methods, for list-backed/repeatable form sections. |

`generateSchema` and `generateValidateForm` only take effect while `generateFields` is also `true`
— turning `generateFields` off (e.g. for a purely internal type) silently drops the schema and
form validator too, even if you left those flags on.

`generateValidateForm` and `generateIndexedFields` are **off by default** because the code they
emit references `ValidasiFormController`/`IndexedField`, which live in the Flutter-dependent
`validasi_ui` package. Flutter consumers opt in by setting the flag(s) to `true` and importing
`validasi_ui` in the source file. Pure-Dart packages leave them off.

Per-class overrides win over the build-level default for `generateFields`, `generateSchema`, and
`generateIndexedFields` — but **not** `generateValidateForm`, which is build-level only:

```dart
@ValidateClass(generateFields: false, generateSchema: false)
class Internal { ... }
```

## Custom & extensible rules

Beyond the built-in rule catalog, four mechanisms extend what a `@Validate<T>([...])` list can do:

| Rule | Use it when | Shape |
|---|---|---|
| `Inline` | a one-off synchronous check local to this field | `Inline(bool Function(T?) validator, {name, message, runOnNull})` — `validator` must be a `static` or top-level function |
| `AsyncInline` | same, but needs `await` (an HTTP call, a DB lookup) | `AsyncInline(FutureOr<bool> Function(T?) validator, {name, message})` |
| `CustomRule` | a reusable, parameterizable rule shared across fields/classes | subclass with a `static bool check(T? value, {...})` method |
| `AsyncCustomRule` | same, but async | subclass with a `static FutureOr<bool> check(T? value, {...})` method |

```dart
class NoSpaces extends CustomRule<String> {
  const NoSpaces({String? message, super.runOnNull})
      : super(name: 'noSpaces', message: message);

  static bool check(String? value) => value == null || !value.contains(' ');
}

@Validate<String>([MinLength(3), MaxLength(100), NoSpaces()])
final String email;
```

For `CustomRule`/`AsyncCustomRule`, `check`'s first parameter must be positional (the value); any
further parameters must be named and must match a field name declared on the rule subclass — their
values are read off the const rule instance and threaded through as config.

Any `AsyncInline`/`AsyncCustomRule` rule anywhere on a class makes its generated `validate()`
throw `StateError` — use `validateAsync()` for that class from then on.

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

### Cross-field sugar

For the common cross-field shapes, a class-level annotation desugars into a synthetic `@RefineFn`
so you don't have to hand-write one. They're stackable:

```dart
@ValidateClass(generateFields: false, generateSchema: false)
@RequiredAny(['email', 'phone'])
@MatchesField(field: 'password', matchesField: 'passwordConfirmation')
class ContactInfo {
  final String? email;
  final String? phone;
  final String? password;
  final String? passwordConfirmation;
  const ContactInfo({this.email, this.phone, this.password, this.passwordConfirmation});
}
```

| Annotation | Checks |
|---|---|
| `RequiredAny(fields, {message})` | at least one of `fields` is present |
| `RequiredOneOf(fields, {message})` | exactly one of `fields` is present (XOR) |
| `RequiredAll(fields, {message})` | if any of `fields` is present, all are present |
| `DependsOn({field, dependsOn, message})` | if `field` is present, `dependsOn` is present |
| `MutuallyExclusive(fieldA, fieldB, {message})` | not both present |
| `MatchesField({field, matchesField, message})` | the two fields are equal |

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
