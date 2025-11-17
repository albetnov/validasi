# Transformations

Transformations allow you to modify and preprocess data during validation. This powerful feature enables you to clean, normalize, and convert data before applying validation rules.

## Basic Transformations

### Transform Rule

The `Transform` rule modifies values as they pass through validation:

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

final schema = Validasi.string([
  Transform((value) => value?.trim()),
  StringRules.minLength(3),
]);

final result = schema.validate('  hello  ');
print(result.data); // "hello" (trimmed)
```

The transformed value is:
- Used for subsequent validation rules
- Returned in `result.data` if validation succeeds

## Common String Transformations

### Trimming Whitespace

```dart
final trimSchema = Validasi.string([
  Transform((value) => value?.trim()),
]);

print(trimSchema.validate('  text  ').data); // "text"
```

### Converting Case

```dart
// Lowercase
final lowercaseSchema = Validasi.string([
  Transform((value) => value?.toLowerCase()),
]);

print(lowercaseSchema.validate('HELLO').data); // "hello"

// Uppercase
final uppercaseSchema = Validasi.string([
  Transform((value) => value?.toUpperCase()),
]);

print(uppercaseSchema.validate('hello').data); // "HELLO"
```

### Normalizing Input

```dart
final normalizedEmailSchema = Validasi.string([
  Transform((value) => value?.trim()),
  Transform((value) => value?.toLowerCase()),
  StringRules.minLength(5),
]);

final result = normalizedEmailSchema.validate('  USER@EXAMPLE.COM  ');
print(result.data); // "user@example.com"
```

### Replacing Characters

```dart
final slugSchema = Validasi.string([
  Transform((value) => value?.trim()),
  Transform((value) => value?.toLowerCase()),
  Transform((value) => value?.replaceAll(RegExp(r'\s+'), '-')),
  Transform((value) => value?.replaceAll(RegExp(r'[^a-z0-9-]'), '')),
]);

final result = slugSchema.validate('Hello World! 2024');
print(result.data); // "hello-world-2024"
```

## Chaining Transformations

Multiple `Transform` rules execute in order:

```dart
final schema = Validasi.string([
  Nullable(),
  Transform((value) => value?.trim()),           // 1. Remove whitespace
  Transform((value) => value?.toLowerCase()),    // 2. Convert to lowercase
  Transform((value) => value?.replaceAll(' ', '-')), // 3. Replace spaces
  StringRules.minLength(3),                      // 4. Then validate
]);

final result = schema.validate('  Hello World  ');
print(result.data); // "hello-world"
```

::: tip Order Matters
Place `Transform` rules before validation rules to ensure the transformed value is validated, not the original.
:::

## Preprocessing with ValidasiTransformation

For type conversion before validation, use `withPreprocess`:

```dart
import 'package:validasi/transformer.dart';

final schema = Validasi.string([
  StringRules.minLength(3),
]).withPreprocess(
  ValidasiTransformation((value) => value.toString()),
);

// Converts number to string, then validates
final result = schema.validate(12345);
print(result.isValid); // true
print(result.data);    // "12345"
```

### Type Conversion Examples

**Number to String:**

```dart
final numberToStringSchema = Validasi.string([
  StringRules.minLength(1),
]).withPreprocess(
  ValidasiTransformation((value) => value.toString()),
);

print(numberToStringSchema.validate(42).data); // "42"
```

**String to Number:**

```dart
final stringToNumberSchema = Validasi.number<int>([
  NumberRules.moreThan(0),
]).withPreprocess(
  ValidasiTransformation((value) {
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return value;
  }),
);

print(stringToNumberSchema.validate('42').data); // 42
```

**JSON String to Map:**

```dart
import 'dart:convert';

final jsonSchema = Validasi.map<dynamic>([
  MapRules.hasFieldKeys({'name', 'age'}),
]).withPreprocess(
  ValidasiTransformation((value) {
    if (value is String) {
      return jsonDecode(value);
    }
    return value;
  }),
);

final result = jsonSchema.validate('{"name":"John","age":30}');
print(result.data); // {name: John, age: 30}
```

## Practical Transformation Examples

### Email Normalization

```dart
final emailSchema = Validasi.string([
  Transform((value) => value?.trim()),
  Transform((value) => value?.toLowerCase()),
  StringRules.minLength(5),
  InlineRule<String>((value) {
    if (!value.contains('@')) {
      return 'Invalid email format';
    }
    return null;
  }),
]);

final result = emailSchema.validate('  USER@EXAMPLE.COM  ');
print(result.data); // "user@example.com"
```

### Phone Number Cleaning

```dart
final phoneSchema = Validasi.string([
  Transform((value) => value?.replaceAll(RegExp(r'[\s\-\(\)]'), '')),
  StringRules.minLength(10),
  InlineRule<String>((value) {
    if (!RegExp(r'^\+?\d+$').hasMatch(value)) {
      return 'Invalid phone number';
    }
    return null;
  }),
]);

