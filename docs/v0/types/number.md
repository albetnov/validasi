# Number

The `Number` schema is used to validate the input value as a number. This schema contains some useful built-in validators to validate the input value.

The following code shows how to create a `Number` schema:

::: code-group

```dart [Using Validasi]
Validasi.number();
```

```dart [Using Direct Class]
NumberValidator();
```

:::

::: info
The `Number` schema is based on [`num`](https://api.dart.dev/stable/3.5.3/dart-core/num-class.html). Which could represent
both `int` and `double` values.
:::

Below are the available methods for the `Number` schema:
[[toc]]

## nonDecimal

```dart
Validasi.number().nonDecimal({String? message});
```

The `nonDecimal` method is used to validate that the input value is a non-decimal number. This method will return an error message if the input value is a decimal number.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.number().nonDecimal();

    final result = schema.tryParse(3.14);

    print(result.errors.first.message); // 'field must be non-decimal number'
}
```

## decimal

```dart
Validasi.number().decimal({String? message});
```

The `decimal` method is used to validate that the input value is a decimal number. This method will return an error message if the input value is not a decimal number.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.number().decimal();

    final result = schema.tryParse(3);

    print(result.errors.first.message); // 'field must be decimal number'
}
```

## positive

```dart
Validasi.number().positive({String? message});
```

The `positive` method is used to validate that the input value is a positive number. This method will return an error message if the input value is not a positive number.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.number().positive();

    final result = schema.tryParse(-1);

    print(result.errors.first.message); // 'field must be positive number'
}
```

## negative

```dart
Validasi.number().negative({String? message});
```

The `negative` method is used to validate that the input value is a negative number. This method will return an error message if the input value is not a negative number.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.number().negative();

    final result = schema.tryParse(1);

    print(result.errors.first.message); // 'field must be negative number'
}
```

## nonPositive

```dart
Validasi.number().nonPositive({String? message});
```

The `nonPositive` method is used to validate that the input value is a non-positive number. This method will return an error message if the input value is a positive number.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.number().nonPositive();

    final result = schema.tryParse(1);

    print(result.errors.first.message); // 'field must be non-positive number'
}
```

## nonNegative

```dart
Validasi.number().nonNegative({String? message});
```

The `nonNegative` method is used to validate that the input value is a non-negative number. This method will return an error message if the input value is a negative number.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.number().nonNegative();

    final result = schema.tryParse(-1);

    print(result.errors.first.message); // 'field must be non-negative number'
}
```

## gt

```dart
Validasi.number().gt(num min, {String? message});
```

The `gt` method is used to validate that the input value is greater than the specified minimum value. This method will return an error message if the input value is not greater than the specified minimum value.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.number().gt(5);

    final result = schema.tryParse(3);

    print(result.errors.first.message); // 'field must be greater than 5'
}
```

## gte

```dart
Validasi.number().gte(num min, {String? message});
```

The `gte` method is used to validate that the input value is greater than or equal to the specified minimum value. This method will return an error message if the input value is not greater than or equal to the specified minimum value.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.number().gte(5);

    final result = schema.tryParse(3);

    print(result.errors.first.message); // 'field must be greater than or equal to 5'
}
```

## lt

```dart
Validasi.number().lt(num max, {String? message});
```

The `lt` method is used to validate that the input value is less than the specified maximum value. This method will return an error message if the input value is not less than the specified maximum value.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.number().lt(5);

    final result = schema.tryParse(7);

    print(result.errors.first.message); // 'field must be less than 5'
}
```

## lte

```dart
Validasi.number().lte(num max, {String? message});
```

The `lte` method is used to validate that the input value is less than or equal to the specified maximum value. This method will return an error message if the input value is not less than or equal to the specified maximum value.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.number().lte(5);

    final result = schema.tryParse(7);

    print(result.errors.first.message); // 'field must be less than or equal to 5'
}
```

## finite

```dart
Validasi.number().finite({String? message});
```

The `finite` method is used to validate that the input value is a finite number. This method will return an error message if the input value is not a finite number.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.number().finite();

    final result = schema.tryParse(double.infinity);

    print(result.errors.first.message); // 'field must be finite number'
}
```