# Creating Custom Rules

While Validasi provides a comprehensive set of built-in validation rules, you may encounter scenarios that require custom validation logic. This guide explains how to create your own validation rules by extending the `Rule<T>` class.

## Custom Rules vs InlineRule

Before diving into custom rules, it's important to understand the difference:

- **InlineRule**: A built-in rule that accepts a callback function. Quick and convenient for simple validations, but has limited flexibility (no access to `ValidationState` mutation like stopping the chain).

- **Custom Rule**: A class extending `Rule<T>`. Provides full control over validation logic, error handling, state manipulation, and can be reused across your application.

Use `InlineRule` for quick, one-off validations. Create a custom rule when you need:
- Reusable validation logic
- Complex validation with multiple conditions
- State manipulation (transforming values, stopping validation)
- Custom error details and structured error messages

## Basic Structure

Every custom rule extends `Rule<T>` and implements the `apply` method:

```dart
import 'package:validasi/validasi.dart';

class MyCustomRule extends Rule<String> {
  const MyCustomRule({super.message});

  @override
  String? apply(String? value, ValidationState state) {
    if (value == null || value.isEmpty) {
      state.addError(
        ValidationError(
          rule: 'MyCustomRule',
          message: message ?? 'Value cannot be empty',
        ),
      );
    }
    return value;
  }
}
```

## The `runOnNull` Property

The `runOnNull` property controls whether your rule should execute when the value is `null`. By default, it's `false`.

```dart
class EmailRule extends Rule<String> {
  const EmailRule({super.message});

  @override
  bool get runOnNull => false; // Skip validation if value is null

  @override
  String? apply(String? value, ValidationState state) {
    if (value == null) return null;
    if (!value.contains('@')) {
      state.addError(
        ValidationError(
          rule: 'Email',
          message: message ?? 'Invalid email format',
        ),
      );
    }
    return value;
  }
}
```

### When to Use `runOnNull`

Set `runOnNull = true` when your rule needs to:
- Validate null values (like `Required` rule)
- Transform null values (like `Transform` rule)
- Provide default values for null inputs

```dart
class DefaultValue<T> extends Rule<T> {
  const DefaultValue(this.defaultValue, {super.message});

  final T defaultValue;

  @override
  bool get runOnNull => true; // Must run on null to set default

  @override
  T? apply(T? value, ValidationState state) {
    if (value == null) {
      return defaultValue;
    }
    return value;
  }
}
```

## Message Overriding

The `message` parameter allows users to customize error messages when using your rule:

```dart
class MinAge extends Rule<int> {
  const MinAge(this.minAge, {super.message});

  final int minAge;

  @override
  int? apply(int? value, ValidationState state) {
    if (value == null) return null;
    if (value < minAge) {
      state.addError(
        ValidationError(
          rule: 'MinAge',
          // Use custom message if provided, otherwise use default
          message: message ?? 'Age must be at least $minAge',
          details: {'minAge': minAge.toString()},
        ),
      );
    }
    return value;
  }
}

// Usage with custom message
final schema = ValidasiEngine<int, int>(
  rules: [
    MinAge(18, message: 'You must be 18 or older to register'),
  ],
);
```

### Best Practices for Messages

1. **Always provide a default message** using the `??` operator
2. **Include relevant values** in the default message for clarity
3. **Add error details** for programmatic error handling
4. **Keep messages user-friendly** and actionable

```dart
class RangeRule extends Rule<int> {
  const RangeRule(this.min, this.max, {super.message});

  final int min;
  final int max;

  @override
  int? apply(int? value, ValidationState state) {
    if (value == null) return null;
    if (value < min || value > max) {
      state.addError(
        ValidationError(
          rule: 'Range',
          message: message ?? 'Value must be between $min and $max',
          details: {
            'min': min.toString(),
            'max': max.toString(),
            'value': value.toString(),
          },
        ),
      );
    }
    return value;
  }
}
```

## Working with ValidationState

The `ValidationState` provides properties for interacting with the validation process:

### Adding Errors

```dart
state.addError(
  ValidationError(
    rule: 'RuleName',
    message: 'Error message',
    details: {'key': 'value'}, // Optional metadata
  ),
);
```

### Transforming Values

Custom rules can modify the value during validation by returning a new value:

```dart
class TrimString extends Rule<String> {
  const TrimString({super.message});

  @override
  String? apply(String? value, ValidationState state) {
    return value?.trim();
  }
}
```

### Stopping Validation

Stop the validation chain to prevent subsequent rules from running:

```dart
class StopIfEmpty extends Rule<String> {
  const StopIfEmpty({super.message});

  @override
  bool get runOnNull => true;

  @override
  String? apply(String? value, ValidationState state) {
    if (value == null || value.isEmpty) {
      state.addError(
        ValidationError(
          rule: 'StopIfEmpty',
          message: message ?? 'Value is required',
        ),
      );
      state.isStopped = true; // Prevents further rules from executing
    }
    return value;
  }
}
```

## Complete Example: URL Validation Rule

Here's a comprehensive example demonstrating all concepts:

