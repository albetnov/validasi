import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class Alpha extends Rule<String> {
  const Alpha({super.message});

  static final _pattern = RegExp(r'^[a-zA-Z]+$');

  @override
  String? apply(String? value, ValidationState state) {
    if (value != null && !_pattern.hasMatch(value)) {
      state.addError(
        ValidationError(
          rule: 'Alpha',
          message: message ?? 'Must contain only letters',
        ),
      );
    }
    return value;
  }
}
