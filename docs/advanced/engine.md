# Understanding the Validasi Engine

The Validasi engine is the core component that orchestrates the validation process. This guide provides a deep dive into how the engine processes data, applies transformations, executes rules, and manages validation flow.

## Engine Architecture

The `ValidasiEngine<T, TInput>` is a dual-generic engine responsible for:
1. **Input type tracking**: Accepting specified input type (`TInput`)
2. **Preprocessing**: Transforming raw input into the expected output type (`T`)
3. **Type checking**: Ensuring type safety
4. **Rule execution**: Running validation rules sequentially
5. **Context management**: Maintaining validation state
6. **Result generation**: Producing structured validation results
7. **Caching**: Optimizing repeated validations

**Type Parameters:**
- `T` (output type): The validated data type after rules are applied
- `TInput` (input type, defaults to `T`): The type accepted by `validate()`

When `TInput ≠ T`, the engine enforces preprocessing to convert input to output type.

## Validation Pipeline

When you call `validate()`, the engine executes a multi-stage pipeline:

```
Input Value
    ↓
┌───────────────┐
│ Cache Lookup  │ ← Check if already validated
└───────┬───────┘
        ↓ (miss)
┌───────────────┐
│  Preprocess   │ ← Transform raw input to type T
└───────┬───────┘
        ↓
┌───────────────┐
│  Type Check   │ ← Verify value is T or T?
└───────┬───────┘
        ↓
┌───────────────┐
│ Rule Loop     │ ← Execute each rule sequentially
│  - runOnNull? │
│  - apply()    │
│  - stopped?   │
└───────┬───────┘
        ↓
┌───────────────┐
│ Build Result  │ ← Create ValidasiResult<T>
└───────┬───────┘
        ↓
┌───────────────┐
│ Cache Store   │ ← Store result for future lookups
└───────┬───────┘
        ↓
   Return Result
```

## Stage 1: Cache Lookup

Before running validation, the engine checks if this input was validated before.

```dart
final cacheKey = cacheEnabled ? computeCacheKey(originalInput) : null;
if (cacheKey != null && cacheEnabled) {
  final cached = EngineCache.get(this, cacheKey);
  if (cached != null) {
    return cached as ValidasiResult<T>;
  }
}
```

**Key Points**:
- Cache lookup happens with the **original input** before preprocessing
- If cache hit, entire pipeline is skipped
- Cache is enabled by default (`cacheEnabled: true`)

**Example**:
```dart
final schema = ValidasiEngine<int, int>(rules: [MoreThan(0)]);

// First call: full pipeline
final result1 = schema.validate(5);

// Second call: cache hit, immediate return
final result2 = schema.validate(5);
```

**Typed Input Example (with withPreprocess):**
```dart
// Accept String input, validate as int
final schema = ValidasiEngine<int, String>(
  rules: [MoreThan(0)],
).withPreprocess(
  ValidasiTransformation<String, int>((s) => int.parse(s)),
);

final result = schema.validate('42'); // String input, cached by original '42'
```

## Stage 2: Preprocessing

Preprocessing transforms the raw input into the expected type `T`. This is useful for type conversion or data normalization.

```dart
if (preprocess != null) {
  final result = preprocess!.tryTransform(value);
  if (!result.isValid) {
    return ValidasiResult<T>.error(
      ValidationError(
        rule: 'Preprocess',
        message: 'Failed to preprocess value',
        details: {
          'exception': result.error?.toString() ?? 'Unknown error',
        },
      ),
    );
  }
  value = result.data;
}
```

**Key Points**:
- Preprocessing runs **before** type checking
- Preprocessing failures create a validation error with rule name `'Preprocess'`
- Transformed value is used for subsequent stages

**Example**:
```dart
// Convert string to int before validation
final schema = ValidasiEngine<int, int>(
  rules: [MoreThan(0)],
).withPreprocess(
  ValidasiTransformation<String, int>((s) => int.parse(s)),
);

// Input: "42" (String)
// After preprocess: 42 (int)
// Then: validate against rules
final result = schema.validate("42");
print(result.isValid); // true
print(result.data);    // 42
```

### Adding Preprocessing

Use `withPreprocess()` to add preprocessing to an existing engine. The returned engine's `validate()` method will accept the input type specified in the transformation:

```dart
final baseEngine = ValidasiEngine<int, int>(
  rules: [MoreThan(0), LessThan(100)],
);

// withPreprocess returns ValidasiEngine<int, String>
final engineWithPreprocess = baseEngine.withPreprocess(
  ValidasiTransformation<String, int>((s) => int.parse(s)),
);

// Now accepts String input at compile time
engineWithPreprocess.validate("50"); // OK: String input
engineWithPreprocess.validate(50);   // ERROR: int is not String
```

## Stage 3: Type Checking

After preprocessing, the engine verifies the transformed value matches output type `T`:

