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

You can also have nesting schemas in the `Array` schema. The following code shows how to create a nested `Array` schema:

```dart
Validasi.array(Validasi.array(Validasi.string()));
```

::: info
The Array schema will reconstruct your input value accoring to the schema you provided. This allow you to take advantage of transformer in the schema
to convert the array value into the desired format.

```dart
Validasi.array(Validasi.number(transformer: NumberTransformer()));
```

Above code will convert the input value into a list of numbers.
:::

::: warning
Notice about `null` value. When the item on your array fail to validate, the item will be replaced with `null` value. This is to ensure the array length is still the same as the input value.

```dart
final schema = Validasi.array(Validasi.string());

final result = schema.tryParse(['a', 'b', 1]);

print(result.value); // ['a', 'b', null]
```

If this behaviour is not what you want, you might want to use `parse` variants instead (E.g. `parse` and `parseAsync`) to prevent the validator returning
result when error occurred.
:::

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

## max

```dart
Validasi.array(Validasi.string()).max(int length, {String? message});
```

The `max` method is used to validate the maximum number of items in the array. This method will return an error message if the array contains more items than the specified length.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.array(Validasi.string()).max(3);

    final result = schema.tryParse(['a', 'b', 'c', 'd']);

    print(result.errors.first.message); // 'field must have at most 3 items'
}
```

## contains

```dart
Validasi.array(Validasi.string()).contains(List<T> value, {String? message});
```

The `contains` method is used to validate that the array contains the specified value. This method will return an error if the array contains any value that is not in the specified list. 

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.array(Validasi.string()).contains(['a']);

    final result = schema.tryParse(['b', 'c']);

    print(result.errors.first.message); // 'field must contain a'
}
```

## notContains

```dart
Validasi.array(Validasi.string()).notContains(List<T> value, {String? message});
```

The `notContains` method is used to validate that the array does not contain the specified value. This method will return an error message if the array contains the specified value.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.array(Validasi.string()).notContains(['a']);

    final result = schema.tryParse(['a', 'b', 'c']);

    print(result.errors.first.message); // 'field must not contain a'
}
```

## unique

```dart
Validasi.array(Validasi.string()).unique({String? message});
```

The `unique` method is used to validate that all items in the array are unique. This method will return an error message if the array contains duplicate items.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.array(Validasi.string()).unique();

    final result = schema.tryParse(['a', 'b', 'a']);

    print(result.errors.first.message); // 'field must have unique items'
}
```