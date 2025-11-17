# Number Validation Examples

Learn how to validate numbers (integers and doubles) with Validasi's number validation rules.

## Basic Number Validation

### Integer Validation

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

final ageSchema = Validasi.number<int>([
  NumberRules.moreThanEqual(0),
  NumberRules.lessThanEqual(150),
]);

// Valid
print(ageSchema.validate(25).isValid); // true
print(ageSchema.validate(0).isValid); // true

// Invalid
print(ageSchema.validate(-1).isValid); // false
print(ageSchema.validate(200).isValid); // false
```

### Double Validation

```dart
final priceSchema = Validasi.number<double>([
  NumberRules.moreThan(0.0),
  NumberRules.lessThan(1000000.0),
]);

// Valid
print(priceSchema.validate(99.99).isValid); // true
print(priceSchema.validate(0.01).isValid); // true

// Invalid
print(priceSchema.validate(0.0).isValid); // false
print(priceSchema.validate(-10.5).isValid); // false
```

## Comparison Rules

### Greater Than

```dart
final positiveSchema = Validasi.number<int>([
  NumberRules.moreThan(0),
]);

print(positiveSchema.validate(1).isValid); // true
print(positiveSchema.validate(0).isValid); // false
print(positiveSchema.validate(-1).isValid); // false
```

### Greater Than or Equal

```dart
final nonNegativeSchema = Validasi.number<int>([
  NumberRules.moreThanEqual(0),
]);

print(nonNegativeSchema.validate(0).isValid); // true
print(nonNegativeSchema.validate(1).isValid); // true
print(nonNegativeSchema.validate(-1).isValid); // false
```

### Less Than

```dart
final belowHundredSchema = Validasi.number<int>([
  NumberRules.lessThan(100),
]);

print(belowHundredSchema.validate(99).isValid); // true
print(belowHundredSchema.validate(100).isValid); // false
print(belowHundredSchema.validate(101).isValid); // false
```

### Less Than or Equal

```dart
final maxHundredSchema = Validasi.number<int>([
  NumberRules.lessThanEqual(100),
]);

print(maxHundredSchema.validate(100).isValid); // true
print(maxHundredSchema.validate(99).isValid); // true
print(maxHundredSchema.validate(101).isValid); // false
```

## Range Validation

### Simple Range

```dart
final percentageSchema = Validasi.number<int>([
  NumberRules.moreThanEqual(0),
  NumberRules.lessThanEqual(100),
]);

// Valid
print(percentageSchema.validate(0).isValid); // true
print(percentageSchema.validate(50).isValid); // true
print(percentageSchema.validate(100).isValid); // true

// Invalid
print(percentageSchema.validate(-1).isValid); // false
print(percentageSchema.validate(101).isValid); // false
```

### Exclusive Range

```dart
final temperatureSchema = Validasi.number<double>([
  NumberRules.moreThan(-273.15), // Above absolute zero
  NumberRules.lessThan(1000.0),
]);

print(temperatureSchema.validate(20.5).isValid); // true
print(temperatureSchema.validate(-273.15).isValid); // false
```

## Finite Number Validation

### Check for Finite Values

```dart
final finiteSchema = Validasi.number<double>([
  NumberRules.finite(),
]);

// Valid
print(finiteSchema.validate(42.0).isValid); // true
print(finiteSchema.validate(-123.456).isValid); // true
print(finiteSchema.validate(0.0).isValid); // true

// Invalid
print(finiteSchema.validate(double.infinity).isValid); // false
print(finiteSchema.validate(double.negativeInfinity).isValid); // false
print(finiteSchema.validate(double.nan).isValid); // false
```

### Combined with Range

```dart
final safeDoubleSchema = Validasi.number<double>([
  NumberRules.finite(),
  NumberRules.moreThanEqual(0.0),
]);

print(safeDoubleSchema.validate(123.45).isValid); // true
print(safeDoubleSchema.validate(double.infinity).isValid); // false
print(safeDoubleSchema.validate(-5.0).isValid); // false
```

## Number Transformations

### Absolute Value

```dart
final absSchema = Validasi.number<int>([
  Transform((value) => value?.abs()),
  NumberRules.lessThanEqual(100),
]);

final result = absSchema.validate(-50);
print(result.isValid); // true
print(result.data); // 50
```

### Rounding

```dart
final roundedSchema = Validasi.number<double>([
  Transform((value) => value?.roundToDouble()),
]);