```dart
if (value is! T?) {
  return ValidasiResult<T>.error(ValidationError(
    rule: 'TypeCheck',
    message: 'Expected type $T, got ${value.runtimeType}',
    details: {'value': value},
  ));
}
```

**Key Points**:
- Type check happens **after** preprocessing
- The check is `T?` (nullable) to allow null values
- Type errors create a validation error with rule name `'TypeCheck'`
- Validation stops immediately on type mismatch

**Example**:
```dart
final schema = ValidasiEngine<int, int>(rules: [MoreThan(0)]);

// Type mismatch: expects int, got String
final result = schema.validate("hello");
print(result.isValid); // false
print(result.errors.first.rule); // 'TypeCheck'
```

## Stage 4: Context Creation

The engine creates a `ValidationContext<T>` to manage validation state:

```dart
final context = ValidationContext(value: value);
```

The context provides:
- `value`: Current value being validated (mutable)
- `errors`: List of validation errors
- `isStopped`: Flag to stop rule execution
- Methods: `setValue()`, `addError()`, `stop()`, `requireValue`

**Example**:
```dart
// Context is created internally, but rules interact with it:
class CustomRule extends Rule<String> {
  @override
  void apply(ValidationContext<String> context) {
    // Access current value
    final value = context.value;
    
    // Add error
    context.addError(ValidationError(
      rule: 'CustomRule',
      message: 'Validation failed',
    ));
    
    // Transform value
    context.setValue(value?.toUpperCase());
    
    // Stop further validation
    context.stop();
  }
}
```

## Stage 5: Rule Loop

The engine iterates through all rules and applies them sequentially:

```dart
for (final rule in rules ?? <Rule<T>>[]) {
  // Skip null values unless rule explicitly handles them
  if (context.value == null && !rule.runOnNull) {
    continue;
  }

  // Apply the rule
  rule.apply(context);

  // Stop if requested
  if (context.isStopped) {
    break;
  }
}
```

### Rule Execution Order

Rules execute in the order they're defined:

```dart
final schema = ValidasiEngine<String, String>(
  rules: [
    MinLength(5),      // 1st: Check minimum length
    MaxLength(20),     // 2nd: Check maximum length
    Transform((s) => s?.trim()), // 3rd: Transform
    MinLength(3),      // 4th: Check trimmed length
  ],
);
```

**Order matters**! Transformations affect subsequent validations:

```dart
final schema = ValidasiEngine<String, String>(
  rules: [
    MinLength(10),                      // Checks original length
    Transform((s) => s?.trim()),        // Removes whitespace
    MaxLength(5),                       // Checks trimmed length
  ],
);

// "   hi   " → original length 8 (fails MinLength)
// But would pass after trim
```

### The `runOnNull` Check

Before applying each rule, the engine checks if the value is null:

```dart
if (context.value == null && !rule.runOnNull) {
  continue; // Skip this rule
}
```

**Rules with `runOnNull = true`**:
- `Required`: Must check null to add error
- `Nullable`: Allows null values
- `Transform`: May transform null to non-null

**Rules with `runOnNull = false`** (default):
- All type-specific rules (string, number, list, map)
- These assume a non-null value exists

**Example**:
```dart
final schema = ValidasiEngine<String, String>(
  rules: [
    Nullable(),        // runOnNull = true → executes
    MinLength(5),      // runOnNull = false → skipped if null
  ],
);

// Value is null
schema.validate(null); // Valid! MinLength skipped
```

### Context Value Changes

Rules can modify the value during validation:

```dart
final schema = ValidasiEngine<String, String>(
  rules: [
    Transform((s) => s?.toUpperCase()),  // Changes value
    MinLength(5),                        // Validates transformed value
  ],
);

final result = schema.validate("hello");
print(result.data); // "HELLO" (transformed)
```

**Flow**:
1. Initial value: `"hello"`
2. After Transform: `"HELLO"` (context.value changed)
3. MinLength validates: `"HELLO"` (5 chars, passes)

### Stopping Validation

Rules can stop the validation chain using `context.stop()`:

```dart
class StopOnError extends Rule<String> {
  @override
  void apply(ValidationContext<String> context) {
    if (context.requireValue.isEmpty) {
      context.addError(ValidationError(
        rule: 'StopOnError',
        message: 'Empty value',
      ));
      context.stop(); // Prevents further rules from running
    }
  }
}

final schema = ValidasiEngine<String, String>(
  rules: [
    StopOnError(),     // Stops if empty
    MinLength(5),      // Won't execute if stopped
    MaxLength(20),     // Won't execute if stopped
  ],
);

schema.validate(""); // Only StopOnError executes
```

**When to stop**:
- Critical validation failure (no point continuing)
- Performance optimization (skip expensive checks)
- Error cascades (prevent redundant errors)

## Stage 6: Result Generation

After all rules execute (or stop), the engine creates the result:

