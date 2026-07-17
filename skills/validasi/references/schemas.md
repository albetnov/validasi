# Schema & Rule Catalog

Complete reference for every schema builder, its rules (with real signatures and options), and the
modifier rules that apply across schemas. All examples assume:

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';
```

## Contents

- [Builders at a glance](#builders-at-a-glance)
- [String — `Rules.string.*`](#string--rulesstring)
- [Number — `Rules.number.*`](#number--rulesnumber)
- [List — `Rules.iterable.*`](#list--rulesiterable)
- [Map — `Rules.map.*`](#map--rulesmap)
- [Any](#any)
- [Modifier rules](#modifier-rules)

## Builders at a glance

Each builder takes an **optional positional** `List<Rule<...>>` and returns a
`ValidasiEngine<Out, In>` (with `In == Out` until `withPreprocess` changes the input type).

```dart
Validasi.string([...])            // Rule<String>          — not generic
Validasi.number<T extends num>()  // Rule<T>               — T constrained to num
Validasi.list<T>([...])           // Rule<List<T>>
Validasi.map<T>([...])            // Rule<Map<String, T>>  — keys are always String
Validasi.any<T>([...])            // Rule<T>               — no constraint on T
```

## String — `Rules.string.*`

All string rules take an optional `{String? message}` unless noted. None are generic.

| Rule | Signature | Checks |
|------|-----------|--------|
| `minLength` | `minLength(int len, {message})` | at least `len` characters |
| `maxLength` | `maxLength(int len, {message})` | at most `len` characters |
| `oneOf` | `oneOf(List<String> values, {message})` | value is one of `values` |
| `startsWith` | `startsWith(String prefix, {message})` | starts with `prefix` |
| `endsWith` | `endsWith(String suffix, {message})` | ends with `suffix` |
| `contains` | `contains(String substring, {message})` | contains `substring` |
| `regex` | `regex(String pattern, {message})` | matches the pattern |
| `lowercase` | `lowercase({message})` | only lowercase characters |
| `uppercase` | `uppercase({message})` | only uppercase characters |
| `alpha` | `alpha({message})` | only `a-z A-Z` |
| `alphanumeric` | `alphanumeric({message})` | only `a-z A-Z 0-9` |
| `numeric` | `numeric({message})` | only digits `0-9` |
| `uuid` | `uuid({List<int> versions = const [4, 7], message})` | valid UUID of an allowed version |
| `ulid` | `ulid({message})` | valid ULID |
| `ip` | `ip({message})` | valid IPv4 or IPv6 |
| `ipv4` | `ipv4({message})` | valid IPv4 |
| `ipv6` | `ipv6({message})` | valid IPv6 |
| `url` | `url({bool requireScheme = true, bool requireHost = true, bool httpsOnly = false, message})` | valid URL |
| `email` | `email({bool allowTopLevelDomain, bool allowInternational, List<String>? domains, message})` | valid email |

```dart
final workEmail = Validasi.string([
  Rules.string.email(domains: ['company.com', 'company.org']),
]);
print(workEmail.validate('user@company.com').isValid); // true
print(workEmail.validate('user@gmail.com').isValid);   // false

