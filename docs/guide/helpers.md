# Helpers

Validasi provides a few helper classes to help you for Flutter Development.

## FieldValidator

The `FieldValidator` is a class that can be used to validate a single schema. This class is useful since you can
get first error message from the schema directly.

```dart
import 'package:validasi/validasi.dart';

final schema = Validasi.string().minLength(3);

TextFormField(
    validator: (value) => FieldValidator(schema).validate(value),
);
```

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
    validator: (value) => schema.validate('name', value),
);

TextFormField(
    validator: (value) => schema.validate('email', value),
);
```