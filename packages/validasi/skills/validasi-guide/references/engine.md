# The Engine, Preprocessing & Dynamic Input

Every `Validasi.*` builder returns a `ValidasiEngine<T, TInput>`. Understanding the engine explains
transform vs. preprocess, dynamic input, and the synthetic errors you may see.

## Dual generics

```dart
class ValidasiEngine<T, TInput> { ... }
```

- `T` — the validated **output** type (what `data` holds, what rules see).
- `TInput` — the type `validate(...)` **accepts**. Builders start with `TInput == T`.

`withPreprocess` is what makes `TInput` differ from `T`.

## The pipeline

`validate(value)` runs, in order:

1. **Preprocess** (optional) — convert raw input into `T`. On failure, returns a `Preprocess` error.
2. **Type check** — verify the value is `T?`. On mismatch, returns a `TypeCheck` error
   (`Expected type $T, got ...`). This is what keeps `dynamic` input safe at runtime.
3. **Rule loop** — run rules in declared order. Each rule gets the current `T?` value and the mutable
   `ValidationState`; its return value feeds the next rule. Rules with `runOnNull == false` are
   skipped on null; `state.isStopped = true` ends the loop early.
4. **Build result** — return `ValidasiResult<T>(isValid, data, errors)`.

`validateAsync` runs the same stages but uses the async rule path; container rules (`hasFields`,
`forEach`, `allValues`, `anyOf`) support async children. Preprocess itself stays synchronous.

## Transform vs. preprocess

Both mutate the value, at different stages:

| Goal | Use | Stage |
|------|-----|-------|
| Normalize a value already of type `T` (trim, lowercase) | `Rules.transform<T>(...)` | inside the rule loop (step 3) |
| Parse/convert raw input into `T` | `withPreprocess(...)` | before type check (step 1) |

`withPreprocess` also tightens the *input* type at compile time:

```dart
final ageSchema = Validasi.number<int>([
  Rules.number.moreThanEqual(0),
]).withPreprocess((String value) => int.parse(value));

ageSchema.validate('25'); // OK — validate() now accepts String
// ageSchema.validate(25); // compile-time error
```

Signature: `withPreprocess<TNextInput>(TNextInput input) => T, {String? message}`. It returns a **new**
engine `ValidasiEngine<T, TNextInput>` carrying the same rules — it doesn't mutate the original.

## Dynamic input

When the input type is genuinely unknown at compile time, two options — prefer preprocess:

```dart
// Preferred: explicit conversion, compile-time-safe call site
final a = Validasi.number<int>([Rules.number.moreThan(0)])
    .withPreprocess((String s) => int.parse(s));
a.validate('42'); // OK

// Escape hatch: accept anything, rely on the runtime TypeCheck
import 'package:validasi/engine.dart'; // ValidasiEngine lives here, not in validasi.dart

final b = ValidasiEngine<int, dynamic>(rules: [Rules.number.moreThan(0)]);
b.validate(42);   // OK
b.validate('42'); // fails with a TypeCheck error (no preprocess to convert it)
```

Two things to get right when constructing an engine directly:

- Import `package:validasi/engine.dart` — `ValidasiEngine` is not exported by `validasi.dart` or
  `rules.dart`.
- The constructor takes a **named** `rules:` parameter: `ValidasiEngine<int, dynamic>(rules: [...])`,
  not a positional list. (This is also how you'd instantiate an engine directly in a test.)

Reserve the direct-engine form for truly dynamic callers; the `Validasi.*` builders plus
`withPreprocess` cover almost everything with better ergonomics.
