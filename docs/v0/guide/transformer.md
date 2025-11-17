# Transformer

Transformer is a way to convert the input value to another type. This is useful when you want to convert the input value to another type before the validation process.

You can also use the transformer to handle the error when the conversion failed

## Using Transformer

You can use the `transformer` parameter to provide a transformer to the supported schema.

```dart
import 'package:validasi/validasi.dart';

void main() {
    final schema = Validasi.number(transformer: NumberTransformer());

    final result = schema.tryParse('10');

    print(result.value); // 10
}
```

When the conversion failed, the transformer will return an error message (`invalidType`).

## Built-in Transformers

Validasi provides a few built-in transformer:

- [`NumberTransformer`](#numbertransformer)
- [`StringTransformer`](#stringtransformer)
- [`DateTransformer`](#datetransformer)

### NumberTransformer

The `NumberTransformer` is used to convert the input value to a number. This transformer will convert the input value to a number using the `num.parse` method.

```dart
import 'package:validasi/validasi.dart';

final schema = Validasi.number(transformer: NumberTransformer()); // [!code focus:2]
print(schema.tryParse('10').value); // 10
```

### StringTransformer

The `StringTransformer` is used to convert the input value to a string. This transformer will convert the input value to a string using the `toString` method.

```dart
import 'package:validasi/validasi.dart';

final schema = Validasi.string(transformer: StringTransformer()); // [!code focus:2]
print(schema.tryParse(10).value); // '10'
```

### DateTransformer

The `DateTransformer` is used to convert the input value to a date. This transformer will convert the input value to a date using the `DateFormat.tryParse` method.

```dart
import 'package:validasi/validasi.dart';

final schema = Validasi.date(transformer: DateTransformer()); // [!code focus:2]
print(schema.tryParse('2021-01-01').value); // DateTime(2021-01-01 00:00:00.000)
```

## Building your own Transformer

You can also build your own transformer by extending the `Transformer` class.

```dart
import 'package:validasi/validasi.dart';

class MyTransformer extends Transformer<String> {
    @override
    String? transform(value, fail) {
        return convert(value);
    }
}
```

The `transform` method will receive the input value and the `fail` function. You can use the `fail` function to handle the error when the conversion failed.

The `fail` function accept a message as the parameter. You can use this message as the error message when the conversion failed. When the conversion fail, the transformer will return an error message (`invalidType`).

The transformer could also return `null`. It could fails depend whatever `nullable` is set or not. If not, then the
required rule will run and return the error message (`required`). See [Execution Flow](/guide/execution-order) for more information.