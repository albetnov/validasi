# Validasi

A flexible and easy to use Dart Validation Library.

> Type Inference Limitation:
The Validasi Library will try to infer types based on Dart Generic System capabilities. Some types are not supported for infer
are `array` and `object` for now. The `number` also returning `num` which can represents both `double` and `int`.

> The library is still on-going active development.

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

## Features

### Validating without throwing exception

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

### Validating an object

Validasi also support Object/Map Validation simply by using `Validasi.object`. The method expect `schema` which is
`Map<String, Validator>`. The Object Validator also support nesting.

> Object Validation can actually be more strictier and can perform runtime checks by overriding the Generic 
interface from the `ObjectValidator` itself. However, keep in mind that the check will be done on Dart side
so you should handle it as how you handle TypeError in general. Both Try Catch from `FieldError` and `try` 
variants methods won't capture this type of error for you.

```dart
import 'package:validasi/validasi.dart';

void main() {
  var schema = Validasi.object({
    'name': Validasi.string().required().maxLength(255),
    'address': Validasi.object({
        'streetName': Validasi.string().required().maxLength(255),
        'cityName': Validasi.string().required().maxLength(255)
    }).required()
  });

  var result = schema.parse({
    'name': 'Asep Surasep',
    'address': {
        'streetName': 'Jl. Tidak tahu',
        'cityName': 'Unknown City'
    }
  });

  print("Hi, ${result.value.name}! I also happen to live in ${result.value.address.cityName}");
}
```

### Validating an array

Validasi support array validation for it's child. The Array Validator also support nesting.

> Similar to `ObjectValidator` The `ArrayValidator` also support strictier checks by overriding the Generic 
Interface. However, keep in mind that the check will be done on Dart side so you should
handle it as how you handle TypeError in general. Both Try Catch from `FieldError` and `try` variants methods
won't capture this type of error for you.

```dart
import 'package:validasi/validasi.dart';

void main() {
    var schema = Validasi.array(Validasi.string().required());

    schema.parse([1,2,3], path: 'names'); // Exception, FieldError: 'names.0 must be a string'
}
```

### Allow non-strict validation

By default, some validators on Validasi accept `dynamic` in the `parse` and it's variants 
(`tryParse`, `parseAsync`, `tryParseAsync`) method. This is intentional as these type with `dynamic`
signature means they support type conversion.

Currently, Validasi supports:

- DateTime (from String conversion)
- Number (from `num.tryParse` conversion)
- String (from `toString` method calls)

```dart
import 'package:validasi/validasi.dart';

void main() {
    var schema = Validasi.number(strict: false).required();

    var result = schema.parse(20);

    print(result.value); // 20
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

You can also replace the default message for each rules. For some validators that perform Type Check in runtime
like `Date`, `Number`, `String` (thus with non-strict support) the default message can also be overriden.

You can also access the `path` above by specifiying custom template `:name`.

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

### Field Helpers

The `FieldValidator` is a Helper for Validasi to run and extract first error message as a `String` or `null`. This is useful
if you want to pass in for Flutter's `FormField`.

```dart
TextFormField(
    // (...)
    validator: (value) => FieldValidator(Validasi.string().required().minLength(3)).validate(value)
);
```

The `FieldValidator` also support `validateAsync` in which you can use to run custom validators that require asyncronous context.

### Group Helpers

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