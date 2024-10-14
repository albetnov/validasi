# Custom Rule

Validasi provides a way to create a custom rule by using the `custom` and `customFor` method. The custom rule
will then be called when the built-in rules already performed. For details, see [Execution Flow](/guide/execution-order).

## `custom` Method

The `custom` method will receive a function that will be called when the validation is performed.

```dart
import 'package:validasi/validasi.dart';

Validasi.string().custom((value, fail) {});
```

## `customFor` Method

The `customFor` method will receive a class instance that implements the `CustomRule` interface. This method is useful
when you want to create a custom rule that can be reused in multiple schemas.

::: code-group

```dart [main.dart]
import 'package:validasi/validasi.dart';
import 'package:app/rules/my_rule.dart';

Validasi.string().customFor(MyRule()); // [!code focus]
```

```dart [my_rule.dart]
import 'dart:async';
import 'package:validasi/validasi.dart';

class MyRule extends CustomRule<String> { // [!code focus:6]
    @override
    FutureOr<bool> handle(value, fail) {
        return true;
    }
}
```

:::

## Asyncronous Custom Rule

You can also run an async function inside the custom rule.

```dart
import 'package:validasi/validasi.dart';
import 'package:app/data.dart';

void main() {
    final schema = Validasi.string().custom((value, fail) async {
        if (await Data.user().contains(value)) {
            return true;
        }

        return fail('Ups, not hello');
    });

    final result = schema.tryParseAsync('world');
}
```

Keep in mind when running async rule, you need to use the async variants instead (e.g. `tryParseAsync`, `parseAsync`).

## The Method Signature

Both the `custom` and `handle` method share similar signature. The `value` parameter is the value that will be validated
by your custom rule. The `fail` parameter is a function that you can call when the validation failed.

Both methods expects `FutureOr<bool>` as the return type. You can return `true` to indicate that the validation passed
or `false` to indicate that the validation failed. You can also return a `Future<bool>` if you want to run an async since
`FutureOr` is a union type of `Future` and `T`.

The `fail` parameter is a function that will receive a message that will be used as the error message. The `fail` function
will return `false` to indicate that the validation failed. Alternatively, you can just return `false` this will
fallback to default error message: `field is not valid`.

::: info
When running async rule in a non-async parse variants (e.g. `tryParse`, `parse`), Validasi will throw an exception.
:::

