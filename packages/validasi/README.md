# Validasi

![Logo](art/logo.png)

![image](art/validasi.png?raw=true)

A flexible, composeable, and type-safe validation library for Dart & Flutter.

[Documentation](https://albetnov.github.io/validasi/)
[API Documentation](https://pub.dev/documentation/validasi/latest)

> [!CAUTION]
> This is the complete rewrite of the Validasi library into a completely new API (with modifier support).

## Installation

To use this package, add `validasi` as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  validasi: 1.0.0-dev.0
```

## Quick Usage

To use this library, simply import `package:validasi/validasi.dart` and the rules from `package:validasi/rules.dart`. Here's a basic example:

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

void main() {
  final schema = Validasi.string([
    Nullable(),
    Transform((input) => input?.trim()),
    StringRules.minLength(3),
    StringRules.maxLength(16)
  ]);

  final result = schema.validate('   Hello World!   ');
  print("isValid: ${result.isValid}, errors: ${result.errors.map((e) => e.message).join(', ')}, value: ${result.data}");
}
```

### Type-Safe Validation with Input Transformation

When accepting different input types, use `withPreprocess` to ensure type safety at compile time:

```dart
final ageSchema = Validasi.number<int>([
  NumberRules.moreThan(0),
  NumberRules.lessThan(150),
]).withPreprocess(
  ValidasiTransformation<String, int>((value) => int.parse(value)),
);

// validate() now accepts String due to preprocessing
final result = ageSchema.validate('25');
print("Valid: ${result.isValid}, Age: ${result.data}"); // Valid: true, Age: 25
```

### Validating Complex Data Structures

**Map Validation:**
```dart
final schema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'name': Validasi.string([
      StringRules.minLength(1),
    ]),
    'age': Validasi.number<int>([
      NumberRules.moreThan(0),
    ]),
  }),
]);

final result = schema.validate({'name': 'John', 'age': 30});
print('Valid: ${result.isValid}');
```

**List Validation:**
```dart
final schema = Validasi.list<String>([
  IterableRules.forEach(
    Validasi.string([
      StringRules.minLength(1),
    ]),
  ),
]);

final result = schema.validate(['item1', 'item2', 'item3']);
print('Valid: ${result.isValid}');
```

**Handling Dynamic Inputs with withPreprocess:**
```dart
// Accept JSON-like data and validate as typed schema
final userSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'name': Validasi.string([StringRules.minLength(1)]),
    'age': Validasi.number<int>([NumberRules.moreThan(0)]),
  }),
]);

final result = userSchema.validate({
  'name': 'Alice',
  'age': 28,
});
```

## Features

### Type-Safe Validation Engine
Validasi provides type-safe validation schemas for various data types:
- `Validasi.string()` - String validation
- `Validasi.number<T>()` - Numeric validation (int, double, num)
- `Validasi.list<T>()` - List/Iterable validation
- `Validasi.map<T>()` - Map validation
- `Validasi.any<T>()` - Generic type validation

### Built-in Rules
The library comes with comprehensive built-in rules organized by data type:

**String Rules:**
- `StringRules.minLength()` - Minimum length validation
- `StringRules.maxLength()` - Maximum length validation
- `StringRules.oneOf()` - Value must be one of specified options

**Number Rules:**
- `NumberRules.finite()` - Ensures number is finite
- `NumberRules.lessThan()` - Less than comparison
- `NumberRules.lessThanEqual()` - Less than or equal comparison
- `NumberRules.moreThan()` - Greater than comparison
- `NumberRules.moreThanEqual()` - Greater than or equal comparison

**Iterable Rules:**
- `IterableRules.minLength()` - Minimum list length
- `IterableRules.forEach()` - Validate each item in the list

**Map Rules:**
- `MapRules.hasFields()` - Validate nested map fields with individual schemas
- `MapRules.hasFieldKeys()` - Ensure required keys exist
- `MapRules.conditionalField()` - Conditional field validation based on other fields

**Modifier Rules:**
- `Nullable()` - Allow null values
- `Required()` - Ensure non-null values
- `Transform()` - Transform values during validation
- `Having()` - Custom validation with context access
- `InlineRule()` - Create custom validation rules inline

### Preprocessing & Transformation
Use `ValidasiTransformation` to preprocess input data before validation:

```dart
final schema = Validasi.string([StringRules.minLength(3)])
  .withPreprocess(ValidasiTransformation((value) => value.toString()));

final result = schema.validate(123); // Converts to "123" then validates
```

### Safe Validation
All validation returns a `ValidasiResult` object that contains:
- `isValid` - Boolean indicating validation success
- `data` - The validated (and potentially transformed) data
- `errors` - List of validation errors with messages and paths

### Nested Validation with Error Paths
Validasi tracks error paths for nested structures, making it easy to identify exactly where validation fails:

```dart
final result = schema.validate(complexNestedData);
result.errors.forEach((error) {
  print("Error at ${error.path?.join('.')}: ${error.message}");
});
```

### License

The Validasi Library is licensed under [MIT License](./LICENSE).

## Contribution

We welcome contributions! Here's how to set up the development environment:

### Setting Up Development Environment

```bash
# Clone the repository
git clone https://github.com/albetnov/validasi
cd validasi

# Install root dependencies (includes melos)
dart pub get

# Install workspace dependencies
dart run melos bootstrap
```

### Running Tests

The test structure in `test/` directory mirrors the `lib/src` structure:

```bash
# Run all tests
dart run melos run test

# Run tests for root package only
dart run melos run test:validasi

# Run tests for MCP package only
dart run melos run test:mcp

# Run tests with coverage
dart test --coverage=coverage

# Format coverage report
dart pub global activate coverage
dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib
```