```dart
import 'package:validasi/validasi.dart';

class UrlRule extends Rule<String> {
  const UrlRule({
    this.schemes = const ['http', 'https'],
    this.requireTld = true,
    super.message,
  });

  final List<String> schemes;
  final bool requireTld;

  @override
  bool get runOnNull => false; // Don't validate null values

  @override
  String? apply(String? value, ValidationState state) {
    final url = value;
    if (url == null) return null;

    // Check if URL has valid scheme
    bool hasValidScheme = false;
    for (final scheme in schemes) {
      if (url.startsWith('$scheme://')) {
        hasValidScheme = true;
        break;
      }
    }

    if (!hasValidScheme) {
      state.addError(
        ValidationError(
          rule: 'Url',
          message: message ?? 'URL must start with ${schemes.join(" or ")}://',
          details: {
            'allowedSchemes': schemes.join(', '),
            'value': url,
          },
        ),
      );
      return value;
    }

    // Check for TLD if required
    if (requireTld && !url.contains('.')) {
      state.addError(
        ValidationError(
          rule: 'Url',
          message: message ?? 'URL must contain a valid domain with TLD',
          details: {'requireTld': requireTld.toString()},
        ),
      );
    }
    return value;
  }
}

// Usage
final schema = ValidasiEngine<String, String>(
  rules: [
    UrlRule(
      schemes: ['http', 'https', 'ftp'],
      requireTld: true,
      message: 'Please enter a valid URL',
    ),
  ],
);

final result = schema.validate('https://example.com');
```

## Advanced Patterns

### Parameterized Rules

Create flexible rules that accept configuration:

```dart
class Contains extends Rule<String> {
  const Contains(this.substring, {this.caseSensitive = true, super.message});

  final String substring;
  final bool caseSensitive;

  @override
  String? apply(String? value, ValidationState state) {
    if (value == null) return null;
    final contains = caseSensitive
        ? value.contains(substring)
        : value.toLowerCase().contains(substring.toLowerCase());

    if (!contains) {
      state.addError(
        ValidationError(
          rule: 'Contains',
          message: message ?? 'Value must contain "$substring"',
          details: {
            'substring': substring,
            'caseSensitive': caseSensitive.toString(),
          },
        ),
      );
    }
    return value;
  }
}
```

### Generic Type Rules

Create rules that work with multiple types:

```dart
class NotEqual<T> extends Rule<T> {
  const NotEqual(this.forbidden, {super.message});

  final T forbidden;

  @override
  T? apply(T? value, ValidationState state) {
    if (value == forbidden) {
      state.addError(
        ValidationError(
          rule: 'NotEqual',
          message: message ?? 'Value must not equal $forbidden',
          details: {'forbidden': forbidden.toString()},
        ),
      );
    }
    return value;
  }
}

// Works with any type
ValidasiEngine<int, int>(rules: [NotEqual(0)]);
ValidasiEngine<String, String>(rules: [NotEqual('')]);
```

### Composite Validation

Combine multiple checks in one rule:

```dart
class PasswordStrength extends Rule<String> {
  const PasswordStrength({super.message});

  @override
  String? apply(String? value, ValidationState state) {
    if (value == null) return null;
    final password = value;
    final errors = <String>[];

    if (password.length < 8) {
      errors.add('at least 8 characters');
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      errors.add('one uppercase letter');
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      errors.add('one number');
    }
    if (!password.contains(RegExp(r'[!@#$%^&*]'))) {
      errors.add('one special character');
    }

    if (errors.isNotEmpty) {
      state.addError(
        ValidationError(
          rule: 'PasswordStrength',
          message: message ?? 'Password must contain ${errors.join(", ")}',
          details: {'requirements': errors},
        ),
      );
    }
    return value;
  }
}
```

## Testing Custom Rules

Always test your custom rules thoroughly:

```dart
import 'package:test/test.dart';
import 'package:validasi/validasi.dart';

void main() {
  group('UrlRule', () {
    test('accepts valid HTTPS URL', () {
      final schema = ValidasiEngine<String, String>(rules: [UrlRule()]);
      final result = schema.validate('https://example.com');
      expect(result.isValid, true);
    });

    test('rejects URL without scheme', () {
      final schema = ValidasiEngine<String, String>(rules: [UrlRule()]);
      final result = schema.validate('example.com');
      expect(result.isValid, false);
      expect(result.errors.first.rule, 'Url');
    });

    test('accepts custom message', () {
      final schema = ValidasiEngine<String, String>(
        rules: [UrlRule(message: 'Custom error')],
      );
      final result = schema.validate('invalid');
      expect(result.errors.first.message, 'Custom error');
    });
  });
}
```

## Async Custom Rules

For rules that need async operations (e.g., database lookups), extend `AsyncRule<T>` instead:

```dart
import 'package:validasi/validasi.dart';

class UniqueEmailRule extends AsyncRule<String> {
  const UniqueEmailRule(this.userRepository, {super.message});

  final UserRepository userRepository;

  @override
  bool get runOnNull => true;

  @override
  Future<String?> applyAsync(String? value, ValidationState state) async {
    if (value == null) return null;
    final taken = await userRepository.isEmailTaken(value);
    if (taken) {
      state.addError(
        ValidationError(
          rule: 'UniqueEmail',
          message: message ?? 'Email is already registered',
        ),
      );
    }
    return value;
  }
}

// Usage
final schema = Validasi.string([
  Rules.required(),
  UniqueEmailRule(userRepository),
]);
final result = await schema.validateAsync('user@example.com');
```

Key differences from sync rules:
- Extend `AsyncRule<T>` instead of `Rule<T>`
- Override `applyAsync()` instead of `apply()`
- Must use `validateAsync()` instead of `validate()`
- `apply()` throws `StateError` if called directly

## Summary

Creating custom rules in Validasi is straightforward:

1. Extend `Rule<T>` with your specific type
2. Override `runOnNull` if you need to handle null values
3. Implement `apply(T? value, ValidationState state)` with your validation logic
4. Use `state.addError()` to report validation failures
5. Support message customization via the `message` parameter
6. Return the (potentially modified) value from `apply`
7. Use `state.isStopped = true` for stopping validation chain
8. Add error details for better debugging and programmatic handling

For async rules, extend `AsyncRule<T>` and override `applyAsync()` instead. Use `validateAsync()` at the engine level.

Custom rules give you full control while maintaining the composability and type safety that makes Validasi powerful.
