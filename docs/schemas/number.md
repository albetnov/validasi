# Number Schema

Use `Validasi.number<T>()` to validate numeric values.

`T` must extend `num`, so you can choose the exact numeric type you want:

- `Validasi.number<int>(...)` for integers
- `Validasi.number<double>(...)` for floating-point values
- `Validasi.number<num>(...)` for mixed numeric values

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

final intSchema = Validasi.number<int>([
	Rules.number.moreThanEqual(0),
]);

final doubleSchema = Validasi.number<double>([
	Rules.number.moreThan(0.0),
]);
```

## Available Rules

### Rules.number.moreThan

Ensures the value is strictly greater than a minimum.

```dart
final positiveSchema = Validasi.number<int>([
	Rules.number.moreThan(0),
]);

print(positiveSchema.validate(1).isValid); // true
print(positiveSchema.validate(0).isValid); // false
```

### Rules.number.moreThanEqual

Ensures the value is greater than or equal to a minimum.

```dart
final nonNegativeSchema = Validasi.number<int>([
	Rules.number.moreThanEqual(0),
]);

print(nonNegativeSchema.validate(0).isValid); // true
print(nonNegativeSchema.validate(-1).isValid); // false
```

### Rules.number.lessThan

Ensures the value is strictly less than a maximum.

```dart
final belowHundredSchema = Validasi.number<int>([
	Rules.number.lessThan(100),
]);

print(belowHundredSchema.validate(99).isValid); // true
print(belowHundredSchema.validate(100).isValid); // false
```

### Rules.number.lessThanEqual

Ensures the value is less than or equal to a maximum.

```dart
final maxHundredSchema = Validasi.number<int>([
	Rules.number.lessThanEqual(100),
]);

print(maxHundredSchema.validate(100).isValid); // true
print(maxHundredSchema.validate(101).isValid); // false
```

### Rules.number.finite

Ensures a `double` value is finite (not `NaN`, `Infinity`, or `-Infinity`).

```dart
final finiteDoubleSchema = Validasi.number<double>([
	Rules.number.finite(),
]);

print(finiteDoubleSchema.validate(10.5).isValid); // true
print(finiteDoubleSchema.validate(double.infinity).isValid); // false
```

### Rules.number.integer

Ensures the value is a finite integer.

```dart
final intSchema = Validasi.number<int>([
	Rules.number.integer(),
]);

print(intSchema.validate(42).isValid); // true
print(intSchema.validate(-10).isValid); // true
```

### Rules.number.decimal

Ensures the value is a finite decimal (double).

```dart
final doubleSchema = Validasi.number<double>([
	Rules.number.decimal(),
]);

print(doubleSchema.validate(3.14).isValid); // true
print(doubleSchema.validate(double.infinity).isValid); // false
```

### Rules.number.positive

Ensures the value is strictly greater than zero.

```dart
final positiveSchema = Validasi.number<int>([
	Rules.number.positive(),
]);

print(positiveSchema.validate(1).isValid); // true
print(positiveSchema.validate(0).isValid); // false
print(positiveSchema.validate(-1).isValid); // false
```

### Rules.number.negative

Ensures the value is strictly less than zero.

```dart
final negativeSchema = Validasi.number<int>([
	Rules.number.negative(),
]);

print(negativeSchema.validate(-1).isValid); // true
print(negativeSchema.validate(0).isValid); // false
print(negativeSchema.validate(1).isValid); // false
```

### Rules.number.nonPositive

Ensures the value is less than or equal to zero.

```dart
final nonPositiveSchema = Validasi.number<int>([
	Rules.number.nonPositive(),
]);

print(nonPositiveSchema.validate(-1).isValid); // true
print(nonPositiveSchema.validate(0).isValid); // true
print(nonPositiveSchema.validate(1).isValid); // false
```

### Rules.number.nonNegative

Ensures the value is greater than or equal to zero.

```dart
final nonNegativeSchema = Validasi.number<int>([
	Rules.number.nonNegative(),
]);

print(nonNegativeSchema.validate(1).isValid); // true
print(nonNegativeSchema.validate(0).isValid); // true
print(nonNegativeSchema.validate(-1).isValid); // false
```

### Rules.number.between

Ensures the value is within an inclusive range.

```dart
final ageSchema = Validasi.number<int>([
	Rules.number.between(0, 120),
]);

print(ageSchema.validate(25).isValid); // true
print(ageSchema.validate(0).isValid); // true
print(ageSchema.validate(120).isValid); // true
print(ageSchema.validate(-1).isValid); // false
print(ageSchema.validate(121).isValid); // false
```

## Combining Number Rules

You can combine range and safety checks in one schema.

```dart
final priceSchema = Validasi.number<double>([
	Rules.number.decimal(),
	Rules.number.positive(),
	Rules.number.lessThanEqual(9999.99),
]);

final result = priceSchema.validate(149.99);
print(result.isValid); // true
```
