# Number Rules

Number validation rules for integer and double validation.

## NumberRules.moreThan()

Validates that a number is strictly greater than a specified value.

### Syntax

```dart
NumberRules.moreThan<T extends num>(T value, {String? message})
```

### Parameters

- **`value`** (T extends num, required) - The value that the input must be greater than
- **`message`** (String?, optional) - Custom error message

### Default Error Message

```
"Value must be more than {value}"
```

### Example

```dart
final priceSchema = Validasi.number<double>([
  NumberRules.moreThan(0.0, message: 'Price must be positive'),
]);

print(priceSchema.validate(0.01).isValid); // true
print(priceSchema.validate(0.0).isValid); // false
```

## NumberRules.moreThanEqual()

Validates that a number is greater than or equal to a specified value.

### Syntax

```dart
NumberRules.moreThanEqual<T extends num>(T value, {String? message})
```

### Parameters

- **`value`** (T extends num, required) - The minimum value allowed (inclusive)
- **`message`** (String?, optional) - Custom error message

### Default Error Message

```
"Value must be more than or equal to {value}"
```

### Example

```dart
final stockSchema = Validasi.number<int>([
  NumberRules.moreThanEqual(0, message: 'Stock cannot be negative'),
]);

print(stockSchema.validate(0).isValid); // true
print(stockSchema.validate(-1).isValid); // false
```

## NumberRules.lessThan()

Validates that a number is strictly less than a specified value.

### Syntax

```dart
NumberRules.lessThan<T extends num>(T value, {String? message})
```

### Parameters

- **`value`** (T extends num, required) - The value that the input must be less than
- **`message`** (String?, optional) - Custom error message

### Default Error Message

```
"Value must be less than {value}"
```

### Example

```dart
final temperatureSchema = Validasi.number<double>([
  NumberRules.lessThan(100.0, message: 'Temperature must be below boiling point'),
]);

print(temperatureSchema.validate(99.9).isValid); // true
print(temperatureSchema.validate(100.0).isValid); // false
```

## NumberRules.lessThanEqual()

Validates that a number is less than or equal to a specified value.

### Syntax

```dart
NumberRules.lessThanEqual<T extends num>(T value, {String? message})
```

### Parameters

- **`value`** (T extends num, required) - The maximum value allowed (inclusive)
- **`message`** (String?, optional) - Custom error message

### Default Error Message

```
"Value must be less than or equal to {value}"
```

### Example

```dart
final percentSchema = Validasi.number<double>([
  NumberRules.lessThanEqual(100.0, message: 'Percentage cannot exceed 100'),
]);

print(percentSchema.validate(100.0).isValid); // true
print(percentSchema.validate(100.1).isValid); // false
```

## NumberRules.finite()

Validates that a number is finite (not infinity or NaN).

### Syntax

```dart
NumberRules.finite({String? message})
```

### Parameters

- **`message`** (String?, optional) - Custom error message

### Default Error Message

```
"Value must be finite"
```

### Example

```dart
final schema = Validasi.number<double>([
  NumberRules.finite(message: 'Must be a valid number'),
]);

print(schema.validate(42.0).isValid); // true
print(schema.validate(double.infinity).isValid); // false
print(schema.validate(double.nan).isValid); // false
```

## See Also

- [Number Validation Examples](/examples/number-validation)
