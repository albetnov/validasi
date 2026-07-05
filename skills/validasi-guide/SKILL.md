---
name: validasi-guide
description: Comprehensive usage guide for the validasi core validation library. Use when the user asks how to validate data, build schemas, use built-in rules, handle errors, write custom rules, or understand the validation engine in Dart/Flutter.
---

# Validasi Core Guide

This skill covers the core `validasi` package: building schemas, applying rules, handling results, and extending the library with custom rules.

## When to Use This Skill

Use this skill when the user:

- Asks how to validate strings, numbers, lists, maps, or custom types in Dart
- Wants to understand `Validasi`, `Rules`, `ValidasiResult`, or `ValidationError`
- Needs help with transformations, preprocessing, or type-safe input handling
- Wants to write a custom validation rule
- Asks about async validation or the validation pipeline
- Needs examples of schema composition or nested validation

## Core Imports

```dart
import 'package:validasi/validasi.dart'; // Schema builders and engine
import 'package:validasi/rules.dart';    // Rule factories
```

For custom rules, also import the engine internals:

```dart
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';
```

## The Validation Flow

Every validation follows the same flow:

1. Define a schema with `Validasi.<type>([...rules])`
2. Call `validate(value)` or `validateAsync(value)`
3. Inspect the `ValidasiResult<T>`

```dart
final nameSchema = Validasi.string([
  Rules.string.minLength(2),
  Rules.string.maxLength(50),
]);

final result = nameSchema.validate('Alice');

if (result.isValid) {
  print(result.data); // Alice
} else {
  for (final error in result.errors) {
    print('${error.rule}: ${error.message}');
  }
}
```

## Schema Types

### String

```dart
final schema = Validasi.string([
  Rules.string.minLength(3),
  Rules.string.maxLength(20),
  Rules.string.email(),
]);
```

Common rules: `minLength`, `maxLength`, `oneOf`, `startsWith`, `endsWith`, `contains`, `regex`, `lowercase`, `uppercase`, `alpha`, `alphanumeric`, `numeric`, `uuid`, `ulid`, `ip`, `ipv4`, `ipv6`, `url`, `email`.

### Number

```dart
final ageSchema = Validasi.number<int>([
  Rules.number.moreThanEqual(0),
  Rules.number.lessThan(150),
]);
```

`T` must extend `num`. Use `int`, `double`, or `num` explicitly.

Common rules: `moreThan`, `moreThanEqual`, `lessThan`, `lessThanEqual`, `between`, `finite`, `integer`, `decimal`, `positive`, `negative`, `nonPositive`, `nonNegative`.

### List

```dart
final tagsSchema = Validasi.list<String>([
  Rules.iterable.minLength(1),
  Rules.iterable.maxLength(5),
  Rules.iterable.forEach<String>([
    Rules.string.minLength(2),
    Rules.string.maxLength(20),
  ]),
]);
```

Common rules: `minLength`, `maxLength`, `exactLength`, `isEmpty`, `isNotEmpty`, `contains`, `notContains`, `unique`, `containsAll`, `forEach`.

Use `keySelector` or `equals`/`hasher` with `unique` for object comparisons. Provide `hasher` alongside `equals` for O(N) performance.

### Map

```dart
final userSchema = Validasi.map<dynamic>([
  Rules.map.hasFields({
    'name': FieldRules<String>([
      Rules.string.minLength(2),
    ]),
    'age': FieldRules<int>([
      Rules.number.moreThanEqual(18),
    ]),
  }),
]);
```

`Validasi.map<T>()` validates `Map<String, T>`. Keys must be `String`.

Common rules: `hasFieldKeys`, `hasFields`, `conditionalField`, `conditionalFieldAsync`, `allowedKeys`, `forbiddenKeys`, `minKeys`, `maxKeys`, `allValues`, `requiredAny`, `requiredOneOf`, `requiredAll`, `dependsOn`, `mutuallyExclusive`, `matchesField`.

### Any

```dart
final termsSchema = Validasi.any<bool>([
  Rules.inline<bool>((value) {
    return value == true ? null : 'You must accept the terms';
  }),
]);
```

Use `Validasi.any<T>()` when the type is not covered by specialized builders, for custom domain models, or for maps with non-`String` keys.

## Modifier Rules

Rules that apply across schema types:

- `Rules.nullable<T>()` — allows `null`; skips subsequent rules on null
- `Rules.required<T>()` — requires a non-null value
- `Rules.transform<T>((value) => ...)` — modifies the value before later rules run
- `Rules.transformAsync<T>((value) async => ...)` — async transformation
- `Rules.having<T>([...])` — value must be one of the allowed values
- `Rules.inline<T>((value) => ...)` — custom inline validator returning a message or `null`
- `Rules.inlineAsync<T>((value) async => ...)` — async inline validator
- `Rules.equals<T>(value)` — value must equal the given value
- `Rules.notEquals<T>(value)` — value must not equal the given value
- `Rules.anyOf<T>([[...rules], [...rules]])` — value must satisfy at least one rule set

