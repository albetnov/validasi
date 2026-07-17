---
name: validasi
description: >-
  Build, run, and reason about validation with the validasi library for Dart & Flutter.
  Use this whenever the user validates strings, numbers, lists, maps, or custom types in Dart;
  builds schemas with Validasi.string/number/list/map/any; applies Rules.* (built-in or custom);
  handles ValidasiResult / ValidationError; uses transformations, preprocessing, or async validation;
  writes a custom Rule<T> or AsyncRule<T>; or asks how to structure validation code, order rules, or
  avoid common mistakes. Reach for this skill whenever validasi, Validasi.*, Rules.*, FieldRules, or
  ValidasiEngine appears in the code or request, even if the user doesn't name the library explicitly.
---

# Validasi

`validasi` is a composable, type-safe validation library for Dart & Flutter. You describe a
schema as a builder plus a list of rules, run it against a value, and read a structured result.
This skill is the curated, always-in-context reference; the deep catalogs live in `references/`.

## Imports

```dart
import 'package:validasi/validasi.dart'; // Validasi.* builders, ValidasiResult, ValidationError
import 'package:validasi/rules.dart';    // Rules.* factories, Rule, AsyncRule, ValidationState, FieldRules
```

Import **both** in most files. `rules.dart` is the one that exports `Rule`/`AsyncRule`/
`ValidationState` — you need it (not `validasi.dart` alone) to write custom rules. Constructing a
raw `ValidasiEngine` directly additionally needs `package:validasi/engine.dart` (see
`references/engine.md`), but you rarely need that — the `Validasi.*` builders cover it.

## The validation flow

Every validation is the same three steps: build a schema, call `validate` (or `validateAsync`),
inspect the `ValidasiResult<T>`.

```dart
final nameSchema = Validasi.string([
  Rules.string.minLength(2),
  Rules.string.maxLength(50),
]);

final result = nameSchema.validate('Alice');

if (result.isValid) {
  print(result.data); // Alice — the validated (and possibly transformed) value
} else {
  for (final error in result.errors) {
    print('${error.rule}: ${error.message}');
  }
}
```

Builders take an **optional positional** `List<Rule<...>>`. The pipeline is always:
**preprocess (optional) → type check against `T` → rule loop (in declared order) → build result.**

## Picking a schema

| Builder | Validates | Reach for it when |
|---------|-----------|-------------------|
| `Validasi.string([...])` | `String` | text fields, formats (email/url/uuid), case, patterns |
| `Validasi.number<T extends num>([...])` | `int`/`double`/`num` | ranges, sign, integer/decimal checks |
| `Validasi.list<T>([...])` | `List<T>` | length, membership, uniqueness, per-item rules |
| `Validasi.map<T>([...])` | `Map<String, T>` | object shape, required/conditional fields, cross-field rules |
| `Validasi.any<T>([...])` | any `T` | custom domain models, non-`String`-key maps, escape hatch |

Always pass the generic explicitly (`Validasi.number<int>`, `Rules.nullable<String>()`) — it keeps
input/output types precise and turns mistakes into compile errors instead of runtime surprises.

A few common rules per type (full catalogs with every option in `references/schemas.md`):

- **string** — `minLength`, `maxLength`, `email`, `url`, `uuid`, `oneOf`, `regex`, `alphanumeric`
- **number** — `moreThan(Equal)`, `lessThan(Equal)`, `between`, `positive`, `integer`, `decimal`
- **list** (`Rules.iterable.*`) — `minLength`, `unique`, `contains`, `forEach<T>([...])`
- **map** (`Rules.map.*`) — `hasFields`, `hasFieldKeys`, `allowedKeys`, `conditionalField`, `matchesField`

`Rules.map.hasFields` takes a `FieldRules<T>([...])` per field — not a nested `Validasi.*` schema.
Nest a map by putting another `hasFields` inside a `FieldRules<Map<String, dynamic>>([...])`:

```dart
final userSchema = Validasi.map<dynamic>([
  Rules.map.hasFields({
    'name': FieldRules<String>([Rules.string.minLength(2)]),
    'age': FieldRules<int>([Rules.number.moreThanEqual(18)]),
  }),
]);
```

## Modifier rules

These apply across schema types (details in `references/schemas.md`):

- `Rules.nullable<T>()` — allow `null`; skips later rules when the value is null
- `Rules.required<T>()` — make non-null intent explicit
- `Rules.transform<T>((v) => ...)` / `Rules.transformAsync<T>(...)` — normalize the value in-loop
- `Rules.having<T>([...])` — value must be one of the allowed values
- `Rules.inline<T>((v) => bool)` / `Rules.inlineAsync<T>(...)` — quick one-off custom check
- `Rules.equals<T>(v)` / `Rules.notEquals<T>(v)` — (in)equality, with optional custom `equals`
- `Rules.anyOf<T>([[...], [...]])` — value must satisfy at least one rule set (OR logic)

## Transform vs. preprocess

Both change the value, at different stages — pick by intent:

