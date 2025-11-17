# String

The `String` schema is used to validate the input value as a string. This schema contains some useful built-in validators to validate the input value.

The following code shows how to create a `String` schema:

::: code-group

```dart [Using Validasi]
Validasi.string();
```

```dart [Using Direct Class]
StringValidator();
```

:::

Below are the available methods for the `String` schema:
[[toc]]

## minLength

```dart
Validasi.string().minLength(int length, {String? message});
```

The `minLength` method is used to validate the minimum length of the input value. This method will return an error message if the input value is less than the specified length.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.string().minLength(3);

    final result = schema.tryParse('hi');

    print(result.errors.first.message); // 'field must contains at least 3 characters'
}
```

## maxLength

```dart
Validasi.string().maxLength(int length, {String? message});
```

The `maxLength` method is used to validate the maximum length of the input value. This method will return an error message if the input value is more than the specified length.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.string().maxLength(3);

    final result = schema.tryParse('hello');

    print(result.errors.first.message); // 'field must not be longer than 3 characters'
}
```

## email

```dart
Validasi.string().email({bool allowTopLevelDomain = false, bool allowInternational = false,String? message});
```

The `email` method is used to validate the input value as an email. This method will return an error message if the input value is not a valid email. By default, the `allowTopLevelDomain` and `allowInternational` parameters are set to `false`.

Setting `allowTopLevelDomain` to `true` will allow the email to have a top-level domain (e.g., `.com`, `.net`, `.org`) to be omitted. Setting `allowInternational` to `true` will allow the email to have international characters.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.string().email();

    final result = schema.tryParse('hello@world');

    print(result.errors.first.message); // 'field must be a valid email'
}
```

## startsWith

```dart
Validasi.string().startsWith(String text, {String? message});
```

The `startsWith` method is used to validate the input value to start with the specified text. This method will return an error message if the input value does not start with the specified text.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.string().startsWith('hello');

    final result = schema.tryParse('world');

    print(result.errors.first.message); // 'field must start with "hello"'
}
```

## endsWith

```dart
Validasi.string().endsWith(String text, {String? message});
```

The `endsWith` method is used to validate the input value to end with the specified text. This method will return an error message if the input value does not end with the specified text.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.string().endsWith('world');

    final result = schema.tryParse('hello');

    print(result.errors.first.message); // 'field must end with "world"'
}
```

## contains

```dart
Validasi.string().contains(String text, {String? message});
```

The `contains` method is used to validate the input value to contain the specified text. This method will return an error message if the input value does not contain the specified text.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.string().contains('world');

    final result = schema.tryParse('hello');

    print(result.errors.first.message); // 'field must contains "world"'
}
```

## url

```dart
Validasi.string().url({String? message, List<UrlChecks> checks = const [UrlChecks.scheme, UrlChecks.host]});
```

The `url` method is used to validate the input value as a URL. This method will return an error message if the input value is not a valid URL.
Additionally, you can specify the `checks` parameter to validate the URL with specific checks. The available checks are:
- `UrlChecks.scheme`: Check if the URL has a valid scheme (e.g., `http`, `https`).
- `UrlChecks.host`: Check if the URL has a valid host (e.g., `example.com`).
- `UrlChecks.httpsOnly`: Check if the URL is using HTTPS scheme.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.string().url(
        checks: [...defaultUrlChecks, UrlChecks.httpsOnly]
    );

    final result = schema.tryParse('hello');

    print(result.errors.first.message); // 'field must be a valid URL'
}
```

## regex

```dart
Validasi.string().regex(String pattern, {String? message});
```

The `regex` method is used to validate the input value using a regular expression pattern. This method will return an error message if the input value does not match the specified pattern.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.string().regex(r'^[0-9]+$');

    final result = schema.tryParse('hello');

    print(result.errors.first.message); // 'field must match the pattern'
}
```