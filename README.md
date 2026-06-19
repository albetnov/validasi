# Validasi

![Logo](https://github.com/albetnov/validasi/blob/v1/art/logo.png?raw=true)

A flexible, composeable, and type-safe validation library for Dart & Flutter.

[Documentation](https://albetnov.github.io/validasi/)
[API Documentation](https://pub.dev/documentation/validasi/latest)

> [!CAUTION]
> This is the complete rewrite of the Validasi library into a completely new API (with modifier support).

## Installation

To use this package, add `validasi` as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  validasi: 1.0.0-dev.x
```

> Check the [pub.dev page](https://pub.dev/packages/validasi/versions) for the latest pre-release version.

## Quick Usage

To use this library, simply import `package:validasi/validasi.dart` and the rules from `package:validasi/rules.dart`. Here's a basic example:

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

void main() {
  final schema = Validasi.string([
    Rules.nullable<String>(),
    Rules.transform<String>((input) => input?.trim()),
    Rules.string.minLength(3),
    Rules.string.maxLength(16)
  ]);

  final result = schema.validate('   Hello World!   ');
  print("isValid: ${result.isValid}, errors: ${result.errors.map((e) => e.message).join(', ')}, value: ${result.data}");
}
```

### Validating Complex Data Structures

**Map Validation:**

```dart
final schema = Validasi.map<dynamic>([
  Rules.map.hasFields({
    'name': Validasi.string([Rules.string.minLength(1)]),
    'age': Validasi.number<int>([Rules.number.moreThan(0)]),
  }),
]);

final result = schema.validate({'name': 'John', 'age': 30});
```

**List Validation:**

```dart
final schema = Validasi.list<String>([
  Rules.iterable.forEach<String>(
    Validasi.string([Rules.string.minLength(1)]),
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

The library comes with comprehensive built-in rules organized by data type. See the documentation for the full list:

- [String Rules](https://albetnov.github.io/validasi/schemas/string) - `alpha`, `email`, `url`, `uuid`, `regex`, and more
- [Number Rules](https://albetnov.github.io/validasi/schemas/number) - `finite`, `lessThan`, `moreThan`, and more
- [List Rules](https://albetnov.github.io/validasi/schemas/list) - `minLength`, `maxLength`, `unique`, `contains`, `forEach`, and more
- [Map Rules](https://albetnov.github.io/validasi/schemas/map) - `hasFields`, `hasFieldKeys`, `allowedKeys`, `requiredAny`, `matchesField`, and more
- [Generic Rules](https://albetnov.github.io/validasi/schemas/any) - `required`, `nullable`, `transform`, `equals`, `anyOf`, `inline`, and more

### Preprocessing & Transformation

Use `withPreprocess` to transform input data before validation:

```dart
final schema = Validasi.string([Rules.string.minLength(3)])
  .withPreprocess((value) => value.toString());

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
