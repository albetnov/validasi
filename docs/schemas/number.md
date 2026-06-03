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

## Combining Number Rules

You can combine range and safety checks in one schema.

```dart
final priceSchema = Validasi.number<double>([
	Rules.number.finite(),
	Rules.number.moreThan(0.0),
	Rules.number.lessThanEqual(9999.99),
]);

final result = priceSchema.validate(149.99);
print(result.isValid); // true
```
