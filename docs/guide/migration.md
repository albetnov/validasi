# Migrating from v0

Validasi v1 is a rewrite: schemas are typed, rules are explicit, and validation returns a
`ValidasiResult` instead of the old validator objects. This guide maps the v0 API to v1. The old
documentation stays available at [v0 documentation](/v0/).

## Dependency

`validasi` v1 is the default version on pub.dev:

```bash
dart pub add validasi
# or
flutter pub add validasi
```

Your v0 code keeps working on the `0.0.x` line if you pin it explicitly:

```yaml
dependencies:
  validasi: ^0.0.10
```

## Imports

v0 exposed everything from `package:validasi/validasi.dart`. v1 splits the surface:

```dart
import 'package:validasi/validasi.dart'; // Validasi.* builders, ValidasiResult, ValidationError
import 'package:validasi/rules.dart';    // Rules.*, Rule, AsyncRule, ValidationState, FieldRules
```

`ValidasiEngine` and the field/schema abstractions are available from `package:validasi/engine.dart`
and `package:validasi/fields.dart` when you need them directly.

## Schema construction

v0 used a fluent validator per type. v1 takes a list of rules:

::: code-group

```dart [v0]
final schema = Validasi.string().minLength(3).maxLength(20).email();
final result = schema.tryParse('user@example.com');
```

```dart [v1]
final schema = Validasi.string([
  Rules.string.minLength(3),
  Rules.string.maxLength(20),
  Rules.string.email(),
]);
final result = schema.validate('user@example.com');
```

:::

## Required and nullable

v0 made every field required by default and used `.nullable()` to opt out. v1 has no implicit
required check: add `Rules.required<T>()` when null must fail, and `Rules.nullable<T>()` when it
must pass.

::: code-group

```dart [v0]
final schema = Validasi.string().nullable();
print(schema.tryParse(null).isValid); // true
```

```dart [v1]
final schema = Validasi.string([
  Rules.nullable<String>(),
  Rules.string.minLength(3),
]);
print(schema.validate(null).isValid); // true
```

:::

`Rules.nullable<T>()` stops the rule pipeline for `null`, so later rules are skipped. Put it first.

## Result access

| v0 | v1 |
|---|---|
| `schema.tryParse(value)` | `schema.validate(value)` |
| `schema.tryParseAsync(value)` | `schema.validateAsync(value)` |
| `result.value` | `result.data` |
| `result.isValid` | `result.isValid` (unchanged) |
| `result.errors` (`FieldError`) | `result.errors` (`ValidationError`) |
| `error.path` (single path) | `error.path` (`List<String>?`) |
| `schema.parse(value)` (throws) | `result.requireValue()` or throw manually |

```dart
final result = schema.validate(input);

if (!result.isValid) {
  for (final error in result.errors) {
    print('${error.path?.join('.') ?? 'root'}: ${error.message}');
  }
  throw FormatException(
    result.errors.map((error) => error.message).join(', '),
  );
}

final value = result.requireValue();
```

## Type-specific builders

| v0 | v1 |
|---|---|
| `Validasi.string()` | `Validasi.string([...])` |
| `Validasi.number()` | `Validasi.number<num>([...])` or `number<int>` / `number<double>` |
| `Validasi.object({...})` | `Validasi.map<dynamic>([Rules.map.hasFields({...})])` |
| `Validasi.array(itemSchema)` | `Validasi.list<T>([Rules.iterable.forEach([...])])` |
| `Validasi.generic<T>()` | `Validasi.any<T>([...])` |
| `Validasi.date()` | No built-in date schema; use `Validasi.any<DateTime>([...])` with an inline/custom rule |

### Object / map

::: code-group

```dart [v0]
final schema = Validasi.object({
  'name': Validasi.string().minLength(1),
  'age': Validasi.number().gte(0),
});
```

```dart [v1]
final schema = Validasi.map<dynamic>([
  Rules.map.hasFields({
    'name': FieldRules<String>([
      Rules.string.minLength(1),
    ]),
    'age': FieldRules<int>([
      Rules.number.moreThanEqual(0),
    ]),
  }),
]);
```

:::

### Array / list

::: code-group

```dart [v0]
final schema = Validasi.array(Validasi.string().minLength(1));
```

```dart [v1]
final schema = Validasi.list<String>([
  Rules.iterable.forEach<String>([
    Rules.string.minLength(1),
  ]),
]);
```

:::

### Generic

::: code-group

```dart [v0]
final schema = Validasi.generic<String>().oneOf(['a', 'b']);
```

```dart [v1]
final schema = Validasi.any<String>([
  Rules.having<String>(['a', 'b']),
]);
```

:::

## Rules mapping

