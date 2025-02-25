# Helpers

Validasi provides a few helper classes to help you for Flutter Development.

## FieldValidator

The `FieldValidator` is a class that can be used to validate a single schema. This class is useful since you can
get first error message from the schema directly.

```dart
import 'package:validasi/validasi.dart';

final schema = Validasi.string().minLength(3);

TextFormField(
    validator: FieldValidator(schema).validate,
);
```

::: info
For asyncronous validation, you can use `validateAsync` method instead.
:::

## GroupValidator

The `GroupValidator` is a wrapper around the `FieldValidator` that can be used to nicely grouped some schema
together. This class is useful when you have multiple schema and you want to place them in one place.

```dart
import 'package:validasi/validasi.dart';

final schema = GroupValidator({
    'name': Validasi.string().minLength(3),
    'email': Validasi.string().email(),
});

TextFormField(
    validator: schema.on('name').validate,
);

TextFormField(
    validator: (value) => schema.on('email').validate,
);
```

::: info
For asyncronous validation, you can use `validateAsync` method instead.
:::

## Customizing The Path Error Message

You can customize the path error message by passing the `path` parameter to the `FieldValidator` or `GroupValidator`:

```dart
import 'package:validasi/validasi.dart';

FieldValidator(Validasi.string(), path: 'Custom Path').validate('Invalid Value');
GroupValidator({
    'name': Validasi.string().minLength(3),
    'email': Validasi.string().email(),
}).on('name', path: 'Custom Path').validate('Invalid Value');
```