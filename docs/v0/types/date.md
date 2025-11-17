# Date

The `Date` schema is used to validate the input value as a `DateTime`. This schema contains some useful built-in validators to validate the input value.

The following code shows how to create a `Date` schema:

::: code-group

```dart [Using Validasi]
Validasi.date();
```

```dart [Using Direct Class]
DateValidator();
```

:::

Below are the available methods for the `Date` schema:
[[toc]]

## DateUnit Enum

The `DateUnit` enum is used to specify the unit of the date difference.

```dart
enum DateUnit {
    day,
    month,
    year,
}
```

## before

```dart
Validasi.date().before(DateTime target, {DateUnit unit = DateUnit.day, int difference = 1, String? message});
```

The `before` method is used to validate that the input date is before the specified target date. This method will return an error message if the input date is not before the target date.

The `unit` parameter is used to specify the unit of the date difference. The default value is `DateUnit.day`. The `difference` parameter is used to specify the number of units to compare. The default value is `1`.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.date().before(DateTime(2023, 1, 1));

    final result = schema.tryParse(DateTime(2023, 1, 2));

    print(result.errors.first.message); // 'field must be before 2023-01-01'
}
```

## after

```dart
Validasi.date().after(DateTime target, {DateUnit unit = DateUnit.day, int difference = 1, String? message});
```

The `after` method is used to validate that the input date is after the specified target date. This method will return an error message if the input date is not after the target date.

The `unit` parameter is used to specify the unit of the date difference. The default value is `DateUnit.day`. The `difference` parameter is used to specify the number of units to compare. The default value is `1`.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.date().after(DateTime(2023, 1, 1));

    final result = schema.tryParse(DateTime(2022, 12, 31));

    print(result.errors.first.message); // 'field must be after 2023-01-01'
}
```

## beforeSame

```dart
Validasi.date().beforeSame(DateTime target, {DateUnit unit = DateUnit.day, String? message});
```

The `beforeSame` method is used to validate that the input date is before or the same as the specified target date. This method will return an error message if the input date is not before or the same as the target date.

The `unit` parameter is used to specify the unit of the date difference. The default value is `DateUnit.day`.

::: tip
This is similar to the `before` method, with `difference` set to `0`.
:::

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.date().beforeSame(DateTime(2023, 1, 1));

    final result = schema.tryParse(DateTime(2023, 1, 2));

    print(result.errors.first.message); // 'field must be before or equal 2023-01-01'
}
```

## afterSame

```dart
Validasi.date().afterSame(DateTime target, {DateUnit unit = DateUnit.day, String? message});
```

The `afterSame` method is used to validate that the input date is after or the same as the specified target date. This method will return an error message if the input date is not after or the same as the target date.

The `unit` parameter is used to specify the unit of the date difference. The default value is `DateUnit.day`.

::: tip
This is similar to the `after` method, with `difference` set to `0`.
:::

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.date().afterSame(DateTime(2023, 1, 1));

    final result = schema.tryParse(DateTime(2022, 12, 31));

    print(result.errors.first.message); // 'field must be after or equal 2023-01-01'
}
```