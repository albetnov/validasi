# Generic

The Generic Validation is a new feature provided in Validasi starting from version 0.0.4. This new validation allow you to validate any type of data
for instance checking, transforming, and etc. The `GenericValidator` expect `T` as the type to validate against.

Available rules for `GenericValidator`:

[[toc]]

## `equalTo`

```dart
Validasi.generic<T>(transformer).equalTo(T value, {String? message});
```

The `equalTo` method is used to validate that the value is equal to the specified value. This method will return an error if the value is not equal to the specified value.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.generic<String>().equalTo('a');

    final result = schema.tryParse('b');

    print(result.errors.first.message); // 'field must be equal to a'
}
```

::: info
The equality check uses `==` operator to compare the value. Therefore, it is recommended for you to override the `==` operator in your custom class to ensure the equality check works as expected.
:::

## `notEqualTo`

```dart
Validasi.generic<T>(transformer).notEqualTo(T value, {String? message});
```

The `notEqualTo` method is used to validate that the value is not equal to the specified value. This method will return an error message if the value is equal to the specified value.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.generic<String>().notEqualTo('a');

    final result = schema.tryParse('a');

    print(result.errors.first.message); // 'field must not be equal to a'
}
```

::: info
Similar to `equalTo`, the equality check uses `!=` operator to compare the value. Therefore, it is recommended for you to override the `==` operator in your custom class to ensure the equality check works as expected.
:::

## `oneOf`

```dart
Validasi.generic<T>(transformer).oneOf(List<T> values, {String? message});
```

The `oneOf` method is used to validate that the value is one of the specified values. This method will return an error message if the value is not in the specified list.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.generic<String>().oneOf(['a', 'b']);

    final result = schema.tryParse('c');

    print(result.errors.first.message); // 'field must be one of a, b'
}
```

::: info
Similar to `equalTo` but with multiple values. It will return an error message if the value is not in the specified list.
:::

## `notOneOf`

```dart
Validasi.generic<T>(transformer).notOneOf(List<T> values, {String? message});
```

The `notOneOf` method is used to validate that the value is not one of the specified values. This method will return an error message if the value is in the specified list.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.generic<String>().notOneOf(['a', 'b']);

    final result = schema.tryParse('a');

    print(result.errors.first.message); // 'field must not be one of a, b'
}
```

::: info
Just like oneOf, but the opposite. It will return an error message if the value is in the specified list.
:::