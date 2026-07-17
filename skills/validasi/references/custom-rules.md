# Custom Rules

When no built-in rule fits — or the same `inline` check keeps reappearing — write a class. A custom
rule is reusable, testable, and (unlike `Rules.inline`) can manipulate `ValidationState` to stop the
chain or attach structured `details`.

## Imports

`Rule`, `AsyncRule`, `ValidationState`, and `ValidationError` come from `rules.dart` — **not** from
`validasi.dart` alone. In a typical file you already import both, which is enough:

```dart
import 'package:validasi/validasi.dart'; // Validasi.*, ValidasiResult, ValidationError
import 'package:validasi/rules.dart';    // Rules.*, Rule, AsyncRule, ValidationState
```

## Anatomy of a `Rule<T>`

Extend `Rule<T>`, implement `apply`, return the (possibly modified) value, and report failures via
`state.addError`. Use a `const` constructor forwarding `{super.message}` so callers can override the
message, and always fall back with `message ?? '<default>'`.

```dart
class MinAge extends Rule<int> {
  const MinAge(this.minAge, {super.message});

  final int minAge;

  @override
  int? apply(int? value, ValidationState state) {
    if (value == null) return null;
    if (value < minAge) {
      state.addError(ValidationError(
        rule: 'MinAge',
        message: message ?? 'Age must be at least $minAge',
        details: {'minAge': minAge.toString()}, // for logs / programmatic handling
      ));
    }
    return value;
  }
}

final schema = Validasi.number<int>([const MinAge(18)]);
```

`ValidationError` fields: `rule` (String, required), `message` (String, required),
`path` (`List<String>?`, set automatically by container rules like `hasFields`/`forEach`), and
`details` (`Map<String, dynamic>?`). Keep `message` user-facing; keep `rule`/`details` for diagnostics.

## `runOnNull`

By default `runOnNull` is `false`, so the rule loop skips your rule when the value is `null` (that's
why the `MinAge` null-guard is rarely hit in practice). Override it as a getter only when the rule
must *see* null — to require it, to transform it, or to supply a default:

```dart
class DefaultValue<T> extends Rule<T> {
  const DefaultValue(this.defaultValue, {super.message});

  final T defaultValue;

  @override
  bool get runOnNull => true; // must run on null to substitute

  @override
  T? apply(T? value, ValidationState state) => value ?? defaultValue;
}
```

## `ValidationState`

The mutable state threaded through the rule loop exposes:

- `addError(ValidationError error)` — record a failure (a rule can add several).
- `isStopped` — a settable `bool`. Set `state.isStopped = true` to halt the chain so later rules
  don't run (useful after a fatal error like "value is required").
- `isValid` (`bool get`) and `errors` (`List<ValidationError> get`) — the accumulated state so far.

```dart
class StopIfEmpty extends Rule<String> {
  const StopIfEmpty({super.message});

  @override
  bool get runOnNull => true;

  @override
  String? apply(String? value, ValidationState state) {
    if (value == null || value.isEmpty) {
      state.addError(ValidationError(
        rule: 'StopIfEmpty',
        message: message ?? 'Value is required',
      ));
      state.isStopped = true; // skip the remaining rules
    }
    return value;
  }
}
```

## Transforming values

`apply` returns the value passed to the next rule, so a custom rule can normalize in place:

```dart
class TrimString extends Rule<String> {
  const TrimString({super.message});

  @override
  String? apply(String? value, ValidationState state) => value?.trim();
}
```

For most normalization, prefer `Rules.transform<T>((v) => ...)` — reach for a class only when you
also need reuse, `details`, or chain control.

## Async custom rules

For I/O (DB lookups, HTTP), extend `AsyncRule<T>` and override `applyAsync`. Its `apply` throws a
`StateError`, so the schema **must** be run with `validateAsync()`.

```dart
class UniqueEmail extends AsyncRule<String> {
  const UniqueEmail(this.repository, {super.message});

  final UserRepository repository;

  @override
  Future<String?> applyAsync(String? value, ValidationState state) async {
    if (value == null) return null;
    if (await repository.isEmailTaken(value)) {
      state.addError(ValidationError(
        rule: 'UniqueEmail',
        message: message ?? 'Email is already registered',
      ));
    }
    return value;
  }
}

final schema = Validasi.string([
  Rules.required(),
  UniqueEmail(repository),
]);
final result = await schema.validateAsync('user@example.com');
```

Sync rules run fine inside an async pipeline (their inherited `applyAsync` delegates to `apply`), so
you can freely mix built-in rules with an `AsyncRule`.

## Checklist

1. Extend `Rule<T>` (async: `AsyncRule<T>`), with a `const` constructor and `{super.message}`.
2. Implement `apply` (async: `applyAsync`); return the value, add errors via `state.addError`.
3. Override `runOnNull => true` only if the rule must handle null.
4. Default every message with `message ?? '<default>'`; add `details` for diagnostics.
5. Use `state.isStopped = true` to stop the chain when continuing makes no sense.
6. Run async pipelines with `validateAsync()`.
