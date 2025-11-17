# Built-in Rules

Validasi comes with a set of universal validation rules that work across all data types. These modifier rules control validation behavior, allow transformations, and enable custom logic.

## Overview

Built-in rules are divided into two categories:

### Global Modifier Rules
Universal rules that modify validation behavior (covered on this page):
- **Nullable** - Allow null values
- **Required** - Ensure non-null values
- **Transform** - Transform values during validation
- **Having** - Custom validation with context access
- **InlineRule** - Create custom validation rules inline

### Type-Specific Rules
Rules designed for specific data types (see dedicated pages):
- [String Rules](/guide/string-rules) - `minLength`, `maxLength`, `oneOf`
- [Number Rules](/guide/number-rules) - `finite`, `lessThan`, `moreThan`, etc.
- [Iterable Rules](/guide/iterable-rules) - `minLength`, `forEach`
- [Map Rules](/guide/map-rules) - `hasFields`, `hasFieldKeys`, `conditionalField`

---

## Global Modifier Rules

These rules work with any schema type and modify how validation behaves:

### Nullable

Allows null values to pass validation. By default, Validasi rejects null values unless explicitly allowed.

```dart
import 'package:validasi/rules.dart';

final optionalNameSchema = Validasi.string([
  Nullable(),
  StringRules.minLength(3),
]);

print(optionalNameSchema.validate(null).isValid);    // true
print(optionalNameSchema.validate('John').isValid);  // true
print(optionalNameSchema.validate('Jo').isValid);    // false
```

**Use cases:**
- Optional form fields
- Optional API parameters
- Nullable database columns

**Examples with different types:**

```dart
// Optional number
final optionalAge = Validasi.number<int>([
  Nullable(),
  NumberRules.moreThanEqual(0),
]);

// Optional list
final optionalTags = Validasi.list<String>([
  Nullable(),
  IterableRules.minLength(1),
]);

// Optional map
final optionalSettings = Validasi.map<dynamic>([
  Nullable(),
  MapRules.hasFieldKeys({'theme'}),
]);
```

::: tip Best Practice
Place `Nullable()` as the first rule in your schema to make the intent clear.
:::

### Required

Explicitly ensures value is not null. This is the default behavior, but can be used for clarity.

```dart
final requiredNameSchema = Validasi.string([
  Required(),
  StringRules.minLength(3),
]);

print(requiredNameSchema.validate(null).isValid);    // false
print(requiredNameSchema.validate('John').isValid);  // true
```

**When to use:**
- For explicit documentation of required fields
- When overriding nullable schemas
- In schema composition for clarity

### Transform

Transforms the value during validation. The transformed value is used for subsequent rules and returned in the result.

```dart
final trimmedSchema = Validasi.string([
  Transform((value) => value?.trim()),
  StringRules.minLength(3),
]);

final result = trimmedSchema.validate('  hello  ');
print(result.data); // "hello" (trimmed)
print(result.isValid); // true
```

**Common transformations:**

```dart
// Trim and lowercase
final emailSchema = Validasi.string([
  Transform((value) => value?.trim()),
  Transform((value) => value?.toLowerCase()),
  StringRules.minLength(5),
]);

// Convert to absolute value
final absoluteSchema = Validasi.number<int>([
  Transform((value) => value?.abs()),
  NumberRules.moreThan(0),
]);

// Filter empty strings from list
final cleanListSchema = Validasi.list<String>([
  Transform((list) => list?.where((s) => s.isNotEmpty).toList()),
  IterableRules.minLength(1),
]);
```

::: warning Order Matters
Place `Transform` rules before validation rules to ensure the transformed value is validated.
:::

**See also:** [Transformations Guide](/guide/transformations) for detailed transformation patterns.

### Having

Custom validation with access to the validation context. Useful for complex validation logic that needs information about the validation state.

```dart
final schema = Validasi.string([
  Having((context, value) {
    // Access validation context
    // context provides information about the validation state
    
    if (value == null || value.isEmpty) {
      return 'Value is required';
    }
    
    return null; // null means valid
  }),
]);
```

**Advanced usage:**

```dart
final passwordConfirmSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'password': Validasi.string([StringRules.minLength(8)]),
    'confirm_password': Validasi.string([StringRules.minLength(8)]),
  }),
  Having((context, value) {
    // Access the entire map being validated
    if (value is Map) {
      if (value['password'] != value['confirm_password']) {
        return 'Passwords do not match';
      }
    }
    return null;
  }),
]);
```

**When to use `Having`:**
- Need access to validation context
- Cross-field validation
- Complex conditional logic
- State-dependent validation

### InlineRule

Create custom validation rules inline without accessing context. Simpler than `Having` for basic custom validation.

```dart
final passwordSchema = Validasi.string([
  StringRules.minLength(8),
  InlineRule<String>((value) {
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Must contain at least one uppercase letter';
    }
    return null; // null means valid
  }),
  InlineRule<String>((value) {
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Must contain at least one number';
    }
    return null;
  }),
]);
```

**Common patterns:**

```dart
// Email validation
final emailSchema = Validasi.string([
  InlineRule<String>((value) {
    if (!value.contains('@') || !value.contains('.')) {
      return 'Invalid email format';
    }
    return null;
  }),
]);

// URL validation
final urlSchema = Validasi.string([
  InlineRule<String>((value) {
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      return 'URL must start with http:// or https://';
    }
    return null;
  }),
]);

// Custom business logic
final ageSchema = Validasi.number<int>([
  InlineRule<int>((value) {
    if (value < 18) {
      return 'Must be 18 or older';
    }
    if (value > 120) {
      return 'Age seems invalid';
    }
    return null;
  }),
]);

// Pattern matching
final usernameSchema = Validasi.string([
  InlineRule<String>((value) {
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }),
]);
```

