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

### Validating Complex Data Structures

**Map Validation:**
```dart
final schema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'name': Validasi.string([StringRules.minLength(1)]),
    'age': Validasi.number<int>([NumberRules.moreThan(0)]),
  }),
]);

final result = schema.validate({'name': 'John', 'age': 30});
```

**List Validation:**
```dart
final schema = Validasi.list<String>([
  IterableRules.forEach(
    Validasi.string([StringRules.minLength(1)]),
  ),
]);

final result = schema.validate(['item1', 'item2', 'item3']);
```

Refer to the [examples](packages/validasi/example/) folder to see more usage samples or see the [documentation](https://albetnov.github.io/validasi/).

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

### Agent-Native Core Support (Beta)

Agent-native support is currently in beta and only supports Validasi `v1.0.0-dev.x`.

Validasi now includes machine-friendly schema and result payloads for tool calling workflows.

```dart
import 'dart:convert';
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

final schema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'name': Validasi.string([StringRules.minLength(2)]),
    'age': Validasi.number<int>([NumberRules.moreThanEqual(18)]),
  }),
]);

// Describe validation contract for an agent/tool.
final descriptor = schema.introspect().toJson();
print(jsonEncode(descriptor));

// Validate and return deterministic tool payload.
final result = schema.validate({'name': 'A', 'age': 15});
print(jsonEncode(result.toToolResponse()));
```

Tooling-focused APIs:
- `ValidasiEngine.introspect()` for rule/schema metadata
- `ValidationError.toToolMap()` for stable error payloads
- `ValidasiResult.toToolResponse()` for stable validation envelopes

### MCP Adapter (Beta)

For external MCP clients, use the adapter package in `packages/validasi_mcp`.

This adapter is beta and targets only Validasi `v1.0.0-dev.x`.

It exposes stdio JSON-RPC support for:
- `initialize`
- `tools/list`
- `tools/call`

With built-in tools:
- `list_schemas`
- `describe_schema`
- `validate_input`

See `packages/validasi_mcp/README.md` for usage and embedding examples.

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

The test structure in `packages/validasi/test/` mirrors `packages/validasi/lib/src`.

```bash
# Run all tests
dart run melos run test

# Run tests for root package only
dart run melos run test:validasi

# Run tests for MCP package only
dart run melos run test:mcp

# Run tests with coverage
pushd packages/validasi
dart test --coverage=coverage

# Format coverage report
dart pub global activate coverage
dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib
popd
```