final result = phoneSchema.validate('(555) 123-4567');
print(result.data); // "5551234567"
```

### Username Normalization

```dart
final usernameSchema = Validasi.string([
  Transform((value) => value?.trim()),
  Transform((value) => value?.toLowerCase()),
  Transform((value) => value?.replaceAll(RegExp(r'\s+'), '_')),
  StringRules.minLength(3),
  StringRules.maxLength(20),
  InlineRule<String>((value) {
    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }),
]);

final result = usernameSchema.validate('  John Doe  ');
print(result.data); // "john_doe"
```

### Price Formatting

```dart
final priceSchema = Validasi.number<double>([
  NumberRules.moreThan(0.0),
]).withPreprocess(
  ValidasiTransformation((value) {
    if (value is String) {
      // Remove currency symbols and parse
      final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return value;
  }),
);

print(priceSchema.validate('$99.99').data);   // 99.99
print(priceSchema.validate('€149.50').data);  // 149.5
```

### Date String to DateTime

```dart
final dateSchema = Validasi.any<DateTime>([
  InlineRule<DateTime>((value) {
    if (value.isAfter(DateTime.now())) {
      return 'Date cannot be in the future';
    }
    return null;
  }),
]).withPreprocess(
  ValidasiTransformation((value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return value;
  }),
);

final result = dateSchema.validate('2024-01-15');
print(result.data); // DateTime object
```

## Complex Transformations

### Nested Map Transformations

```dart
final userSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'email': Validasi.string([
      Transform((value) => value?.trim().toLowerCase()),
      StringRules.minLength(5),
    ]),
    'name': Validasi.string([
      Transform((value) => value?.trim()),
      Transform((value) {
        // Capitalize first letter of each word
        return value?.split(' ')
          .map((word) => word.isEmpty ? '' : 
            word[0].toUpperCase() + word.substring(1).toLowerCase())
          .join(' ');
      }),
    ]),
    'tags': Validasi.list<String>([
      IterableRules.forEach(
        Validasi.string([
          Transform((value) => value?.trim().toLowerCase()),
        ]),
      ),
    ]),
  }),
]);

final result = userSchema.validate({
  'email': '  USER@EXAMPLE.COM  ',
  'name': 'john doe',
  'tags': ['  Flutter  ', '  DART  '],
});

print(result.data);
// {
//   email: "user@example.com",
//   name: "John Doe",
//   tags: ["flutter", "dart"]
// }
```

### Conditional Transformations

```dart
final schema = Validasi.string([
  Transform((value) {
    if (value == null) return null;
    
    // Only trim if value starts/ends with whitespace
    if (value.startsWith(' ') || value.endsWith(' ')) {
      return value.trim();
    }
    
    return value;
  }),
  StringRules.minLength(3),
]);
```

## Transformation with Nullable

When using `Nullable()`, handle null in transformations:

```dart
final schema = Validasi.string([
  Nullable(),
  Transform((value) => value?.trim()), // Safe navigation
  Transform((value) => value?.toLowerCase()),
]);

print(schema.validate(null).isValid);      // true
print(schema.validate(null).data);         // null
print(schema.validate('  HELLO  ').data);  // "hello"
```

## Performance Considerations

### Efficient Transformations

```dart
// Good ✓ - Single transformation
final efficient = Validasi.string([
  Transform((value) {
    if (value == null) return null;
    return value.trim().toLowerCase().replaceAll(' ', '-');
  }),
]);

// Less efficient ✗ - Multiple transformations
final lessEfficient = Validasi.string([
  Transform((value) => value?.trim()),
  Transform((value) => value?.toLowerCase()),
  Transform((value) => value?.replaceAll(' ', '-')),
]);
```

However, multiple transformations are fine for readability:

```dart
// More readable, slight performance cost
final readable = Validasi.string([
  Transform((value) => value?.trim()),      // Clear intent
  Transform((value) => value?.toLowerCase()), // Clear intent
  Transform((value) => value?.replaceAll(' ', '-')), // Clear intent
]);
```

## Best Practices

### 1. Order Your Rules

```dart
final schema = Validasi.string([
  Nullable(),              // 1. Handle nulls first
  Transform((value) => value?.trim()), // 2. Clean data
  StringRules.minLength(3), // 3. Then validate
]);
```

### 2. Use Safe Navigation

```dart
// Good ✓
Transform((value) => value?.trim())

// May throw ✗
Transform((value) => value.trim())
```

### 3. Keep Transformations Pure

Transformations should not have side effects:

```dart
// Good ✓
Transform((value) => value?.toLowerCase())

// Avoid ✗
Transform((value) {
  saveToDatabase(value); // Side effect!
  return value;
})
```

### 4. Document Complex Logic

```dart
final schema = Validasi.string([
  Transform((value) {
    // Normalize whitespace: trim and collapse multiple spaces
    return value?.trim().replaceAll(RegExp(r'\s+'), ' ');
  }),
]);
```

## Next Steps

- [Error Handling](/guide/error-handling) - Handle validation errors
- [Examples](/examples/string-validation) - See more examples
- [Advanced](/advanced/custom-rule) - Create custom rules

<div style="margin-top: 3rem;">
  <a href="/guide/error-handling" class="vp-button vp-button-brand">Error Handling →</a>
</div>