**Multiple conditions:**

```dart
final strongPasswordSchema = Validasi.string([
  StringRules.minLength(8),
  InlineRule<String>((value) {
    final hasUpper = value.contains(RegExp(r'[A-Z]'));
    final hasLower = value.contains(RegExp(r'[a-z]'));
    final hasDigit = value.contains(RegExp(r'[0-9]'));
    final hasSpecial = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    if (!hasUpper) return 'Must contain uppercase letter';
    if (!hasLower) return 'Must contain lowercase letter';
    if (!hasDigit) return 'Must contain number';
    if (!hasSpecial) return 'Must contain special character';
    
    return null;
  }),
]);
```

## Combining Modifier Rules

Modifier rules can be combined for powerful validation:

```dart
final schema = Validasi.string([
  Nullable(),                              // 1. Allow null
  Transform((value) => value?.trim()),     // 2. Clean data
  Transform((value) => value?.toLowerCase()), // 3. Normalize
  InlineRule<String>((value) {             // 4. Custom validation
    if (value != null && value.length < 3) {
      return 'Too short';
    }
    return null;
  }),
  StringRules.maxLength(50),               // 5. Type-specific rules
]);
```

## Best Practices

### 1. Order Your Rules Logically

```dart
final schema = Validasi.string([
  Nullable(),              // 1. Handle nulls first
  Required(),              // 2. Or require non-null
  Transform(...),          // 3. Transform data
  InlineRule(...),         // 4. Custom validation
  StringRules.minLength(3), // 5. Type-specific rules
]);
```

### 2. Use the Right Tool

```dart
// Simple custom validation → InlineRule
InlineRule<String>((value) => value.contains('@') ? null : 'Invalid email')

// Need context → Having
Having((context, value) => /* access context */)

// Data cleaning → Transform
Transform((value) => value?.trim())
```

### 3. Keep Rules Focused

```dart
// Good ✓ - Each rule has one purpose
final schema = Validasi.string([
  Transform((value) => value?.trim()),
  InlineRule<String>((value) {
    if (!value.contains('@')) return 'Must contain @';
    return null;
  }),
]);

// Less clear ✗ - Mixing concerns
final schema2 = Validasi.string([
  Transform((value) {
    final trimmed = value?.trim();
    if (trimmed != null && !trimmed.contains('@')) {
      // Don't validate in Transform!
    }
    return trimmed;
  }),
]);
```

### 4. Provide Clear Error Messages

```dart
// Good ✓
InlineRule<String>((value) {
  if (!value.contains(RegExp(r'[A-Z]'))) {
    return 'Password must contain at least one uppercase letter';
  }
  return null;
})

// Unclear ✗
InlineRule<String>((value) {
  if (!value.contains(RegExp(r'[A-Z]'))) {
    return 'Invalid';
  }
  return null;
})
```

## Type-Specific Rules

For rules specific to data types, see the dedicated pages:

<div class="vp-doc" style="margin-top: 2rem; display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem;">
  <a href="/guide/string-rules" class="vp-button vp-button-alt" style="display: block; text-align: center;">String Rules →</a>
  <a href="/guide/number-rules" class="vp-button vp-button-alt" style="display: block; text-align: center;">Number Rules →</a>
  <a href="/guide/iterable-rules" class="vp-button vp-button-alt" style="display: block; text-align: center;">Iterable Rules →</a>
  <a href="/guide/map-rules" class="vp-button vp-button-alt" style="display: block; text-align: center;">Map Rules →</a>
</div>



## Modifier Rules

Special rules that modify validation behavior:

### Nullable

Allows null values to pass validation.

```dart
import 'package:validasi/rules.dart';

final optionalNameSchema = Validasi.string([
  Nullable(),
  StringRules.minLength(3),
]);

print(optionalNameSchema.validate(null).isValid);    // true
print(optionalNameSchema.validate('John').isValid);  // true
print(optionalNameSchema.validate('Jo').isValid);    // false
```

### Required

Ensures value is not null (default behavior, explicit form).

```dart
final requiredNameSchema = Validasi.string([
  Required(),
  StringRules.minLength(3),
]);
```

### Transform

Transforms the value during validation.

```dart
final trimmedSchema = Validasi.string([
  Transform((value) => value?.trim()),
  StringRules.minLength(3),
]);

final result = trimmedSchema.validate('  hello  ');
print(result.data); // "hello" (trimmed)
```

See [Transformations](/guide/transformations) for more details.

### Having

Custom validation with context access.

```dart
final schema = Validasi.string([
  Having((context, value) {
    // Access validation context
    // Implement custom logic
    return null; // or error message
  }),
]);
```

### InlineRule

Create custom validation rules inline.

```dart
final passwordSchema = Validasi.string([
  InlineRule<String>((value) {
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Must contain uppercase letter';
    }
    return null;
  }),
]);
```

## Next Steps

- [Transformations](/guide/transformations) - Transform data during validation
- [Error Handling](/guide/error-handling) - Work with validation errors
- [Examples](/examples/string-validation) - See practical examples

<div style="margin-top: 3rem;">
  <a href="/guide/transformations" class="vp-button vp-button-brand">Learn Transformations →</a>
</div>
