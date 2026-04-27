# Understanding the Validasi Engine

The Validasi engine is the core component that orchestrates preprocessing, type checking, rule execution, and result creation.

## Engine Architecture

`ValidasiEngine<T, TInput>` uses dual generics:

- `T`: validated output type
- `TInput`: accepted input type for `validate()`

By default, schema builders use `TInput = T`. When you call `withPreprocess`, the returned engine can accept a different input type.

## Validation Pipeline

When you call `validate()`, the engine runs this sequence:

```text
Input Value
    ↓
Preprocess (optional)
    ↓
Type Check (against T)
    ↓
Rule Loop
    ↓
Build Result
    ↓
Return ValidasiResult<T>
```

## Stage 1: Preprocessing

Preprocessing runs first (if configured) and is responsible for converting input into `T`.

```dart
final schema = Validasi.number<int>([
  NumberRules.moreThan(0),
]).withPreprocess(
  ValidasiTransformation<String, int>((input) => int.parse(input)),
);

final result = schema.validate('42');
print(result.data); // 42
```

If preprocessing throws or fails, validation returns a `Preprocess` error.

## Stage 2: Type Check

After preprocessing, engine verifies the value matches `T` (nullable-aware check).

```dart
if (processedValue is! T?) {
  return ValidasiResult<T>.error(
    ValidationError(
      rule: 'TypeCheck',
      message: 'Expected type $T, got ${processedValue.runtimeType}',
      details: {'value': processedValue},
    ),
  );
}
```

This keeps dynamic inputs safe at runtime.

## Stage 3: Rule Loop

Rules run in declaration order. Each rule receives a mutable `ValidationContext<T>`.

```dart
final schema = Validasi.string([
  Transform((s) => s?.trim()),
  StringRules.minLength(3),
]);
```

Important behavior:

- Rules can modify value via `context.setValue(...)`
- Rules can add errors via `context.addError(...)`
- Rules can stop further execution with `context.stop()`
- Rules with `runOnNull = false` are skipped on null values

## Stage 4: Result Build

The engine returns a `ValidasiResult<T>`:

```dart
final result = schema.validate(input);

if (result.isValid) {
  print(result.data);
} else {
  for (final error in result.errors) {
    print('${error.rule}: ${error.message}');
  }
}
```

## withPreprocess Type Behavior

`withPreprocess` changes the accepted input type at compile time.

```dart
final base = Validasi.number<int>([
  NumberRules.moreThanEqual(0),
]);

final fromString = base.withPreprocess(
  ValidasiTransformation<String, int>((s) => int.parse(s)),
);

fromString.validate('10'); // OK
// fromString.validate(10); // Compile-time error
```

## Dynamic Input Strategy

If input is unknown at compile time:

- Use `ValidasiEngine<T, dynamic>` when callers are truly dynamic
- Prefer `withPreprocess` with explicit input type when possible

This gives the best balance of static safety and runtime validation.
