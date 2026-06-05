import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class Lowercase extends Rule<String> {
  const Lowercase({super.message});

  @override
  String? apply(String? value, ValidationState state) {
    if (value != null && value != value.toLowerCase()) {
      state.addError(
        ValidationError(
          rule: 'Lowercase',
          message: message ?? 'Must be lowercase',
        ),
      );
    }
    return value;
  }
}

class Uppercase extends Rule<String> {
  const Uppercase({super.message});

  @override
  String? apply(String? value, ValidationState state) {
    if (value != null && value != value.toUpperCase()) {
      state.addError(
        ValidationError(
          rule: 'Uppercase',
          message: message ?? 'Must be uppercase',
        ),
      );
    }
    return value;
  }
}
