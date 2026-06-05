import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class Ulid extends Rule<String> {
  const Ulid({super.message});

  static final _pattern = RegExp(
    r'^[0-7][0-9a-hjkmnp-z]{25}$',
    caseSensitive: false,
  );

  @override
  String? apply(String? value, ValidationState state) {
    if (value != null && !_pattern.hasMatch(value)) {
      state.addError(
        ValidationError(
          rule: 'Ulid',
          message: message ?? 'Must be a valid ULID',
        ),
      );
    }
    return value;
  }
}