| v0 method | v1 rule |
|---|---|
| `minLength(n)` | `Rules.string.minLength(n)` / `Rules.iterable.minLength(n)` |
| `maxLength(n)` | `Rules.string.maxLength(n)` / `Rules.iterable.maxLength(n)` |
| `email()` | `Rules.string.email()` |
| `startsWith(s)` / `endsWith(s)` / `contains(s)` | `Rules.string.startsWith/endsWith/contains(s)` |
| `gt(n)` / `gte(n)` / `lt(n)` / `lte(n)` | `Rules.number.moreThan/moreThanEqual/lessThan/lessThanEqual(n)` |
| `positive()` / `negative()` / `nonPositive()` / `nonNegative()` | `Rules.number.positive/negative/nonPositive/nonNegative()` |
| `nonDecimal()` | `Rules.number.integer()` |
| `decimal()` | `Rules.number.decimal()` |
| `finite()` | `Rules.number.finite()` |
| `equalTo(v)` / `notEqualTo(v)` | `Rules.equals(v)` / `Rules.notEquals(v)` |
| `oneOf(values)` / `notOneOf(values)` | `Rules.having(values)` / `Rules.notEquals(v)` per value, or `Rules.anyOf(...)` |
| `min(n)` / `max(n)` on arrays | `Rules.iterable.minLength(n)` / `Rules.iterable.maxLength(n)` |
| `contains(v)` / `notContains(v)` on arrays | `Rules.iterable.contains(v)` / `Rules.iterable.notContains(v)` |
| `unique()` | `Rules.iterable.unique()` |
| `.extend({...})` / `.without([...])` | Compose `Rules.map.hasFields` / `Rules.map.forbiddenKeys` or build the field map in Dart |

## Transformers and preprocessing

v0's `transformer:` constructor parameter is split in v1:

- Use `.withPreprocess(...)` when the **input type** differs from the schema type.
- Use `Rules.transform<T>(...)` when the value is already the right type but needs normalization.

::: code-group

```dart [v0]
final schema = Validasi.number(transformer: NumberTransformer());
final result = schema.tryParse('10');
```

```dart [v1]
final schema = Validasi.number<int>([
  Rules.number.moreThan(0),
]).withPreprocess((String input) => int.parse(input));

final result = schema.validate('10');
```

:::

## Custom rules

v0's `.custom((value, fail) { ... })` becomes either an inline rule or a reusable `Rule<T>`.

::: code-group

```dart [v0]
final schema = Validasi.string().custom((value, fail) {
  return value.startsWith('SKU-') || fail('Invalid SKU');
});
```

```dart [v1]
final schema = Validasi.string([
  Rules.inline<String>(
    (value) => value != null && value.startsWith('SKU-'),
    message: 'Invalid SKU',
  ),
]);
```

:::

For reusable rules, extend `Rule<T>` (sync) or `AsyncRule<T>` (async) and implement
`apply` / `applyAsync`; see [Custom Rules](/advanced/custom-rule).

## Async validation

v0's `tryParseAsync` / `parseAsync` become `validateAsync`. Async rules are explicit:
`Rules.inlineAsync`, `Rules.transformAsync`, `AsyncConditionalField`, or a custom `AsyncRule<T>`.

::: code-group

```dart [v0]
final result = await schema.tryParseAsync(value);
```

```dart [v1]
final result = await schema.validateAsync(value);
```

:::

Calling sync `validate()` on a pipeline containing an async rule throws a `StateError`.

## Flutter form helpers

The v0 `FieldValidator` / `GroupValidator` helpers are gone. Use the companion packages:

- `validasi_ui` provides `ValidasiForm`, `ValidasiFormField`, `ValidasiTextField`, and
  `ValidasiFormController` for Flutter forms.
- `validasi_annotation` + `validasi_gen` generate typed `XFields` and schemas so the form and
  model stay in sync.

See [Form Management](/companion/form-management/overview) and
[Code Generation](/companion/generator/overview) for the v1 patterns.

## Removed APIs

- `parse` / `parseAsync` throwing variants: use `validate` / `validateAsync` and inspect the result.
- `tryParse` / `tryParseAsync`: replaced by `validate` / `validateAsync`.
- `ValidasiResult.value`: replaced by `ValidasiResult.data`.
- `Validasi.object`, `Validasi.array`, `Validasi.generic`, `Validasi.date`: replaced by
  `Validasi.map`, `Validasi.list`, `Validasi.any`, and rules for the latter.
- Validator chaining (`.minLength(...).email()`): replaced by an explicit rule list.
- `FieldError`: replaced by `ValidationError`, with a list-based `path`.

## Checklist

1. Replace fluent validator chains with `Validasi.*([Rules...])`.
2. Add `Rules.required<T>()` where null must be rejected; `Rules.nullable<T>()` where it must pass.
3. Replace `tryParse` with `validate`, `value` with `data`, and update error-path handling.
4. Move object/array schemas to `Validasi.map` / `Validasi.list` with `FieldRules` and iterable rules.
5. Move input conversion to `.withPreprocess(...)`; keep normalization in `Rules.transform`.
6. Replace custom callbacks with `Rules.inline` or a `Rule<T>` subclass.
7. For Flutter forms, move from `FieldValidator` / `GroupValidator` to `validasi_ui`.
