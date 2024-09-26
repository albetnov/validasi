# Validasi

A flexible and easy to use Dart Validation Library.

> Type Inference Limitation:
The Validasi Library will try to infer types based on Dart Generic System capabilities. Some types are not supported for infer
are `array` and `object` for now. The `number` also returning `num` which can represents both `double` and `int`.

## Installation

Add `validasi` to your pubspec dependencies or use `pub get`.

## Quick Usage

To use the library, simply import the package and use `Validasi` class to access to available
validator.


```dart
import 'package:validasi/validasi.dart';

void main(List<String> args) {
  var schema = Validasi.string().required().maxLength(255);

  var result = schema.parse(args.firstOrNull);

  print("Hello! ${result.value}");
}
```

## Supported Validations

- [String](#string)
- [Numeric](#numbernumdouble-int)
- [Date](#date)
- [Array / List](#arraylist)
- [Map](#objectmap)

### String
```dart
Validasi.string();
```
- required()

    check if the input is not empty (`''`) and not null
- minLength(int length)
    
    check if the input length above given `length`
- maxLength(int length)

    check if the input length below given `length`

- email({bool allowTopLevelDomain, bool allowInternational})

    check if the input is a valid email address based on international schema if `allowInternational: true` 
    and allowing top level domain if `allowTopLevelDomain: true`.

- startsWith(String text)

    check if the input starts with the given `text`.

- endsWith(String text)

    check if the input ends with the given `text`.

- contains(String text)

    check if the input contains `text`.

- url()

    check if the input is a valid URL scheme.

- regex(String pattern)

    check if the input match with regex `pattern`.
### Number/num(double, int)
```dart
Validasi.number();
```
- required()

    check if the input is not null

### Date
```dart
Validasi.date();
```
- required()

    check if the input is not null
- before(DateTime target, {DateUnit unit, int difference})

    check if the input is before `target` based on `unit` and `difference`
- beforeSame(DateTime target, {DateUnit unit})

    check if the input is before or the same to `target` based on `unit`. This is similar to `difference: 0` of the `before` method.
- after(DateTime target, {DateUnit unit, int difference})

    check if the input is after `target` based on `unit` and
    `difference`
- afterSame(DateTime target, {DateUnit unit})

    check if the input is after or the same to `target` based on `unit`. This is similar to `difference: 0` of the `after` method.

### Array/List
```dart
Validasi.array(Validator);
```
- required()

    check if the input is not null

### Object/Map
```dart
Validasi.object(Map<String, Validator> schema);
```

- required()

    check if the input is not null
    
> More rules are planned to be added!

## Features

- [Transformer](#transformer)
- [Safe Validation](#safe-validation)
- [Replacing Default Path](#replacing-default-pathfield)
- [Replacing Default Message](#replacing-default-message)
- [Custom Rule](#custom-rule)
- [Helpers](#helpers)

### Transformer

By concept, Validasi takes `dynamic` as the input. Allowing you, as the developer or the user to immediately put any
value there. Each of the type checking mechanism are done via Runtime. For the input that mismatch the expected type
Validasi will return `invalidType` error.

In case you want to perform losess type validation like using Number Validation but from String input, you may use Transformer. Transformer allow you to convert and handle type conversion further. The Transformer will only execute
when the given input is already mismatch with the validation type.

```dart
var schema = Validasi.number(transformer: NumberTransformer())

schema.parse('10');
```

The `NumberTransformer` will only be executed when the received input is differs with the validation type (`num` in this case). Since the input on above is string `'10'` it satisfy the constraint and therefore the transformer will be called. Thus, allowing type conversion to occur and is handled by `NumberTransformer`.

The `NumberTransformer` itself is a subclass of `Transformer` and under the hood contains code below:

```dart
class NumberTransformer extends Transformer<num> {
  @override
  num? transform(value, fail) => num.tryParse(value.toString());
}
```

You can create your own Transformer by extending the `Transformer` class and override `transform` method. The `transform`
method receive raw `value` and `fail` function. If for some reason you can't transform the `value` then use `fail` to 
throw `invalidType` exception again.

### Safe Validation

In order to validate without throwing Exception, make sure to use the `try` variants of `parse`.
Different to `parse`, `tryParse` will keep running even if previous rule fails. The errors will then
combined under `result.errors` from the `Result` instance.

```dart
import 'package:validasi/validasi.dart';

void main() {
  var schema = Validasi.string().required().maxLength(255);

  // use `tryParse` for validating without throwing exception.
  var result = schema.tryParse(args.firstOrNull);

  if(!result.isValid) {
    // show all errors on string.
    print(result.errors.map((err) => err.message).join(','));
    return;
  }

  print("Hello! ${result.value}");
}
```

### Replacing default path/field.

Validation erorr message usually contains `field`. For example, `required` rule have failed error below:

`field is required`

You can also customize field according to your form field, or your needs.

```dart
import 'package:validasi/validasi.dart';

void main() {
    var schema = Validasi.string().required();

    schema.parse(null, path: 'github_link'); // FieldErorr: 'github_link is required'
}
```

### Replacing default message

You can also replace the default message for each rules. The message string support template literals `:name` to later on
be mapped on based on `path`.

```dart
import 'package:validasi/validasi.dart';

void main() {
    var schema = Validasi.number(message: ':name should be numerical!').required()

    schema.parse('10', path: 'age'); // FieldError: 'age should be numerical!'
}
```

### Custom Rule

Validasi also support Custom Rule for your additional needs. Simply specifying `custom` for a callback or
`customFor` for class-based custom validation.

#### Custom Callback

The Custom Callback receive a function with two arguments, the `value` (converted if on non-strict) and
`fail` function.

The function should also return `bool` indicating success or failing. The `value` will be nullable and depends
on the Validation being used the type might be inferred, for below case is `num`. You might get 
`Map<dynamic, dynamic>` on Object and so-on.

In order to indicate the custom rule failing, you can either use `fail` or directly `return false`. By returning
false the default message `field is invalid` will be used. The `fail` function however accepts `String message`
in which you can use to assign message according to your failing scenario.

Similar to customizing message, `fail` also support custom template `:name`.

```dart
import 'package:validasi/validasi.dart';

void main() {
    var schema = Validasi.number().required().custom((value, fail) {
        if(value == null) return false; 

        if(getFromDb(value) == null) {
            return fail('Ups :name not exist!');
        }

        if(isMember(value)) {
            return fail('Whoops :name is not a VIP!');
        }

        return true;
    });

    schema.parse(24);
}
```

#### Custom Rule Class

If you need to extract your rule to it's own class or your rules is complex enough you can use class-based
Custom Rule. Your class simply need to extend from `CustomRule<T>`.

The Generic of CustomRule should be filled with your target validator's type. For example, if you target for
`StringValidator` then you have to extend from `CustomRule<String>` as for types with generic like `List` and
`Map` simply put `CustomRule<List>` or `CustomRule<List<dynamic>>`, same thing applied for `Map`.

> I did want to actually put `CustomRule<StringValidator>` or something like that, but I don't think the Dart
Generic System have such capabilities to extract signature and such yet.

Your class should then override `handle` method which have the same signature as the [Custom Callback](#custom-callback).

```dart
import 'package:validasi/validasi.dart';

class EnsureDomainRegistered extends CustomRule<String> {
    List<String>? getDomainsFromValue(String value) {
        // (...)
    }

    Domain getDomain(String domain) {
        // (...)
    }

    @override
    FutureOr<bool> handle(String? value, FailFn fail) {
        if(value == null) return false;

        var domains = getDomainsFromValue(value);                 

        if(domains == null) return fail(':name is not a valid format'); 

        var domain = getDomain(domains.first);        

        if(!domain.active) return fail(':name is not active');

        return true;
    };
}

void main() {
    var schema = Validasi.string().required()
                    .customFor(EnsureDomainRegistered());
    
    schema.parse('example@mail.com');
}
```

#### Asyncronous Custom Rule

Both `custom`'s callback and `customFor`'s `handle` have `FutureOr` signature. Meaning you can freely pass `async` to the function.

```dart
Validasi.string().custom((value, fail) async {
    // perform async operations
});

class Custom extends CustomRule<String> {
    @override
    FutureOr<bool> handle(String? value, FailFn fail) async {
        // perform async operations
    } 
}
```

In order to execute and run the rule properly you should use the `async` variants so the asyncronous validation can be
properly handled using `Future` as well.

```dart
schema.parseAsync() // use the async variant
schema.tryParseAsync() // use the async variant
```

Both the async variants will return `Future<Result>`.

> If you try to use non-async variant with an Async Custom, the `parse` or `tryParse` method will throw `ValidasiException`
to warn you to use the `async` variant.

### Helpers

To make work with Validasi easier, two helpers class are exposed. These classes are best to work with when you are validating
Flutter FormField widget.

#### Field Helpers

The `FieldValidator` is a Helper for Validasi to run and extract first error message as a `String` or `null`. This is useful
if you want to pass in for Flutter's `FormField`.

```dart
TextFormField(
    // (...)
    validator: (value) => FieldValidator(Validasi.string().required().minLength(3)).validate(value)
);
```

The `FieldValidator` also support `validateAsync` in which you can use to run custom validators that require asyncronous context.

#### Group Helpers

The `GroupValidator` at a glance might be similar to `ObjectValidator`. But the purpose is difference, the GroupValidator used to
grouping your validation under `Map<String, Validator>` schema. It did not support nested.

The Group Validator allow you to group your fields validations on forms. The GroupValidator are just the FieldValidator under the hood.
But Grouped. Hence, their signature are actually similar.

```dart
var group = GroupValidator({
    'name': Validasi.string().required().maxLength(255),
    'age': Validasi.number().required(),
    'address': Validasi.object({
        'cityName': Validasi.string().required(),
        'streetName': Validasi.string().required()
    })
});

group.validate('name', 'Asep Surasep'); // Under the hood: FieldValidator(schema['name']).validate(...)
```

It will throw `ValidasiException` if the key not found.

### License

The Validasi Library is licensed under [MIT License](./LICENSE).

### Contribution

You can use below script to spin up development environment for this library base:

```bash
# Clone the repo
git clone https://github.com/albetnov/validasi
# Install the dependencies
dart pub get
```

The Tests in `test/` directory are mapped 1:1 to `lib` and `src` folder. So their structure are similar.