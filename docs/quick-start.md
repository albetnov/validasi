# Quick Start

This is a quick start guide to get you up and running with Validasi.

## Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  validasi: ^0.0.1
```

or use pub command:

```bash
pub get validasi
```

## Usage

Here's a simple example to get you started:

```dart
import 'package:validasi/validasi.dart';

void main() {
  final validator = Validasi.object({
    'name': Validasi.string().minLength(1, message: 'name is required').maxLength(255),
    'email': Validasi.string().minLength(1, message: 'email is required').maxLength(255).email(),
  });

  final result = validator.tryParse({
    'name': 'John Doe',
    'email': 'johndoe@example.com',
  });

  if (result.isValid) {
    print('Validation success');
  } else {
    print('Validation failed');
    print(result.errors);
  }
}
```

This example creates a validator that validates an object with two fields: `name` and `email`. The `name` field is required and must be between 1 and 255 characters long. The `email` field is also required and must be a valid email address.

The `tryParse` method is used to validate the object. If the object is valid, the `isValid` property will be `true`. Otherwise, the `isValid` property will be `false`, and the `errors` property will contain a list of validation errors.

That's it! You're now ready to start using Validasi in your Dart projects. For more information, check out the [API Documentation](/api-examples).