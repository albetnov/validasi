# Basic Concept

Before reading this, make sure you have read the [Execution Flow](/guide/execution-order) to understand how the validation works in Validasi.

## Required by default
Validasi takes inspiration from [Zod](https://zod.dev). Where by default, all fields are required.
If you want to make a field to optional you need to use `nullable` method.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.string().nullable();

    final result = schema.tryParse(null);

    print(result.isValid); // true
}
```

By adding `nullable` method, the field is now optional and every rule after `nullable` will be ignored if the field is `null`. Except for Custom Rule.

## Validate Anything

Validasi can validate anything, from simple string, number, object, array, and even nested object.
Each of these validation are checked on the Runtime by the library. This means you can validate
anything and Validasi will handle the type mismatch for you.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.string();

    final result = schema.tryParse(10);

    print(result.errors.first.message); // 'Expected type String. Got int instead.'
}
```

This also means that the Dart Type System will be ignored when performing validation. It will be handled by 
Validasi instead.

## The Transformer

Since Validasi is a runtime validation library, it can also transform the input value to the desired type.
This is useful when your input is a numerical string and you want to convert it to an integer, where
you can use the number validators later on.

You can use the `transformer` parameter to provide a transformer to the suppported schema.

> See [Transformer](/guide/transformer) for more information.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.number(transformer: NumberTransformer());

    final result = schema.tryParse('10');

    print(result.value); // 10
}
```

## Custom Rule

You can also create a custom rule by using `custom` method. This method will receive a function that
will be called when the validation is performed.

> See [Custom Rule](/guide/custom-rule) for more information.

```dart
import 'package:validasi/validasi.dart';
import 'package:app/data.dart';

void main() {
    final schema = Validasi.string().custom((value, fail) {
        if (Data.user().contains(value)) {
            return true;
        }

        return fail('Ups, user not found');
    });

    final result = schema.tryParse('world');
}
```

## Throw on Error

In order to throw an error when the validation failed, you can use `parse` variants method.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.string();

    try {
        final result = schema.parse(10); // or parseAsync
    } catch (e) {
        print(e); // 'Expected type String. Got int instead.'
    }
}
```

## Replacing default path

By default, the error path is `field`. You can replace the default assign path to the parse method.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.string().minLength(3).maxLength(3);
    final result = schema.tryParse('', path: 'id'); // or parse(10, path: 'id').
    final firstErr = result.errors.first;

    print(firstErr.path); // 'id'
    print(firstErr.message); // 'id must contains at least 3 characters.'
}
```

The same applies to async variants (e.g `tryParseAsync`, `parseAsync`).

## Replacing default message

You can also replace the default message by using the `message` parameter.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.string().minLength(3, message: 'The :name is too short');
    final result = schema.tryParse('', path: 'id');

    print(result.errors.first.message); // 'The id is too short'
}
```

::: info
Notice `:name` this are special template keyword in which will be replaced
by the path name.
:::

## Error Handling

In Validasi, only `FieldError` will be intercept and handled by Validasi. Any other error will be thrown
as is even though you run it in `tryParse` or `tryParseAsync`.

The design is to make sure that you wary about other error beyond validation is occured and not handled by Validasi.