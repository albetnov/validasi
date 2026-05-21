# validasi_gen

Code generator for [Validasi](https://github.com/albetnov/validasi). Generates zero-cost validation code from `@ValidateClass()` and `@Validate` annotations.

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';
import 'package:validasi_annotation/annotation.dart';

part 'user.g.dart';

@ValidateClass()
class User {
  @Validate.string([MinLength(3), MaxLength(100)])
  final String email;

  User({required this.email});
}
```

## Usage

Add to `pubspec.yaml`:

```yaml
dependencies:
  validasi: ^1.0.0
  validasi_annotation: ^0.1.0

dev_dependencies:
  validasi_gen: ^0.1.0
  build_runner: ^2.4.0
```

Run the generator:

```sh
dart run build_runner build
```
