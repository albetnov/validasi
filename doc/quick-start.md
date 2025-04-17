# Quick Start

This is a quick start guide to get you up and running with Validasi.

## Installation

Simply run this command:

```bash
pub add validasi
```

## Usage

Here's a simple example to get you started:

::: code-group

```dart [flutter_example.dart]
import 'package:validasi/validasi.dart';

class MyForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // In flutter, validation are done with helpers like `FieldValidator`
    // and `GroupValidator`. Both of these helpers return a `String?` value
    // which is the expected type for `validator` parameter

    // GroupValidator to specify validator for each field and use `on` method 
    // to get the validator for each field
    final validator = GroupValidator({
      'name': Validasi.string()
        .minLength(1, message: 'name is required')
        .maxLength(255),
      'email': Validasi.string()
        .minLength(1, message: 'email is required')
        .maxLength(255)
        .email(),
    });

    return Form(
      child: Column(
        children: [
          TextFormField(
            validator: validator.using('name').validate,
            autoValidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              labelText: 'Name',
            ),
          ),
          SizedBox(height: 10),
          TextFormField(
            validator: validator.using('email').validate,
            autoValidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              labelText: 'Email',
            ),
          ),
          SizedBox(height: 10),
          TextFormField(
            // inline validation
            validator: FieldValidator(Validasi.string().minLength(1, message: 'Inline example')).validate,
            autoValidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              labelText: 'Inline Example',
            ),
          )
        ],
      ),
    );
  }
}
```

```dart [dart_example.dart]
import 'package:validasi/validasi.dart';

void main() {
  // Create object validation, it different from GroupValidator
  // because it will validate the map and return the result
  final validator = Validasi.object({
    'name': Validasi.string().minLength(1, message: 'name is required').maxLength(255),
    'email': Validasi.string().minLength(1, message: 'email is required').maxLength(255).email(),
  });

  // tryParse is used to validate the input value
  // and return the result
  final result = validator.tryParse({
    'name': 'John Doe',
    'email': 'johndoe@example.com',
  });

  // without using FieldValidator/GroupValidator, the result will be more 
  // verbose.
  if (result.isValid) {
    print('Validation success');
  } else {
    print('Validation failed');
    print(result.errors); // List<FieldError>
  }
}
```

:::

See [Basic Concept](/guide/basic-concept) for more information about Validasi specific usage. And see [API Reference](https://pub.dev/documentation/validasi/latest) for more details on the available methods and options.