---
name: validasi-gen
description: >-
  Generate typed validators for Dart & Flutter classes at build time with validasi_gen and
  validasi_annotation, instead of hand-writing validasi schemas. Use this whenever the user
  annotates a class with @ValidateClass or @Validate<T>, runs build_runner for validation code,
  asks which validasi_gen build flag to turn on (generateFields/generateSchema/generateValidateForm/
  generateIndexedFields), needs a *.g.dart validator regenerated, or wants a custom, async, or
  cross-field rule wired into a generated class — Inline, AsyncInline, CustomRule, AsyncCustomRule,
  RefineFn, or the cross-field sugar annotations (@RequiredAny, @MatchesField, etc). Reach for this
  skill whenever validasi_gen, validasi_annotation, @ValidateClass, or a generated validasi *.g.dart
  file appears in the code or request, even if the user doesn't name the package explicitly.
---

# Validasi Gen

`validasi_gen` is the `build_runner` code generator for `validasi`: annotate a plain Dart class
with `@ValidateClass` and field-level `@Validate<T>([...])`, run the build, and get a `*.g.dart`
part file with a sealed field hierarchy plus `validate()`/`validateAsync()` extension methods —
instead of hand-writing a `Validasi.*` builder. This skill is the curated, always-in-context
reference for the codegen decisions; deep catalogs live in `references/`.

## Imports & setup

```sh
dart pub add validasi validasi_annotation
dart pub add --dev build_runner validasi_gen
```

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi_annotation/validasi_annotation.dart';

part 'user.g.dart';

@ValidateClass()
class User {
  @Validate<String>([MinLength(3), MaxLength(100)])
  final String email;

  const User({required this.email});
}
```

Run `dart run build_runner build --delete-conflicting-outputs` (or `watch`) to (re)generate. The
builder declares `auto_apply: dependents` and `build_to: source`, so any package depending on
`validasi_gen` gets its `.g.dart` written next to the source file automatically — the `part`
directive is the only manual wiring needed.

## Build flags

Four `bool` options, set under `targets > $default > builders > validasi_gen:validasi > options`
in `build.yaml`, each overridable per class via `@ValidateClass(...)`:

| Flag | Default | Effect |
|------|---------|--------|
| `generateFields` | `true` | Emits the sealed `XFields<V>` hierarchy + `validateField()`/`validateFieldAsync()`. **Gates the two below** — `generateSchema` and `generateValidateForm` only take effect while this is also `true`. |
| `generateSchema` | `true` | Emits `ValidasiSchema<X>`, exposed as `XFields.schema`. |
| `generateValidateForm` | `false` | Emits `validateForm_X(ValidasiFormController<X>)`. Needs the `validasi_ui` dependency; **no per-class override** — build-level only. |
| `generateIndexedFields` | `false` | Emits `indexedFields`/`reconstructItem`/`reconstructAll` for list-backed forms. Needs `validasi_ui`. |

Full option reference, `build.yaml` examples, and the per-class override form: `references/flags.md`.

## Declaring field rules

`@Validate<T>([...])` — the type argument `T` picks the rule dispatch (string / iterable / generic
context), it isn't a named constructor like `@Validate.string([...])`:

```dart
@Validate<String>([MinLength(3), MaxLength(100), Email()])
final String email;
```

A non-nullable Dart field type gets an implicit `Required` check for free. Use `@Nullable()` to opt
a non-nullable-typed field **out** of that automatic check, or `@Required(message: '...')` to
customize its message or force the check onto a nullable-typed field.

## Choosing an extensibility mechanism

| Need | Reach for |
|------|-----------|
| One-off synchronous check, local to this field | `Inline` |
| One-off check that needs `await` / I/O | `AsyncInline` |
| Reusable, parameterizable rule shared across fields or classes | `CustomRule` |
| Same, but async | `AsyncCustomRule` |
| Check spans multiple fields (confirm-password, conditional required) | `RefineFn` |
| ...and it's a common cross-field shape | a cross-field sugar annotation (`@RequiredAny`, `@MatchesField`, etc.) instead of hand-writing `RefineFn` |

```dart
@Validate<String>([MinLength(3), Inline(_noSpaces)])
final String username;

static bool _noSpaces(String? value) => value == null || !value.contains(' ');
```

Full contracts — constructor signatures, the `static check(...)` build-time rules for
`CustomRule`/`AsyncCustomRule`, `RefineFn`'s `FailFn`/`dependsOn` wiring, and every cross-field
sugar annotation — are in `references/extensibility.md`.

## Async rules discipline

Any async rule anywhere on a class — `AsyncInline`, `AsyncCustomRule`, or an async `@RefineFn` —
makes the **whole generated `validate()` throw**:
`StateError('Async rules cannot be used with validate(). Use validateAsync() instead.')`. There is
no partial-async mode: once one field needs `validateAsync()`, every caller of that class does too.
Treat adding an async rule as a call-site-breaking change, not a local one.

## Quick reference

| Task | Approach |
|------|----------|
| Skip `XFields`/`validateField` for an internal type | `@ValidateClass(generateFields: false)` |
| One class needs the schema, another doesn't | per-class `@ValidateClass(generateSchema: ...)` override |
| Confirm-password / two fields must match | `@MatchesField(field: 'password', matchesField: 'passwordConfirmation')` |
| At least one of several fields required | `@RequiredAny(['email', 'phone'])` |
| Reusable sync check across fields | `CustomRule` subclass with `static bool check(value, {...})` |
| DB-backed uniqueness check | `AsyncCustomRule` (or `AsyncInline` for a one-off) + `validateAsync()` |
| Field depends on sibling fields | `@RefineFn(dependsOn: [...])` static method taking `FailFn` |
| Nothing validates and no error is raised | check for a typo'd/unregistered rule — see `references/gotchas.md` |

## Companion references

- `references/flags.md` — full build-flag reference, `build.yaml`/per-class override forms, the stale-README warning.
- `references/extensibility.md` — Inline, AsyncInline, CustomRule, AsyncCustomRule, RefineFn, and cross-field sugar, each with signatures and a worked example.
- `references/gotchas.md` — nested validation behavior, the silently-dropped-unknown-rule footgun, name-collision suffixing, regeneration reminders.

See `validasi` for the runtime library these generated classes call into (`ValidasiResult`, error
handling, hand-written custom `Rule<T>`/`AsyncRule<T>`).
