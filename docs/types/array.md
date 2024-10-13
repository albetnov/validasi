# Array

The `Array` schema is used to validate the input value as an array or `List`. This schema contains some useful built-in validators to validate the input value.

The following code shows how to create an `Array` schema:

::: code-group

```dart [Using Validasi]
Validasi.array(Validasi.string());
```

```dart [Using Direct Class]
ArrayValidator(StringValidator());
```

:::

The `Array` schema requires a schema parameter to validate the items in the array. The schema parameter is used to validate each item in the array.

WIP: tell about nesting, reconstruction (casting, etc), and null value.

Below are the available methods for the `Array` schema:
[[toc]]

## min

```dart
Validasi.array(Validasi.string()).min(int length, {String? message});
```

The `min` method is used to validate the minimum number of items in the array. This method will return an error message if the array contains fewer items than the specified length.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.array(Validasi.string()).min(3);

    final result = schema.tryParse(['a', 'b']);

    print(result.errors.first.message); // 'field must have at least 3 items'
}
```