final result = roundedSchema.validate(3.7);
print(result.data); // 4.0

final result2 = roundedSchema.validate(3.2);
print(result2.data); // 3.0
```

### Clamping

```dart
final clampedSchema = Validasi.number<int>([
  Transform((value) => value?.clamp(0, 100)),
]);

print(clampedSchema.validate(-10).data); // 0
print(clampedSchema.validate(50).data); // 50
print(clampedSchema.validate(150).data); // 100
```

### Precision Control

```dart
final precisionSchema = Validasi.number<double>([
  Transform((value) {
    if (value == null) return null;
    return (value * 100).round() / 100; // 2 decimal places
  }),
]);

final result = precisionSchema.validate(3.14159);
print(result.data); // 3.14
```

## Nullable Numbers

```dart
final optionalAgeSchema = Validasi.number<int>([
  Nullable(),
  NumberRules.moreThanEqual(0),
  NumberRules.lessThanEqual(150),
]);

// Valid
print(optionalAgeSchema.validate(null).isValid); // true
print(optionalAgeSchema.validate(25).isValid); // true

// Invalid
print(optionalAgeSchema.validate(-1).isValid); // false
```

## Real-World Examples

### Price Validation

```dart
final priceSchema = Validasi.number<double>([
  NumberRules.finite(),
  NumberRules.moreThan(0.0),
  NumberRules.lessThan(1000000.0),
  Transform((value) {
    // Round to 2 decimal places
    if (value == null) return null;
    return (value * 100).round() / 100;
  }),
]);

final result = priceSchema.validate(19.999);
print('Valid: ${result.isValid}');
print('Price: \$${result.data}'); // $20.0
```

### Rating System

```dart
final ratingSchema = Validasi.number<int>([
  NumberRules.moreThanEqual(1),
  NumberRules.lessThanEqual(5),
  InlineRule<int>((value) {
    final validRatings = [1, 2, 3, 4, 5];
    return validRatings.contains(value) 
      ? null 
      : 'Rating must be between 1 and 5';
  }),
]);

// Valid
print(ratingSchema.validate(5).isValid); // true

// Invalid
print(ratingSchema.validate(0).isValid); // false
print(ratingSchema.validate(6).isValid); // false
```

### Percentage Calculation

```dart
final percentSchema = Validasi.number<double>([
  NumberRules.moreThanEqual(0.0),
  NumberRules.lessThanEqual(100.0),
  Transform((value) {
    // Round to 1 decimal place
    if (value == null) return null;
    return (value * 10).round() / 10;
  }),
]);

final result = percentSchema.validate(75.678);
print('Percentage: ${result.data}%'); // 75.7%
```

### Temperature Validation

```dart
final celsiusSchema = Validasi.number<double>([
  NumberRules.moreThan(-273.15), // Absolute zero
  NumberRules.lessThan(1000.0),
  InlineRule<double>((value) {
    if (value < -100 || value > 100) {
      return 'Unusual temperature value';
    }
    return null;
  }),
]);

print(celsiusSchema.validate(25.5).isValid); // true
print(celsiusSchema.validate(-273.15).isValid); // false
```

### Age Validation

```dart
final ageSchema = Validasi.number<int>([
  NumberRules.moreThanEqual(0),
  NumberRules.lessThanEqual(150),
  InlineRule<int>((value) {
    if (value < 18) {
      return 'Must be at least 18 years old';
    }
    return null;
  }),
]);

print(ageSchema.validate(25).isValid); // true
print(ageSchema.validate(15).isValid); // false
```

### Quantity Validation

```dart
final quantitySchema = Validasi.number<int>([
  NumberRules.moreThan(0),
  NumberRules.lessThanEqual(999),
  InlineRule<int>((value) {
    if (value > 100) {
      return 'Large orders require special handling';
    }
    return null;
  }),
]);

print(quantitySchema.validate(5).isValid); // true
print(quantitySchema.validate(150).isValid); // false (warning)
```

### Discount Validation

```dart
final discountSchema = Validasi.number<double>([
  NumberRules.moreThanEqual(0.0),
  NumberRules.lessThan(100.0), // Can't discount 100%
  Transform((value) {
    // Ensure max 2 decimal places
    if (value == null) return null;
    return (value * 100).round() / 100;
  }),
]);

