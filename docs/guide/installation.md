# Installation

Get Validasi up and running in your Dart or Flutter project.

## Add Dependency

```bash
# Dart projects
dart pub add validasi

# Flutter projects
flutter pub add validasi
```

> Check the [pub.dev page](https://pub.dev/packages/validasi/versions) for the latest pre-release version.

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