final v4Only = Validasi.string([Rules.string.uuid(versions: [4])]);
final httpsOnly = Validasi.string([Rules.string.url(httpsOnly: true)]);
```

## Number — `Rules.number.*`

Comparison rules are generic `<T extends num>`; `finite`/`integer`/`decimal` are not.

| Rule | Signature | Checks |
|------|-----------|--------|
| `moreThan` | `moreThan<T extends num>(T min, {message})` | strictly `> min` |
| `moreThanEqual` | `moreThanEqual<T extends num>(T min, {message})` | `>= min` |
| `lessThan` | `lessThan<T extends num>(T max, {message})` | strictly `< max` |
| `lessThanEqual` | `lessThanEqual<T extends num>(T max, {message})` | `<= max` |
| `between` | `between<T extends num>(T min, T max, {message})` | inclusive range `[min, max]` |
| `finite` | `finite({message})` | not `NaN`/`Infinity` |
| `integer` | `integer({message})` | a finite integer value |
| `decimal` | `decimal({message})` | a finite double value |
| `positive` | `positive<T extends num>({message})` | `> 0` |
| `negative` | `negative<T extends num>({message})` | `< 0` |
| `nonPositive` | `nonPositive<T extends num>({message})` | `<= 0` |
| `nonNegative` | `nonNegative<T extends num>({message})` | `>= 0` |

```dart
final priceSchema = Validasi.number<double>([
  Rules.number.decimal(),
  Rules.number.positive(),
  Rules.number.lessThanEqual(9999.99),
]);
print(priceSchema.validate(149.99).isValid); // true
```

## List — `Rules.iterable.*`

For `Validasi.list<T>([...])`. Every rule is generic `<T>`.

| Rule | Signature | Checks |
|------|-----------|--------|
| `minLength` | `minLength<T>(int len, {message})` | at least `len` items |
| `maxLength` | `maxLength<T>(int len, {message})` | at most `len` items |
| `exactLength` | `exactLength<T>(int len, {message})` | exactly `len` items |
| `isEmpty` | `isEmpty<T>({message})` | list is empty |
| `isNotEmpty` | `isNotEmpty<T>({message})` | list is non-empty |
| `contains` | `contains<T>(T element, {Object? Function(T)? keySelector, message})` | contains `element` |
| `notContains` | `notContains<T>(T element, {keySelector, message})` | does not contain `element` |
| `unique` | `unique<T>({bool Function(T, T)? equals, int Function(T)? hasher, keySelector, message})` | all items unique |
| `containsAll` | `containsAll<T>(List<T> elements, {keySelector, message})` | contains all of `elements` |
| `forEach` | `forEach<T>(List<Rule<T>> rules)` | applies `rules` to each item — **no `message` param** |

`keySelector` extracts a comparable key for object elements (O(k) lookups). For `unique` with custom
equality, always pass `hasher` alongside `equals` — `equals` alone falls back to O(N²).

```dart
final uniqueById = Validasi.list<Map<String, dynamic>>([
  Rules.iterable.unique(
    equals: (a, b) => a['id'] == b['id'],
    hasher: (m) => m['id']?.hashCode ?? 0,
  ),
]);

