# Validasi

![image](https://github.com/albetnov/validasi/blob/main/img/validasi.png?raw=true)

A flexible and straightforward Dart Validation Library.

[Documentation](https://albetnov.github.io/validasi/)
[API Documentation](https://pub.dev/documentation/validasi/latest)

## Installation

Add `validasi` to your pubspec dependencies or use `pub get`.

## Quick Usage

To use the library, simply import the package and use `Validasi` class to access to available
validator.

```dart
import 'package:validasi/validasi.dart';

void main(List<String> args) {
  var schema = Validasi.string().maxLength(255);

  var result = schema.parse(args.firstOrNull);

  print("Hello! ${result.value}");
}
```

## Supported Validations

- String
- Numeric
- Date
- List
- Map

## Features

- Handling Type Conversion using Transformer

Validasi takes `dynamic` input and allows you to put any type of data. It will automatically convert the data into the desired type using `Transformer`.

- Safe Validation

Validasi provide `tryParse` or `tryParseAsync` method to validate the input data. It will return `Result` object that contains the validation result without
throwing any exception related to rule failing.

- Custom Rule

You can create your own custom rule to be used in the Validator by simply using `custom` and `customFor` method.

- Helpers

Validasi also provide some helper classes to help you organize and capture the validation result to be passed on Flutter's FormField.

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

The `docs/` directory contains the documentation for the library, You would need [Deno 2.0](https://deno.com/). You can run the documentation locally by using below command:

```bash
deno i
deno run docs:dev
```

Alternatively, you could use your package manager to just execute `vitepress` command:

```bash
npx vitepress dev docs
bunx vitepress dev docs
pnpm dlx vitepress dev docs
```