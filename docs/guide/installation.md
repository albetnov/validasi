# Installation

Get Validasi up and running in your Dart or Flutter project in just a few steps.

## Requirements

- Dart SDK: `>=3.0.0 <4.0.0`
- Flutter: Any version supporting Dart 3.0+

## Add Dependency

### Using Command Line

For Dart projects:

```bash
dart pub add validasi
```

For Flutter projects:

```bash
flutter pub add validasi
```

### Manual Installation

Add Validasi to your `pubspec.yaml`:

```yaml
dependencies:
  validasi: ^1.0.0-dev.0
```

Then run:

```bash
dart pub get  # For Dart projects
# or
flutter pub get  # For Flutter projects
```

## Import the Library

In your Dart files, import Validasi:

```dart
// Core validation engine
import 'package:validasi/validasi.dart';

// Built-in validation rules
import 'package:validasi/rules.dart';

// Optional: Transformations
import 'package:validasi/transformer.dart';
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

If you see the expected output, you're all set! 🎉

## IDE Setup

### VS Code

Install the Dart extension for better IntelliSense and code completion:

```
ext install Dart-Code.dart-code
```

### IntelliJ IDEA / Android Studio

The Dart and Flutter plugins come pre-installed with IntelliJ IDEA and Android Studio for Flutter development.

## Troubleshooting

### Version Conflicts

If you encounter version conflicts, try:

```bash
dart pub upgrade validasi
# or
flutter pub upgrade validasi
```

### Import Errors

Make sure you've run `pub get` after adding the dependency:

```bash
dart pub get
# or
flutter pub get
```

### Need Help?

- Check the [GitHub Issues](https://github.com/albetnov/validasi/issues)
- Review the [API Documentation](https://pub.dev/documentation/validasi/latest)
