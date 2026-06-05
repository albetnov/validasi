import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class Alphanumeric extends Rule<String> {
  const Alphanumeric({super.message});

  static final _pattern = RegExp(r'^[a-zA-Z0-9]+$');

  @override
  String? apply(String? value, ValidationState state) {
    if (value != null && !_pattern.hasMatch(value)) {
      state.addError(
        ValidationError(
          rule: 'Alphanumeric',
          message: message ?? 'Must contain only letters and digits',
        ),
      );
    }
    return value;
  }
}