```dart
final ValidasiResult<T> result = ValidasiResult<T>(
  isValid: context.errors.isEmpty,
  data: context.value,
  errors: context.errors,
);
```

**Result properties**:
- `isValid`: `true` if no errors were added
- `data`: Final value (may be transformed by rules)
- `errors`: List of all validation errors

**Example**:
```dart
final schema = ValidasiEngine<String, String>(
  rules: [
    Required(),
    MinLength(5),
    MaxLength(10),
  ],
);

final result = schema.validate("hi");

print(result.isValid);        // false
print(result.data);           // "hi"
print(result.errors.length);  // 1 (MinLength failed)
print(result.errors.first.rule); // "MinLength"
```

## Stage 7: Cache Storage

If caching is enabled, the result is stored for future lookups:

```dart
if (cacheKey != null && cacheEnabled) {
  EngineCache.set(this, cacheKey, result);
}
```

**Key Points**:
- Cache stores the **final result** (including transformed value and errors)
- Cache key is computed from **original input** (before preprocessing)
- Cache is per-engine-instance

**Example**:
```dart
final schema = ValidasiEngine<String, String>(
  rules: [Transform((s) => s?.toUpperCase()), MinLength(5)],
);

// First validation: full pipeline
final result1 = schema.validate("hello");
print(result1.data); // "HELLO"

// Second validation: cache hit
final result2 = schema.validate("hello");
print(result2.data); // "HELLO" (from cache, transform not re-run)
```

## Complete Example: Engine Flow

Let's trace a complete validation through all stages:

```dart
final schema = ValidasiEngine<int, int>(
  rules: [
    Required(),
    MoreThan(0),
    LessThan(100),
    Transform((n) => n! * 2),
    LessThan(150),
  ],
);

final result = schema.validate("42");
```

**Execution trace**:

1. **Cache Lookup**: No cached result for `"42"`

2. **Preprocess**: 
   - Input: `"42"` (String)
   - Transform: `int.parse("42")`
   - Output: `42` (int)

3. **Type Check**:
   - Check: `42 is int?` → ✓ true

4. **Context Creation**:
   - `context.value = 42`
   - `context.errors = []`

5. **Rule Loop**:
   - **Required**: value = 42 (not null) → passes
   - **MoreThan(0)**: 42 > 0 → ✓ passes
   - **LessThan(100)**: 42 < 100 → ✓ passes
   - **Transform**: 42 * 2 = 84 → `context.value = 84`
   - **LessThan(150)**: 84 < 150 → ✓ passes

6. **Result Generation**:
   - `isValid = true` (no errors)
   - `data = 84` (transformed)
   - `errors = []`

7. **Cache Storage**: Store result for `"42"`

8. **Return**: `ValidasiResult<int>(isValid: true, data: 84)`

## Advanced Patterns

### Conditional Rule Application

Use `Having` to conditionally apply rules:

```dart
final schema = ValidasiEngine<String, String>(
  rules: [
    Having(
      (value) => value?.startsWith('@') ?? false,
      [MinLength(5)], // Only if starts with '@'
    ),
  ],
);

schema.validate("@hi");    // Fails MinLength
schema.validate("hi");     // Passes (Having condition false)
```

### Error Accumulation

The engine accumulates all errors, not just the first:

```dart
final schema = ValidasiEngine<String, String>(
  rules: [
    MinLength(5),
    MaxLength(2),  // Changed to 2
    InlineRule((s) => s?.contains('@') ?? false, message: 'Must contain @'),
  ],
);

final result = schema.validate("hi");

// Multiple rules fail:
print(result.errors.length); // 2 (MinLength and InlineRule)
```

### Preprocessing for Normalization

Use preprocessing to normalize data before validation:

```dart
// Normalize whitespace before validation
final schema = ValidasiEngine<String, String>(
  rules: [
    MinLength(3),
    MaxLength(20),
  ],
).withPreprocess(
  ValidasiTransformation<String, String>((input) {
    return input.trim().toLowerCase();
  }),
);

// "  HELLO  " → "hello" → validates as "hello"
final result = schema.validate("  HELLO  ");
print(result.data); // "hello"
```

### Early Termination for Performance

Stop validation early to avoid expensive checks:

```dart
final schema = ValidasiEngine<String, String>(
  rules: [
    InlineRule((s) {
      if (s == null || s.isEmpty) {
        return false; // Failed
      }
      return true;
    }, message: 'Required'),
    
    InlineRule((s) {
      // Expensive check only if previous passed
      return expensiveValidation(s);
    }),
  ],
);
```

Or use explicit stopping:

```dart
class RequiredWithStop extends Rule<String> {
  @override
  bool get runOnNull => true;

  @override
  void apply(ValidationContext<String> context) {
    if (context.value == null || context.value!.isEmpty) {
      context.addError(ValidationError(
        rule: 'Required',
        message: 'Field is required',
      ));
      context.stop(); // Skip expensive rules
    }
  }
}
```

