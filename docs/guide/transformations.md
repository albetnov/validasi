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
  Transform((value) => value?.trim()),
  Transform((value) => value?.toLowerCase()),
  StringRules.minLength(5),
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

Use `withPreprocess` when raw input may be a different type than the schema expects.

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';
import 'package:validasi/transformer.dart';

final ageSchema = Validasi.number<int>([
  NumberRules.moreThanEqual(0),
]).withPreprocess(
  ValidasiTransformation((value) {
    if (value is String) return int.parse(value);
    return value as int;
  }),
);

print(ageSchema.validate('42').data); // 42
```

How it works:

- Runs before type checking.
- If preprocessing fails, validation fails with a `Preprocess` error.
- If preprocessing succeeds but returns the wrong type, validation fails at type check.

## Execution Order

Validation flow is:

1. `withPreprocess(...)` transformation (if configured)
2. Type check against schema type
3. Rule execution, including `Transform(...)`
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

## Combined Example

```dart
final usernameSchema = Validasi.string([
  Nullable(),
  Transform((value) => value?.trim()),
  Transform((value) => value?.toLowerCase()),
  StringRules.minLength(3),
]).withPreprocess(
  ValidasiTransformation((value) => value.toString()),
);

print(usernameSchema.validate(1234).data); // "1234"
print(usernameSchema.validate('  John  ').data); // "john"
```