- **`Rules.transform<T>`** runs *inside* the rule loop, after the type check. Use it to clean a value
  that is already the right type (trim, lowercase). It runs on `null` too, so keep it null-safe.
- **`withPreprocess`** runs *before* the type check and converts raw input into `T`. It also changes
  the accepted input type at compile time, so wrong-typed calls fail to compile.

```dart
final ageSchema = Validasi.number<int>([
  Rules.number.moreThanEqual(0),
]).withPreprocess((String value) => int.parse(value));

ageSchema.validate('25'); // OK — validate() now accepts String
// ageSchema.validate(25); // compile-time error
```

Put transforms *before* the validation rules that depend on the normalized value — otherwise, e.g.,
a `minLength` check runs against the untrimmed input. See `references/engine.md` for the full engine
model and dynamic-input strategies.

## Errors

`ValidasiResult<T>` gives you `isValid`, `data` (`T?`), and `errors` (`List<ValidationError>`).
Each `ValidationError` carries `rule`, `message`, `path` (`List<String>?`), and `details`.

Always branch on `isValid` before using `data`. Treat `error.path` as the source of truth for
*where* a nested error happened, `message` as user-facing text, and `rule`/`details` as diagnostics.

```dart
Map<String, List<String>> errorsByField<T>(ValidasiResult<T> result) {
  final grouped = <String, List<String>>{};
  for (final error in result.errors) {
    final field = error.path?.join('.') ?? 'root';
    grouped.putIfAbsent(field, () => []).add(error.message);
  }
  return grouped;
}
```

## Custom rules (quickstart)

When no built-in rule fits and the check recurs, extend `Rule<T>` and implement `apply`. Return the
(possibly modified) value, and report failures via `state.addError`:

```dart
class AdultAge extends Rule<int> {
  const AdultAge({super.message});

  @override
  int? apply(int? value, ValidationState state) {
    if (value == null) return null; // runOnNull defaults to false; null is skipped anyway
    if (value < 18) {
      state.addError(ValidationError(
        rule: 'AdultAge',
        message: message ?? 'Age must be at least 18',
      ));
    }
    return value;
  }
}

final schema = Validasi.number<int>([const AdultAge()]);
```

For async work (e.g. a DB lookup) extend `AsyncRule<T>`, override `applyAsync`, and validate with
`validateAsync()`. `references/custom-rules.md` covers `ValidationState` (including `state.isStopped`
to halt the chain), `runOnNull`, error `details`, and full sync/async examples.

## Async validation

If any rule is async (`AsyncRule`, `Rules.inlineAsync`, `Rules.transformAsync`), call
`validateAsync()` — calling `validate()` throws a `StateError`. Container rules (`hasFields`,
`forEach`, `allValues`, `anyOf`) transparently support async children.

```dart
final result = await schema.validateAsync('user@example.com');
```

## A few high-value habits (full list in `references/best-practices.md`)

- **Order rules by intent**: nullability first, then transforms, then validation, then cross-field
  checks. The loop feeds each rule's output to the next, so order changes behavior.
- **Prefer a built-in rule over `inline`** when one exists — it's tested and gives better messages.
- **Keep transforms pure** (no side effects) and null-safe under `nullable` schemas.
- **Break big schemas into named rule lists / sub-schemas** and compose them; it's easier to test.
- **Format at the boundary**: return the full `errors` list from inner layers, shape it for UI/API
  at the edge — don't leak `rule` names into user-facing text.

## Companion packages

The core `validasi` package is enough for plain validation. The ecosystem also has companions, each
solving one problem — a dedicated skill will cover these in depth; for now, just know they exist:

- **`validasi_annotation` + `validasi_gen`** — annotate a class (`@Validate`, rule annotations) and
  generate typed validators at build time with `build_runner`. Reach for it when you want
  compile-time schemas instead of hand-written ones. See the `validasi-gen` skill for build flags
  and codegen-specific rule extensibility (Inline, AsyncInline, CustomRule, RefineFn).
- **`validasi_ui`** — headless form management for Flutter (controllers, signals, widgets), which can
  bind generated field classes or manual descriptors. Reach for it when wiring validation into forms.
  See the `validasi-ui` skill for controller ownership/disposal, register/unregister, and
  `shouldUnregister` lifecycle rules.

## Quick reference

| Task | Approach |
|------|----------|
| Optional string field | `Validasi.string([Rules.nullable<String>(), Rules.string.email()])` |
| Trim then validate | `Rules.transform<String>((v) => v?.trim())` before the length/format rules |
| Parse string to int | `Validasi.number<int>([...]).withPreprocess((String s) => int.parse(s))` |
| Validate each list item | `Rules.iterable.forEach<T>([...])` |
| Validate map fields | `Rules.map.hasFields({'k': FieldRules<T>([...])})` |
| Match two fields (confirm password) | `Rules.map.matchesField('password', 'passwordConfirm')` |
| Reusable custom check | extend `Rule<T>` (async: `AsyncRule<T>` + `validateAsync()`) |
| One-off custom check | `Rules.inline<T>((v) => condition)` |
