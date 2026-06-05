# Transformations

Validasi provides two transformation mechanisms:

- `Transform` modifier rule: changes values inside schema validation.
- `withPreprocess(...)`: converts raw input before type checking and rules.

Use them together when needed, but for different responsibilities.

## 1) Transform Modifier

Use `Transform` when the input type is already correct and you want to normalize data before validation rules.

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

final emailSchema = Validasi.string([
  Rules.transform<String>((value) => value?.trim()),
  Rules.transform<String>((value) => value?.toLowerCase()),
  Rules.string.minLength(5),
]);

final result = emailSchema.validate('  USER@EXAMPLE.COM  ');
print(result.data); // "user@example.com"
```

How it works:

- Runs as part of rule execution.
- The transformed value is passed to subsequent rules.
- The final transformed value is returned in `result.data`.
- `Transform` runs on null values too, so null-safe code is recommended.

## 2) Preprocess Transformation

Use `withPreprocess` when raw input may be a different type than the schema expects. The key benefit: `validate()` parameter type is updated at compile time to match the preprocess input type.

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';
import 'package:validasi/transformer.dart';

// Create base schema validating int
final ageSchema = Validasi.number<int>([
  Rules.number.moreThanEqual(0),
]);

// Add preprocessing: accepts String, converts to int
final ageSchemaWithPreprocess = ageSchema.withPreprocess(
  ValidasiTransformation<String, int>((value) => int.parse(value)),
);

// Now validate() accepts String, not int
print(ageSchemaWithPreprocess.validate('42').data); // 42
```

How it works:

- Preprocessing runs **before type checking**.
- `withPreprocess()` returns a new engine where `validate()` accepts the transformation input type.
- If preprocessing fails, validation fails with a `Preprocess` error.
- If preprocessing succeeds but returns the wrong type, validation fails at type check.
- Type enforcement is compile-time: passing wrong input type causes compiler error.

## Execution Order

Validation flow is:

1. `withPreprocess(...)` transformation (if configured)
2. Type check against schema type
3. Rule execution, including `Rules.transform<String>(...)`
4. Final `ValidasiResult`

This means:

- Use preprocess for parsing/conversion into the expected type.
- Use `Transform` for cleanup/normalization after conversion.

## Proper Usage Guidelines

- Use preprocess to parse external input: JSON strings, query params, form strings.
- Use `Transform` for schema-level normalization: trim, lowercase, formatting.
- Keep transformations pure: return transformed data, avoid side effects.
- Put `Transform` before other validation rules that depend on normalized values.
- Keep transforms null-safe when using nullable schemas.
- When accepting dynamic input, create `ValidasiEngine<T, dynamic>` or use `withPreprocess` to define the allowed input type.
- Use explicit transformation input types: `ValidasiTransformation<InputType, OutputType>` for compile-time safety.

## Combined Example: Type-Safe Transformation

```dart
// Schema validates String and applies Transform rules
final usernameSchema = Validasi.string([
  Rules.nullable<String>(),
  Rules.transform<String>((value) => value?.trim()),
  Rules.transform<String>((value) => value?.toLowerCase()),
  Rules.string.minLength(3),
]);

// Add preprocessing to accept dynamic input and convert to String
final usernameSchemaWithPreprocess = usernameSchema.withPreprocess(
  ValidasiTransformation<dynamic, String>((value) => value.toString()),
);

// Now validate() accepts dynamic input with compile-time flexibility
print(usernameSchemaWithPreprocess.validate(1234).data);       // "1234"
print(usernameSchemaWithPreprocess.validate('  John  ').data); // "john"
```

## Handling Dynamic Inputs

When you need to accept values of unknown type at compile time, two approaches:

**Approach 1: Use `dynamic` as input type**
```dart
// Engine<OutputType, dynamic> accepts any input
final schema = ValidasiEngine<int, dynamic>([
  Rules.number.moreThan(0),
]);

schema.validate(42);     // OK: int
schema.validate('42');   // Runtime TypeCheck error (no preprocess)
```

**Approach 2: Use withPreprocess (recommended)**
```dart
// Explicit preprocessing handles type conversion
final schema = Validasi.number<int>([
  Rules.number.moreThan(0),
]).withPreprocess(
  ValidasiTransformation<String, int>((s) => int.parse(s)),
);

schema.validate('42'); // OK: compile-time guarantees String input
```
