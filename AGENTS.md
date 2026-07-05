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
| `validasi_annotation` | Annotations and core contracts (`ValidasiKey`, `@ValidateClass`) |
| `validasi_gen` | Code generator for compile-time validation |
| `validasi_ui` | Headless form management for Flutter |
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

# Run tests for validasi_gen package only
dart run melos run test:gen

# Run tests for validasi_ui package only (Flutter)
dart run melos run test:ui

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

Note: `dart run melos run analyze` runs on all workspace packages. With Flutter SDK installed, `dart analyze` can handle Flutter packages too — no need for `--ignore` flags.

```bash
cd packages/validasi_ui && flutter analyze
```

**Do not commit `packages/validasi_ui/roadmap.md`** — this file is untracked and should remain so. It documents internal planning and is not part of the published package.

**When docs change (`docs/` directory):**

The MCP server fetches docs from production (`https://albetnov.github.io/validasi`).
MCP e2e tests verify response **structure** (shape, types, known sections)
rather than pinning exact content, so they don't break on routine doc edits.

After any docs change, simply run:

```bash
dart run melos run test:mcp
```

If you need to test against a local VitePress dev server, set the
`LOCAL_DOCS` environment variable:

```bash
LOCAL_DOCS=http://localhost:4173/validasi dart run melos run test:mcp
```

## Architecture

### Core Types

- **`Rule<T>`** (`lib/src/engine/rule.dart`): Base class for all rules; includes `applyAsync()` defaulting to sync `apply()`
- **`AsyncRule<T>`** (`lib/src/engine/rule.dart`): Base class for inherently async rules; throws on sync `apply()`
- **`ValidationState`** (`lib/src/engine/state.dart`): Collects errors during validation
- **`ValidationError`** (`lib/src/engine/error.dart`): Represents a validation failure
- **`ValidasiResult<T>`** (`lib/src/engine/result.dart`): Result of a validation run
- **`ValidasiEngine<T, TInput>`**: Runs rules and returns `ValidasiResult<T>`; exposes `validate()` and `validateAsync()`
- **`Validasi`**: Schema builder (`Validasi.string()`, `Validasi.list()`, etc.)
- **`Rules`**: Factory for all built-in rules
- **`ValidasiKey<T>`** (`validasi_annotation`): Marker for generated field keys
- **`FieldDescriptor<T, V>`** (`validasi`): Field name + extractor interface
- **`ValidasiField<T, V>`** (`validasi`): `FieldDescriptor` with validation capability

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
| Async | `Rules.inlineAsync<T>()`, `Rules.transformAsync<T>()`, etc. | `lib/src/rules/` |
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

## Generic Rules

Current rules in `lib/src/rules/`:

- `Required<T>` - Value must be non-null (`runOnNull = true`)
- `Nullable<T>` - Allows null, stops pipeline (`runOnNull = true`)
- `Transform<T>` - Transforms value (`runOnNull = true`)
- `InlineRule<T>` - Custom inline validator (`runOnNull = true`)
- `AsyncTransform<T>` - Async transformation (`runOnNull = true`)
- `AsyncInlineRule<T>` - Custom async inline validator (`runOnNull = true`)
- `Having<T>` - Value must be in a list (`runOnNull = true`)
- `Equals<T>` - Value must equal a specific value (optional comparator)
- `NotEquals<T>` - Value must not equal a specific value (optional comparator)
- `AnyOf<T>` - Value must satisfy at least one rule set (OR logic)

## Async Rules

Async rules extend `AsyncRule<T>` and can only be run via `validateAsync()`. They are placed alongside sync rules in the same pipeline and execute sequentially.

Current async rules:

- `AsyncInlineRule<T>` - Async custom validator (`Rules.inlineAsync()`)
- `AsyncTransform<T>` - Async value transformation (`Rules.transformAsync()`)
- `AsyncConditionalField<T>` - Async conditional map validation (`Rules.map.conditionalFieldAsync()`)

Container rules (`HasFields`, `ForEach`, `AllValues`, `AnyOf`) override `applyAsync()` so they can host async child rules when `validateAsync()` is used.

## Iterable Rules

Current rules in `lib/src/rules/iterable/`:

- `MinLength<T>` - List must have at least N items
- `MaxLength<T>` - List must have at most N items
- `ExactLength<T>` - List must have exactly N items
- `IsEmpty<T>` - List must be empty
- `IsNotEmpty<T>` - List must not be empty
- `Contains<T>` - List must contain element (optional comparator)
- `NotContains<T>` - List must not contain element (optional comparator)
- `Unique<T>` - All elements must be unique (optional comparator)
- `ContainsAll<T>` - List must contain all given elements (optional comparator)
- `ForEach<I>` - Apply rules to each list element

