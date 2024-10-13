# New Validation

You can create a new validation by extending the `Validator` class. The `Validator` class is an abstract class that contains a method to validate the input value.

The following code shows how to create a new validation:

```dart
import 'package:validasi/validasi.dart';

class MyValidator extends Validator<String> {
  @override
  StringValidator nullable() => super.nullable();

  @override
  StringValidator custom(CustomCallback<String> callback) =>
      super.custom(callback);

  @override
  StringValidator customFor(CustomRule<String> customRule) =>
      super.customFor(customRule);
}
```

That's it! That's all you need to create a new validation. You can now use the `MyValidator` class to validate the input value.

## Adding Rule

You can add a new rule by adding a new method to your class. Following the convention of Validasi, the method name should match the rule name, and the method should return the same type as the class.

The following code shows how to add a new rule to the `MyValidator` class:

```dart
import 'package:validasi/validasi.dart';

class MyValidator extends Validator<String> {
    MyValidator myRule() {
        addRule(
            name: 'myRule',
            test: (value) => value == 'myValue',
            message: ':name must be myValue',
        );

        return this;
    }
}
```

The rule will be registered using the `addRule` method. The `addRule` method requires three parameters:

- `name`: The name of the rule.
- `test`: The test function to validate the input value.
- `message`: The error message to return if the test function fails.

Similarly to [customizing default error message](guide/basic-concept.html#replacing-default-message) you can also use `:name` here!

## Adding Transformer Support

In order to add [Transformer](/guide/transformer) support to your custom validator, you can inherit the `transformer` property from the `Validator` class.

```dart
import 'package:validasi/validasi.dart';

class MyValidator extends Validator<String> {
    MyValidator({super.transformer});
}
```

That's it!

## Using your Custom Validator

In order to use your Custom Validator just call the class like how you did it with normal Dart.

```dart
MyValidator myValidator = MyValidator();

myValidator.myRule().parse('myValue');
```

Your Custom Validator can also be passed to sub-type of `Validator` like [`ArrayValidator`](/types/array) and [`ObjectValidator`](/types/object).

```dart
Validasi.array(MyValidator());

Validasi.object({
    'name': MyValidator(),
});
```

## Adding to Validasi

Now if you want to add your custom validator to Validasi, you have to extends the `Validasi` class and add a new method to return your custom validator.

::: code-group
```dart [utils/validation.dart]
import 'package:validasi/validasi.dart';

class MyValidasi extends Validasi {
    MyValidator myValidator() => MyValidator();
}
```

```dart [main.dart]
import 'package:app/utils/validation.dart';

void main() {
    MyValidator.myValidator().myRule().parse('myValue');
}
```
::: code-group

As of currently, Dart doesn't support static method extensions, see [this issue](https://github.com/dart-lang/language/issues/723) for more information.