final result = discountSchema.validate(15.999);
print('Discount: ${result.data}%'); // 16.0%
```

### Coordinate Validation

```dart
final latitudeSchema = Validasi.number<double>([
  NumberRules.moreThanEqual(-90.0),
  NumberRules.lessThanEqual(90.0),
]);

final longitudeSchema = Validasi.number<double>([
  NumberRules.moreThanEqual(-180.0),
  NumberRules.lessThanEqual(180.0),
]);

// Valid coordinates
print(latitudeSchema.validate(37.7749).isValid); // true (SF)
print(longitudeSchema.validate(-122.4194).isValid); // true (SF)

// Invalid
print(latitudeSchema.validate(100.0).isValid); // false
```

## Custom Number Validations

### Even Numbers Only

```dart
final evenSchema = Validasi.number<int>([
  InlineRule<int>((value) {
    return value % 2 == 0 ? null : 'Must be an even number';
  }),
]);

print(evenSchema.validate(4).isValid); // true
print(evenSchema.validate(5).isValid); // false
```

### Multiple Of

```dart
final multipleOfFiveSchema = Validasi.number<int>([
  InlineRule<int>((value) {
    return value % 5 == 0 ? null : 'Must be a multiple of 5';
  }),
]);

print(multipleOfFiveSchema.validate(10).isValid); // true
print(multipleOfFiveSchema.validate(7).isValid); // false
```

### Prime Numbers

```dart
bool isPrime(int n) {
  if (n < 2) return false;
  for (int i = 2; i <= n ~/ 2; i++) {
    if (n % i == 0) return false;
  }
  return true;
}

final primeSchema = Validasi.number<int>([
  InlineRule<int>((value) {
    return isPrime(value) ? null : 'Must be a prime number';
  }),
]);

print(primeSchema.validate(7).isValid); // true
print(primeSchema.validate(8).isValid); // false
```

### Power of Two

```dart
final powerOfTwoSchema = Validasi.number<int>([
  NumberRules.moreThan(0),
  InlineRule<int>((value) {
    // Check if value is a power of 2
    return (value & (value - 1)) == 0 
      ? null 
      : 'Must be a power of 2';
  }),
]);

print(powerOfTwoSchema.validate(8).isValid); // true
print(powerOfTwoSchema.validate(10).isValid); // false
```

## String to Number Conversion

### Parse Integer

```dart
final parseIntSchema = Validasi.string([
  Transform((value) {
    if (value == null) return null;
    return int.tryParse(value);
  }),
]).pipe(
  Validasi.number<int>([
    Required(message: 'Invalid number format'),
    NumberRules.moreThanEqual(0),
  ])
);

final result = parseIntSchema.validate('42');
print('Valid: ${result.isValid}');
print('Number: ${result.data}'); // 42
```

### Parse Double with Validation

```dart
final parseDoubleSchema = Validasi.string([
  Transform((value) => value?.trim()),
  Transform((value) {
    if (value == null) return null;
    return double.tryParse(value);
  }),
]).pipe(
  Validasi.number<double>([
    Required(message: 'Invalid decimal number'),
    NumberRules.finite(),
    NumberRules.moreThanEqual(0.0),
  ])
);

final result = parseDoubleSchema.validate('  19.99  ');
print('Valid: ${result.isValid}');
print('Price: ${result.data}'); // 19.99
```

## Error Messages

### Custom Error Messages

```dart
final customSchema = Validasi.number<int>([
  NumberRules.moreThanEqual(
    0, 
    message: 'Value cannot be negative'
  ),
  NumberRules.lessThanEqual(
    100, 
    message: 'Value cannot exceed 100'
  ),
]);

final result = customSchema.validate(-5);
for (var error in result.errors) {
  print(error.message); // "Value cannot be negative"
}
```

### Context-Aware Messages

```dart
final scoreSchema = Validasi.number<int>([
  NumberRules.moreThanEqual(0),
  NumberRules.lessThanEqual(100),
  InlineRule<int>((value) {
    if (value < 50) {
      return 'Score is below passing grade (50)';
    }
    if (value < 70) {
      return 'Score is acceptable but could be improved';
    }
    return null; // Score is good
  }),
]);
```

## Next Steps

- [String Validation](/examples/string-validation)
- [List Validation](/examples/list-validation)
- [Map Validation](/examples/map-validation)
- [Complex Structures](/examples/complex-structures)
- [Number Rules Reference](/rules/number)
