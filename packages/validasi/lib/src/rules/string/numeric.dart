import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class Numeric extends Rule<String> {
  const Numeric({super.message});

  static final _pattern = RegExp(r'^[0-9]+$');

  @override
  String? apply(String? value, ValidationState state) {
    if (value != null && !_pattern.hasMatch(value)) {
      state.addError(
        ValidationError(
          rule: 'Numeric',
          message: message ?? 'Must contain only digits',
        ),
      );
    }
    return value;
  }
}