All iterable rules extend `Rule<List<T>>`.

## Map Rules

Current rules in `lib/src/rules/map/`:

- `HasFields` - Validate fields with their rules
- `HasFieldKeys<T>` - Ensure keys exist
- `ConditionalField<T>` - Conditional validation
- `AsyncConditionalField<T>` - Async conditional validation
- `AllowedKeys<T>` - Whitelist keys
- `ForbiddenKeys<T>` - Blacklist keys
- `MinKeys<T>` - At least N keys
- `MaxKeys<T>` - At most N keys
- `AllValues<T>` - Apply rules to all values (like ForEach for maps)
- `RequiredAny<T>` - At least one field present
- `RequiredOneOf<T>` - Exactly one field present (XOR)
- `RequiredAll<T>` - All or nothing
- `DependsOn<T>` - Field A requires field B
- `MutuallyExclusive<T>` - Fields A and B cannot both be present
- `MatchesField<T>` - Two fields must have equal values (optional comparator)

All map rules extend `Rule<Map<String, T>>`.

### Generated Field Classes

When `@ValidateClass(generateFields: true)` is used, `validasi_gen` emits a sealed field class hierarchy:

```dart
sealed class UserFields<V> extends ValidasiKey<User> implements ValidasiField<User, V> {
  static const UserFields<String> name = UserNameField();
  static const UserFields<int> age = UserAgeField();
}
```

Each leaf class implements `name`, `extract(owner)`, and `validate(value)`.

### `validasi_ui` Architecture

- **`ValidasiFormController<T>`** (`lib/src/controller.dart`): `ChangeNotifier` keyed by `ValidasiField<T, V>`
- **`ValidasiForm<T>`** (`lib/src/form.dart`): `InheritedWidget` scope providing `ValidasiFormController<T>`
- **`ValidasiFormField<T, V>`** (`lib/src/form_field.dart`): Binds a `ValidasiField<T, V>` to a builder. `T` and `V` are inferred from the `field` argument. Wraps the child in a `_FieldDisposer` that tracks mount/unmount via a deferred post-frame reconcile (no synchronous `notifyListeners` during `finalizeTree`).

```dart
ValidasiForm(
  schema: UserFields.schema,
  builder: (context, submit) => ValidasiFormField(
    field: UserFields.name,
    builder: (context, state) => TextField(
      onChanged: state.onChanged,
      decoration: InputDecoration(errorText: state.errorText),
    ),
  ),
)
```

## Import Prefixes

When two rules share a name (e.g., `MinLength` for string and iterable), use import prefixes in `rules.dart`:

```dart
import 'src/rules/string/min_length.dart' as string_min_len;
import 'src/rules/iterable/min_length.dart' as iterable_min_len;
```

> **Important:** AI agents must **never** increment package versions or update CHANGELOG files. Version bumps and changelog updates are done manually by maintainers to avoid confusion and ensure proper release coordination.

## Version Bumping Rules

When bumping `validasi` core version, update all dependants:

| Package | Dependency on validasi |
|---------|----------------------|
| `validasi_annotation` | Runtime dependency (re-exports `ValidasiKey`) |
| `validasi_ui` | Runtime dependency |
| `validasi_gen` | Dev dependency |
| `validasi_gen/example` | Path dependency (no version constraint) |
| `validasi_ui/example` | Path dependency (no version constraint) |

**Steps:**
1. Bump `packages/validasi/pubspec.yaml` version and update `CHANGELOG.md`.
2. Bump `packages/validasi_annotation/pubspec.yaml` version and dependency constraint; update `CHANGELOG.md`.
3. Bump `packages/validasi_ui/pubspec.yaml` version and dependency constraint; update `CHANGELOG.md`.
4. Update `packages/validasi_gen/pubspec.yaml` dev dependency constraint (no version bump needed — dev deps don't affect consumers).
5. Run `dart run melos run analyze` and `dart run melos run format:fix`.

**Codegen experimental types** (like `ValidasiKey<T>`) marked `@experimental` in `validasi` core.
These are for generated code use only — avoid referencing them directly in application code.

## Code Style

- Follow `package:lints/recommended.yaml`
- No comments unless necessary
- Use `const` constructors where possible
- Generic type parameters: `T` for single types, `I` for iterable item types
- **Always use package imports** (e.g., `import 'package:validasi/src/engine/rule.dart';`), never relative imports (e.g., `import '../../engine/rule.dart';`)
