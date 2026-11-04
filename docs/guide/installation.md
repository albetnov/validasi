# Installation

Get Validasi up and running in your Dart or Flutter project.

## Add Dependency

```bash
# Dart projects (v1 is currently published as a pre-release)
dart pub add validasi:^1.0.0-rc.6

# Flutter projects
flutter pub add validasi:^1.0.0-rc.6
```

> v1 is published as a pre-release for now, so the explicit constraint selects it. Once
> `1.0.0` is the default version, `dart pub add validasi` resolves to v1 without a constraint.
> Check the [pub.dev versions page](https://pub.dev/packages/validasi/versions) for the latest.

## Import the Library

In your Dart files, import Validasi:

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';
```

## Verify Installation

Create a simple test to verify everything works:

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

void main() {
  final schema = Validasi.string([
    Rules.string.minLength(3),
  ]);

  final result = schema.validate('Hello');
  
  print('Valid: ${result.isValid}'); // Output: Valid: true
  print('Data: ${result.data}');     // Output: Data: Hello
}
```

If you see the expected output, you're all set!

## Need Help?

- Check the [GitHub Issues](https://github.com/albetnov/validasi/issues)
- Review the [API Documentation](https://pub.dev/documentation/validasi/latest)