// Per-item rules — and nest forEach for lists-of-lists
final usernames = Validasi.list<String>([
  Rules.iterable.minLength(1),
  Rules.iterable.forEach<String>([
    Rules.string.minLength(3),
    Rules.string.maxLength(20),
  ]),
]);
```

## Map — `Rules.map.*`

For `Validasi.map<T>([...])`, which validates `Map<String, T>` (keys are always `String`; use
`Validasi.any` for non-`String` keys). Rules are generic `<T>` except `hasFields`/`hasFieldKeys`.
Key-set rules take a **`Set<String>`**, not a `List`.

| Rule | Signature | Checks |
|------|-----------|--------|
| `hasFieldKeys` | `hasFieldKeys<T>(Set<String> keys)` | required keys exist |
| `hasFields` | `hasFields(Map<String, FieldRules<Object?>> fields)` | per-field rules (see below) |
| `conditionalField` | `conditionalField<T>(String field, ConditionalFieldCallback<T> cb)` | contextual check on a field |
| `conditionalFieldAsync` | `conditionalFieldAsync<T>(String field, AsyncConditionalFieldCallback<T> cb)` | async version |
| `allowedKeys` | `allowedKeys<T>(Set<String> keys, {message})` | whitelist: only these keys |
| `forbiddenKeys` | `forbiddenKeys<T>(Set<String> keys, {message})` | blacklist: none of these keys |
| `minKeys` | `minKeys<T>(int min, {message})` | at least `min` keys |
| `maxKeys` | `maxKeys<T>(int max, {message})` | at most `max` keys |
| `allValues` | `allValues<T>(List<Rule<T>> rules)` | applies `rules` to every value — **no `message` param** |
| `requiredAny` | `requiredAny<T>(List<String> fields, {message})` | at least one field present |
| `requiredOneOf` | `requiredOneOf<T>(List<String> fields, {message})` | exactly one present (XOR) |
| `requiredAll` | `requiredAll<T>(List<String> fields, {message})` | if any present, all present |
| `dependsOn` | `dependsOn<T>(String field, String dependsOn, {message})` | if `field` present, `dependsOn` present |
| `mutuallyExclusive` | `mutuallyExclusive<T>(String a, String b, {message})` | not both present |
| `matchesField` | `matchesField<T>(String field, String matches, {bool Function(T, T)? equals, message})` | two fields equal |

`hasFields` takes a `FieldRules<T>([...list of rules...])` per field — **not** a nested `Validasi.*`
schema. Nest maps by putting another `hasFields` inside a `FieldRules<Map<String, dynamic>>([...])`:

```dart
final userSchema = Validasi.map<dynamic>([
  Rules.map.hasFields({
    'name': FieldRules<String>([Rules.string.minLength(2)]),
    'profile': FieldRules<Map<String, dynamic>>([
      Rules.map.hasFields({
        'age': FieldRules<int>([Rules.number.moreThanEqual(0)]),
      }),
    ]),
  }),
]);
```

`conditionalField`'s callback is `String? Function(context, T? value)` — return an error message or
`null`. Read sibling fields via `context.get<R>('key')` (the type arg is optional when `T` is
`dynamic`):

```dart
final orderSchema = Validasi.map<dynamic>([
  Rules.map.conditionalField('address', (context, value) {
    if ((context.get<bool>('isDelivery') ?? false) && value == null) {
      return 'address is required for delivery orders';
    }
    return null;
  }),
]);
```

## Any

`Validasi.any<T>([...])` is the direct form of the underlying engine — use it when no specialized
builder fits: custom domain models, non-`String`-key maps, or bare modifier/inline/custom rules.

```dart
// Non-String-key map via inline
final intKeyMap = Validasi.any<Map<int, String>>([
  Rules.inline<Map<int, String>>(
    (value) => value != null && value.containsKey(1),
    message: 'Map must contain key 1',
  ),
]);

// Either/or without dropping to inline
final flexible = Validasi.any<String>([
  Rules.anyOf([
    [Rules.string.minLength(10)],
    [Rules.string.startsWith('special-')],
  ]),
]);
```

## Modifier rules

Cross-schema rules (top-level `Rules.*`). Prefer explicit generics (`Rules.nullable<String>()`).

| Rule | Signature | Notes |
|------|-----------|-------|
| `nullable` | `nullable<T>()` | allow `null`; later rules skip on null. No `message`. |
| `required` | `required<T>({message})` | require a non-null value |
| `transform` | `transform<T>(T? Function(T? value) fn, {message})` | normalize in-loop; runs on null too |
| `transformAsync` | `transformAsync<T>(Future<T?> Function(T? value) fn, {message})` | async normalize; needs `validateAsync()` |
| `having` | `having<T>(List<T> validValues, {message})` | value must be one of `validValues` |
| `inline` | `inline<T>(bool Function(T? value) validator, {message, name})` | one-off check; return `true` when valid |
| `inlineAsync` | `inlineAsync<T>(Future<bool> Function(T? value) validator, {message, name})` | async one-off; needs `validateAsync()` |
| `equals` | `equals<T>(T expected, {bool Function(T, T)? equals, message})` | value equals `expected` |
| `notEquals` | `notEquals<T>(T unexpected, {bool Function(T, T)? equals, message})` | value differs from `unexpected` |
| `anyOf` | `anyOf<T>(List<List<Rule<T>>> ruleSets, {message})` | satisfy at least one rule set (OR) |

```dart
final username = Validasi.string([
  Rules.nullable<String>(),
  Rules.transform<String>((v) => v?.trim().toLowerCase()), // null-safe under nullable
  Rules.string.minLength(3),
  Rules.string.alphanumeric(),
]);
```

See `custom-rules.md` for writing your own `Rule<T>`/`AsyncRule<T>`, and `engine.md` for the pipeline
and `withPreprocess`.
