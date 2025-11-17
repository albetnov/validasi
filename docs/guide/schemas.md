# Validation Schemas

Schemas are the foundation of Validasi. They define the structure and rules for validating your data. This guide covers all schema types and how to use them effectively.

## Schema Types

Validasi provides five main schema types, each optimized for specific data types:

### String Schema

Validate string values with `Validasi.string()`:

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

final nameSchema = Validasi.string([
  StringRules.minLength(2),
  StringRules.maxLength(50),
]);

final result = nameSchema.validate('John Doe');
print(result.isValid); // true
print(result.data);    // "John Doe"
```

**Common Use Cases:**
- User names and usernames
- Email addresses
- Passwords
- Text input validation
- URL and pattern validation

### Number Schema

Validate numeric values with `Validasi.number<T>()`:

```dart
final ageSchema = Validasi.number<int>([
  NumberRules.moreThanEqual(0),
  NumberRules.lessThan(150),
]);

final priceSchema = Validasi.number<double>([
  NumberRules.moreThan(0.0),
  NumberRules.finite(), // Ensures not infinity or NaN
]);

print(ageSchema.validate(25).isValid);    // true
print(priceSchema.validate(99.99).isValid); // true
```

**Supported Number Types:**
- `int` - Integer values
- `double` - Floating-point values
- `num` - Any numeric value

### List Schema

Validate lists and iterables with `Validasi.list<T>()`:

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

final result = tagsSchema.validate(['flutter', 'dart', 'mobile']);
print(result.isValid); // true
```

**Nested List Validation:**

```dart
// Validate list of lists
final matrixSchema = Validasi.list<List<int>>([
  IterableRules.forEach(
    Validasi.list<int>([
      IterableRules.forEach(
        Validasi.number<int>([
          NumberRules.moreThanEqual(0),
        ]),
      ),
    ]),
  ),
]);

final matrix = [
  [1, 2, 3],
  [4, 5, 6],
  [7, 8, 9],
];

print(matrixSchema.validate(matrix).isValid); // true
```

### Map Schema

Validate maps and objects with `Validasi.map<T>()`:

```dart
final userSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'name': Validasi.string([
      StringRules.minLength(1),
    ]),
    'email': Validasi.string([
      StringRules.minLength(1),
    ]),
    'age': Validasi.number<int>([
      NumberRules.moreThanEqual(18),
    ]),
  }),
]);

final userData = {
  'name': 'Alice',
  'email': 'alice@example.com',
  'age': 25,
};

final result = userSchema.validate(userData);
print(result.isValid); // true
```

**Nested Map Validation:**

```dart
final addressSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'street': Validasi.string([
      StringRules.minLength(1),
    ]),
    'city': Validasi.string([
      StringRules.minLength(1),
    ]),
    'country': Validasi.string([
      StringRules.minLength(1),
    ]),
    'coordinates': Validasi.map<dynamic>([
      MapRules.hasFields({
        'lat': Validasi.number<double>([
          NumberRules.moreThanEqual(-90.0),
          NumberRules.lessThanEqual(90.0),
        ]),
        'lng': Validasi.number<double>([
          NumberRules.moreThanEqual(-180.0),
          NumberRules.lessThanEqual(180.0),
        ]),
      }),
    ]),
  }),
]);
```

### Any Schema

Validate any type with `Validasi.any<T>()`:

```dart
// Boolean validation
final termsSchema = Validasi.any<bool>([
  InlineRule<bool>((value) {
    return value == true ? null : 'You must accept the terms';
  }),
]);

// Custom type validation
final customSchema = Validasi.any<DateTime>([
  InlineRule<DateTime>((value) {
    if (value.isAfter(DateTime.now())) {
      return 'Date cannot be in the future';
    }
    return null;
  }),
]);
```

## Schema Composition

Schemas can be composed and reused to build complex validations:

```dart
// Reusable email schema
final emailSchema = Validasi.string([
  Transform((value) => value?.trim().toLowerCase()),
  StringRules.minLength(5),
  InlineRule<String>((value) {
    if (!value.contains('@')) {
      return 'Invalid email format';
    }
    return null;
  }),
]);

// Reusable password schema
final passwordSchema = Validasi.string([
  StringRules.minLength(8),
  InlineRule<String>((value) {
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Must contain uppercase letter';
    }
    return null;
  }),
]);

// Compose into registration schema
final registrationSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'email': emailSchema,
    'password': passwordSchema,
    'confirmPassword': passwordSchema,
  }),
  // Add custom validation
  InlineRule<Map<String, dynamic>>((value) {
    if (value['password'] != value['confirmPassword']) {
      return 'Passwords do not match';
    }
    return null;
  }),
]);
```

## Validation Results

Every schema validation returns a `ValidasiResult` object:

```dart
final result = schema.validate(data);

// Check if valid
if (result.isValid) {
  print('Valid! Data: ${result.data}');
} else {
  print('Invalid! Errors: ${result.errors}');
}
```

### ValidasiResult Properties

- **`isValid`** - `bool`: Whether validation passed
- **`data`** - `T`: The validated (possibly transformed) data
- **`errors`** - `List<ValidasiError>`: List of validation errors

### ValidasiError Properties

- **`message`** - `String`: The error message
- **`path`** - `List<String>?`: Path to the field that failed (for nested structures)

**Example with nested errors:**

```dart
final result = userSchema.validate({
  'profile': {
    'name': '', // Too short
    'age': -5,  // Invalid
  }
});

for (var error in result.errors) {
  print('Error at ${error.path?.join('.')}: ${error.message}');
}
// Output:
// Error at profile.name: String must be at least 1 characters long
// Error at profile.age: Number must be more than or equal to 0
```

## Best Practices

### 1. Create Reusable Schemas

```dart
// Define once
class Schemas {
  static final email = Validasi.string([
    Transform((value) => value?.trim().toLowerCase()),
    StringRules.minLength(5),
  ]);
  
  static final positiveInt = Validasi.number<int>([
    NumberRules.moreThan(0),
  ]);
}

// Use everywhere
final userSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'email': Schemas.email,
    'age': Schemas.positiveInt,
  }),
]);
```

### 2. Use Type Parameters

Always specify type parameters for type safety:

```dart
// Good ✓
final intList = Validasi.list<int>([...]);
final userData = Validasi.map<dynamic>([...]);

// Avoid ✗
final list = Validasi.list([...]); // Less type-safe
```

### 3. Order Rules Logically

Place transformation rules before validation rules:

```dart
final schema = Validasi.string([
  Nullable(),           // 1. Handle nulls first
  Transform(...),       // 2. Transform data
  StringRules.minLength(3), // 3. Then validate
]);
```

### 4. Provide Custom Error Messages

Make errors user-friendly:

```dart
final schema = Validasi.string([
  StringRules.minLength(8, 
    message: 'Password must be at least 8 characters'),
  StringRules.maxLength(128,
    message: 'Password is too long (max 128 characters)'),
]);
```

## Next Steps

- [Built-in Rules](/guide/rules) - Explore all available validation rules
- [Transformations](/guide/transformations) - Learn about data transformation
- [Error Handling](/guide/error-handling) - Handle validation errors effectively

<div style="margin-top: 3rem;">
  <a href="/guide/rules" class="vp-button vp-button-brand">Learn About Rules →</a>
</div>
