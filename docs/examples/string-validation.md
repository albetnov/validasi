# String Validation Examples

Learn how to validate strings with Validasi's powerful string validation rules.

## Basic Length Validation

### Minimum Length

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

final schema = Validasi.string([
  StringRules.minLength(3),
]);

// Valid
print(schema.validate('abc').isValid); // true
print(schema.validate('hello').isValid); // true

// Invalid
print(schema.validate('ab').isValid); // false
```

### Maximum Length

```dart
final schema = Validasi.string([
  StringRules.maxLength(10),
]);

// Valid
print(schema.validate('short').isValid); // true

// Invalid
print(schema.validate('this is too long').isValid); // false
```

### Combined Length Rules

```dart
final usernameSchema = Validasi.string([
  StringRules.minLength(3),
  StringRules.maxLength(20),
]);

final result = usernameSchema.validate('john_doe');
print('Valid username: ${result.isValid}');
```

## Pattern Matching

### Email Validation

```dart
final emailSchema = Validasi.string([
  StringRules.email(),
]);

// Valid emails
print(emailSchema.validate('user@example.com').isValid); // true
print(emailSchema.validate('john.doe@company.co.uk').isValid); // true

// Invalid emails
print(emailSchema.validate('invalid.email').isValid); // false
print(emailSchema.validate('@example.com').isValid); // false
```

### URL Validation

```dart
final urlSchema = Validasi.string([
  StringRules.url(),
]);

// Valid URLs
print(urlSchema.validate('https://example.com').isValid); // true
print(urlSchema.validate('http://localhost:3000').isValid); // true

// Invalid URLs
print(urlSchema.validate('not a url').isValid); // false
```

## Enum Validation

Validate that a string is one of specific values:

```dart
final statusSchema = Validasi.string([
  StringRules.oneOf(['active', 'inactive', 'pending']),
]);

// Valid
print(statusSchema.validate('active').isValid); // true
print(statusSchema.validate('pending').isValid); // true

// Invalid
print(statusSchema.validate('unknown').isValid); // false
```

## String Transformation

### Trimming Whitespace

```dart
final trimmedSchema = Validasi.string([
  Transform((value) => value?.trim()),
  StringRules.minLength(3),
]);

final result = trimmedSchema.validate('  hello  ');
print('Trimmed: "${result.data}"'); // Output: "hello"
```

### Converting to Lowercase

```dart
final lowercaseSchema = Validasi.string([
  Transform((value) => value?.toLowerCase()),
]);

final result = lowercaseSchema.validate('HELLO WORLD');
print('Lowercase: ${result.data}'); // Output: "hello world"
```

### Chaining Transformations

```dart
final normalizedSchema = Validasi.string([
  Transform((value) => value?.trim()),
  Transform((value) => value?.toLowerCase()),
  StringRules.minLength(3),
]);

final result = normalizedSchema.validate('  HELLO  ');
print('Normalized: "${result.data}"'); // Output: "hello"
```

## Custom String Rules

Create custom validation for specific patterns:

```dart
// Phone number validation
final phoneSchema = Validasi.string([
  InlineRule<String>((value) {
    final phoneRegex = RegExp(r'^\+?[\d\s-()]+$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Invalid phone number format';
    }
    return null;
  }),
]);

// Alphanumeric validation
final alphanumericSchema = Validasi.string([
  InlineRule<String>((value) {
    final alphanumericRegex = RegExp(r'^[a-zA-Z0-9]+$');
    if (!alphanumericRegex.hasMatch(value)) {
      return 'Must contain only letters and numbers';
    }
    return null;
  }),
]);
```

## Real-World Examples

### Username Validation

```dart
final usernameSchema = Validasi.string([
  Transform((value) => value?.trim().toLowerCase()),
  StringRules.minLength(3),
  StringRules.maxLength(20),
  InlineRule<String>((value) {
    final usernameRegex = RegExp(r'^[a-z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Username can only contain lowercase letters, numbers, and underscores';
    }
    return null;
  }),
]);

print(usernameSchema.validate('John_Doe123').isValid); // true (after transform)
print(usernameSchema.validate('invalid@user').isValid); // false
```

### Password Strength Validation

```dart
final strongPasswordSchema = Validasi.string([
  StringRules.minLength(8),
  InlineRule<String>((value) {
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Must contain at least one uppercase letter';
    }
    return null;
  }),
  InlineRule<String>((value) {
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Must contain at least one lowercase letter';
    }
    return null;
  }),
  InlineRule<String>((value) {
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Must contain at least one number';
    }
    return null;
  }),
  InlineRule<String>((value) {
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Must contain at least one special character';
    }
    return null;
  }),
]);

final result = strongPasswordSchema.validate('MyP@ssw0rd');
print('Strong password: ${result.isValid}');
```

### Slug Validation

```dart
final slugSchema = Validasi.string([
  Transform((value) => value?.trim().toLowerCase()),
  Transform((value) => value?.replaceAll(RegExp(r'\s+'), '-')),
  StringRules.minLength(3),
  InlineRule<String>((value) {
    final slugRegex = RegExp(r'^[a-z0-9-]+$');
    if (!slugRegex.hasMatch(value)) {
      return 'Invalid slug format';
    }
    return null;
  }),
]);

final result = slugSchema.validate('Hello World Post');
print('Slug: ${result.data}'); // Output: "hello-world-post"
```

## Next Steps

- [Number Validation Examples](/examples/number-validation)
- [Complex Structures](/examples/complex-structures)
- [Built-in Rules Reference](/guide/rules)
