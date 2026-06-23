# Installation

Get Validasi up and running in your Dart or Flutter project.

## Add Dependency

Add `validasi` as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  validasi: ^1.0.0-rc.1
```

> Check the [pub.dev page](https://pub.dev/packages/validasi/versions) for the latest pre-release version.

Or use the command line:

```bash
# For Dart projects
dart pub add validasi

# For Flutter projects
flutter pub add validasi
```

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
