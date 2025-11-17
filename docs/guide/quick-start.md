# Quick Start

Let's build your first validation schema with Validasi! This guide will walk you through the basics and get you validating data in minutes.

## Basic String Validation

The simplest validation checks if a string meets certain criteria:

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

void main() {
  // Create a schema
  final nameSchema = Validasi.string([
    StringRules.minLength(2),
    StringRules.maxLength(50),
  ]);

  // Validate data
  final result = nameSchema.validate('John Doe');
  
  if (result.isValid) {
    print('✓ Valid name: ${result.data}');
  } else {
    print('✗ Errors: ${result.errors.map((e) => e.message).join(', ')}');
  }
}
```

## Number Validation

Validate numeric values with range checks:

```dart
final ageSchema = Validasi.number<int>([
  NumberRules.moreThanEqual(0),
  NumberRules.lessThan(150),
]);

final result = ageSchema.validate(25);
print('Age is valid: ${result.isValid}');
```

## Nullable Fields

Handle optional fields with the `Nullable` modifier:

```dart
final optionalEmailSchema = Validasi.string([
  Nullable(),
  StringRules.email(),
]);

// Both are valid
print(optionalEmailSchema.validate(null).isValid);        // true
print(optionalEmailSchema.validate('test@example.com').isValid); // true
```

## Map Validation

Validate complex objects with nested fields:

```dart
final userSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'name': Validasi.string([
      StringRules.minLength(2),
    ]),
    'email': Validasi.string([
      StringRules.email(),
    ]),
    'age': Validasi.number<int>([
      NumberRules.moreThanEqual(18),
    ]),
  }),
]);

final userData = {
  'name': 'Alice Smith',
  'email': 'alice@example.com',
  'age': 28,
};

final result = userSchema.validate(userData);

if (result.isValid) {
  print('User data is valid!');
  print('Validated data: ${result.data}');
} else {
  for (var error in result.errors) {
    print('Error at ${error.path?.join('.')}: ${error.message}');
  }
}
```

## List Validation

Validate arrays and collections:

```dart
final tagsSchema = Validasi.list<String>([
  IterableRules.minLength(1),
  IterableRules.forEach(
    Validasi.string([
      StringRules.minLength(2),
      StringRules.maxLength(20),
    ]),
  ),
]);

final result = tagsSchema.validate(['flutter', 'dart', 'validation']);
print('Tags are valid: ${result.isValid}');
```

## Data Transformation

Transform values during validation:

```dart
final trimmedNameSchema = Validasi.string([
  Transform((value) => value?.trim()),
  StringRules.minLength(2),
]);

final result = trimmedNameSchema.validate('  John  ');
print('Trimmed name: ${result.data}'); // Output: "John"
```

## Custom Validation

Create custom validation rules inline:

```dart
final passwordSchema = Validasi.string([
  StringRules.minLength(8),
  InlineRule<String>((value) {
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain an uppercase letter';
    }
    return null; // null means valid
  }),
  InlineRule<String>((value) {
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain a number';
    }
    return null;
  }),
]);

final result = passwordSchema.validate('MyPass123');
print('Password is valid: ${result.isValid}');
```

## Putting It All Together

Here's a complete example validating a registration form:

```dart
final registrationSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'username': Validasi.string([
      Transform((value) => value?.trim().toLowerCase()),
      StringRules.minLength(3),
      StringRules.maxLength(20),
    ]),
    'email': Validasi.string([
      Transform((value) => value?.trim().toLowerCase()),
      StringRules.email(),
    ]),
    'password': Validasi.string([
      StringRules.minLength(8),
      InlineRule<String>((value) {
        final hasUpper = value.contains(RegExp(r'[A-Z]'));
        final hasLower = value.contains(RegExp(r'[a-z]'));
        final hasDigit = value.contains(RegExp(r'[0-9]'));
        
        if (!hasUpper || !hasLower || !hasDigit) {
          return 'Password must contain uppercase, lowercase, and numbers';
        }
        return null;
      }),
    ]),
    'age': Validasi.number<int>([
      Nullable(),
      NumberRules.moreThanEqual(13),
    ]),
    'terms': Validasi.any<bool>([
      InlineRule<bool>((value) {
        return value == true ? null : 'You must accept the terms';
      }),
    ]),
  }),
]);

final formData = {
  'username': '  JohnDoe  ',
  'email': 'JOHN@EXAMPLE.COM',
  'password': 'SecurePass123',
  'age': 25,
  'terms': true,
};

final result = registrationSchema.validate(formData);

if (result.isValid) {
  print('✓ Registration successful!');
  print('Processed data: ${result.data}');
} else {
  print('✗ Validation failed:');
  for (var error in result.errors) {
    print('  - ${error.path?.join('.')}: ${error.message}');
  }
}
```

## Next Steps

Now that you understand the basics, explore more advanced features:

- [Validation Schemas](/guide/schemas) - Deep dive into schema creation
- [Built-in Rules](/guide/rules) - Complete list of available rules
- [Transformations](/guide/transformations) - Data preprocessing and transformation
- [Error Handling](/guide/error-handling) - Working with validation errors

<div style="margin-top: 3rem;">
  <a href="/guide/schemas" class="vp-button vp-button-brand">Learn More →</a>
</div>