## Transformations vs Preprocessing

### Use `Transform` for normalization

`Transform` runs inside the rule loop, after type checking. Use it to clean or normalize values that are already the correct type.

```dart
final emailSchema = Validasi.string([
  Rules.transform<String>((value) => value?.trim().toLowerCase()),
  Rules.string.email(),
]);

print(emailSchema.validate('  USER@EXAMPLE.COM  ').data); // user@example.com
```

### Use `withPreprocess` for type conversion

`withPreprocess` converts raw input into the schema type before type checking. It also changes the accepted input type at compile time.

```dart
final ageSchema = Validasi.number<int>([
  Rules.number.moreThanEqual(0),
]).withPreprocess((String value) => int.parse(value));

ageSchema.validate('25'); // OK
// ageSchema.validate(25); // Compile-time error
```

Pipeline order: preprocess → type check → rule loop (including `Transform`) → result.

## Error Handling

`validate()` returns a `ValidasiResult<T>` with:

- `isValid`: whether validation passed
- `data`: the validated/transformed value
- `errors`: list of `ValidationError`

Each `ValidationError` has:

- `rule`: the rule that produced the error
- `message`: human-readable message
- `path`: field path for nested errors
- `details`: optional debug metadata

Default pattern:

```dart
final result = schema.validate(input);

if (result.isValid) {
  use(result.data);
} else {
  for (final error in result.errors) {
    final field = error.path?.join('.') ?? 'root';
    print('[$field] ${error.message} (${error.rule})');
  }
}
```

Group errors by field for UI mapping:

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

## Custom Rules

Extend `Rule<T>` for reusable validation logic:

```dart
class AdultAgeRule extends Rule<int> {
  const AdultAgeRule({super.message});

  @override
  int? apply(int? value, ValidationState state) {
    if (value == null) return null;
    if (value < 18) {
      state.addError(
        ValidationError(
          rule: 'AdultAge',
          message: message ?? 'Age must be at least 18',
        ),
      );
    }
    return value;
  }
}
```

Key conventions:

- Use a `const` constructor with `{super.message}`
- Return the (possibly modified) value
- Add errors via `state.addError(...)`
- Override `runOnNull` only when the rule must see null values (default is `false`)
- Use `message ?? 'default message'` for custom/default messages
- Stop the chain with `state.isStopped = true` when needed

For async rules, extend `AsyncRule<T>` and override `applyAsync()`:

```dart
class UniqueEmailRule extends AsyncRule<String> {
  const UniqueEmailRule(this.repository, {super.message});

  final UserRepository repository;

  @override
  Future<String?> applyAsync(String? value, ValidationState state) async {
    if (value == null) return null;
    if (await repository.isEmailTaken(value)) {
      state.addError(
        ValidationError(
          rule: 'UniqueEmail',
          message: message ?? 'Email is already registered',
        ),
      );
    }
    return value;
  }
}
```

Always use `validateAsync()` when the pipeline contains async rules.

## Async Validation

- Use `validateAsync()` for pipelines containing `AsyncRule`, `inlineAsync`, or `transformAsync`
- Sync rules run through their default `applyAsync()` delegation
- Container rules (`HasFields`, `ForEach`, `AllValues`, `AnyOf`) support async children
- Calling `validate()` on a pipeline with async rules throws `StateError`

```dart
final schema = Validasi.string([
  Rules.required(),
  Rules.inlineAsync((email) async {
    if (email == null) return true;
    return !(await repository.isEmailTaken(email));
  }, message: 'Email is already taken'),
]);

final result = await schema.validateAsync('user@example.com');
```

## Engine Architecture

`ValidasiEngine<T, TInput>` uses dual generics:

- `T`: validated output type
- `TInput`: accepted input type for `validate()`

Default schema builders set `TInput = T`. `withPreprocess` returns an engine with a different `TInput`.

Pipeline stages:

1. Preprocess (optional)
2. Type check against `T`
3. Rule loop
4. Build `ValidasiResult<T>`

For truly dynamic input, use `ValidasiEngine<T, dynamic>`, but prefer `withPreprocess` with an explicit input type when possible.

## Quick Reference

| Task | Approach |
|------|----------|
| Optional string field | `Validasi.string([Rules.nullable<String>(), Rules.string.email()])` |
| Trim and lowercase | `Rules.transform<String>((v) => v?.trim().toLowerCase())` |
| Parse string to int | `Validasi.number<int>([...]).withPreprocess((String s) => int.parse(s))` |
| Validate list items | `Rules.iterable.forEach<T>([...])` |
| Validate map fields | `Rules.map.hasFields({...})` |
| Custom reusable rule | Extend `Rule<T>` |
| Async database check | Extend `AsyncRule<T>` and use `validateAsync()` |
| One-off custom check | `Rules.inline<T>((value) => condition ? null : 'message')` |

See `validasi-best-practices` for idiomatic usage patterns and anti-patterns.
