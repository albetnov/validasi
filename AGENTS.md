# AGENTS.md - Validasi Development Guide

## Project Overview

**Validasi** is a flexible, composable, type-safe validation library for Dart/Flutter.

- **Language**: Dart (SDK ^3.5.0)
- **Structure**: Melos monorepo
- **Main package**: `packages/validasi/`

## Packages

| Package | Purpose |
|---------|---------|
| `validasi` | Core validation library |
| `validasi_mcp` | MCP integration |

## Commands

This project uses **Melos** for monorepo management. Run commands from the **root directory**.

### Melos Scripts

```bash
# Install dependencies for all packages
dart pub get

# Run tests for all packages
dart run melos run test

# Run tests for validasi package only
dart run melos run test:validasi

# Run tests for validasi_mcp package only
dart run melos run test:mcp

# Analyze all packages
dart run melos run analyze

# Check formatting across all packages
dart run melos run format:check

# Fix formatting across all packages
dart run melos run format:fix
```

### Running Tests Directly

To run tests for a specific file, navigate to the package directory:

```bash
cd packages/validasi
dart test test/rules/iterable/min_length_test.dart
```

### Required: After Making Changes

**Always run these commands after making changes:**

```bash
# From root directory
dart run melos run analyze
dart run melos run format:fix
```

## Architecture

### Core Types

- **`Rule<T>`** (`lib/src/engine/rule.dart`): Base class for all rules
- **`ValidationState`** (`lib/src/engine/state.dart`): Collects errors during validation
- **`ValidationError`** (`lib/src/engine/error.dart`): Represents a validation failure
- **`ValidasiEngine<T, TInput>`**: Runs rules and returns `ValidasiResult<T>`
- **`Validasi`**: Schema builder (`Validasi.string()`, `Validasi.list()`, etc.)
- **`Rules`**: Factory for all built-in rules

### Rule Pattern

Every rule follows this structure:

```dart
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class MyRule<T> extends Rule<T> {
  const MyRule(this.param, {super.message});
  
  final SomeType param;

  @override
  T? apply(T? value, ValidationState state) {
    if (value != null && /* condition fails */) {
      state.addError(ValidationError(
        rule: 'MyRule',
        message: message ?? 'Default error message',
      ));
    }
    return value;
  }
}
```

**Key conventions:**
- `const` constructor with `super.message`
- `runOnNull = false` by default (override to `true` if rule must see nulls)
- Always return the value (unless it's a transform rule)
- Use `message ?? 'Default'` for custom/default messages

### Rule Categories

| Category | Class | Location |
|----------|-------|----------|
| Generic | `Rules.required<T>()`, `Rules.nullable<T>()`, etc. | `lib/src/rules/` |
| String | `Rules.string.*` | `lib/src/rules/string/` |
| Number | `Rules.number.*` | `lib/src/rules/numbers/` |
| Iterable | `Rules.iterable.*` | `lib/src/rules/iterable/` |
| Map | `Rules.map.*` | `lib/src/rules/map/` |

## Adding a New Rule

1. **Create rule file**: `lib/src/rules/<category>/<rule_name>.dart`
2. **Create test file**: `test/rules/<category>/<rule_name>_test.dart`
3. **Register in `lib/rules.dart`**:
   - Import the rule (use prefix if name collision)
   - Add factory method to the appropriate sub-class

### Example: Adding `MaxLength<T>` to iterable

```dart
// lib/src/rules/iterable/max_length.dart
class MaxLength<T> extends Rule<List<T>> {
  const MaxLength(this.length, {super.message});
  final int length;

  @override
  List<T>? apply(List<T>? value, ValidationState state) {
    if (value != null && value.length > length) {
      state.addError(ValidationError(
        rule: 'MaxLength',
        message: message ?? 'List must have at most $length items',
      ));
    }
    return value;
  }
}
```

```dart
// In lib/rules.dart - add to _IterableRules:
MaxLength<T> maxLength<T>(int length, {String? message}) =>
    MaxLength<T>(length, message: message);
```

## Test Pattern

```dart
import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/iterable/my_rule.dart';

void main() {
  group('MyRule', () {
    test('should pass when ...', () {
      final rule = MyRule<int>(...);
      final state = ValidationState();
      
      rule.apply(value, state);
      
      expect(state.errors, isEmpty);
    });

    test('should fail when ...', () {
      final rule = MyRule<int>(...);
      final state = ValidationState();
      
      rule.apply(value, state);
      
      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('MyRule'));
      expect(state.errors.first.message, equals('...'));
    });

    test('should use custom message', () {
      final rule = MyRule<int>(..., message: 'Custom');
      // ...
    });
  });
}
```

## Iterable Rules

Current rules in `lib/src/rules/iterable/`:
- `MinLength<T>` - List must have at least N items
- `ForEach<I>` - Apply rules to each list element

All iterable rules extend `Rule<List<T>>`.

## Import Prefixes

When two rules share a name (e.g., `MinLength` for string and iterable), use import prefixes in `rules.dart`:

```dart
import 'src/rules/string/min_length.dart' as string_min_len;
import 'src/rules/iterable/min_length.dart' as iterable_min_len;
```

## Code Style

- Follow `package:lints/recommended.yaml`
- No comments unless necessary
- Use `const` constructors where possible
- Generic type parameters: `T` for single types, `I` for iterable item types
- **Always use package imports** (e.g., `import 'package:validasi/src/engine/rule.dart';`), never relative imports (e.g., `import '../../engine/rule.dart';`)
